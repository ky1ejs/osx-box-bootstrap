#!/bin/bash

#
# You can use this script to upgrade system components automatically
#

function print_and_do_command {
  echo "$ $@"
  $@
}

echo "--> Starting system refresh..."
print_and_do_command brew update
print_and_do_command brew doctor
print_and_do_command brew upgrade
#
print_and_do_command rvm osx-ssl-certs update all
print_and_do_command rvm get stable
#
print_and_do_command gem update --system
print_and_do_command gem update
#
print_and_do_command gem install cocoapods
print_and_do_command pod setup
#
echo "<-- Finished with system refresh"


echo "--> Starting system upgrade..."
print_and_do_command sudo softwareupdate --install --all
echo "<-- Finished with system upgrade"