#!/bin/bash
linux=/data/linux/linux
clear
sh ./umount.sh
clear
sh ./mount.sh
clear
mkdir $linux/dev
mkdir $linux/dev/pts
mkdir $linux/dev/shm
mkdir $linux/proc
mkdir $linux/sys
clear
echo "LANG=zh_CN.UTF-8" >$linux/etc/locale.conf
echo "127.0.0.1 localhost" >$linux/etc/hosts
echo "nameserver 114.114.114.114" >$linux/etc/resolv.conf
echo "nameserver 8.8.8.8" >>$linux/etc/resolv.conf
echo "nameserver 8.8.4.4" >>$linux/etc/resolv.conf
echo "nameserver 127.0.0.1" >>$linux/etc/resolv.conf
clear
cp init.sh $linux/boot/init.sh
chown root:root $linux/boot/init.sh
chmod 777 $linux/boot/init.sh
clear
chroot $linux /boot/init.sh
exit