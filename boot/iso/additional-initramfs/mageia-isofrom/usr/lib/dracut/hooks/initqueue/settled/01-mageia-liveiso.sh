#!/bin/sh

# https://forums.mageia.org/de/viewtopic.php?f=8&t=1713
# Test with
# sudo qemu-system-x86_64 -m 1024 -hda /dev/sdb -vga std -monitor stdio -enable-kvm -smp 2

echo 01-mageia-liveiso-1
sleep 1 # Needed on my system; FIXME

type getarg >/dev/null 2>&1 || . /lib/dracut-lib.sh

# isofrom="/dev/sda1:/m4.iso"
if [ -n "$isofrom" ]; then
  isomount="/live/isomount"
  isodev=$(echo "$isofrom" | sed 's,:.*$,,g')
  isofile=$(echo "$isofrom" | sed 's,^.*:,,g')
  if [ ! -z "$isodev" -a ! -z "$isofile" ]; then
    mkdir -m 0755 -p "$isomount" 
  else 
    emergency_shell -n isofrom "Break in liveiso, check isodev and isofrom "
fi

echo 01-mageia-liveiso-2
sleep 1 # Needed on my system; FIXME
  
  isodevfs=$(blkid -s TYPE -o value "$isodev")
  grep -q "$isomount" /proc/mounts || mount -n -r -t "$isodevfs" "$isodev" "$isomount"  || emergency_shell -n isofrom "Break in liveiso, mounting failed"
  
  if [ -e "${isomount}${isofile}" ]; then
    
    losetup -a | grep -q "${isomount}${isofile}"
    if [ $? -ne 0 ]; then
      losetup $(losetup -f) "${isomount}${isofile}" || emergency_shell -n isofrom "Break in liveiso, losetup failed"
    fi
  else
     emergency_shell -n isofrom "Break in liveiso, isofile does not exist" 
  fi
fi
