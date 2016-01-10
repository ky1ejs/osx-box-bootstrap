#!/bin/bash
set -e

# echo
# echo "=== Revision / ID ======================"
# echo "* BITRISE_OSX_REV_NUMBER: $BITRISE_OSX_REV_NUMBER"
# echo "========================================"
# echo

# Make sure that the reported version is only
#  a single line!
echo
echo "=== Pre-installed tool versions ========"

ver_line="$(go version)" ;                        echo "* Go: $ver_line"
ver_line="$(ruby --version)" ;                    echo "* Ruby: $ver_line"
ver_line="$(python --version 2>&1 >/dev/null)" ;  echo "* Python: $ver_line"

echo
ver_line="$(git --version)" ;                     echo "* git: $ver_line"
ver_line="$(hg --version | grep version)" ;       echo "* mercurial/hg: $ver_line"
ver_line="$(curl --version | grep curl)" ;        echo "* curl: $ver_line"
ver_line="$(wget --version | grep 'GNU Wget')" ;  echo "* wget: $ver_line"
ver_line="$(rsync --version | grep version)" ;    echo "* rsync: $ver_line"
ver_line="$(unzip -v | head -n 1)" ;              echo "* unzip: $ver_line"
ver_line="$(tar --version | head -n 1)" ;         echo "* tar: $ver_line"

echo
ver_line="$(brew --version)" ;                    echo "* brew: $ver_line"
ver_line="$(xctool --version)" ;                  echo "* xctool: $ver_line"
ver_line="$(node --version)" ;                    echo "* Node.js: $ver_line"
ver_line="$(npm --version)" ;                     echo "* NPM: $ver_line"
ver_line="$(ansible --version | grep ansible)" ;  echo "* Ansible: $ver_line"
ver_line="$(gtimeout --version | grep 'timeout')" ;  echo "* gtimeout: $ver_line"

echo
echo "--- Bitrise CLI tool versions"
ver_line="$(bitrise --version)" ;                 echo "* bitrise: $ver_line"
ver_line="$(stepman --version)" ;                 echo "* stepman: $ver_line"
ver_line="$(envman --version)" ;                  echo "* envman: $ver_line"
ver_line="$(bitrise-bridge --version)" ;          echo "* bitrise-bridge: $ver_line"
ver_line="$(cmd-bridge --version)" ;              echo "* cmd-bridge: $ver_line"
echo "========================================"
echo

echo
echo "=== Ruby GEMs =========================="
ver_line="$(bundle --version)" ;                  echo "* Bundler: $ver_line"
ver_line="$(pod --version)" ;                     echo "* CocoaPods: $ver_line"
ver_line="$(fastlane --version)" ;                echo "* fastlane: $ver_line"
ver_line="$(xcpretty --version)" ;                echo "* xcpretty: $ver_line"
ver_line="$(gem -v nomad-cli)" ;                  echo "* Nomad CLI: $ver_line"
ver_line="$(ipa --version)" ;                     echo "* Nomad CLI IPA / Shenzhen: $ver_line"
echo "========================================"
echo

echo
echo "=== Xcode =============================="
echo
echo "* Active Xcode Command Line Tools:"
xcode-select --print-path
echo
echo "* Xcode Version:"
xcodebuild -version
echo
echo "* Installed SDKs:"
xcodebuild -showsdks
echo
echo "* Available Simulators:"
xcrun simctl list | grep -i --invert-match 'unavailable'
echo
echo "========================================"
echo

echo
echo "=== OS X info ========================="
echo
echo "* sw_vers"
sw_vers
echo
echo "* system_profiler SPSoftwareDataType"
system_profiler SPSoftwareDataType
echo
echo "========================================"
echo

echo
echo "=== System infos ======================="
info_line="$( df -kh / | grep '/' )" ;            echo "* Free disk space: $info_line"
echo "========================================"
echo
