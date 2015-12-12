#!/bin/bash

# TODO
# Don't show the finish-install nag screen, set language and keyboard, run customize/init

# Successfully detects
# Mageia-5-LiveDVD-GNOME-x86_64-DVD.iso

detect_mageia() {

HERE=$(dirname $(readlink -f $0))

MOUNTPOINT="$1"

#
# Make sure this ISO is one that this script understands - otherwise return asap
#

find "$MOUNTPOINT"/loopbacks/distrib-lzma.sqfs 2>/dev/null || return

#
# Parse the required information out of the ISO
#

LIVETOOL="mgalive"
LIVETOOLVERSION=1

CFG=$(find "$MOUNTPOINT" -name isolinux.cfg | head -n 1)

LINUX=$(cat $CFG | grep "kernel " | head -n 1 | sed -e 's|kernel ||g' | xargs)
if [[ $LINUX != *"/"* ]] ; then
  LINUX=$(find "$MOUNTPOINT" -name "$LINUX" | sed -e "s|$MOUNTPOINT||g" ) # Need to get full path
fi
echo "* LINUX $LINUX"

INITRD=$(cat $CFG | grep "append " | head -n 1 | cut -d = -f 2 | cut -d " " -f 1 | xargs)
if [[ $INITRD != *"/"* ]] ; then
  INITRD=$(find "$MOUNTPOINT" -name "$INITRD" | sed -e "s|$MOUNTPOINT||g" ) # Need to get full path
fi
echo "* INITRD $INITRD"

APPEND=$(cat $CFG | grep "append " | head -n 1 | sed -e 's|append ||g' | sed -e 's|initrd=/boot/cdrom/initrd.gz ||g' | xargs)
echo "* APPEND $APPEND"

#
# Put together a grub entry
#

read -r -d '' GRUBENTRY << EOM

menuentry "$ISONAME - $LIVETOOL $LIVETOOLVERSION" --class mageia {
        iso_path="/boot/iso/$ISONAME"
        search --no-floppy --file \${iso_path} --set
        live_args="for-dracut --> isofrom=/dev/disk/by-uuid/$UUID:\${iso_path} selinux=0 rd.live.deltadir=/run/initramfs/isoscan/boot/deltadir rd.live.user=$USERNAME rd.live.host=$HOSTNAME lang=$KEYBOARD"
        custom_args=""
        iso_args="$APPEND"
        loopback loop \${iso_path}
        linux (loop)$LINUX \${live_args} \${custom_args} \${iso_args}
        initrd (loop)$INITRD /boot/iso/additional-initramfs/initramfs
}
EOM

}
