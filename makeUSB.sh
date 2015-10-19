#!/bin/bash

#check if user is root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

release="2014.11"
case "$1" in
        small32)
            url="http://download.grml.org/grml32-small_${release}.iso"
            ;;

        full32)
            url="http://download.grml.org/grml32-full_${release}.iso"
            ;;

        small64)
            url="http://download.grml.org/grml64-small_${release}.iso"
            ;;
        full64)
            url="http://download.grml.org/grml64-full_${release}.iso"
            ;;
        *)
            echo $"Usage: $0 {small32|full32|small64|full64}"
            exit 1

esac

#get tools
if [ ! -f "/usr/lib/syslinux/mbr/mbr.bin" ]
then
  echo "Installing needed packages..."
  apt-get install live-boot live-boot-initramfs-tools extlinux
  update-initramfs -u
fi

echo "Where is the drive mounted?"
echo "Example /mnt"
read TARGET

if [ TARGET = "" ]
then
    echo "A Mounted Location is Required"
    exit 1
fi

#variables
ISO="/tmp/grml.iso"
mnt=/tmp/mnt

echo "Which Device do you want to install to?"
echo "Example: /dev/sdb"
read dev

if [ dev = "" ]
then
  echo "A Device is needed"
  exit 1
fi


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
