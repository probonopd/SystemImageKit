#!/bin/bash

# TODO
# ...

# Successfully detects
# Fedora-Live-Desktop-i686-20-1.iso
# Fedora-Live-Xfce-i686-20-1.iso
# Fedora-Live-Workstation-i686-rawhide-20140531.iso
# CentOS-6.5-i386-LiveCD.iso
# Fedora-Live-Security-i686-20-1.iso
# Fedora-Live-Design-suite-i686-20-1.iso
# Fedora-Live-Scientific-KDE-i686-20-1.iso
# CentOS-6.4-i386-LiveDVD.iso
# Fedora-Live-Desktop-i686-19-1.iso
# CentOS-7.0-1406-x86_64-GnomeLive.iso

detect_dracut() {

HERE=$(dirname $(readlink -f $0))

MOUNTPOINT="$1"

#
# Make sure this ISO is one that this script understands - otherwise return asap
#
ls /opt/LiveOS
find "$MOUNTPOINT"/LiveOS/squashfs.img 2>/dev/null || return

#
# Parse the required information out of the ISO
#

LIVETOOL="dracut"
LIVETOOLVERSION=1
mount "$MOUNTPOINT"/LiveOS/squashfs.img "$MOUNTPOINT" -o loop
if [ -e "$MOUNTPOINT"/LiveOS/ext3fs.img ] ; then
  mount "$MOUNTPOINT"/LiveOS/ext3fs.img "$MOUNTPOINT" -o loop
  LIVETOOLVERSION=$(find "$MOUNTPOINT"/var/lib/yum/yumdb/ -name *dracut-0* | grep -o -e dracut.*$ | sed -e 's|dracut-||g')
  # . "$MOUNTPOINT"/lib/dracut/dracut-version.sh # conveniently sets DRACUT_VERSION but does not exist in CentOS 6.4
  umount "$MOUNTPOINT"
fi
umount "$MOUNTPOINT"


CFG=$(find "$MOUNTPOINT" -name isolinux.cfg | head -n 1)

LINUX=$(cat $CFG | grep "kernel " | head -n 1 | sed -e 's|kernel ||g' | xargs)
LINUX=$(find "$MOUNTPOINT" -name "$LINUX" | sed -e "s|$MOUNTPOINT||g" ) # Need to get full path
echo "* LINUX $LINUX"

INITRD=$(cat $CFG | grep "append " | head -n 1 | cut -d = -f 2 | cut -d " " -f 1 | xargs)
INITRD=$(find "$MOUNTPOINT" -name "$INITRD" | sed -e "s|$MOUNTPOINT||g" ) # Need to get full path
echo "* INITRD $INITRD"

APPEND=$(cat $CFG | grep "append " | head -n 1 | sed -e 's|append ||g' | xargs)
echo "* APPEND $APPEND" # TODO: Remove extraneous initrd (first argument)

#
# Put together a grub entry
#

read -r -d '' GRUBENTRY << EOM

menuentry "$ISONAME - $LIVETOOL $LIVETOOLVERSION" --class fedora {
        iso_path="/boot/iso/$ISONAME"
        search --no-floppy --file \${iso_path} --set
        live_args="for-dracut --> iso-scan/filename=\${iso_path} selinux=0 rd.live.deltadir=/run/initramfs/isoscan/boot/deltadir vconsole.keymap=$KEYBOARD locale.LANG=$LANGUAGE"
        custom_args=""
        iso_args="$APPEND"
        loopback loop \${iso_path}
        linux (loop)$LINUX \${live_args} \${custom_args} \${iso_args}
        initrd (loop)$INITRD /boot/iso/additional-initramfs/initramfs
}
EOM

}
