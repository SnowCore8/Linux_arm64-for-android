#!/bin/sh
linux=/data/linux/linux

clear
./mount.sh

clear
[ ! -d $linux/dev ] && mkdir -p $linux/dev
[ ! -d $linux/dev/pts ] && mkdir -p $linux/dev/pts
[ ! -d $linux/proc ] && mkdir -p $linux/proc
[ ! -d $linux/sys ] && mkdir -p $linux/sys

clear
echo "
LANG="zh_CN.UTF-8"
LANGUAGE="zh_CN:zh"
LC_NUMERIC="zh_CN"
LC_TIME="zh_CN"
LC_MONETARY="zh_CN"
LC_PAPER="zh_CN"
LC_NAME="zh_CN"
LC_ADDRESS="zh_CN"
LC_TELEPHONE="zh_CN"
LC_MEASUREMENT="zh_CN"
LC_IDENTIFICATION="zh_CN"
LC_ALL="zh_CN.UTF-8"
" >$linux/etc/default/locale
echo "LANG=zh_CN.UTF-8" >$linux/etc/locale.conf
echo "127.0.0.1	localhost" >$linux/etc/hosts
echo "
nameserver 114.114.114.114
nameserver 8.8.8.8
nameserver 8.8.4.4
" >$linux/etc/resolv.conf

clear
cp init.sh $linux/boot/init.sh
chown root:root $linux/boot/init.sh
chmod 777 $linux/boot/init.sh

clear
chroot $linux /boot/init.sh
for pid in `lsof | grep $linux | sed -e's/  / /g' | cut -d' ' -f2`; do kill -9 $pid >/dev/null 2>&1; done
./umount.sh
exit