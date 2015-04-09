#!/bin/bash

(
	echo
	echo "---> [install] RVM"
	tmp_rvm_install_script_path="$HOME/rvm-install-tmp.sh"
	echo " (i) tmp_rvm_install_script_path: ${tmp_rvm_install_script_path}"

	\curl -sSL -o "${tmp_rvm_install_script_path}" https://get.rvm.io
	if [ $? -ne 0 ] ; then
		echo " [!] Error: failed to download rvm installer"
		exit 1
	fi

	cat "${tmp_rvm_install_script_path}" | bash -s stable
	if [ $? -ne 0 ] ; then
		echo " [!] Error: failed to do the RVM install"
		exit 1
	fi

	rm "${tmp_rvm_install_script_path}"
	if [ $? -ne 0 ] ; then
		echo " [!] Error: failed to remove the temporary RVM install script file"
		exit 1
	fi

	res_code=$?
	echo "---> [install] RVM [done]"

	exit $res_code
) 2>> ~/Desktop/debug.log 1>> ~/Desktop/debug.log
exit $?
