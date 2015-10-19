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
            type="32small"
            type2="32-small"
            ;;

        full32)
            url="http://download.grml.org/grml32-full_${release}.iso"
            type="32full"
            type2="32-full"
            ;;

        small64)
            url="http://download.grml.org/grml64-small_${release}.iso"
            type="64small"
            type2="64-small"
            ;;
        full64)
            url="http://download.grml.org/grml64-full_${release}.iso"
            type="64full"
            type2="64-full"
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

echo "Possible Devices:"
mount |grep vfat|awk '{print $1 " " $3}'

echo "Where is the drive mounted?"
echo "Example /mnt"
read TARGET

if [ $TARGET = "" ]
then
    echo "A Mounted Location is Required"
    exit 1
fi

#variables
ISO="/tmp/grml${type2}_${release}.iso"
mnt=/tmp/mnt

dev="$(mount|grep "/media/metalx1000/B531-EB29"|awk '{print $1}')"
dev=${dev::-1}
echo "Is this the correct device? (y/n)"
echo $dev
read devq

if [ $devq != "y" ]
then
  echo "Wrong device\nExiting"
  exit 1
fi

if [ $dev = "" ]
then
  echo "A Device is needed"
  exit 1
fi


#get ISO
wget -c "$url" -O "$ISO"
rm -fr "$mnt"
mkdir "$mnt"
mount "$ISO" "$mnt"

mkdir -p ${TARGET}/boot/extlinux ${TARGET}/live
extlinux -i ${TARGET}/boot/extlinux
dd if=/usr/lib/syslinux/mbr/mbr.bin of=$dev #X is the drive letter

cp -v $mnt/boot/grml${type}/vmlinuz ${TARGET}/boot/vmlinuz
cp -v $mnt/boot/grml${type}/initrd.img ${TARGET}/boot/initrd
cp -v $mnt/live/grml${type2}/*.squashfs ${TARGET}/live
umount "$ISO"

cp extlinux.conf ${TARGET}/boot/extlinux/extlinux.conf

echo 'Complete!!!' 
