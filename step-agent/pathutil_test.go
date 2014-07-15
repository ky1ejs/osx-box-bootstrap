package main

import (
	"fmt"
	"os"
	"testing"
)

func TestExpandPath(t *testing.T) {
	t.Log("should expand path")

	homePathEnv := "/path/home/test-user"
	err := os.Setenv("HOME", homePathEnv)
	if err != nil {
		t.Error("Could not set the ENV $HOME")
	}
	testFileRelPathFromHome := "some/file.ext"
	absPathToTestFile := fmt.Sprintf("%s/%s", homePathEnv, testFileRelPathFromHome)

	expandedPath := ExpandPath(fmt.Sprintf("$HOME/%s", testFileRelPathFromHome))
	if expandedPath != absPathToTestFile {
		t.Error("Returned path doesn't match the expected path. :", expandedPath)
	}

	expandedPath = ExpandPath(fmt.Sprintf("~/%s", testFileRelPathFromHome))
	if expandedPath != absPathToTestFile {
		t.Error("Returned path doesn't match the expected path. :", expandedPath)
	}
}
