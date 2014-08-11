Install
-------

Boot Ubuntu Live system and run:

```
sudo su
grub-install --boot-directory=/media/XXX/boot/ /dev/sdX
```

If you run into "error: will not proceed with blocklists", then use gparted to move the start of the first partition up 1MB. This works without having to reformat the device. Finally it should succeed:

```
grub-install --boot-directory=/media/XXX/boot/ /dev/sdX
Installation finished. No error reported.
(Tested with grub-install (GRUB) 2.02~beta2-9 from Ubuntu 14.04 LTS Trusty Tahr)

# THE FOLLOWING IS PURELY EXPERIMENTAL FOR MAC
sudo apt-get install grub-efi-amd64
sudo grub-install --target=x86_64-efi --efi-directory=/isodevice/boot/efi --boot-directory=/isodevice/boot/ /dev/sdXX
sudo mkdir -p /isodevice/EFI/BOOT
sudo mv /isodevice/boot/efi/EFI/ubuntu/grubx64.efi /isodevice/EFI/BOOT/bootx64.efi

```
We need to do this only once.

Whenever we want to add a new ISO, we need to do the following.

Next we need to write grub.conf, but we run into an error:

```
update-grub 
/usr/sbin/grub-probe: error: cannot find a device for / (is /dev mounted?).
```

We can use this workaround:

```
apt-get install curl
mv /usr/sbin/grub-probe /usr/sbin/grub-probe.orig
curl edoceo.com/pub/grub-probe.sh > /usr/sbin/grub-probe
chmod 0755 /usr/sbin/grub-probe
```

If we do not want the native OSes at all, but ONLY the ISOs, then we can use instead (with /isodevice being the path to the boot directory):
```
/isodevice/boot/42_liveiso > /isodevice/boot/grub/grub.cfg
```

Finally, let the live ISOs be recognized and a grub.cfg be generated:
```
cp 42_liveiso /etc/grub.d/
chmod a+x /etc/grub.d/42_liveiso
# We do NOT want the host live system's native entries
chmod a-x /etc/grub.d/20_memtest86+ /etc/grub.d/30_os-prober

update-grub -o /media/XXX/boot/grub/grub.cfg
```
