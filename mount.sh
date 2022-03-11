#!/bin/sh
linux=/data/linux/linux
mount -o bind /dev $linux/dev
mount -o bind /dev/pts $linux/dev/pts
mount -o bind /proc $linux/proc
mount -o bind /sys $linux/sys
