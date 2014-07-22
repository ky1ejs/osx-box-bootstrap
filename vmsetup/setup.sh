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


echo " (i) SSH setup..."
print_and_do_command_exit_on_error mkdir -p ~/.ssh
print_and_do_command_exit_on_error cp ./authorized_keys ~/.ssh/authorized_keys
print_and_do_command_exit_on_error chmod 600 ~/.ssh/authorized_keys
print_and_do_command_exit_on_error sudo cp ./sshd_config /etc/sshd_config


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


# RVM
echo " (i) Installing RVM and Ruby..."
source ../installers/install_rvm.sh
if [ $? -ne 0 ]; then
	echo " [!] Failed!"
	exit 1
fi

print_and_do_command_exit_on_error rvm osx-ssl-certs update all
source ~/.bash_profile
#
print_and_do_command_exit_on_error gem update --system
print_and_do_command_exit_on_error gem update
#
echo " (i) Installing Cocoapods..."
print_and_do_command_exit_on_error gem install cocoapods
print_and_do_command_exit_on_error pod setup


echo " (i) Profile setups..."
print_and_do_command_exit_on_error cp ../profiles/bashrc ~/.bashrc
print_and_do_command_exit_on_error cp ../profiles/profile ~/.profile
print_and_do_command_exit_on_error cp ../profiles/bash_profile ~/.bash_profile
print_and_do_command_exit_on_error source ~/.bash_profile


echo " (i) Initialising box-info.json..."
print_and_do_command_exit_on_error cp ./box-info.json ~/Desktop/box-info.json


echo
echo "---> Finished with automatic stuff - but here's some things you have to do manually:"
echo
echo " (*) Set the correct version in ~/Desktop/box-info.json!"
echo " (!) ssh config changed so you won't be able to log in with password (after the ssh daemon or system restart) - check ~/.ssh/authorized_keys for ssh keys!"
echo " (!) After you finished with the preparations RESTART the machine! (just to be sure)"
echo
echo "---> Finished"
