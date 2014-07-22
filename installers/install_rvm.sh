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

curl -sSL https://get.rvm.io | bash -s stable --ruby
print_and_do_command_exit_on_error source "$HOME/.rvm/scripts/rvm"
print_and_do_command_exit_on_error source ~/.bash_profile
print_and_do_command_exit_on_error rvm install ruby-2.0.0
print_and_do_command_exit_on_error rvm use --default 2.0.0
print_and_do_command_exit_on_error rvm list