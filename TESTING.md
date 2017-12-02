# Testing

Flash BootImage.img to a USB stick, `/dev/sdc` in the example below.

## Mac

### BIOS emulation ("Windows") on Mac

```
This is not a bootable disk.  Please insert a bootable floppy and
press any key to try again ... 
```

Reason unknown.

### EFI on Mac

Works.

## QEMU

### BIOS on QEMU

```
sudo apt -y install qemu-system-x86
sudo qemu-system-x86_64 -m 1G -vga qxl -enable-kvm /dev/sdc
```

Note: Without `-m 1G` it boots, but hangs in the emergency busybox shell.

### EFI on QEMU

```
sudo apt -y install qemu-system-x86 ovmf
sudo qemu-system-x86_64 -m 1G -vga qxl -bios /usr/share/ovmf/OVMF.fd -enable-kvm /dev/sdc
```

Note: As part of the BootImage generation process, need to have copied

```
me@host:~$ ls /cdrom/EFI/BOOT/
BOOTx64.EFI  grubx64.efi

me@host:~$ find /cdrom/EFI/
/cdrom/EFI/
/cdrom/EFI/BOOT
/cdrom/EFI/BOOT/BOOTx64.EFI
/cdrom/EFI/BOOT/grubx64.efi
```

If we have not done this,

then, at the `grub>` prompt, enter (using tab completion):

```
grub> configfile (hd0,msdos1)/boot/grub/grub.cfg
```

Note: But then we get:

```
error: can't find command 'loopback'.
error: can't find command 'linux'.
error: can't find command 'initrd'.

Press any key to continue...
```

Why?
