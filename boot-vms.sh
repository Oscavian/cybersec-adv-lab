#!/bin/bash

# Check if VirtualBox is installed
if ! command -v VBoxManage &>/dev/null; then
  echo "VirtualBox is not installed. Please install VirtualBox and try again."
  exit 1
fi

VBoxManage startvm isprouter --type headless
sleep 2
VBoxManage startvm dc --type headless
sleep 2
VBoxManage startvm companyrouter --type headless
sleep 2
VBoxManage startvm web --type headless
sleep 2
VBoxManage startvm database --type headless
#sleep 2
#VBoxManage startvm win10
sleep 2
VBoxManage startvm red --type headless
