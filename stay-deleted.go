// For making sure that files stay deleted
// For example, if a directory is backed up using
// rsync running in both directions.
package main

import (
	"bufio"
	"crypto/md5"
	"flag"
	"fmt"
	"os"
	"path/filepath"
)

const sdFolderName = ".stay-deleted"

type ActionForFile struct {
	file, action string
}

func main() {
	var fileToMark, fileToUnmark, directoryToSweep, sweepFromFile string
	flag.StringVar(&fileToMark, "mark", "",
		"The file or directory to mark for deletion")
	flag.StringVar(&fileToUnmark, "unmark", "",
		"The file or directory whose mark for deletion you want to remove")
	flag.StringVar(&directoryToSweep, "delete", "",
		"The directory to sweep")
	flag.StringVar(&sweepFromFile, "sweepFrom", "",
		"A file containing directories to sweep")

	flag.Parse()

	var err error
	if directoryToSweep != "" {
		err = sweepDirectory(directoryToSweep)
	} else if sweepFromFile != "" {
		err = sweepFrom(sweepFromFile)
	} else if fileToMark != "" {
		err = markFile(fileToMark)
	} else if fileToUnmark != "" {
		err = unmarkFile(fileToUnmark)
	} else {
		fmt.Println("Please tell me what to do!")
		os.Exit(1)
	}
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: '%v'!\n", err)
	}
}

func sweepDirectory(directoryToSweep string) error {
	var absDirectoryToSweep, err = filepath.Abs(directoryToSweep)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to find the absolute path for '%v'!\n",
			directoryToSweep)
		return err
	}

	fmt.Printf("Sweeping: '%v'\n", absDirectoryToSweep)
	filesToDelete := make([]string, 0)
	walker := func(path string, info os.FileInfo, err error) error {
		if err != nil {
			fmt.Fprintf(os.Stderr, "%v\n", err)
			return err
		}

		if info.IsDir() && info.Name() == sdFolderName {
			sdFolder := path
			fmt.Printf("Search SD folder '%v'\n", sdFolder)
			containingFolder := filepath.Dir(sdFolder)
			fmt.Printf("Containing folder '%v'\n", containingFolder)

			sdFiles, err := filepath.Glob(filepath.Join(sdFolder, "*.txt"))
			if err != nil {
				fmt.Fprintf(os.Stderr, "%v\n", err)
				return err
			}

			for _, sdFile := range sdFiles {
				fmt.Printf("SD File '%v'\n", sdFile)
				actionForFile, err := getActionForFile(sdFile, containingFolder)
				if err != nil {
					fmt.Fprintf(os.Stderr, "%v\n", err)
					return err
				}

				if actionForFile.action == "delete" {
					fmt.Printf("Deleting '%v'\n", actionForFile.file)
					filesToDelete = append(filesToDelete, actionForFile.file)
				} else if actionForFile.action == "keep" {
					fmt.Printf("Keeping '%v'\n", actionForFile.file)
				} else {
					return fmt.Errorf("Unrecognised action '%v'!\n",
						actionForFile.action)
				}
			}
		}

		return nil
	}

	err = filepath.Walk(absDirectoryToSweep, walker)
	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		return err
	}

	for _, fileToDelete := range filesToDelete {
		fmt.Printf("Deleting: '%v'\n", fileToDelete)
		os.RemoveAll(fileToDelete)
	}

	return nil
}

func sweepFrom(sweepFromFileName string) error {
	sweepFromFile, err := os.Open(sweepFromFileName)
	defer sweepFromFile.Close()

	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to open file to sweep from: %v\n", err)
		return err
	}

	input := bufio.NewScanner(sweepFromFile)
	for input.Scan() {
		directoryToSweep := input.Text()
		err := sweepDirectory(directoryToSweep)
		if err != nil {
			fmt.Fprintf(os.Stderr, "Unable to sweep from: '%v' - '%v'\n", directoryToSweep, err)
			continue
		}
	}

	return nil
}

func markFile(fileToMark string) error {
	return setActionForFile(fileToMark, "delete")
}

func unmarkFile(fileToUnmark string) error {
	return setActionForFile(fileToUnmark, "keep")
}

func getActionForFile(sdFileName, containingFolder string) (ActionForFile, error) {
	sdFile, err := os.Open(sdFileName)
	defer sdFile.Close()

	if err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		return ActionForFile{"", ""}, err
	}

	input := bufio.NewScanner(sdFile)
	input.Scan()
	fileToProcessName := filepath.Join(containingFolder, input.Text())
	input.Scan()
	action := input.Text()

	return ActionForFile{fileToProcessName, action}, nil
}

func setActionForFile(fileName string, action string) error {
	var absFileName, err = filepath.Abs(fileName)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to find the absolute path for '%v'!\n", fileName)
		return err
	}

	fmt.Printf("Marking: '%v'!\n", absFileName)
	fileBase := filepath.Base(absFileName)
	sdFileName, err := getSdFile(absFileName)

	if err != nil {
		fmt.Fprintf(os.Stderr, "Unable to get sd file name for '%v'!",
			absFileName)
		return err
	}

	fmt.Printf("SD File: '%v'!\n", sdFileName)
	sdFolder := filepath.Dir(sdFileName)

	if _, err := os.Stat(sdFolder); os.IsNotExist(err) {
		fmt.Printf("Making directory '%v'\n", sdFolder)
		os.Mkdir(sdFolder, 0755)
	}

	sdFile, err := os.Create(sdFileName)
	defer sdFile.Close()

	if err != nil {
		fmt.Fprintf(os.Stderr, "Couldn't create file '%v'!\n",
			sdFileName)
		return err
	}

	fmt.Fprintf(sdFile, "%v\n%v\n", fileBase, action)

	return nil
}

func getSdFolder(file string) (string, error) {
	dir := filepath.Dir(file)
	attemptedAbsSdFolder := filepath.Join(dir, sdFolderName)
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
		fmt.Fprintf(os.Stderr, "Unable to get sd folder for '%v'!", file)
		return "", err
	} else {
		fileBase := filepath.Base(file)
		data := []byte(fileBase)
		return fmt.Sprintf("%v/%x.txt", sdFolder, md5.Sum(data)), nil
	}
}
