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
# Solus-RC1.iso

detect_dracut() {

HERE=$(dirname $(readlink -f $0))

MOUNTPOINT="$1"

#
# Make sure this ISO is one that this script understands - otherwise return asap
#

find "$MOUNTPOINT"/LiveOS/squashfs.img 2>/dev/null || return

#
# Parse the required information out of the ISO
#

LIVETOOL="dracut"
LIVETOOLVERSION=1
mount "$MOUNTPOINT"/LiveOS/squashfs.img "$MOUNTPOINT" -o loop
if [ -e "$MOUNTPOINT"/LiveOS/ext3fs.img ] ; then
  mount "$MOUNTPOINT"/LiveOS/ext3fs.img "$MOUNTPOINT" -o loop
  if [ -e "$MOUNTPOINT"/lib/dracut/dracut-version.sh ] ; then
    . "$MOUNTPOINT"/lib/dracut/dracut-version.sh # conveniently sets DRACUT_VERSION but does not exist in CentOS 6.4
    LIVETOOLVERSION=$DRACUT_VERSION # For Fedora 23
  else
    LIVETOOLVERSION=$(find "$MOUNTPOINT"/var/lib/yum/yumdb/ -name *dracut-0* | grep -o -e dracut.*$ | sed -e 's|dracut-||g')
    # yumdb is no longer there in Fedora 23
  fi
  umount "$MOUNTPOINT"
fi
umount "$MOUNTPOINT"

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

APPEND=$(cat $CFG | grep "append " | head -n 1 | sed -e 's|append ||g' | sed -e 's|initrd=initrd0.img ||g' | xargs)
echo "* APPEND $APPEND"

#
# Put together a grub entry
#

read -r -d '' GRUBENTRY << EOM

menuentry "$ISONAME - $LIVETOOL $LIVETOOLVERSION" --class fedora {
        iso_path="/boot/iso/$ISONAME"
        search --no-floppy --file \${iso_path} --set
        live_args="for-dracut --> iso-scan/filename=\${iso_path} selinux=0 rd.live.deltadir=/run/initramfs/isoscan/boot/deltadir rd.live.user=$USERNAME rd.live.host=$HOSTNAME vconsole.keymap=$KEYBOARD locale.LANG=$LOCALE max_loop=256"
        custom_args=""
        iso_args="$APPEND"
        loopback loop \${iso_path}
        linux (loop)$LINUX \${live_args} \${custom_args} \${iso_args}
        initrd (loop)$INITRD /boot/iso/additional-initramfs/initramfs
}
EOM

}
