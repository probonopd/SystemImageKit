#!/bin/sh

# Recursively link files into to the root of the live system
# Example:
# rd.live.deltadir=/run/initramfs/isoscan/boot/deltadir
# would recursively symlink the contents of /boot/deltadir
# on the partition on which the ISO is located
# into / of the live system
# (also known as /sysroot or $NEWROOT at runtime)

DELTADIR=$(getarg rd.live.deltadir=)

if [ "$DELTADIR" == "" ] ; then
  echo "No deltadir specified"
  echo "Example: rd.live.deltadir=/run/initramfs/isoscan/boot/deltadir"
else
  cp -rsf "${DELTADIR}"/* "${NEWROOT}"/
fi
