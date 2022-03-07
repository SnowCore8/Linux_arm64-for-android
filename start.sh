#!/bin/sh
linux=/data/linux/linux

clear
[ ! -d $linux/dev ] && mkdir -p $linux/dev
[ ! -d $linux/dev/shm ] && mkdir -p $linux/dev/shm
[ ! -d $linux/dev/pts ] && mkdir -p $linux/dev/pts
[ ! -d $linux/proc ] && mkdir -p $linux/proc
[ ! -d $linux/sys ] && mkdir -p $linux/sys

clear
./mount.sh

clear
cp /etc/hosts $linux/etc/hosts
cp /etc/resolv.conf $linux/etc/resolv.conf

clear
cp init.sh $linux/boot/init.sh
chown root:root $linux/boot/init.sh
chmod 777 $linux/boot/init.sh

clear
chroot $linux /boot/init.sh
for pid in `lsof | grep $linux | sed -e's/  / /g' | cut -d' ' -f2`; do kill -9 $pid >/dev/null 2>&1; done
./umount.sh
exit