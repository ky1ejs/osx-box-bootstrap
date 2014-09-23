#!/bin/bash

#
# Create a Base Box (package a working vagrant VM) from a VirtualBox vagrant VM on your machine
#  [!] Starts with a rollback -> carefully commit the version you want to package before running this script!
#

# the dir of the Vagrantfile you use for this vagrant VM
vagrant_vm_dir=$1
# you can get the VirtualBox VM names with: $ VBoxManage list vms
virtualbox_vm_name=$2
# Bitrise box version (for later patching), something like: r2p3
box_version_id=$3

function print_usage {
	echo
	echo "Usage:"
	echo "$ bash virtualbox-repackage-box.sh < vagrant_vm_dir > < virtualbox_vm_name > < box_version_id >"
	echo
}

is_arg_missing=0
if [ "${vagrant_vm_dir}" == "" ]; then
	echo "[!] vagrant_vm_dir missing"
	is_arg_missing=1
fi
if [ "${virtualbox_vm_name}" == "" ]; then
	echo "[!] virtualbox_vm_name missing"
	is_arg_missing=1
fi
if [ "${box_version_id}" == "" ]; then
	echo "[!] box_version_id missing"
	is_arg_missing=1
fi

if [ ${is_arg_missing} -ne 0 ]; then
	print_usage
	exit 1
fi

echo
echo "--- Args:"
echo " * vagrant_vm_dir: ${vagrant_vm_dir}"
echo " * virtualbox_vm_name: ${virtualbox_vm_name}"
echo " * box_version_id: ${box_version_id}"
echo "---------"
echo

box_version_file_content=$( cat <<EOF
{
  "version": "${box_version_id}",
  "applied_patches": [
  ]
}
EOF
)

echo " (debug) box_version_file_content: ${box_version_file_content}"

# --- UTILS

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

function fail_if_cmd_error {
	err_msg=$1
	last_cmd_result=$?
	if [ ${last_cmd_result} -ne 0 ]; then
		echo "${err_msg}"
		exit ${last_cmd_result}
	fi
}


# --- MAIN

(
	print_and_do_command_exit_on_error cd "${vagrant_vm_dir}"
	print_and_do_command_exit_on_error vagrant sandbox rollback
	print_and_do_command_exit_on_error sleep 25
	print_and_do_command_exit_on_error vagrant sandbox off
	print_and_do_command_exit_on_error sleep 25

	echo "${box_version_file_content}" | vagrant ssh -c 'cat > ~/Desktop/box-info.json'
  fail_if_cmd_error "Failed to write the box-info.json in the VM"
	echo
	echo " (debug) Box info content from VM:"
	vagrant ssh -c 'cat ~/Desktop/box-info.json'
  fail_if_cmd_error "Failed to read-back the box-info.json from the VM"
	echo

	print_and_do_command_exit_on_error vagrant halt
	print_and_do_command_exit_on_error sleep 20
)
fail_if_cmd_error "Failed to prepare the VM for packaging"



echo "-> creating the new box"
print_and_do_command_exit_on_error vagrant package --base "${virtualbox_vm_name}"
