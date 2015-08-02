#!/bin/bash

# TODO
# Language, keyboard

# Successfully detects
# openSUSE-Tumbleweed-GNOME-Live-x86_64-Snapshot20150728-Media.iso

detect_kiwi() {

HERE=$(dirname $(readlink -f $0))

MOUNTPOINT="$1"

#
# Make sure this ISO is one that this script understands - otherwise return asap
#

find "$MOUNTPOINT"/config.isoclient 2>/dev/null || return
find "$MOUNTPOINT"/boot/grub2/grub.cfg 2>/dev/null || return

#
# Parse the required information out of the ISO
#

LIVETOOL="kiwi"
LIVETOOLVERSION=1

CFG="$MOUNTPOINT"/boot/grub2/grub.cfg

LINUX=$(cat $CFG | grep "\$linux" | head -n 1 | sed -e 's|\$linux ||g' | xargs)
echo "* LINUX $LINUX"

INITRD=$(cat $CFG | grep "\$initrd" | head -n 1 | sed -e 's|\$initrd ||g' | xargs)
echo "* INITRD $INITRD"

APPEND="ramdisk_size=512000 ramdisk_blocksize=4096 quiet splash" # FIXME: Parse out of the file on the ISO
echo "* APPEND $APPEND" # TODO: Remove extraneous initrd (first argument)

#
# Put together a grub entry
#

read -r -d '' GRUBENTRY << EOM

menuentry "$ISONAME - $LIVETOOL $LIVETOOLVERSION" --class opensuse --class os {
        iso_path="/boot/iso/$ISONAME"
        search --no-floppy --file \${iso_path} --set
        live_args="for-kiwi --> isofrom_device=/dev/disk/by-uuid/$UUID isofrom_system=\${iso_path} lang=$LOCALE max_loop=256"
        custom_args="init=/isofrom/boot/customize/init"
        iso_args="$APPEND"
        loopback loop \${iso_path}
        linux (loop)$LINUX \${live_args} \${custom_args} \${iso_args}
        initrd (loop)$INITRD /boot/iso/additional-initramfs/initramfs
}
EOM

}
