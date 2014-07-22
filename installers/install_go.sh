#!/bin/bash

function print_and_do_command {
	echo "-> $ $@"
	$@
}

function print_and_do_command_exit_on_error {
	print_and_do_command $@
	if [ $? -ne 0 ]; then
		echo " [!] Failed!"
		exit 1
	fi
}

print_and_do_command_exit_on_error brew install go

echo 'export PATH="$PATH:/usr/local/opt/go/libexec/bin"' >> ~/.bashrc
if [ $? -ne 0 ]; then
	echo " [!] Failed!"
	exit 1
fi

echo 'export GOPATH="$HOME/go"' >> ~/.bashrc
if [ $? -ne 0 ]; then
	echo " [!] Failed!"
	exit 1
fi

# bash_profile should load bashrc
print_and_do_command_exit_on_error source ~/.bash_profile
print_and_do_command_exit_on_error mkdir -p "$GOPATH/src"
print_and_do_command_exit_on_error mkdir -p "$GOPATH/bin"
print_and_do_command_exit_on_error mkdir -p "$GOPATH/pkg"