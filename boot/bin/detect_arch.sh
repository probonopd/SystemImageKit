#!/bin/bash

# TODO
# Disable /etc/xdg/autostart/cnchi.desktop nag screen
# Set hostname etc.

# Successfully detects
# antergos-2014.08.07-x86_64.iso
# archlinux-2015.06.01-dual.iso

detect_arch() {

HERE=$(dirname $(readlink -f $0))

MOUNTPOINT="$1"

#
# Make sure this ISO is one that this script understands - otherwise return asap
#

find "$MOUNTPOINT"/arch/boot -name archiso.img 2>/dev/null || return
find "$MOUNTPOINT"/arch/ -name *.sfs 2>/dev/null || return

#
# Parse the required information out of the ISO
#

# mount "$MOUNTPOINT"/arch/root-image.sfs "$MOUNTPOINT" -o loop,ro
# mount "$MOUNTPOINT"/root-image.img "$MOUNTPOINT" -o loop,ro


# if [ -f "$MOUNTPOINT"/usr/share/doc/live-boot/changelog.Debian.gz ] ; then
#   LIVETOOL=$(zcat "$MOUNTPOINT"/usr/share/doc/live-boot/changelog.Debian.gz | head -n 1 | cut -d ";" -f 1 | xargs | cut -d " " -f 1)
#   echo "* LIVETOOL $LIVETOOL"
#   LIVETOOLVERSION=$(zcat "$MOUNTPOINT"/usr/share/doc/live-boot/changelog.Debian.gz | head -n 1 | cut -d "(" -f 2 | cut -d ")" -f 1)
#   echo "* LIVETOOLVERSION $LIVETOOLVERSION"
# fi

# umount "$MOUNTPOINT"
# umount "$MOUNTPOINT"

LIVETOOL=archiso
LIVETOOLVERSION=0

CFG=$(find "$MOUNTPOINT"/loader/entries/archiso-*.conf | head -n 1)

LINUX=$(cat $CFG | grep "linux " | head -n 1 | sed -e 's|linux ||g' | xargs)
echo "* LINUX $LINUX"

INITRD=$(cat $CFG | grep "archiso.img" | head -n 1 | sed -e 's|initrd ||g' | xargs)
echo "* INITRD $INITRD"

APPEND=$(cat $CFG | grep "options " | head -n 1 | sed -e 's|options ||g' | xargs)
echo "* APPEND $APPEND"

#
# Put together a grub entry
#

read -r -d '' GRUBENTRY << EOM

menuentry "$ISONAME - $LIVETOOL $LIVETOOLVERSION" --class arch {
        iso_path="/boot/iso/$ISONAME"
        search --no-floppy --file \${iso_path} --set
        live_args="for-arch --> img_loop=\${iso_path} img_dev=/dev/disk/by-uuid/$UUID layout=$KEYBOARD keytable=$KEYBOARD lang=$LOCALE_NODOT"
        custom_args=""
        iso_args="$APPEND"
        loopback loop \${iso_path}
        linux (loop)$LINUX \${live_args} \${custom_args} \${iso_args}
        initrd (loop)$INITRD /boot/iso/additional-initramfs/initramfs
}
EOM

}
