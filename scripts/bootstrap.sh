#!/bin/bash

function print_and_do_command {
  echo "$ $@"
  $@
}

function sync_system_time_from_server {
	server_url=$1
	print_and_do_command sudo ntpdate -u "$server_url"
	if [ $? -ne 0 ]; then
		echo " (!) Failed to sync time with server: $server_url"
		return 1
	fi
	return 0
}

function do_if_prev_failed {
	prev_res=$?
	if [ $prev_res -ne 0 ]; then
		$@
		return $?
	fi
	return 0
}

sync_system_time_from_server "time1.google.com"
do_if_prev_failed sync_system_time_from_server "time2.google.com"
do_if_prev_failed sync_system_time_from_server "time3.google.com"
do_if_prev_failed sync_system_time_from_server "time4.google.com"
exit $?