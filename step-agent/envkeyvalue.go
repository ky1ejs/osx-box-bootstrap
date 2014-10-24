package main

import (
	"encoding/base64"
	"errors"
	"fmt"
	"os"
	"strings"
)

type EnvKeyValuePair struct {
	Key      string
	Value    string
	IsExpand bool
}

func (e EnvKeyValuePair) String() string {
	return e.Key + "=" + e.Value
}

//
// ToEnvironmentString
// Returns a string in the key=value format.
//  Respects the EnvKeyValuePair's IsExpand setting,
//		expands the value if it's true, does not expands it if it's false
func (e EnvKeyValuePair) ToEnvironmentString() string {
	theValue := e.Value
	if e.IsExpand {
		theValue = os.ExpandEnv(theValue)
	}
	return fmt.Sprintf("%s=%s", e.Key, theValue)
}

func decodeEnvKeyValuePair(combinedEncodedKeyValue string) (EnvKeyValuePair, error) {
	encodedEnvPairComponents := strings.Split(combinedEncodedKeyValue, ".")
	envSplitComponentsLength := len(encodedEnvPairComponents)
	if envSplitComponentsLength < 2 {
		return EnvKeyValuePair{}, errors.New(fmt.Sprintf("Not a valid Environment key-value pair: %s", combinedEncodedKeyValue))
	}

	anEnvKey, err := decodeSingleValue(encodedEnvPairComponents[0])
	if err != nil {
		return EnvKeyValuePair{}, err
	}

	anEnvValue, err := decodeSingleValue(encodedEnvPairComponents[1])
	if err != nil {
		return EnvKeyValuePair{}, err
	}

	isExpand := true
	if envSplitComponentsLength == 3 && encodedEnvPairComponents[2] == "false" {
		isExpand = false
	}

	return EnvKeyValuePair{Key: anEnvKey, Value: anEnvValue, IsExpand: isExpand}, nil
}

func decodeSingleValue(encodedContent string) (string, error) {
	bytes, err := base64.StdEncoding.DecodeString(encodedContent)
	if err != nil {
		// fmt.Println("Failed for input: ", encodedContent)
		return "", err
	}

	return string(bytes), nil
}

// decodeCombinedEnvs decodes the combined envs
//
func decodeCombinedEnvs(combinedEncodedEnvs string) ([]EnvKeyValuePair, error) {
	if len(combinedEncodedEnvs) < 1 {
		return []EnvKeyValuePair{}, nil
	}

	decodedEnvKeyValuePairs := []EnvKeyValuePair{}

	encodedEnvPairList := strings.Split(combinedEncodedEnvs, ",")
	for _, anEncodedEnvPair := range encodedEnvPairList {
		anEnvKeyValuePair, err := decodeEnvKeyValuePair(anEncodedEnvPair)
		if err != nil {
			return []EnvKeyValuePair{}, err
		} else {
			decodedEnvKeyValuePairs = append(decodedEnvKeyValuePairs, anEnvKeyValuePair)
		}
	}

	return decodedEnvKeyValuePairs, nil
}
