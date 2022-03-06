#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

export USER=root
export HOME=/root
export TERM=linux

service ssh start
systemctl start sshd.service
bash -i
service ssh stop
systemctl stop sshd.service
systemctl enable sshd.service
clear&&clear
exit