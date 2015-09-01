#!/bin/bash

(

	set -e
	echo
	echo "------ Install Bitrise CLI Stack Tools..."

	# bitrise
	echo
	echo "[bitrise] Downloading..."
	curl -L https://github.com/bitrise-io/bitrise/releases/download/0.9.11/bitrise-$(uname -s)-$(uname -m) > /usr/local/bin/bitrise
	echo "[bitrise] chmod"
	chmod +x /usr/local/bin/bitrise
	echo "[bitrise] setup"
	bitrise setup --minimal
	echo "[bitrise] version"
	bitrise --version

	# bitrise-bridge
	echo
	echo "[bitrise-bridge] Downloading..."
	curl -L https://github.com/bitrise-io/bitrise-bridge/releases/download/0.9.1/bitrise-bridge-$(uname -s)-$(uname -m) > /usr/local/bin/bitrise-bridge
	echo "[bitrise-bridge] chmod"
	chmod +x /usr/local/bin/bitrise-bridge
	echo "[bitrise-bridge] version"
	bitrise-bridge --version

	echo "------ Install Bitrise CLI Stack Tools [DONE]"

) 2>> ~/Desktop/debug.log 1>> ~/Desktop/debug.log
exit $?
