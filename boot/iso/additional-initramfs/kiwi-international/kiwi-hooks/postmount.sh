#!/bin/sh

touch /mnt/.kiwiPostmountRan

# Set keyboard and language according to
# https://github.com/openSUSE/kiwi/issues/355

sed -i -e 's|RC_LANG=\"\"|RC_LANG=\"de_DE.UTF-8\"|g' \
/mnt/etc/sysconfig/language

sed -i -e 's|ROOT_USES_LANG=\"ctype\"|ROOT_USES_LANG=\"yes\"|g' \
/mnt/etc/sysconfig/language

sed -i -e 's|KEYTABLE=\"us.map.gz\"|KEYTABLE=\"de-latin1-nodeadkeys\"|g' \
/mnt/etc/sysconfig/keyboard

# http://www.freedesktop.org/software/systemd/man/locale.conf.html
# The /etc/locale.conf file configures system-wide locale settings. 
# It is read at early-boot by systemd(1).
# But seemingly this does not impact GNOME on openSUSE.
# cat > /mnt/etc/locale.conf <<EOF
# LANG=de_DE.UTF-8
# EOF
