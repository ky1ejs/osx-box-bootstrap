package main

import (
	"os"
	"strings"
)

// Expands ENV vars and the ~ character
func ExpandPath(path string) string {
	if path[:2] == "~/" {
		path = strings.Replace(path, "~/", "$HOME/", 1)
	}
	return os.ExpandEnv(path)
}
