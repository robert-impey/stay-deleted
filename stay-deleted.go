// For making sure that files stay deleted
package main

import (
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
	}
}

func markFile(fileToMark string) {
	var absFileToMark, err = filepath.Abs(fileToMark)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to find the absolute path for '%v'!\n",
			fileToMark)
	} else {
		fmt.Printf("Marking: '%v'!\n", absFileToMark)
		sdFile, err := getSdFile(absFileToMark)
		if err == nil {
			fmt.Printf("SD File: '%v'!\n", sdFile)
		}
	}
}

func unmarkFile(fileToUnmark string) {
	var absFileToUnmark, err = filepath.Abs(fileToUnmark)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to find the absolute path for '%v'!\n",
			fileToUnmark)
	} else {
		fmt.Printf("Unmarking: '%v'!\n", absFileToUnmark)
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
