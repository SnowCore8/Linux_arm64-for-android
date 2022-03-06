#!/bin/sh
linux=/data/linux/linux
mount /dev $linux/dev
mount -t devpts devpts $linux/dev/pts
mount -t proc proc $linux/proc
mount -t sysfs sys $linux/sys
