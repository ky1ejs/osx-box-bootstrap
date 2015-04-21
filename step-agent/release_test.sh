#!/bin/bash

go test ./...
if [ $? -ne 0 ]; then
	echo " [!] Go Test failed"
	exit 1
fi

# run the build
bash _scripts/make_osx.sh
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

echo
echo "=> Ready for release!"
echo
