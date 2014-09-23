#!/bin/bash

(
	echo
	echo "---> [install] Homebrew"
	yes '' | ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	res_code=$?
	echo "---> [install] Homebrew [done]"

	exit $res_code
) 2>> ~/Desktop/debug.log 1>> ~/Desktop/debug.log
exit $?
