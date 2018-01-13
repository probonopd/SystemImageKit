#!/bin/bash

# Known to work with
# manjaro-xfce-17.1.1-stable-x86_64.iso

detect_loopbackcfg() {

HERE=$(dirname $(readlink -f $0))

MOUNTPOINT="$1"

#
# Make sure this ISO is one that this script understands - otherwise return asap
#

ls "$MOUNTPOINT"/boot/grub/loopback.cfg 2>/dev/null || return

echo "loopback.cfg found"

#
# Parse the required information out of the ISO
#

LIVETOOL=loopback.cfg
LIVETOOLVERSION=0
LINUX="loopback!"
INITRD="loopback!"
APPEND="loopback!"

#
# Put together a grub entry
#

read -r -d '' GRUBENTRY << EOM

menuentry "$ISONAME - $LIVETOOL $LIVETOOLVERSION" {
        iso_path="/boot/iso/$ISONAME"
        export iso_path
        search --set=root --file \$iso_path
        probe -u -s rootuuid \$root
        export rootuuid
        loopback loop \$iso_path
        root=(loop)
        configfile /boot/grub/loopback.cfg
        loopback --delete loop
}
EOM

}
