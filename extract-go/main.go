// extract-go is a small and very dirty script for extracting data from
// the Rebelstar Raiders video game TZX tape files: BASIC programs, game
// level data, screens (PNG), the ZAPCODE disassembly, etc.
//
// Dependencies:
//   - tzxcat (https://github.com/shred/tzxtools)
//   - Rebelstar Raiders ZX Spectrum TZX tape files, side 1 & side 2
//
// Usage:
//
//	$ go run extract-go/main.go
//
// Copyright 2023 Michael R. Cook
// License: MIT
package main

import (
	"bytes"
	"fmt"
	"math/big"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

var (
	// if the command can not be found, you may need to specify the full path here
	tzxcatCommand = "tzxcat"

	// working directories -- you shouldn't need to change these
	rootDirectory = "../"
	screensDir    = "assets" // relative to root
	sourceDir     = ""       // relative to root
	// location of TZX files, relative to root
	tapes = map[int]string{
		1: "tzx/rebelstar-raiders-side1.tzx",
		2: "tzx/rebelstar-raiders-side2.tzx",
	}
)

func main() {
	// Automatically get the root directory.
	// If this script is in extract-go directory, go up one level.
	if dir, err := os.Getwd(); err != nil {
		panic(err)
	} else {
		rootDirectory = strings.TrimSuffix(dir, "/extract-go")
	}

	// create the directories if they don't exist
	_ = os.Mkdir(filepath.Join(rootDirectory, screensDir), 0755)
	_ = os.Mkdir(filepath.Join(rootDirectory, sourceDir), 0755)

	// extract all the data!
	extractBASIC()
	extractScreens()
	extractRaiders()
	extractZapCode()
	extractScenarioData()
}

// Extracts the BASIC program: "MAIN-COMP"
func extractBASIC() {
	var cat tzxcat
	var contents strings.Builder

	contents.WriteString("REM : REBELSTAR Program\n")
	contents.WriteString("REM : Load RAIDERS machine code and display splash screen\n")
	contents.WriteString("REM : Load the MAIN-COMP BASIC program\n")
	cat = tzxcat{side: 1, block: 2, kind: BASIC}
	contents.Write(cat.execute())
	saveSource("rebelstar.bas", []byte(contents.String()))
	contents.Reset()

	contents.WriteString("REM : MAIN-COMP Program\n")
	cat = tzxcat{side: 1, block: 6, kind: BASIC}
	contents.Write(cat.execute())
	saveSource("main-comp.bas", []byte(contents.String()))
	contents.Reset()
}

// Extracts the assembly source code from the RAIDER machine code block.
func extractRaiders() {
	var contents strings.Builder
	contents.WriteString("; RAIDERS disassembly\n\n")
	cat := tzxcat{side: 1, block: 4, skip: 8000, limit: 24, base: 51000, kind: ASSEMBLER}
	asm := unmarshallASM(cat.execute())
	asm.addRaidersComments()
	for i := 0; i < len(asm.lines); i++ {
		line := &asm.lines[i]
		if line.newlinePrefix {
			contents.WriteString("\n")
		}
		if len(line.comment) > 0 {
			contents.WriteString(fmt.Sprintf("; %s\n", line.comment))
		}
		contents.WriteString(fmt.Sprintf("%04X  %s\n", line.address, line.code))
	}
	saveSource("raiders.asm", []byte(contents.String()))
}

// Extract all screens a PNG files.
func extractScreens() {
	var cat tzxcat
	cat = tzxcat{side: 1, block: 4, limit: 6912, kind: SCREEN, target: filepath.Join(rootDirectory, screensDir, "rebelstar-raiders.png")}
	cat.execute()
	cat = tzxcat{side: 1, block: 8, skip: 768, limit: 6912, kind: SCREEN, target: filepath.Join(rootDirectory, screensDir, "credits.png")}
	cat.execute()
	cat = tzxcat{side: 1, block: 29, kind: SCREEN, target: filepath.Join(rootDirectory, screensDir, "screen-1-moonbase.png")}
	cat.execute()
	cat = tzxcat{side: 2, block: 20, kind: SCREEN, target: filepath.Join(rootDirectory, screensDir, "screen-2-starlingale.png")}
	cat.execute()
	cat = tzxcat{side: 2, block: 41, kind: SCREEN, target: filepath.Join(rootDirectory, screensDir, "screen-3-final-assault.png")}
	cat.execute()
}

// Extract data from the ZAPCODE machine code block of "Side 1".
func extractZapCode() {
	var cat tzxcat

	var contents strings.Builder

	// custom character set
	cat = tzxcat{side: 1, block: 8, limit: 768, kind: DUMP}
	charSet := unmarshallDEFB(cat.execute())
	charSet.formatAndWriteSprite(false, "ZAPCODE custom character set", &contents)
	saveSource("character-set.asm", []byte(contents.String()))
	contents.Reset()

	// disassembly routines
	contents.WriteString("; ZAPCODE disassembly\n")
	contents.WriteString(";\n")
	contents.WriteString("; Some helper routines for updating the screen/attrs and a SFX generator.\n")
	cat = tzxcat{side: 1, block: 8, skip: 7680, limit: 320, base: 65041, kind: ASSEMBLER}
	asm := unmarshallASM(cat.execute())
	asm.addZapcodeComments()
	for i := 0; i < len(asm.lines); i++ {
		line := &asm.lines[i]
		if line.newlinePrefix {
			contents.WriteString("\n")
		}
		if len(line.comment) > 0 {
			contents.WriteString(fmt.Sprintf("; %s\n", line.comment))
		}
		contents.WriteString(fmt.Sprintf("%04X  %s\n", line.address, line.code))
	}
	contents.WriteString("\n")

	// SFX data
	contents.WriteString("; SFX data (address 65361)\n")
	cat = tzxcat{side: 1, block: 8, skip: 8000, base: 65361, kind: DUMP}
	sfx := unmarshallDEFB(cat.execute())
	for _, line := range sfx.format(10, true, false, false) {
		contents.WriteString(line)
	}
	contents.WriteString("\n")

	saveSource("zapcode.asm", []byte(contents.String()))
}

// Extract all level data from both sides of the tape
func extractScenarioData() {
	scenarioHeading := " - DIM(2,10). Indicates the order of operatives/raiders, which\n; corresponds to how level data is organised in CHARS block"
	movePointsHeading := " - DIM(20,32,8). Screen: 20 rows, 32 columns, 8 bytes per tile"
	weaponHeading := " - DIM(10,19). Available weapons for each operative/raider"
	deployHeading := " - DIM(20,32). Deployments areas for each player\n; Hex values correspond to the 3-bit PAPER(?) colour attributes"
	attrHeading := " - DIM(20,32). Colour attribute map of the original screen image (as loaded from tape)"
	charsHeading := " - DIM(160,28). Character data; %s followed by %s (max 80 per side); each side is deployed in order listed"
	occupyHeading := " - DIM(20,32). Preset positions for various operatives"
	victoryHeader := " - 5-bytes per number (Little Endian), plus 3-bytes"

	var cat tzxcat
	var data defb

	var contents strings.Builder
	{
		contents.WriteString("; Scenario #1: Moonbase\n")
		contents.WriteString(introTextMoonbase())
		cat = tzxcat{side: 1, block: 11, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(10, false, true, "BLK#11: MOONBASE"+scenarioHeading, &contents)
		cat = tzxcat{side: 1, block: 13, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(19, false, true, "BLK#13: 1-WEAPONS"+weaponHeading, &contents)
		cat = tzxcat{side: 1, block: 15, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSprite(true, "BLK#15: 1-UDGs", &contents)
		cat = tzxcat{side: 1, block: 17, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(32, false, false, "BLK#17: 1-DEPLOY"+deployHeading+" ($02=RED/raiders, $03=MAGENTA/operatives)", &contents)
		cat = tzxcat{side: 1, block: 19, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(32, false, false, "BLK#19: 1-ATTR"+attrHeading, &contents)
		cat = tzxcat{side: 1, block: 21, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(28, false, true, "BLK#21: 1-CHARS"+fmt.Sprintf(charsHeading, "Raiders", "Operatives"), &contents)
		cat = tzxcat{side: 1, block: 23, skip: headerLength + headerDim3d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(256, false, false, "BLK#23: 1-MOVE Pts"+movePointsHeading, &contents)
		cat = tzxcat{side: 1, block: 25, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(32, false, false, "BLK#25: 1-OCCUPY"+occupyHeading+"\n; 3x Sentry Robots (LASER GUN), 2x Mining Robots (GRAPPLER), 2x Auto-Guns (LASER GUN)", &contents)
		cat = tzxcat{side: 1, block: 27, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(5, false, false, "BLK#27: 1-VICTORY"+victoryHeader, &contents)
		saveSource("level-1-moonbase.asm", []byte(contents.String()))
		contents.Reset()
	}
	{
		contents.Reset()
		contents.WriteString("; Scenario #2: Starlingale\n")
		contents.WriteString(introTextStarlingale())
		cat = tzxcat{side: 2, block: 2, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(10, false, true, "BLK#02: STARLING"+scenarioHeading, &contents)
		cat = tzxcat{side: 2, block: 4, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(19, false, true, "BLK#04: 2-WEAPONS"+weaponHeading, &contents)
		cat = tzxcat{side: 2, block: 6, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSprite(true, "BLK#06: 2-UDGs", &contents)
		cat = tzxcat{side: 2, block: 8, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(32, false, false, "BLK#08: 2-DEPLOY"+deployHeading+" ($01=BLUE/operatives, $03=MAGENTA/raiders)", &contents)
		cat = tzxcat{side: 2, block: 10, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(32, false, false, "BLK#10: 2-ATTR"+attrHeading, &contents)
		cat = tzxcat{side: 2, block: 12, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(28, false, true, "BLK#12: 2-CHARS"+fmt.Sprintf(charsHeading, "Operatives", "Raiders"), &contents)
		cat = tzxcat{side: 2, block: 14, skip: headerLength + headerDim3d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(256, false, false, "BLK#14: 2-MOVE Pts"+movePointsHeading, &contents)
		cat = tzxcat{side: 2, block: 16, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(32, false, false, "BLK#16: 2-OCCUPY"+occupyHeading+"\n; 2x Nav-Comp, 3x Pilots (LAS-PISTOL), 3x Pilots (LAS-RIFLE)", &contents)
		cat = tzxcat{side: 2, block: 18, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(5, false, false, "BLK#18: 2-VICTORY"+victoryHeader, &contents)
		saveSource("level-2-starlingale.asm", []byte(contents.String()))
		contents.Reset()
	}
	{
		contents.WriteString("; Scenario #3: The Final Assault\n")
		contents.WriteString(introTextAssault())
		cat = tzxcat{side: 2, block: 23, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(10, false, true, "BLK#23: ASSAULT"+scenarioHeading, &contents)
		cat = tzxcat{side: 2, block: 25, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(19, false, true, "BLK#25: 3-WEAPONS"+weaponHeading, &contents)
		cat = tzxcat{side: 2, block: 27, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSprite(true, "BLK#27: 3-UDGs", &contents)
		cat = tzxcat{side: 2, block: 29, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(32, false, false, "BLK#29: 3-DEPLOY"+deployHeading+" ($01=BLUE/operatives, $03=MAGENTA/raiders)", &contents)
		cat = tzxcat{side: 2, block: 31, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(32, false, false, "BLK#31: 3-ATTR"+attrHeading, &contents)
		cat = tzxcat{side: 2, block: 33, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(28, false, true, "BLK#33: 3-CHARS"+fmt.Sprintf(charsHeading, "Raiders", "Operatives"), &contents)
		cat = tzxcat{side: 2, block: 35, skip: headerLength + headerDim3d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(256, false, false, "BLK#35: 3-MOVE Pts"+movePointsHeading, &contents)
		cat = tzxcat{side: 2, block: 37, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(32, false, false, "BLK#37: 3-OCCUPY"+occupyHeading+"\n; 4x Sentry Robots (LASER GUN), 6x Service Robots (CRUSHER), 8x Main-Comp brain elements", &contents)
		cat = tzxcat{side: 2, block: 39, skip: headerLength + headerDim2d, kind: DUMP}
		data = unmarshallDEFB(cat.execute())
		data.formatAndWriteSection(5, false, false, "BLK#39: 3-VICTORY"+victoryHeader, &contents)
		saveSource("level-3-final-assault.asm", []byte(contents.String()))
		contents.Reset()
	}
}

type assembly struct {
	lines []asmCode
}
type asmCode struct {
	address       uint16
	code          string
	comment       string
	newlinePrefix bool
}

func unmarshallASM(data []byte) assembly {
	asm := assembly{}
	// NOTE: if a line is blank, still add an entry
	for _, lineBytes := range bytes.Split(data, []byte{'\n'}) {
		if len(lineBytes) == 0 {
			continue
		}

		line := asmCode{}

		// set address
		n := new(big.Int)
		addr, ok := n.SetString(strings.TrimSpace(string(lineBytes[0:4])), 16)
		if ok {
			line.address = uint16(addr.Uint64())
		} else {
			fmt.Printf("error getting ASM address for %s\n", lineBytes)
		}

		// assign code
		line.code = strings.TrimSpace(string(lineBytes[25:]))

		asm.lines = append(asm.lines, line)
	}

	return asm
}

func (asm *assembly) addZapcodeComments() {
	for i := 0; i < len(asm.lines); i++ {
		switch asm.lines[i].address {
		case 0xFE11:
			asm.lines[i].comment = "Address 65041"
			asm.lines[i].newlinePrefix = true
		case 0xFE12:
			asm.lines[i].comment = "Load screen pixels (address 65042)"
			asm.lines[i].newlinePrefix = true
		case 0xFE24:
			asm.lines[i].comment = "Load screen attributes (address 65060)"
			asm.lines[i].newlinePrefix = true
		case 0xFE3B:
			asm.lines[i].comment = "Load screen pixels (address 65083)"
			asm.lines[i].newlinePrefix = true
		case 0xFE4C:
			asm.lines[i].comment = "Load screen attributes (address 65100)"
			asm.lines[i].newlinePrefix = true
		case 0xFE58:
			asm.lines[i].comment = "Load screen attributes (address 65112)"
			asm.lines[i].newlinePrefix = true
		case 0xFE64:
			asm.lines[i].newlinePrefix = true
		case 0xFE6F:
			asm.lines[i].comment = "Possibly the SFX routine (address 65135)"
			asm.lines[i].newlinePrefix = true
		case 0xFEDD:
			asm.lines[i].newlinePrefix = true
		case 0xFEFC:
			asm.lines[i].newlinePrefix = true
		case 0xFF0D:
			asm.lines[i].newlinePrefix = true
		default:
			// noop
		}
	}
}

func (asm *assembly) addRaidersComments() {
	for i := 0; i < len(asm.lines); i++ {
		switch asm.lines[i].address {
		case 0xC738:
			comment := "Routine at $C738=51000\n"
			comment += "; Looks like a helper routine for the developer.\n"
			comment += "; Copy the SCREEN/ATTR data at $4000 to $A7F8, ready for saving to tape."
			asm.lines[i].comment = comment
		case 0xC744:
			comment := "Routine at $C744=51012\n"
			comment += "; Move the loaded SCREEN/ATTR data from $A7F8 to the SCREEN memory at $4000."
			asm.lines[i].comment = comment
			asm.lines[i].newlinePrefix = true
		default:
			// noop
		}
	}
}

type defb struct {
	address uint16  // start address
	data    []uint8 // all HEX data values
}

func unmarshallDEFB(data []byte) defb {
	d := defb{}

	lines := bytes.Split(data, []byte{'\n'})
	for i, lineBytes := range lines {
		if len(lineBytes) == 0 {
			continue
		}

		parts := bytes.Split(lineBytes, []byte(" | "))
		if len(parts) < 2 {
			panic(fmt.Sprintf("unexpected data line: %s", lineBytes))
		}

		// set start address
		if i == 0 {
			n := new(big.Int)
			addr, ok := n.SetString(strings.TrimSpace(string(parts[0])), 16)
			if ok {
				d.address = uint16(addr.Uint64())
			} else {
				fmt.Printf("error getting address for %s\n", lineBytes)
			}
		}

		hexData := strings.Split(strings.TrimSpace(string(parts[1])), " ")
		for _, val := range hexData {
			n := new(big.Int)
			addr, ok := n.SetString(val, 16)
			if ok {
				d.data = append(d.data, uint8(addr.Uint64()))
			} else {
				fmt.Printf("error converting HEX data for: %s\n", lineBytes)
				break
			}
		}
	}

	return d
}

func (d *defb) formatAndWriteSection(width int, address bool, ascii bool, heading string, writer *strings.Builder) {
	writer.WriteString("\n\n")
	writer.WriteString(fmt.Sprintf("; %s\n", heading))
	for _, line := range d.format(width, address, ascii, false) {
		writer.WriteString(line)
		writer.WriteString("\n")
	}
}

// Format and write the character data + ASCII art for the sprite.
func (d *defb) formatAndWriteSprite(headingPrefix bool, heading string, writer *strings.Builder) {
	if headingPrefix {
		writer.WriteString("\n\n")
	}
	writer.WriteString(fmt.Sprintf("; %s\n", heading))

	charCounter := 0
	for i, line := range d.format(1, false, false, true) {
		if i == 0 || i%8 == 0 {
			writer.WriteString(fmt.Sprintf("; CHR %02d\n", charCounter))
			charCounter++
		}
		writer.WriteString(line)
		writer.WriteString("\n")
	}
}

// formats the defb data.
// width   : is the number of bytes to include per line
// address : includes the address for each line
// ascii   : includes the ASCII representation at the end of the line
func (d *defb) format(width int, address, ascii, binary bool) []string {
	var output []string

	currentAddress := d.address

	hexData := d.chunkData(d.data, width)
	for _, data := range hexData {
		var line strings.Builder
		if address {
			line.WriteString(fmt.Sprintf("%04X ", currentAddress))
		}
		hexLine := d.commaSeparatedHexValues(data)
		line.WriteString("db ")
		line.WriteString(hexLine)
		if ascii || binary {
			// *4 = hex values are: $ + 2 chars + comma
			// -1 = because no comma after last hex value
			diff := width*4 - 1 - len(hexLine)
			if diff > 0 {
				spaces := make([]byte, diff)
				for i := 0; i < diff; i++ {
					spaces[i] = ' '
				}
				line.Write(spaces)
			}
			line.WriteString(" ; ")

			for _, datum := range data {
				if ascii {
					line.WriteString(sinclairAsciiToPrintable(datum))
				} else if binary {
					bin := fmt.Sprintf("%08b", datum)
					bin = strings.ReplaceAll(bin, "0", " ")
					bin = strings.ReplaceAll(bin, "1", "█")
					line.WriteString(bin)
				}
			}
		}

		output = append(output, line.String())

		currentAddress += uint16(len(data))
	}

	return output
}

func (d *defb) commaSeparatedHexValues(data []byte) string {
	var hexValues []string
	for _, datum := range data {
		hexValues = append(hexValues, fmt.Sprintf("$%02X", datum))
	}
	return strings.Join(hexValues, ",")
}

func (d *defb) chunkData(data []byte, size int) [][]uint8 {
	var chunks [][]uint8
	for i := 0; i < len(data); i += size {
		end := i + size
		// necessary check to avoid slicing beyond
		// slice capacity
		if end > len(data) {
			end = len(data)
		}
		chunks = append(chunks, data[i:end])
	}
	return chunks
}

// tzxcat data types to extract
const (
	BASIC     = "-B"
	ASSEMBLER = "-A"
	SCREEN    = "-S"
	DUMP      = "-d"
)

const (
	headerLength = 3 // tzxcat length of array block header: 16-bit data length, flag byte
	headerDim2d  = 2 // DIM(a,b) length bytes: a is inferred, b = 2-bytes
	headerDim3d  = 4 // DIM(a,b,c) length bytes: a is inferred, b = 2-bytes, c 2-bytes
)

type tzxcat struct {
	side   int    // which side of the tape to use: 1 or 2
	block  int    // -b NR, --block NR         block number to cat
	skip   int    // -s BYTES, --skip BYTES    skip the given number of bytes before output
	limit  int    // -l BYTES, --length BYTES  limit output to the given number of bytes
	base   int    // -O BASE, --org BASE       base address for disassembled code
	target string // -o TARGET, --to TARGET    target file, stdout if omitted

	// kind of data to extract:
	// -t, --text                convert ZX Spectrum text to plain text
	// -B, --basic               convert ZX Spectrum BASIC to plain text
	// -A, --assembler           disassemble Z80 code
	// -S, --screen              convert a ZX Spectrum SCREEN$ to PNG
	// -d, --dump                convert to a hex dump
	kind string
}

func (cat *tzxcat) execute() []byte {
	args := []string{
		fmt.Sprintf("-b=%d", cat.block), // block number to cat
		fmt.Sprintf("-s=%d", cat.skip),  // skip the given number of bytes before output
	}
	// limit data to the given number of bytes
	if cat.limit > 0 {
		args = append(args, fmt.Sprintf("-l=%d", cat.limit))
	}
	// if base address is given
	if cat.base > 0 {
		args = append(args, fmt.Sprintf("-O=%d", cat.base))
	}
	// if a target file given
	if len(cat.target) > 0 {
		args = append(args, fmt.Sprintf("-o=%s", cat.target))
	}
	// type of data to extract: -S, -B, etc.
	args = append(args, cat.kind)

	// add the tape filename
	if cat.side < 1 || cat.side > 2 {
		panic("invalid tape side")
	}
	args = append(args, filepath.Join(rootDirectory, tapes[cat.side]))

	// create the `tzxcat` command to run
	cmd := exec.Command(tzxcatCommand, args...)

	// run the command and capture the output
	data, err := cmd.CombinedOutput()
	if err != nil {
		panic(err)
	}
	return data
}

func saveSource(filename string, data []byte) {
	srcFile := filepath.Join(rootDirectory, sourceDir, filename)
	file, err := os.Create(srcFile)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	_, err = file.Write(data)
	if err != nil {
		panic(err)
	}
}

// Converts a Sinclair ASCII to a printable character.
func sinclairAsciiToPrintable(ascii byte) string {
	char, ok := mappableCharacters[ascii]
	if !ok {
		return "."
	}
	return char
}

// Sinclair ASCII / printable character mapping
var mappableCharacters = map[byte]string{
	// Normal ASCII set
	0x20: " ", 0x21: "!", 0x22: "\"", 0x23: "#", 0x24: "$", 0x25: "%", 0x26: "&", 0x27: "'",
	0x28: "(", 0x29: ")", 0x2A: "*", 0x2B: "+", 0x2C: ",", 0x2D: "-", 0x2E: ".", 0x2F: "/",
	0x30: "0", 0x31: "1", 0x32: "2", 0x33: "3", 0x34: "4", 0x35: "5", 0x36: "6", 0x37: "7", 0x38: "8", 0x39: "9",
	0x3A: ":", 0x3B: ";", 0x3C: "<", 0x3D: "=", 0x3E: ">", 0x3F: "?", 0x40: "@",
	0x41: "A", 0x42: "B", 0x43: "C", 0x44: "D", 0x45: "E", 0x46: "F", 0x47: "G", 0x48: "H", 0x49: "I", 0x4A: "J", 0x4B: "K", 0x4C: "L", 0x4D: "M",
	0x4E: "N", 0x4F: "O", 0x50: "P", 0x51: "Q", 0x52: "R", 0x53: "S", 0x54: "T", 0x55: "U", 0x56: "V", 0x57: "W", 0x58: "X", 0x59: "Y", 0x5A: "Z",
	0x5B: "[", 0x5C: "\\", 0x5D: "]", 0x5E: "↑", 0x5F: "_", 0x60: "£",
	0x61: "a", 0x62: "b", 0x63: "c", 0x64: "d", 0x65: "e", 0x66: "f", 0x67: "g", 0x68: "h", 0x69: "i", 0x6A: "j", 0x6B: "k", 0x6C: "l", 0x6D: "m",
	0x6E: "n", 0x6F: "o", 0x70: "p", 0x71: "q", 0x72: "r", 0x73: "s", 0x74: "t", 0x75: "u", 0x76: "v", 0x77: "w", 0x78: "x", 0x79: "y", 0x7A: "z",
	0x7B: "{", 0x7C: "|", 0x7D: "}", 0x7E: "~", 0x7F: "©",
	// Block graphics without shift
	0x80: " ", 0x81: "▝", 0x82: "▘", 0x83: "▀", 0x84: "▗", 0x85: "▐", 0x86: "▚", 0x87: "▜",
	// Block graphics with shift
	0x88: "▖", 0x89: "▞", 0x8A: "▌", 0x8B: "▛", 0x8C: "▄", 0x8D: "▟", 0x8E: "▙", 0x8F: "█",
	// UDGs
	0x90: "Ⓐ", 0x91: "Ⓑ", 0x92: "Ⓒ", 0x93: "Ⓓ", 0x94: "Ⓔ", 0x95: "Ⓕ", 0x96: "Ⓖ", 0x97: "Ⓗ", 0x98: "Ⓘ", 0x99: "Ⓙ", 0x9A: "Ⓚ",
	0x9B: "Ⓛ", 0x9C: "Ⓜ", 0x9D: "Ⓝ", 0x9E: "Ⓞ", 0x9F: "Ⓟ", 0xA0: "Ⓠ", 0xA1: "Ⓡ", 0xA2: "Ⓢ", 0xA3: "Ⓣ", 0xA4: "Ⓤ",
}

func introTextMoonbase() string {
	return `
; DEPLOYMENT
; The Operatives deploy first on the MAGENTA areas.
; The Raiders deploy second on the RED areas and move first.
;
; OPERATIVES ALREADY DEPLOYED
;   3x Sentry Robots (LASER GUN)
;   2x Mining Robots (GRAPPLER)
;   2x Auto-Guns (LASER GUN)
; OPERATIVES' ORDER OF DEPLOYMENT
;   4x Technicians (PISTOL)
;   8x Security Guards (LAS-PISTOL)
;   4x Sentry Robots (LASER GUN)
;   1x Mining Robot (GRAPPLER)
; RAIDERS' ORDER OF DEPLOYMENT
;   4x Photon Commanders (PHOTON)
;   4x Raiders (GRENADE)
;  16x Raiders (LASER GUN)
`
}

func introTextStarlingale() string {
	return `
; DEPLOYMENT
; The Raiders deploy first on the MAGENTA areas.
; The Operatives deploy second on the BLUE areas and move first.
; Raider reinforcements arrive on game turn four.
;
; RAIDERS ALREADY DEPLOYED
;    2x Nav-Comp
;    3x Pilots (LAS-PISTOL)
;    3x Pilots (LAS-RIFLE)
; RAIDERS ORDER OF DEPLOYMENT
;   2x Photon Commanders (PHOTON)
;   3x Raiders (LASER GUN)
;   9x Raiders (LAS-RIFLE)
; RAIDER REINFORCEMENTS
;   8x Raiders (LAS-RIFLE)
; OPERATIVES ORDER OF DEPLOYMENT
;   4x Zorbotrons (GAS BOMB)
;  13x Fly-Bots (ZEEKER)
;   4x Slavers (LAS-WHIP)
;   1x Mining Robot (GRAPPLER)
;   2x Security Guards (LAS-PISTOL)
`
}

func introTextAssault() string {
	return `
; DEPLOYMENT
; The Operatives deploy first on the BLUE areas.
; The Raiders deploy second on the MAGENTA areas and move first.
;
; OPERATIVES ALREADY DEPLOYED
;   4x Sentry Robots (LASER GUN)
;   6x Service Robots (CRUSHER)
;   8x Main-Comp brain elements
; OPERATIVES' ORDER OF DEPLOYMENT
;   6x Fly-Bots (ZEEKER)
;  15x Guards (LAS-RIFLE)
;   2x Sentry Robots (LASER GUN)
; RAIDERS' ORDER OF DEPLOYMENT
;   2x Photon Commanders (PHOTON)
;   6x Raiders (LASER GUN)
;   6x Raiders (STARBOLT)
;  15x Raiders (LAS-RIFLE)
`
}
