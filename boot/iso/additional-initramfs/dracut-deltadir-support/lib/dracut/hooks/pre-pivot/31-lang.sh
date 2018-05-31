#!/bin/sh

# Newer Dracut (e.g., on openSUSE Tubmbleweed as of 5/2018
# expects this in lib/dracut/hooks rather than
# usr/lib/dracut/hooks                

LOCALE=$(getarg locale.LANG)

if [ "$LOCALE" == "" ] ; then
  echo "No locale specified"
  echo "Example: locale.LANG=de_DE.UTF-8"
else
# Set the language
cat > "${NEWROOT}"/etc/locale.conf <<EOF
LANG=$LOCALE
LC_NUMERIC=$LOCALE
LC_TIME=$LOCALE
LC_MONETARY=$LOCALE
LC_PAPER=$LOCALE
LC_MEASUREMENT=$LOCALE
EOF
. "${NEWROOT}"/etc/locale.conf
fi
