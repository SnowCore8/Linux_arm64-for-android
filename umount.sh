#!/bin/sh
linux=/data/linux/linux
umount $linux/dev/pts
umount $linux/dev
umount $linux/proc
umount $linux/sys