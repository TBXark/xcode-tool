package asset

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"github.com/TBXark/xcode-tool/internal/file"
)

// Contents represents the structure of an asset Contents.json file.
type Contents struct {
	Images []struct {
		Filename string `json:"filename"`
		Idiom    string `json:"idiom"`
		Scale    string `json:"scale"`
	} `json:"images"`
	Info struct {
		Author  string `json:"author"`
		Version int    `json:"version"`
	} `json:"info"`
}

// Group tracks the imagesets that belong to a .xcassets bundle.
type Group struct {
	XCAssets  string
	Imagesets map[string]bool
}

// Rename renames asset files in .imageset directories to match the asset name.
func Rename(dirPath string) error {
	paths, err := file.FindAllDirectoryPaths(dirPath, ".imageset")
	if err != nil {
		return fmt.Errorf("finding imageset directories: %w", err)
	}

	fmt.Printf("Find %d assets in %s\n", len(paths), dirPath)

	for _, assetPath := range paths {
		if err := renameAsset(assetPath); err != nil {
			log.Printf("Error processing %s: %v", assetPath, err)
		}
	}

	return nil
}

func renameAsset(assetPath string) error {
	jsonPath := filepath.Join(assetPath, "Contents.json")

	// Read JSON file
	data, err := os.ReadFile(jsonPath)
	if err != nil {
		return fmt.Errorf("reading %s: %w", jsonPath, err)
	}

	var contents Contents
	if err := json.Unmarshal(data, &contents); err != nil {
		return fmt.Errorf("parsing %s: %w", jsonPath, err)
	}

	assetName := file.GetFileNameWithoutExt(assetPath)
	didUpdate := false
	jsonStr := string(data)

	for _, image := range contents.Images {
		if image.Filename == "" {
			continue
		}

		parts := strings.Split(image.Filename, ".")
		if len(parts) < 2 {
			continue
		}

		ext := parts[len(parts)-1]
		scale := ""
		if image.Scale != "" && image.Scale != "1x" {
			scale = "@" + image.Scale
		}

		targetName := fmt.Sprintf("%s%s.%s", assetName, scale, ext)

		if targetName != image.Filename {
			oldPath := filepath.Join(assetPath, image.Filename)
			newPath := filepath.Join(assetPath, targetName)

			if err := os.Rename(oldPath, newPath); err != nil {
				log.Printf("Error renaming %s: %v", oldPath, err)
				continue
			}

			// Update JSON string
			pattern := fmt.Sprintf(`"filename"\s*:\s*"%s"`, regexp.QuoteMeta(image.Filename))
			re := regexp.MustCompile(pattern)
			jsonStr = re.ReplaceAllString(jsonStr, fmt.Sprintf(`"filename" : "%s"`, targetName))
			didUpdate = true
		}
	}

	if didUpdate {
		if err := os.WriteFile(jsonPath, []byte(jsonStr), 0644); err != nil {
			return fmt.Errorf("writing %s: %w", jsonPath, err)
		}
	}

	return nil
}

// Clean finds and reports unused image assets by scanning Swift files.
func Clean(dirPath string) error {
	// Find all .xcassets directories
	xcassetsPaths, err := file.FindAllDirectoryPaths(dirPath, ".xcassets")
	if err != nil {
		return fmt.Errorf("finding xcassets directories: %w", err)
	}

	// Map each .xcassets to its imagesets
	var assets []Group
	for _, xcassetsPath := range xcassetsPaths {
		imagesets, err := file.FindAllDirectoryPaths(xcassetsPath, ".imageset")
		if err != nil {
			log.Printf("Error: %v", err)
			continue
		}

		imagesetMap := make(map[string]bool)
		for _, imageset := range imagesets {
			imagesetMap[imageset] = true
		}

		assets = append(assets, Group{
			XCAssets:  xcassetsPath,
			Imagesets: imagesetMap,
		})
	}

	// Find all Swift files
	swiftFiles, err := file.FindAllFilePaths(dirPath, ".swift")
	if err != nil {
		return fmt.Errorf("finding swift files: %w", err)
	}

	// Filter out R.generated.swift files
	var filteredFiles []string
	for _, f := range swiftFiles {
		if filepath.Base(f) != "R.generated.swift" {
			filteredFiles = append(filteredFiles, f)
		}
	}

	// Scan Swift files for asset usage
	for _, f := range filteredFiles {
		content, err := os.ReadFile(f)
		if err != nil {
			log.Printf("Error reading %s: %v", f, err)
			continue
		}

		text := string(content)

		for i := range assets {
			var found []string
			for imageset := range assets[i].Imagesets {
				name := file.GetFileNameWithoutExt(imageset)

				// Check for various patterns
				if strings.Contains(text, fmt.Sprintf("R.image.%s", name)) ||
					strings.Contains(text, fmt.Sprintf(`#imageLiteral(resourceName: "%s")`, name)) ||
					strings.Contains(text, fmt.Sprintf(`UIImage(named: "%s")`, name)) {
					found = append(found, imageset)
					fmt.Printf("%s find %s\n", f, name)
				}
			}

			// Remove found assets
			for _, imageset := range found {
				delete(assets[i].Imagesets, imageset)
			}
		}
	}

	// Print unused assets
	fmt.Printf("\n\n\n\nunused imageset\n")
	for _, asset := range assets {
		for imageset := range asset.Imagesets {
			name := file.GetFileNameWithoutExt(imageset)
			fmt.Printf("%s -> %s\n", asset.XCAssets, name)
		}
	}

	return nil
}
