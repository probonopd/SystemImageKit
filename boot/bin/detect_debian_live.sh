#!/bin/bash

# TODO
# Use grub class to show debian icon

# Successfully detects
# kali-linux-1.0.7-i386.iso - live-boot 3.0.1-1kali1
# kali-linux-2.0-amd64.iso - live-boot 4.0.2-1
# debian-live-7.5.0-i386-gnome-desktop.iso - live-boot 3.0.1-1
# debian-live-7.5-i386-gnome-desktop+nonfree.iso - live-boot 3.0.1-1
# debian_7.0.0_wheezy_i386_20130705_binary.hybrid.iso - live-boot 3.0.1-1
# debian-live-8.0.0-amd64-xfce-desktop+nonfree.iso - live-boot 4.0.2-1
# tails-i386-1.5.iso
# tanglu-3.0-gnome-live-amd64.hybrid.iso

detect_debian_live() {

HERE=$(dirname $(readlink -f $0))

MOUNTPOINT="$1"

#
# Make sure this ISO is one that this script understands - otherwise return asap
#

find "$MOUNTPOINT"/live/filesystem.squashfs 2>/dev/null || return
find "$MOUNTPOINT"/.disk/cd_type 2>/dev/null || return

#
# Parse the required information out of the ISO
#

mount "$MOUNTPOINT"/live/filesystem.squashfs "$MOUNTPOINT" -o loop,ro

if [ -f "$MOUNTPOINT"/usr/share/doc/live-boot/changelog.Debian.gz ] ; then
  LIVETOOL=$(zcat "$MOUNTPOINT"/usr/share/doc/live-boot/changelog.Debian.gz | head -n 1 | cut -d ";" -f 1 | xargs | cut -d " " -f 1)
  echo "* LIVETOOL $LIVETOOL"
  LIVETOOLVERSION=$(zcat "$MOUNTPOINT"/usr/share/doc/live-boot/changelog.Debian.gz | head -n 1 | cut -d "(" -f 2 | cut -d ")" -f 1)
  echo "* LIVETOOLVERSION $LIVETOOLVERSION"
else
  LIVETOOL="debian-live"
  echo "* LIVETOOL $LIVETOOL"
  LIVETOOLVERSION=0
  echo "* LIVETOOLVERSION $LIVETOOLVERSION"
fi

umount "$MOUNTPOINT"

CFG=$(find "$MOUNTPOINT" -name live.cfg | head -n 1)

LINUX=$(cat $CFG | grep "linux " | head -n 1 | sed -e 's|linux ||g' | xargs)
if [ "$LINUX" == "" ] ; then
  LINUX=$(cat $CFG | grep "kernel " | head -n 1 | sed -e 's|kernel ||g' | xargs) # tails-i386-1.5.iso
fi
echo "* LINUX $LINUX"

INITRD=$(cat $CFG | grep "initrd " | head -n 1 | sed -e 's|initrd ||g' | xargs)
if [ "$INITRD" == "" ] ; then
  INITRD=$(cat $CFG | grep "initrd=" | head -n 1  | cut -d = -f 2 | cut -d " " -f 1) # tails-i386-1.5.iso
fi
echo "* INITRD $INITRD"

APPEND=$(cat $CFG | grep "append " | head -n 1 | sed -e 's|append ||g' | xargs | sed -e 's|initrd='$INITRD' ||g') # sed is for tails-i386-1.5.iso
echo "* APPEND $APPEND"

#
# Put together a grub entry
#

read -r -d '' GRUBENTRY << EOM

menuentry "$ISONAME - $LIVETOOL $LIVETOOLVERSION" --class debian {
        iso_path="/boot/iso/$ISONAME"
        search --no-floppy --file \${iso_path} --set
        live_args="for-debian-live-3 --> findiso=\${iso_path} live-config.keyboard-layouts=$KEYBOARD live-config.locales=$LOCALE live-config.timezone=$TIMEZONE live-config.username=$USERNAME live-config.hostname=$HOSTNAME init=/lib/live/mount/findiso/boot/customize/init max_loop=256"
        custom_args=""
        iso_args="$APPEND"
        loopback loop \${iso_path}
        linux (loop)$LINUX \${live_args} \${custom_args} \${iso_args}
        initrd (loop)$INITRD /boot/iso/additional-initramfs/initramfs
}
EOM

}
