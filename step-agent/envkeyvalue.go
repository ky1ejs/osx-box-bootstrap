package main

import (
	"encoding/base64"
	"errors"
	"fmt"
	"os"
	"strings"
)

type EnvKeyValuePair struct {
	Key   string
	Value string
}

func (envKeyValPair *EnvKeyValuePair) String() string {
	return envKeyValPair.Key + "=" + envKeyValPair.Value
}

func (e *EnvKeyValuePair) ToStringWithExpand() string {
	return fmt.Sprintf("%s=%s", e.Key, os.ExpandEnv(e.Value))
}

func decodeEnvKeyValuePair(combinedEncodedKeyValue string) (EnvKeyValuePair, error) {
	encodedEnvPairComponents := strings.Split(combinedEncodedKeyValue, ".")
	if len(encodedEnvPairComponents) != 2 {
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

	return EnvKeyValuePair{Key: anEnvKey, Value: anEnvValue}, nil
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
