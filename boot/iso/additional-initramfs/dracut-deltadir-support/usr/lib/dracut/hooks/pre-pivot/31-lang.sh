#!/bin/sh

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
