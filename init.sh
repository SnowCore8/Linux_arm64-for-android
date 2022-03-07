#!/bin/bash
export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export SHELL=/bin/bash
export HOME=/root
export TERM=linux
apt-get update&&apt-get upgrade
apt-get install language-pack-zh-hans language-pack-zh-hans-base -y
export LANG="zh_CN.UTF-8"
export LANG="zh_CN.UTF-8"
export LANGUAGE="zh_CN:zh"
export LC_MONETARY="zh_CN"
export LC_PAPER="zh_CN"
export LC_NAME="zh_CN"
export LC_ADDRESS="zh_CN"
export LC_TELEPHONE="zh_CN"
export LC_MEASUREMENT="zh_CN"
export LC_IDENTIFICATION="zh_CN"
export LC_ALL="zh_CN.UTF-8"
cd ~
clear
service ssh restart
bash -i
clear&&clear
service ssh stop
exit