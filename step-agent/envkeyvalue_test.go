package main

import (
	"encoding/base64"
	"os"
	"strings"
	"testing"
)

// ------------------------
// --- Helpers

func encodeSingleValue(valueToEncode string) string {
	return base64.StdEncoding.EncodeToString([]byte(valueToEncode))
}

func encodeAndCombineEnvs(envsToEncode []EnvKeyValuePair) string {
	encodedCombinedEnvPairs := make([]string, len(envsToEncode), len(envsToEncode))

	for idx, aKeyVal := range envsToEncode {
		encodedKey := encodeSingleValue(aKeyVal.Key)
		encodedValue := encodeSingleValue(aKeyVal.Value)
		encodedPair := encodedKey + "." + encodedValue
		encodedCombinedEnvPairs[idx] = encodedPair
	}

	return strings.Join(encodedCombinedEnvPairs, ",")
}

var (
	encodedStr_a      = "YQ=="     // a
	encodedStr_echo   = "ZWNobw==" // echo
	encodedStr_hi     = "aGk="     // hi
	encodedStr_bash   = "YmFzaA==" // bash
	encodedStr_minusc = "LWM="     // -c
	encodedStr_exit_1 = "ZXhpdCAx" // exit 1
)

// ------------------------
// --- Tests

func Test_decodeSingleValue(t *testing.T) {
	t.Log("should decode")

	testContString := "any + old & data"
	if decodedString, err := decodeSingleValue(base64.StdEncoding.EncodeToString([]byte(testContString))); err != nil || decodedString != testContString {
		t.Error("decode result doesn't match the expected.\n Expected: %s\n Got:%s\n Error: %v", testContString, decodedString, err)
	}

	testInvalidContString := "this should not be a valid input if not encoded"
	if _, err := decodeSingleValue(testInvalidContString); err == nil {
		t.Error("expected to return an error for an invalid input")
	}

	if decodedStr, _ := decodeSingleValue(encodedStr_echo); decodedStr != "echo" {
		t.Error("decode failed. got: ", decodedStr)
	}
	if decodedStr, _ := decodeSingleValue(encodedStr_bash); decodedStr != "bash" {
		t.Error("decode failed. got: ", decodedStr)
	}
	if decodedStr, _ := decodeSingleValue(encodedStr_exit_1); decodedStr != "exit 1" {
		t.Error("decode failed. got: ", decodedStr)
	}
	if decodedStr, _ := decodeSingleValue(encodedStr_hi); decodedStr != "hi" {
		t.Error("decode failed. got: ", decodedStr)
	}
	if decodedStr, _ := decodeSingleValue(encodedStr_minusc); decodedStr != "-c" {
		t.Error("decode failed. got: ", decodedStr)
	}
}

func Test_decodeEnvKeyValuePair(t *testing.T) {
	t.Log("should decode a pair")

	// at least a "." is required
	if _, err := decodeEnvKeyValuePair(""); err == nil {
		t.Error("should return an error for a completely empty input!")
	}

	keyVal, err := decodeEnvKeyValuePair(".")
	if err != nil {
		t.Error("error returned: ", err)
	}
	if keyVal.Key != "" || keyVal.Value != "" {
		t.Errorf("both the key and the value should be empty.\n Key: %s\n Value: %s", keyVal.Key, keyVal.Value)
	}

	keyVal, err = decodeEnvKeyValuePair(encodedStr_a + ".")
	if err != nil {
		t.Error("error returned: ", err)
	}
	if keyVal.Key != "a" || keyVal.Value != "" {
		t.Errorf("key should be 'a' and the value should be empty.\n Key: %s\n Value: %s", keyVal.Key, keyVal.Value)
	}

	keyVal, err = decodeEnvKeyValuePair("." + encodedStr_a)
	if err != nil {
		t.Error("error returned: ", err)
	}
	if keyVal.Key != "" || keyVal.Value != "a" {
		t.Errorf("value should be 'a' and the key should be empty.\n Key: %s\n Value: %s", keyVal.Key, keyVal.Value)
	}

	keyVal, err = decodeEnvKeyValuePair(encodedStr_a + "." + encodedStr_a)
	if err != nil {
		t.Error("error returned: ", err)
	}
	if keyVal.Key != "a" || keyVal.Value != "a" {
		t.Errorf("both the value and the key should be 'a'.\n Key: %s\n Value: %s", keyVal.Key, keyVal.Value)
	}

	keyVal, err = decodeEnvKeyValuePair(encodedStr_a + "." + encodedStr_a + "." + "true")
	if err != nil {
		t.Error("error returned: ", err)
	}
	if !keyVal.IsExpand {
		t.Errorf("IsExpand should be true.\n %#v", keyVal)
	}

	keyVal, err = decodeEnvKeyValuePair(encodedStr_a + "." + encodedStr_a + "." + "false")
	if err != nil {
		t.Error("error returned: ", err)
	}
	if keyVal.IsExpand {
		t.Errorf("IsExpand should be false.\n %#v", keyVal)
	}
}

func Test_ToEnvironmentString(t *testing.T) {
	if err := os.Setenv("__TEST_KEY__Test_ToEnvironmentString", "TEST VALUE"); err != nil {
		t.Error("Could not set the ENV")
	}

	envKeyValuePair := EnvKeyValuePair{
		Key:      "key",
		Value:    "Some ${__TEST_KEY__Test_ToEnvironmentString} value",
		IsExpand: true,
	}
	res := envKeyValuePair.ToEnvironmentString()
	expectedEnvString := "key=Some TEST VALUE value"
	if res != expectedEnvString {
		t.Errorf("ToEnvironmentString result doesn't match.\n Expected: %s\n Got: %s", expectedEnvString, res)
	}

	envKeyValuePair.IsExpand = false
	res = envKeyValuePair.ToEnvironmentString()
	expectedEnvString = "key=Some ${__TEST_KEY__Test_ToEnvironmentString} value"
	if res != expectedEnvString {
		t.Errorf("ToEnvironmentString result doesn't match.\n Expected: %s\n Got: %s", expectedEnvString, res)
	}
}

func Test_decodeCombinedEnvs(t *testing.T) {
	t.Log("should decode the args.")

	if _, err := decodeCombinedEnvs("cont.1,cont.2"); err == nil {
		t.Error("expected to return an error for an un-encoded input")
	}

	// if decodedArgs, err := decodeCombinedEnvs(""); len(decodedArgs) != 0 || err != nil {
	// 	t.Errorf("for an empty input it's expected to return an empty array and no error.\n Got array: %v\n Error:%v\n",
	// 		decodedArgs, err)
	// }

	// testContentStrings := []string{"cont 1", "cont 2"}
	// testEncodedStrings := []string{
	// 	base64.StdEncoding.EncodeToString([]byte(testContentStrings[0])),
	// 	base64.StdEncoding.EncodeToString([]byte(testContentStrings[1])),
	// }
	// testEncodedCombinedArgs := strings.Join(testEncodedStrings, ",")
	// decodedArgs, err := decodeCombinedEnvs(testEncodedCombinedArgs)
	// if err != nil {
	// 	t.Error("returned error:", err)
	// }
	// if decodedArgs[0] != "cont 1" || decodedArgs[1] != "cont 2" {
	// 	t.Error("result doesn't match the expected.\n Expected: %v\n Got:%v\n Error: %v", testContentStrings, decodedArgs, err)
	// }
}
