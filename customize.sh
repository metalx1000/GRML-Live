#!/bin/bash

#check if user is root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

workfs="/tmp/grmlfs"
tmpmnt="/tmp/fsmnt"

echo "Which Squashfs file?"
mount |grep vfat|awk '{print $3}'|while read line;do find $line -maxdepth 2 -iname "*.squashfs";done
read squashfs

if [ ! -f "$squashfs" ]
then
  echo "$squashfs does not exist.\nExiting..."
  exit 1
fi

if [ -d "$workfs" ]
then
  echo "Directory ${workfs}. Use it?"
  read use
  if [ $use != "y" ]
  then
    echo "Exiting..."
    exit 1
  fi
else
  mkdir -p "$workfs"
  mkdir -p "$tmpmnt"
  mount "$squashfs" "$tmpmnt"
  cp -vr "$tmpmnt/*" "$workfs/"
  umount "$squashfs"
  rm $workfs/etc/resolv.conf
  echo nameserver 8.8.8.8 > $workfs/etc/resolv.conf
fi

mount --bind /dev $workfs/dev
mount -t devpts devpts $workfs/dev/pts
mount -t proc proc $workfs/proc
mount -t sysfs sysfs $workfs/sys

echo "Entering Chroot"
chroot $workfs zsh

umount $workfs/dev $workfs/dev/pts $workfs/proc $workfs/sys

rm $squashfs
mksquashfs "$workfs" $squashfs

echo 'Complete!!!'
