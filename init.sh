#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

export HOME=/root
export TERM=linux

clear
apt-get update&&apt-get upgrade
apt-get install language-pack-zh-han* -y
apt-get install language-pack-kde-zh-han* -y
apt-get install language-pack-gnome-zh-han* -y

clear
service ssh restart
bash -i
clear&&clear
service ssh stop
exit