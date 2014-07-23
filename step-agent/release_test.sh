#!/bin/bash

# run the build
bash scripts/make_osx.sh
if [ $? -ne 0 ]; then
	echo " [!] Failed to make"
	exit 1
fi

# check git status -> nothing should change!
status=`git status -s`
if [ "$status" != "" ]; then
	echo " [!] Some files were changed after make!"
	echo " (i) git status: $status"
	exit 1
fi
