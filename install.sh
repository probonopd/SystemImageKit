#!/bin/bash

set -e

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [ -z "$1" ] ; then
  echo "Usage: $0 /dev/sdX"
  exit 1
fi

SDX="$1" # /dev/sdX

if [ ! -e "$1" ] ; then
  echo "$1 does not exist"
fi

mntpart=$(mount | grep "$SDX" | head -n 1 | cut -d " " -f 3)
if [ "" != "$mntpart" ] ; then
  if [ ! -e "$mntpart" ] ; then
    echo "$mntpart does not exist"
  fi
  echo "$SDX is mounted to $mntpart and currently contains:"
  ls "$mntpart"
fi

echo "Format this disk and install SystemImageKit?"

echo "Everything on all partitions of this disk will be deleted!"

read -p "Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 0
fi

read -p "Are you really sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 0
fi

echo "Continuing..."

# On the desktop, stop automatic mounting of disks
systemctl stop udisks2.service

umount $SDX* || true

# Make one partition
echo 'start=2048, type=0b' | sfdisk $SDX

# Make first partition bootable
sfdisk -A $SDX 1
sleep 1

# Format
mkfs.vfat "$SDX"1

# Mount
mount "$SDX"1 /mnt/

# Install SystemImageKit
apt-get -y install git
git clone https://github.com/probonopd/SystemImageKit.git /mnt

# Clear the gap between the boot sector and the first partition
# to prevent from GRUB having issues being installed
dd if=/dev/zero of=$SDX seek=1 count=2047

# Install bootloader for PC
# Tested with grub-install (GRUB) 2.02~beta2-9 from Ubuntu 14.04 LTS Trusty Tahr
# and with grub2-install (GRUB) 2.02~beta2 from Fedora 22 (Rawhide)
grub-install --boot-directory=/mnt/boot/ $SDX || true # Ubuntu
grub2-install --boot-directory=/mnt/boot/ $SDX || true # Fedora

# Install bootloader for Mac
apt-get -y install grub-efi-amd64
mkdir -p /mnt/boot/efi
sudo grub-install --target=x86_64-efi --efi-directory=/mnt/boot/EFI --boot-directory=/mnt/boot/ "$SDX"1 || true
mkdir -p /mnt/EFI/BOOT
find /mnt/boot/ -name grubx64.efi -exec cp {} /mnt/EFI/BOOT/bootx64.efi \;

# Generate additional initrd (gets loaded in addition to the one on the ISO)
/mnt/boot/iso/additional-initramfs/generate

# Download Ubuntu ISO

if [ -e "/isodevice/boot/iso/xubuntu-18.04-desktop-amd64.iso" ] ; then
  cp "/isodevice/boot/iso/xubuntu-18.04-desktop-amd64.iso" /mnt/boot/iso/
else
  wget -c "http://cdimage.ubuntu.com/xubuntu/releases/18.04/release/xubuntu-18.04-desktop-amd64.iso" -O /mnt/boot/iso/xubuntu-18.04-desktop-amd64.iso
fi

# Configure bootloader
/mnt/boot/bin/detect

# Create and install ExtensionImages, e.g., for Adobe Flash Player and proprietary firmware
bash /mnt/boot/bin/generate-appimaged-extension
bash /mnt/boot/bin/generate-b43firmware-extension
bash /mnt/boot/bin/generate-dymo-extension
umount /mnt

# The disk should now be bootable

# On the desktop, stop automatic mounting of disks
systemctl start udisks2.service
