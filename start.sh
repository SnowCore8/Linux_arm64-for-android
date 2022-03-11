#!/bin/sh
linux=/data/linux/linux

clear
[ ! -d $linux/dev ] && mkdir -p $linux/dev
[ ! -d $linux/dev/pts ] && mkdir -p $linux/dev/pts
[ ! -d $linux/proc ] && mkdir -p $linux/proc
[ ! -d $linux/sys ] && mkdir -p $linux/sys

clear
./mount.sh
echo "\
#!/bin/bash
export PATH="/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
export ARCH="arm64"
export HOME="/root"
export TERM="linux"
apt-get update && apt-get upgrade && apt-get install -f && apt-get clean
apt-get install glibc* -y
apt-get install bison -y
apt-get install language-pack-zh-hans* -y
export LANG=zh_CN.UTF-8
export LANGUAGE=zh_CN:zh
export LC_CTYPE="zh_CN.UTF-8"
export LC_NUMERIC="zh_CN.UTF-8"
export LC_TIME="zh_CN.UTF-8"
export LC_COLLATE="zh_CN.UTF-8"
export LC_MONETARY="zh_CN.UTF-8"
export LC_MESSAGES="zh_CN.UTF-8"
export LC_PAPER="zh_CN.UTF-8"
export LC_NAME="zh_CN.UTF-8"
export LC_ADDRESS="zh_CN.UTF-8"
export LC_TELEPHONE="zh_CN.UTF-8"
export LC_MEASUREMENT="zh_CN.UTF-8"
export LC_IDENTIFICATION="zh_CN.UTF-8"
export LC_ALL=zh_CN.UTF-8
cd ~
clear
service ssh restart
bash -i
clear&&clear
service ssh stop
exit
" >linux/boot/init.sh
chown root:root $linux/boot/init.sh
chmod 777 $linux/boot/init.sh

clear
echo "localhost" > $linux/etc/hostsname
echo "127.0.0.1 localhost" > $linux/etc/hosts
echo "\
nameserver 8.8.4.4
nameserver 8.8.8.8
nameserver 180.76.76.76
nameserver 119.29.29.29
nameserver 114.114.114.114 
" >$linux/etc/resolv.conf

clear
chroot $linux /boot/init.sh
for pid in `lsof | grep $linux | sed -e's/  / /g' | cut -d' ' -f2`; do kill -9 $pid >/dev/null 2>&1; done
./umount.sh
exit