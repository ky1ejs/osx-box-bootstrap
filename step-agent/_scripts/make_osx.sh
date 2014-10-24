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

# test
print_and_do_command_exit_on_error go test ./...

# build
echo "Building..."
print_and_do_command_exit_on_error go build

# move the created 'main' binary into 'bin/step_agent_osx'
echo "Moving to bin..."
print_and_do_command_exit_on_error mkdir -p _bin
print_and_do_command_exit_on_error mv step-agent-go _bin/step_agent_osx

echo "Done"