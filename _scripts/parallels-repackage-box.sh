#!/bin/bash

#
# Create a Base Box from a parallels vagrant VM on your machine
#  [!] Starts with a rollback -> carefully commit the version you want to package before running this script!
#

vagrant_vm_path=$1
parallels_pvm_dir=$2
parallels_pvm_name=$3
box_version_id=$4

function print_usage {
	echo
	echo "Usage:"
	echo "$ bash box_package.sh < vagrant_vm_path > < parallels_pvm_dir > < parallels_pvm_name > < box_version_id >"
	echo
}

is_arg_missing=0
if [ "$vagrant_vm_path" == "" ]; then
	echo "[!] Vagrant VM path missing"
	is_arg_missing=1
fi
if [ "$parallels_pvm_dir" == "" ]; then
	echo "[!] parallels_pvm_dir missing"
	is_arg_missing=1
fi
if [ "$parallels_pvm_name" == "" ]; then
	echo "[!] parallels_pvm_name missing"
	is_arg_missing=1
fi
if [ "$box_version_id" == "" ]; then
	echo "[!] box_version_id missing"
	is_arg_missing=1
fi

if [ $is_arg_missing -ne 0 ]; then
	print_usage
	exit 1
fi

echo
echo "--- Args:"
echo " * vagrant_vm_path: $vagrant_vm_path"
echo " * parallels_pvm_dir: $parallels_pvm_dir"
echo " * parallels_pvm_name: $parallels_pvm_name"
echo " * box_version_id: $box_version_id"
echo "---------"
echo


metadata_file_content=$( cat <<EOF
{
  "provider": "parallels"
}
EOF
)

box_file_content=$( cat <<EOF
{
  "version": "${box_version_id}",
  "applied_patches": [
  ]
}
EOF
)

echo " (debug) box_file_content: ${box_file_content}"

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
  last_cmd_result=$?
  err_msg=$1
  if [ ${last_cmd_result} -ne 0 ]; then
    echo "${err_msg}"
    exit ${last_cmd_result}
  fi
}


# --- MAIN

(
	print_and_do_command_exit_on_error cd "$vagrant_vm_path"
	print_and_do_command_exit_on_error vagrant sandbox rollback
	print_and_do_command_exit_on_error sleep 25
	print_and_do_command_exit_on_error vagrant sandbox off
	print_and_do_command_exit_on_error sleep 25

	echo "${box_file_content}" | vagrant ssh -c 'cat > ~/Desktop/box-info.json'
	echo
	echo " (debug) Box info content from VM:"
	vagrant ssh -c 'cat ~/Desktop/box-info.json'
	echo

	print_and_do_command_exit_on_error vagrant halt
	print_and_do_command_exit_on_error sleep 30
)
fail_if_cmd_error "Failed to prepare the VM for packaging"

(
	print_and_do_command_exit_on_error cd "$parallels_pvm_dir"
	echo "-> writing metadata to file: $metadata_file_content"
	echo "$metadata_file_content" > metadata.json
	print_and_do_command_exit_on_error tar cvzf concrete-worker-osx.box ./$parallels_pvm_name ./metadata.json
)
fail_if_cmd_error "Failed to package"