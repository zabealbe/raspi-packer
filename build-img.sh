#!/bin/sh -ex
losetup /dev/loop0 && exit 1 || true
image=arch-linux.img
wget -q -N http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-3-latest.tar.gz
truncate -s 1G $image
losetup /dev/loop0 $image
parted -s /dev/loop0 mklabel msdos
parted -s /dev/loop0 unit s mkpart primary fat32 -- 1 65535
parted -s /dev/loop0 set 1 boot on
parted -s /dev/loop0 unit s mkpart primary ext2 -- 65536 -1
parted -s /dev/loop0 print
mkfs.vfat -I -n SYSTEM /dev/loop0p1
mkfs.ext4 -F -L root -b 4096 -E stride=4,stripe_width=1024 /dev/loop0p2
mkdir -p root
mount /dev/loop0p2 root
bsdtar xfz ArchLinuxARM-rpi-2-latest.tar.gz -C root
mv root/boot root/boot-temp
mkdir -p root/boot
mount /dev/loop0p1 root/boot
mv root/boot-temp/* root/boot/
rm -rf root/boot-temp
sed -i "s/ defaults / defaults,noatime /" root/etc/fstab
umount root/boot root
losetup -d /dev/loop0

# Take from https://gist.github.com/larsch/4ae5499023a3c5e22552
