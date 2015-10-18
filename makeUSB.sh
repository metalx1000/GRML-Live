#!/bin/bash

#check if user is root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

#variables
url="http://download.grml.org/grml32-small_2014.11.iso"
ISO="/tmp/grml.iso"
TARGET="/mnt"
mnt=/tmp/mnt

echo "Which Device do you want to install to?"
echo "Example: /dev/sdb"
read dev

#get tools
apt-get install live-boot live-boot-initramfs-tools extlinux
update-initramfs -u

#get ISO
wget -c "$url" -O "$ISO"
mkdir "$mnt"
mount "$ISO" "$mnt"

mkdir -p ${TARGET}/boot/extlinux ${TARGET}/live
extlinux -i ${TARGET}/boot/extlinux
dd if=/usr/lib/syslinux/mbr/mbr.bin of=$dev #X is the drive letter

cp -v $mnt/boot/grml32small/vmlinuz ${TARGET}/boot/vmlinuz
cp -v $mnt/boot/grml32small/initrd.img ${TARGET}/boot/initrd
cp -v $mnt/live/grml32-small/grml32-small.squashfs ${TARGET}/live
umount $mnt

cp extlinux.conf ${TARGET}/boot/extlinux/extlinux.conf

echo 'Complete!!!' 
