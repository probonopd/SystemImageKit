#!/bin/bash

# TODO
# Language, keyboard

# Successfully detects
# openSUSE-Tumbleweed-GNOME-Live-i686-Snapshot20151012-Media.iso

detect_kiwi() {

HERE=$(dirname $(readlink -f $0))

MOUNTPOINT="$1"

#
# Make sure this ISO is one that this script understands - otherwise return asap
#

find "$MOUNTPOINT"/config.isoclient 2>/dev/null || return
find "$MOUNTPOINT"/syslinux.cfg 2>/dev/null || return

#
# Parse the required information out of the ISO
#

LIVETOOL="kiwi"
# LIVETOOLVERSION=1
LIVETOOLVERSION=$(ls "$MOUNTPOINT"/*read-only* | rev | cut -d - -f 1 | rev )

CFG="$MOUNTPOINT"/syslinux.cfg

LINUX=$(cat $CFG | grep "kernel" | head -n 1 | sed -e 's|kernel ||g' | xargs)
LINUX="/"$LINUX
echo "* LINUX $LINUX"

INITRD=$(cat $CFG | grep -o "initrd=.*initrd" | head -n 1 | sed -e 's|initrd=|/|g')
echo "* INITRD $INITRD"

APPEND=$(cat $CFG | grep "append" | head -n 1 | sed -e 's|append ||g' | xargs)
SEARCH=$(echo $INITRD | cut -c 2-)
APPEND=$(echo $APPEND | sed -e 's|initrd=||g')
APPEND=$(echo $APPEND | sed -e 's|'$SEARCH' ||g')
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
