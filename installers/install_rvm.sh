#!/bin/bash

(
	echo
	echo "---> [install] RVM"
	curl -sSL https://get.rvm.io | bash -s stable --ruby
	res_code=$?
	echo "---> [install] RVM [done]"

	exit $res_code
) 2>> ~/Desktop/debug.log 1>> ~/Desktop/debug.log
exit $?