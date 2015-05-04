#!/bin/bash

#
# Create a Base Box from a parallels VM on your machine
#  [!] Remove your snapshots before packaging!
#  [!] Don't forget to include the box-info.json file at /Users/vagrant/Desktop/box-info.json
#
# The pvm-name is the .pvm dir name in the parallels_pvm_dir
# With the default Parallels Desktop setup
#  * parallels_pvm_dir: $HOME/Documents/Parallels
#  * parallels_pvm_name is something like: bitrise-MacOSX.pvm
#

parallels_pvm_dir=$1
parallels_pvm_name=$2

function print_usage {
  echo
  echo "Usage:"
  echo "$ bash parallels-package-box.sh < parallels_pvm_dir > < parallels_pvm_name >"
  echo
}

is_arg_missing=0
if [ "${parallels_pvm_dir}" == "" ]; then
  echo "[!] parallels_pvm_dir missing"
  is_arg_missing=1
fi
if [ "${parallels_pvm_name}" == "" ]; then
  echo "[!] parallels_pvm_name missing"
  is_arg_missing=1
fi

if [ ${is_arg_missing} -ne 0 ]; then
  print_usage
  exit 1
fi

echo
echo "--- Args:"
echo " * parallels_pvm_dir: ${parallels_pvm_dir}"
echo " * parallels_pvm_name: ${parallels_pvm_name}"
echo "---------"
echo


metadata_file_content=$( cat <<EOF
{
  "provider": "parallels"
}
EOF
)

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
  print_and_do_command_exit_on_error cd "${parallels_pvm_dir}"
  echo "-> writing metadata to file: ${metadata_file_content}"
  echo "${metadata_file_content}" > metadata.json
  print_and_do_command_exit_on_error tar cvzf concrete-worker-osx.box "./${parallels_pvm_name}" ./metadata.json
)
fail_if_cmd_error "Failed to package"
