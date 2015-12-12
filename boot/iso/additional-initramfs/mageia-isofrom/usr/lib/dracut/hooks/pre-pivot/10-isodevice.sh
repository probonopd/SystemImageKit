# For Mageia 5
# We want to be able to access the device on which the ISO resides
# from the booted system
if [ -e /live/isomount ] ; then
  mkdir -p $NEWROOT/isodevice
  mount --move /live/isomount $NEWROOT/isodevice
fi
