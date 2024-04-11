#!/bin/bash

###############################
# SETUP AND UTILITY FUNCTIONS #
###############################

# OS detection
OS='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
  OS='linux'
elif [[ "$unamestr" == 'Darwin' ]]; then
  OS='mac'
fi

# Colors
CLEAR="\033[0m"
ORANGE="\033[33m"

output() {
  echo -e ${ORANGE}$1${CLEAR}
}

################
# START ME UP! #
################

output ""
output "START ME UP"
output ""
output "Jaguar's system provisioning script"
output ""
output "OS detected: ${OS}"
output ""
output "Note: You will be asked to enter your password and press Enter a few times, so don't run off!"
output ""

if [[ $OS == 'linux' ]]; then
  bash <(curl -s https://raw.githubusercontent.com/jaguardesign/start-me-up/master/install-linux.sh)
elif [[ $OS == 'mac' ]]; then
  bash <(curl -s https://raw.githubusercontent.com/jaguardesign/start-me-up/master/install-macos-arm.sh)
else
  output "OS not recognized. Please run on a Mac or a Ubuntu Linux system."
fi

# vim: set ft=bash
