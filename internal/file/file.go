package file

import (
	"os"
	"path/filepath"
	"strings"
)

func FindAllDirectoryPaths(dirPath, suffix string) ([]string, error) {
	var paths []string
	err := filepath.Walk(dirPath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() && strings.HasSuffix(info.Name(), suffix) {
			paths = append(paths, path)
			return filepath.SkipDir
		}
		return nil
	})
	return paths, err
}

func FindAllFilePaths(dirPath, suffix string) ([]string, error) {
	var paths []string
	err := filepath.Walk(dirPath, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && strings.HasSuffix(info.Name(), suffix) {
			paths = append(paths, path)
		}
		return nil
	})
	return paths, err
}

func GetFileNameWithoutExt(path string) string {
	base := filepath.Base(path)
	ext := filepath.Ext(base)
	return strings.TrimSuffix(base, ext)
}
