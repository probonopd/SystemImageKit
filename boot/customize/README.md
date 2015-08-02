An easy way to create ExtensionImages (using Ubuntu as an example)
sed -i -e 's| universe| universe multiverse|g' /etc/apt/sources.list
sudo apt-get update
sudo apt-get install squashfs-tools

sudo mkdir -p /cow/work /cow/upper

sudo mount -t overlay overlay -olowerdir=/rofs,upperdir=/cow/upper,workdir=/cow/work /cow/work/

sudo mount -o bind /dev/ /cow/work/dev/
sudo mount -o bind /sys/ /cow/work/sys/
sudo mount -o bind /proc/ /cow/work/proc/
sudo mount -o bind /run/ /cow/work/run/

sudo chroot /cow/work/

sudo apt-get install flashplugin-installer
sudo apt-get clean
exit

sudo rm -rf  /cow/upper/var/ /cow/upper/etc/apt /cow/upper/usr/lib/python2.7/
mksquashfs /cow/upper/ Flash.ExtensionImage
