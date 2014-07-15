package main

import (
	"testing"
)

// TODO:
//  * transformIfSpecialEnv
//  * filterEnvironmentKeyValuePairs

func Test_perform(t *testing.T) {
	t.Log("should perform")

	if err := perform("", ""); err == nil {
		t.Error("No error returned - should return an error for empty step-path!")
	}

	if err := perform(encodeSingleValue("./testfiles/step_to_succeed.sh"), ""); err != nil {
		t.Error("returned error: ", err)
	}

	if err := perform(encodeSingleValue("./testfiles/step_to_fail.sh"), ""); err == nil {
		t.Error("should return an error")
	}

	// envs := []EnvKeyValuePair{
	// 	EnvKeyValuePair{
	// 		Key:   "TESTKEY",
	// 		Value: "test-value",
	// 	},
	// }
	// if err := perform(encodeSingleValue("echo \"$TEST\""), encodeAndCombineEnvs(envs)); err != nil {
	// 	t.Error("returned error: ", err)
	// }

	// encodedStepCmd := encodedStr_bash
	// encodedCombinedStepArgs := strings.Join([]string{
	// 	encodedStr_minusc,
	// 	encodedStr_exit_1,
	// }, ",")
	// if err := perform(encodedStepCmd, encodedCombinedStepArgs); err == nil {
	// 	t.Error("No error returned - should return an error for a failing step-path!")
	// }
}
