package main

import (
	"fmt"
	"log"
	"path/filepath"

	"github.com/TBXark/xcode-tool/internal/asset"
	"github.com/TBXark/xcode-tool/internal/color"
	"github.com/spf13/cobra"
)

func main() {
	cmd := createCommand()
	err := cmd.Execute()
	if err != nil {
		log.Panicf("Error: %v", err)
	}
}

func createCommand() *cobra.Command {
	renameAssetCmd := &cobra.Command{
		Use:   "rename-asset [location]",
		Short: "Rename assets in Xcode project",
		Long:  "Rename asset files in .imageset directories to match the asset name.\nExample: xct rename-asset ./xctdemo/Sources",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			dirPath, err := filepath.Abs(args[0])
			if err != nil {
				return err
			}
			return asset.Rename(dirPath)
		},
	}

	cleanAssetCmd := &cobra.Command{
		Use:   "clean-asset [location]",
		Short: "Find unused assets in Xcode project",
		Long:  "Find and report unused image assets by scanning Swift files.\nExample: xct clean-asset ./xctdemo/Sources",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			dirPath, err := filepath.Abs(args[0])
			if err != nil {
				return err
			}
			return asset.Clean(dirPath)
		},
	}

	hexCmd := &cobra.Command{
		Use:   "hex [color]",
		Short: "Convert hex color to UIColor",
		Long:  "Convert a hex color string to UIColor format.\nExample: xct hex 232323",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			hexString := args[0]
			result, err := color.Hex2Color(hexString)
			if err != nil {
				return fmt.Errorf("hex string is illegal: %w", err)
			}
			fmt.Print(result)
			return nil
		},
	}

	replaceHexCmd := &cobra.Command{
		Use:   "replace-hex [location]",
		Short: "Replace hex colors with UIColor in Swift files",
		Long:  "Replace UIColor(hexString:) calls with UIColor(red:green:blue:alpha:) in Swift files.\nExample: xct replace-hex /xctdemo",
		Args:  cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			dirPath, err := filepath.Abs(args[0])
			if err != nil {
				return err
			}
			return color.ReplaceHexInFiles(dirPath)
		},
	}

	rootCmd := &cobra.Command{
		Use:     "xct",
		Version: "2.0.0",
		Short:   "Xcode Tool - A command line tool for Xcode projects",
		Long:    `Xcode Tool (xct) is a CLI utility for managing Xcode projects, including asset management and color conversion.`,
	}

	rootCmd.AddCommand(renameAssetCmd)
	rootCmd.AddCommand(cleanAssetCmd)
	rootCmd.AddCommand(hexCmd)
	rootCmd.AddCommand(replaceHexCmd)

	return rootCmd
}
