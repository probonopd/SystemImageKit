Install
-------

Boot Ubuntu Live system (tested with Ubuntu 14.04 LTS Trusty Tahr) and run the following steps.
NOTE: All data on /dev/sdX will be deleted.

```
sudo su

umount /dev/sdX*

# Make one partition
sfdisk --in-order -L -uS /dev/sdX <<-EOF
63,,c
;
;
EOF

# Make first partition bootable
sfdisk -A /dev/sdX 1

# Format
mkfs.vfat /dev/sdX1

# Mount
mount /dev/sdX1 /mnt/

# Install SystemImageKit
apt-get -y install git
git clone https://github.com/probonopd/SystemImageKit.git /mnt

# Install bootloader for PC
# Tested with grub-install (GRUB) 2.02~beta2-9 from Ubuntu 14.04 LTS Trusty Tahr
# and with grub2-install (GRUB) 2.02~beta2 from Fedora 22 (Rawhide)
grub-install --boot-directory=/mnt/boot/ /dev/sdX # Ubuntu
grub2-install --boot-directory=/mnt/boot/ /dev/sdX # Fedora

# Install bootloader for Mac
sudo apt-get -y install grub-efi-amd64
mkdir /mnt/boot/efi
sudo grub-install --target=x86_64-efi --efi-directory=/mnt/boot/EFI --boot-directory=/mnt/boot/ /dev/sdX1
mkdir -p /mnt/EFI/BOOT
mv /mnt/boot/EFI/BOOT/grubx64.efi /mnt/EFI/BOOT/bootx64.efi

# Download Ubuntu ISO
wget -c "http://releases.ubuntu.com/14.04.1/ubuntu-14.04.1-desktop-amd64.iso" -O /mnt/boot/iso/ubuntu-14.04.1-desktop-amd64.iso

# Configure bootloader
/mnt/boot/42_liveiso > /mnt/boot/gru*/grub.cfg

# Create and install an ExtensionImage for Adobe Flash Player (just as an example)
bash /mnt/boot/bin/generate-flash-extension

# Create and install an ExtensionImage for Broadcom WLAN firmware
bash /mnt/boot/bin/generate-b43firmware-extension

umount /mnt

# The disk should now be bootable

```

If you format the device manually and run into "error: will not proceed with blocklists", then use gparted to move the start of the first partition up 1MB. This works without having to reformat the device.

We need to do this only once.
Whenever we add additional ISOs, we just have to re-run (the example is for a running Ubuntu Live system):

```
sudo su
/isodevice/boot/42_liveiso > /isodevice/boot/grub/grub.cfg
```
