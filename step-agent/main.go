package main

import (
	"errors"
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"os/user"
	"path/filepath"
)

func writeStringToFile(filePath, content string) error {
	if filePath == "" {
		return errors.New("No path provided!")
	}

	file, err := os.Create(filePath)
	if err != nil {
		return err
	}
	defer file.Close()

	_, err = file.Write([]byte(content))
	if err != nil {
		return err
	}

	return nil
}

func transformIfSpecialEnv(envKeyValuePair EnvKeyValuePair) (EnvKeyValuePair, error) {
	if envKeyValuePair.Key == "__INPUT_FILE__" {
		log.Println(" (i) Special key: __INPUT_FILE__")
		usr, err := user.Current()
		if err != nil {
			return EnvKeyValuePair{}, err
		}
		tmpFolderPath := filepath.Join(usr.HomeDir, "bitrise/tmp")
		if err := os.MkdirAll(tmpFolderPath, 0777); err != nil {
			return EnvKeyValuePair{}, err
		}
		stepInputStoreFilePath := filepath.Join(tmpFolderPath, "step_input_store")
		if err := writeStringToFile(stepInputStoreFilePath, envKeyValuePair.Value); err != nil {
			return EnvKeyValuePair{}, err
		}
		envKeyValuePair.Value = stepInputStoreFilePath
		envKeyValuePair.IsExpand = false
	}
	return envKeyValuePair, nil
}

func filterEnvironmentKeyValuePairs(envKeyValuePair []EnvKeyValuePair) []EnvKeyValuePair {
	filteredPairs := []EnvKeyValuePair{}

	for _, aPair := range envKeyValuePair {
		if aPair.Key == "" {
			log.Println("[i] Key is missing - won't add it to the environment. Value: ", aPair.Value)
			continue
		}
		if aPair.Value == "" {
			log.Printf("[i] Value is missing - won't add it to the environment (default value will be used by the Step) (Key: %s)\n", aPair.Key)
			continue
		}

		aPair, err := transformIfSpecialEnv(aPair)
		if err != nil {
			log.Printf("[i] Failed to convert special Env - ignored (Key: %s | Value: %s)\n", aPair.Key, aPair.Value)
			continue
		}
		filteredPairs = append(filteredPairs, aPair)
	}

	return filteredPairs
}

func runStepWithAdditionalEnvironment(commandPath string, envsToAdd []EnvKeyValuePair) error {
	commandDir := filepath.Dir(commandPath)
	commandName := filepath.Base(commandPath)

	cmdBridgeToolPath := os.Getenv("BITRISE_TOOLS_CMD_BRIDGE_PATH")
	var c *exec.Cmd
	if cmdBridgeToolPath != "" {
		c = exec.Command(cmdBridgeToolPath, "-do", "bash -l "+commandName, "-workdir", commandDir)
	} else {
		c = exec.Command("bash", "-l", commandName)
		c.Dir = commandDir
	}

	envLength := len(envsToAdd)
	if envLength > 0 {
		originalOsEnvs := os.Environ()
		var envStringPairs = map[string]string{}
		for _, aEnvPair := range envsToAdd {
			aEnvStringPair := aEnvPair.ToExpandedEnvironmentString()
			if cmdBridgeToolPath != "" {
				envStringPairs[aEnvPair.Key] = fmt.Sprintf("_CMDENV__%s", aEnvStringPair)
			} else {
				envStringPairs[aEnvPair.Key] = aEnvStringPair
			}
			// set as env, so subsequent expansions can use it
			envExpandedValue := aEnvPair.ExpanedValue()
			if err := os.Setenv(aEnvPair.Key, envExpandedValue); err != nil {
				fmt.Println(" [!] Failed to set Env: ", aEnvPair)
			}
		}
		// collect unique values
		var filteredEnvsList = make([]string, len(envStringPairs), len(envStringPairs))
		for _, v := range envStringPairs {
			filteredEnvsList = append(filteredEnvsList, v)
		}
		// append to original ENVs
		c.Env = append(originalOsEnvs, filteredEnvsList...)
	}
	c.Stdout = os.Stdout
	c.Stderr = os.Stderr
	if Config_IsVerboseLogMode {
		log.Printf("Full Command: %#v\n", c)
	}
	if err := c.Run(); err != nil {
		return err
	}
	return nil
}

func runCommandWithArgs(command string, cmdArgs ...string) error {
	c := exec.Command(command, cmdArgs...)
	c.Stdout = os.Stdout
	c.Stderr = os.Stderr
	if err := c.Run(); err != nil {
		return err
	}
	return nil
}

func perform(encodedStepPath, encodedCombinedStepEnvs string) error {
	if encodedStepPath == "" {
		return errors.New("No Step Path provided")
	}

	decodedStepCommand, err := decodeSingleValue(encodedStepPath)
	if err != nil {
		return err
	}
	decodedStepCommand = ExpandPath(decodedStepCommand)
	decodedStepEnvPairs, err := decodeCombinedEnvs(encodedCombinedStepEnvs)
	if err != nil {
		return err
	}

	filteredEnvPairs := filterEnvironmentKeyValuePairs(decodedStepEnvPairs)

	if Config_IsVerboseLogMode {
		fmt.Println("Perform: ", decodedStepCommand, filteredEnvPairs)
	}
	return runStepWithAdditionalEnvironment(decodedStepCommand, filteredEnvPairs)
}

func usage() {
	fmt.Fprintf(os.Stderr, "Usage: %s [FLAGS]\n", os.Args[0])
	flag.PrintDefaults()
}

func main() {
	var (
		flagEncodedStepPath         = flag.String("steppath", "", "[REQUIRED] step's path (base64 encoded)")
		flagEncodedCombinedStepEnvs = flag.String("stepenvs", "", "[REQUIRED] step's encoded-combined environment key-value pairs")
		flagEncode                  = flag.String("encode", "", "If no step provided the value of this flag will be printed in base64 encoded form.")
		flagIsVerbose               = flag.Bool("verbose", false, "Verbose logging?")
		flagIsVersion               = flag.Bool("version", false, "Print version information")
	)

	flag.Usage = usage
	flag.Parse()

	if *flagIsVersion {
		fmt.Println(VersionString)
		os.Exit(0)
	}

	Config_IsVerboseLogMode = *flagIsVerbose

	if *flagEncodedStepPath == "" {
		if *flagEncode != "" {
			encString := encodeSingleValue(*flagEncode)
			fmt.Println(encString)
			os.Exit(0)
		}
		flag.Usage()
		os.Exit(1)
	}

	if err := perform(*flagEncodedStepPath, *flagEncodedCombinedStepEnvs); err != nil {
		log.Fatal(err)
	}
}
