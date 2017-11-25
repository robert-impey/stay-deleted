// For making sure that files stay deleted
package main

import (
	"bufio"
	"crypto/md5"
	"flag"
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	var fileToMark, fileToUnmark, directoryToSweep string
	flag.StringVar(&fileToMark, "mark", "",
		"The file or directory to mark for deletion")
	flag.StringVar(&fileToUnmark, "unmark", "",
		"The file or directory whose mark for deletion you want to remove")
	flag.StringVar(&directoryToSweep, "delete", "",
		"The directory to sweep")

	flag.Parse()

	if directoryToSweep != "" {
		sweepDirectory(directoryToSweep)
	} else if fileToMark != "" {
		markFile(fileToMark)
	} else if fileToUnmark != "" {
		unmarkFile(fileToUnmark)
	} else {
		fmt.Println("Please tell me what to do!")
	}
}

func sweepDirectory(directoryToSweep string) {
	var absDirectoryToSweep, err = filepath.Abs(directoryToSweep)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to find the absolute path for '%v'!\n",
			directoryToSweep)
	} else {
		fmt.Printf("Sweeping: '%v'!\n", absDirectoryToSweep)
		err := filepath.Walk(absDirectoryToSweep, walker)
		if err != nil {
			fmt.Fprintf(os.Stderr, "%v\n", err)
		}
	}
}

func walker(path string, info os.FileInfo, err error) error {
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		return err
	} else {
		if info.IsDir() && info.Name() == ".stay-deleted" {
			sdFolder := path
			fmt.Printf("Search SD folder '%v'\n", sdFolder)
			containingFolder := filepath.Dir(sdFolder)
			fmt.Printf("Containing folder '%v'\n", containingFolder)

			sdFiles, err := filepath.Glob(filepath.Join(sdFolder, "*.txt"))
			if err != nil {
				fmt.Fprintf(os.Stderr, "%v\n", err)
			} else {
				for _, sdFile := range sdFiles {
					fmt.Printf("SD File '%v'\n", sdFile)
					err := processSdFile(sdFile, containingFolder)
					if err != nil {
						fmt.Fprintf(os.Stderr, "%v\n", err)
					}
				}
			}
		}
	}
	return nil
}

func processSdFile(sdFileName string, containingFolder string) error {
	sdFile, err := os.Open(sdFileName)
	defer sdFile.Close()

	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		return err
	}

	input := bufio.NewScanner(sdFile)
	input.Scan()
	fileToProcessName := filepath.Join(containingFolder, input.Text())
	input.Scan()
	action := input.Text()

	if action == "delete" {
		fmt.Printf("Deleting '%v'\n", fileToProcessName)
		os.RemoveAll(fileToProcessName)
	} else if action == "keep" {
		fmt.Printf("Keeping '%v'\n", fileToProcessName)
	} else {
		return fmt.Errorf("Unrecognised action '%v'!\n", action)
	}

	return nil
}

func markFile(fileToMark string) {
	setActionForFile(fileToMark, "delete")
}

func unmarkFile(fileToUnmark string) {
	setActionForFile(fileToUnmark, "keep")
}

func setActionForFile(fileName string, action string) {
	var absFileName, err = filepath.Abs(fileName)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to find the absolute path for '%v'!\n",
			fileName)
	} else {
		fmt.Printf("Marking: '%v'!\n", absFileName)
		fileBase := filepath.Base(absFileName)
		sdFileName, err := getSdFile(absFileName)
		if err == nil {
			fmt.Printf("SD File: '%v'!\n", sdFileName)
			sdFolder := filepath.Dir(sdFileName)

			if _, err := os.Stat(sdFolder); os.IsNotExist(err) {
				fmt.Printf("Making directory '%v'\n", sdFolder)
				os.Mkdir(sdFolder, 0755)
			}

			sdFile, err := os.Create(sdFileName)
			if err != nil {
				fmt.Fprintf(os.Stderr, "Couldn't create file '%v'!\n", sdFileName)
			}
			defer sdFile.Close()

			fmt.Fprintf(sdFile, "%v\n%v\n", fileBase, action)
		}
	}
}

func getSdFolder(file string) (string, error) {
	dir := filepath.Dir(file)
	attemptedAbsSdFolder := dir + "/.stay-deleted"
	absSdFolder, err := filepath.Abs(attemptedAbsSdFolder)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to find the absolute path of '%v'!",
			attemptedAbsSdFolder)
		return "", err
	} else {
		return absSdFolder, nil
	}
}

func getSdFile(file string) (string, error) {
	sdFolder, err := getSdFolder(file)
	if err != nil {
		return "", err
	} else {
		fileBase := filepath.Base(file)
		data := []byte(fileBase)
		return fmt.Sprintf("%v/%x.txt", sdFolder, md5.Sum(data)), nil
	}
}
