# Testing

## QEMU

```
sudo apt -y install qemu-system-x86
sudo qemu-system-x86_64 -enable-kvm /dev/sdc
```

It boots, but hangs in the emergency busybox shell.

### EFI on QEMU

```
sudo apt -y install qemu-system-x86 ovmf
sudo qemu-system-x86_64 -bios /usr/share/ovmf/OVMF.fd -enable-kvm /dev/sdc
```

Then, at the `grub>` prompt, enter (using tab completion):

```
grub> configfile (hd0,msdos1)/boot/grub/grub.cfg
```

But then we get:

```
error: can't find command 'loopback'.
error: can't find command 'linux'.
error: can't find command 'initrd'.

Press any key to continue...
```

Why?
