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
echo "\
#!/bin/bash
export PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export SHELL=/bin/bash
export HOME=/root
export TERM=linux
apt-get update && apt-get upgrade && apt-get clean
apt-get install language-pack-zh-hans  language-pack-zh-hans-base -y
apt-get install xfonts-intl-chinese ttf-wqy-microhei ttf-wqy-zenhei  xfonts-wqy -y
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
" >linux/boot/init.sh

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