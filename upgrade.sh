#!/bin/bash

#
# You can use this script to upgrade system components automatically
#

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

echo "--> Starting system refresh..."
print_and_do_command_exit_on_error brew update
print_and_do_command_exit_on_error brew doctor
print_and_do_command_exit_on_error brew upgrade
#
print_and_do_command_exit_on_error rvm osx-ssl-certs update all
print_and_do_command_exit_on_error rvm get stable
print_and_do_command_exit_on_error rvm osx-ssl-certs update all
print_and_do_command_exit_on_error source ~/.bash_profile
#
print_and_do_command_exit_on_error gem update --system
print_and_do_command_exit_on_error gem update
#
print_and_do_command_exit_on_error gem install cocoapods
print_and_do_command_exit_on_error pod setup
#
echo "<-- Finished with system refresh"


echo "--> Starting system upgrade..."
print_and_do_command_exit_on_error sudo softwareupdate --install --all
# print the current OS version, for debugging
print_and_do_command_exit_on_error sw_vers
echo "<-- Finished with system upgrade"