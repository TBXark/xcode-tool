package color

import (
	"fmt"
	"log"
	"os"
	"regexp"
	"strconv"
	"strings"

	"github.com/TBXark/xcode-tool/internal/file"
)

// Hex2Color converts a hex color string to UIColor format
func Hex2Color(hexString string) (string, error) {
	hex := strings.TrimPrefix(hexString, "#")

	var r, g, b, a float64
	a = 1.0

	var hexValue uint64
	var err error

	switch len(hex) {
	case 3:
		hexValue, err = strconv.ParseUint(hex, 16, 16)
		if err != nil {
			return "", err
		}
		r = float64((hexValue&0xF00)>>8) / 15.0
		g = float64((hexValue&0x0F0)>>4) / 15.0
		b = float64(hexValue&0x00F) / 15.0

	case 4:
		hexValue, err = strconv.ParseUint(hex, 16, 16)
		if err != nil {
			return "", err
		}
		r = float64((hexValue&0xF000)>>12) / 15.0
		g = float64((hexValue&0x0F00)>>8) / 15.0
		b = float64((hexValue&0x00F0)>>4) / 15.0
		a = float64(hexValue&0x000F) / 15.0

	case 6:
		hexValue, err = strconv.ParseUint(hex, 16, 32)
		if err != nil {
			return "", err
		}
		r = float64((hexValue&0xFF0000)>>16) / 255.0
		g = float64((hexValue&0x00FF00)>>8) / 255.0
		b = float64(hexValue&0x0000FF) / 255.0

	case 8:
		hexValue, err = strconv.ParseUint(hex, 16, 64)
		if err != nil {
			return "", err
		}
		r = float64((hexValue&0xFF000000)>>24) / 255.0
		g = float64((hexValue&0x00FF0000)>>16) / 255.0
		b = float64((hexValue&0x0000FF00)>>8) / 255.0
		a = float64(hexValue&0x000000FF) / 255.0

	default:
		return "", fmt.Errorf("invalid hex color length: %d", len(hex))
	}

	return fmt.Sprintf("UIColor(red: %.3f, green: %.3f, blue: %.3f, alpha: %.3f)", r, g, b, a), nil
}

// ReplaceHexInFiles replaces UIColor(hexString:) calls with UIColor(red:green:blue:alpha:) in Swift files
func ReplaceHexInFiles(dirPath string) error {
	swiftFiles, err := file.FindAllFilePaths(dirPath, ".swift")
	if err != nil {
		return fmt.Errorf("finding swift files: %w", err)
	}

	// Pattern to match UIColor(hexString: "#RRGGBB") or UIColor(hexString: "RRGGBB")
	pattern := `UIColor\(hexString:\s*"#?([a-fA-F0-9]{3,8})"\s*\)[!?]?`
	re := regexp.MustCompile(pattern)

	for _, f := range swiftFiles {
		content, err := os.ReadFile(f)
		if err != nil {
			log.Printf("Error reading %s: %v", f, err)
			continue
		}

		text := string(content)
		didChange := false
		result := text

		for {
			matches := re.FindStringSubmatchIndex(result)
			if matches == nil {
				break
			}

			// Extract the hex string (group 1)
			hexStart := matches[2]
			hexEnd := matches[3]
			hexString := result[hexStart:hexEnd]

			// Convert to UIColor
			color, err := Hex2Color(hexString)
			if err != nil {
				log.Printf("Error: Cannot process hex color in %s: %v", f, err)
				break
			}

			// Replace the entire match
			matchStart := matches[0]
			matchEnd := matches[1]
			result = result[:matchStart] + color + result[matchEnd:]
			didChange = true
		}

		if didChange {
			if err := os.WriteFile(f, []byte(result), 0644); err != nil {
				log.Printf("Error writing %s: %v", f, err)
			} else {
				fmt.Printf("Updated %s\n", f)
			}
		}
	}

	return nil
}
