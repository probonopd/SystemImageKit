#!/bin/bash

# Successfully detects
# ubuntu-14.04.1-desktop-amd64.iso
# ubuntu-gnome-15.04-desktop-amd64.iso
# xubuntu-15.10-core-amd64.i

detect_casper() {

HERE=$(dirname $(readlink -f $0))

MOUNTPOINT="$1"

#
# Make sure this ISO is one that this script understands - otherwise return asap
#

find "$MOUNTPOINT"/casper 2>/dev/null || return
ls "$MOUNTPOINT"/boot/grub/loopback.cfg 2>/dev/null || return

#
# Parse the required information out of the ISO
#

LIVETOOL="casper"
LIVETOOLVERSION=$(grep -e "^casper" "$MOUNTPOINT"/casper/filesystem.manifest | head -n 1 | awk '{ print $2; }')

# The following is needed for xubuntu-15.10-core-amd64.iso
if [ "x$LIVETOOLVERSION" == "x" ] ; then
  LIVETOOLVERSION=0
fi

CFG=$(find "$MOUNTPOINT" -name loopback.cfg | head -n 1)

LINUX=$(cat $CFG | grep "linux" | head -n 1 | sed -e 's|linux\t||g' | xargs)
echo "* LINUX $LINUX"

INITRD=$(cat $CFG | grep "initrd" | head -n 1 | sed -e 's|initrd\t||g' | xargs)
echo "* INITRD $INITRD"

APPEND=" " # Don't use this because it's already in the LINUX line

#
# Put together a grub entry
#

read -r -d '' GRUBENTRY << EOM

menuentry "$ISONAME - $LIVETOOL $LIVETOOLVERSION" --class ubuntu {
        iso_path="/boot/iso/$ISONAME"
        search --no-floppy --file \${iso_path} --set
        live_args="for-casper --> iso-scan/filename=\${iso_path} console-setup/layoutcode=$KEYBOARD locale=$LANGUAGE timezone=$TIMEZONE username=$USERNAME hostname=$HOSTNAME noprompt init=/isodevice/boot/customize/init max_loop=256"
        custom_args=""
        iso_args="$APPEND"
        loopback loop \${iso_path}
        linux (loop)$LINUX \${live_args} \${custom_args} \${iso_args}
        initrd (loop)$INITRD /boot/iso/additional-initramfs/initramfs
}
EOM

}
