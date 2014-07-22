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


echo "---> Starting setups..."

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# cd into this script's directory
cd "$SCRIPTDIR"


echo " (i) Profile setups..."
print_and_do_command_exit_on_error cp ../profiles/bashrc ~/.bashrc
print_and_do_command_exit_on_error cp ../profiles/profile ~/.profile
print_and_do_command_exit_on_error cp ../profiles/bash_profile ~/.bash_profile
print_and_do_command_exit_on_error source ~/.bash_profile


echo " (i) SSH setup..."
print_and_do_command mkdir -p ~/.ssh
print_and_do_command cp ./authorized_keys ~/.ssh/authorized_keys
print_and_do_command chmod 600 ~/.ssh/authorized_keys


echo " (i) Installing brew..."
ruby -e "$(curl -fsSL https://raw.github.com/Homebrew/homebrew/go/install)"
print_and_do_command_exit_on_error brew doctor


echo " (i) Installing tools with brew..."
print_and_do_command_exit_on_error brew install wget
print_and_do_command_exit_on_error brew install git
print_and_do_command_exit_on_error brew install xctool
print_and_do_command_exit_on_error brew install mercurial
print_and_do_command_exit_on_error brew install node

source ../installers/install_go.sh
if [ $? -ne 0 ]; then
	echo " [!] Failed!"
	exit 1
fi


source ../installers/install_rvm.sh
if [ $? -ne 0 ]; then
	echo " [!] Failed!"
	exit 1
fi


echo
echo "---> Finished with automatic stuff - but here's some things you have to do manually:"
echo
echo "---> Finished"
