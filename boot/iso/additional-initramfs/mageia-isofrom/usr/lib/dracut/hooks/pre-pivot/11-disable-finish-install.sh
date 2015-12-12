# For Mageia 5
# Boot straight into the Live system without showing a nag screen
# The below does work, but as Mageia does not pick up the correct language yet
# it is temporarily disabled

# if [ -e $NEWROOT/etc/mageia-release ] ; then
# mkdir -p $NEWROOT/etc/sysconfig/
# cat > $NEWROOT/etc/sysconfig/finish-install <<EOF
# FINISH_INSTALL=no
# EOF
# fi
