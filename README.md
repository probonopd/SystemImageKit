Copyright (c) 2004-16 Simon Peter
probono@puredarwin.org

# SystemImageKit

Image-based computing: Operating system complexity reduction by encapsulation.

SystemImageKit lets you run Fedora, CentOS, Ubuntu, Debian, and openSUSE (based) live systems, all directly from unchanged live ISOs all stored on the same physical medium (e.g., USB drive). Currently support for the live booting systems of the mentioned distributions is built in, but the system is modular so that detection scripts for other distributions can be added relatively easily.

SystemImageKit also has means to customize every aspect of the boot process and the booted system, so that you can customize the live systems without having to remaster their live ISOs. It does so by allowing you to overlay files in the initramfs and to overlay files in the booted system.

## Installing

The following steps illustrate how to install an Operating System onto a USB drive using SystemImageKit.

In order to do this, boot Ubuntu Live system (tested with Ubuntu 14.04 LTS Trusty Tahr) and run the following steps.

NOTE: All data on /dev/sdX will be deleted.

```
sudo -i

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

# Generate additional initrd (gets loaded in addition to the one on the ISO)
/mnt/boot/iso/additional-initramfs/generate

# Download Ubuntu ISO
wget -c "http://releases.ubuntu.com/14.04.1/ubuntu-14.04.1-desktop-amd64.iso" -O /mnt/boot/iso/ubuntu-14.04.1-desktop-amd64.iso

# Configure bootloader
/mnt/boot/bin/detect

# Create and install ExtensionImages, e.g., for Adobe Flash Player and proprietary firmware
bash /mnt/boot/bin/generate-*

umount /mnt

# The disk should now be bootable

```

If you format the device manually and run into "error: will not proceed with blocklists", then use gparted to move the start of the first partition up 1MB. This works without having to reformat the device.

We need to do this only once.
Whenever we add additional ISOs, we just have to re-run (the example is for a running Ubuntu Live system):

```
sudo /isodevice/boot/generate
```

## The challenge

Today's operating sytems are hugely complex collections of various files, which are scattered on the mass storage in a way that 
makes it hard for end users to understand, maintain, and upgrade. Here, a way of encapsulating - and thus, making more 
manageable - this complexity is proposed.

An earlier paper of the same author, AppImageKit documentation, has been cited frequently, and has even made it into the Wikipedia 
article on distributions. However, it has focused solely on the the applications aspect. Here, a more comprehensive, and more 
rigorous, plan of systems architecture is described.

Today's operating systems are organized in a way that is logical for developers but not logical for end users.

Typical end users think of the contents of their computers as:
  * 1 operating system (e.g., RHEL7)
  * 1 system extension (e.g., WLAN chip firmware)
  * 3 apps (e.g., OpenOffice, Firefox, VLC)
  * 1 set of settings
  * 300 files being worked on

Instead, most operating systems are organized in a way that they do not confront the user with 306 files (which the user could 
understand) but rather with tens to hundreds of thousands of files (99% of which the user does not understand, and does not want to 
manage). 

Some operating sytems have tried to keep the number of files manageable and understandable by the end user (e.g., early versions of 
the Macintosh System Software), but with the ever increasing complexity and size of modern operating systems like Unix and Windows, 
the number of files grew while no really useful abstractions have been introduced to help the user regain control over all these 
files. Instead, installers and uninstallers (Windows) and package managers (Unix) have been created. In this process, the user 
became increasingly dependent on these tools.

On desktop systems, files in the filesystem can broadly be categorized into
  # Files installed by the operating system
  # Files installed as operating system extensions (e.g., firmware, codecs)
  # Files installed by applications
  # Files created by the administrator or user to customize the system (e.g., configuration files)
  # Files created by the user as work products (e.g., documents)

On most operating system setups, these are intermingled more or less in the same filesystem, which creates increasing complexity. 
Because on most setups these files are distributed througout the filesystem, it is hard to

  * Run a virtually unlimited number of operating systems on the same machine without partitioning
  * Run multiple versions of the same operating system while retaining all extensions, settings, applications, and user data
  * Try a new operating system version with no danger to the system before deciding whether to keep it
  * Delete an old operating system only after having verified for some time that the new version works well
  * Run different architectures (e.g., 32-bit and 64-bit) of the same operating system while retaining all settings and user data
  * Run different operating systems (e.g., RHEL, CentOS, Fedora, debian, Ubuntu) while retaining all extensions, settings, 
applications, and user data
  * Reset the operating system into original "factory" state while retaining or selectively removing extensions, settings, 
applications, and user data
  * Run two different versions of the same app alongside
  * Install extensions and apps without the help of installers or package managers
  * Completely remove extensions and apps without "leftovers" without the help of uninstaller tools or package mangers
  * Quickly verify that the system has not been modified and is in a "sane" state, e.g., using a checksum
  * Allow for any kind of non-permanent modification in the system, because the system is reset to a "known good" state at each 
reboot
  * Move installed operating systems, and/or extensions, applications, customizations from one computer to another

Many of the issues above are caused by the "tight coupling" of operating system, extensions, applications, and customizations by the 
way of the file system. The key to resolving the issues described above is encapsulation of the logical units used in a computer 
system.

## The solution

System-level virtuaization has been used to address some of the issue above (e.g., running multiple operating systems 
easily on the 
same system, being able to reset systems by using snapshots) . However, system-level virtualization (e.g., VMware, VirtualBox, qemu) 
comes at a performance penalty, and unneccessarily increases complexity by requiring a host 
operating system on which a guest operating system is run. Yet, it does not solve some of the issues mentioned above (e.g., 
applying a set of customizations to multiple operating systems).

By setting up the operating system in a way proposed here, it is possible to achieve the above use cases easily. We define 
objects for the categories mentioned above as follows:
  # A bootloader that is capable of booting image files
  # One file per operating system
  # One file per operating system extension (e.g., firmware, set of codecs)
  # One file per application
  # One file to customize the system
  # Files created by the user as work products (e.g., documents)

In the implementation described here, we use:
  # grub2 with custom helper scripts
  # ISO files, containing one live operating system each
  # ExtensionImage files, the contents of which are symlinked into the / upon boot
  # AppImage files, the contents of which are mounted when the app is exected
  # An init file that does local configuration and is run when the system boots (and an auxiliary initrd that helps loading this 
configuration)
  # Files in $HOME which is mounted from a persistent location

In the following paragraps, each of these components is discussed.

### Bootloader

We use grub2, a bootloader that is capable of booting operating systems contained in ISO image files. grub2 can loop-mount and ISO 
file and load the kernel and the initrd from the ISO. What happens once the kernel has control is up to the operating system. 
Luckily, many common operating systems (such as CentOS, Fedora, debian, Ubuntu and openSUSE) nowadays are capable of loop-mounting 
ISO files and continue the boot process from there (at least with a little help in the form of an additional, secondary initrd image 
that patches the required functionality if required, e.g., for openSUSE). We use a helper script to generate the secondary initrd 
image. The contents of this image are loaded in addition to the contents of the original initrd image supplied on the operating 
system ISO.

The advantage of using the bootloader in the way described is that virtually unlimited operating systems can be booted on a computer 
without having to partition the mass storage.

### Operating system ISO files

Many common operating systems (such as	CentOS,	Fedora,	debian,	Ubuntu and openSUSE) nowadays provide readymade Live systems 
(originally intended to run from CD-ROM and/or DVD) which are ideal for our purpose, because they provide defined baseline sets of 
software that we can expect to be installed in each system. For example, if we use the CentOS 7 live ISO we know exactly the set of 
software included therein, and can assume this to be present on any computer running the CentOS 7 live ISO. This is important, as it 
allows us to simplify dependency management substantially. Also, live systems are non-persistent by default, which means that 
changes can be made to all aspects of the system but after a reboot, the system is back to its original condition ("stateless"). As 
mentioned above, some live ISOs are not designed to be booted without being burnt to a CD-ROM and/or DVD (e.g., openSUSE), but by 
adding a secondary initrd image we can patch the required functionality 
in without having to remaster the ISO.

The advantage of using live system ISO files in the way described is that operating systems can be added and removed very easily, 
and at each reboot the system is back to its original condition.

### ExtensionImage files

Some software deeply integrates with the operating system and is not an app. For example, some wireless network cards require binary 
firmware blobs to be loaded into the hardware upon boot. These firmware blobs are installed into the operating system, so that they 
can be loaded by the system at the appropriate time. An ExtensionImage is a file which contains one such operating system extension, 
no matter how many files it consists of. The files contained in the ExtensionImage are linked into the appropriate positions in the 
operating system at an early stage at boot, so that the operating system can pick them up from there.

The advantage of using ExtensionsImage files is that every extension is one file and can therefore be intuitively managed by the 
user (e.g., installed, upgraded, removed, and moved to another machine).

### AppImage files

An app often consists of hundred of files in addition to the main binary, e.g., icons, graphics, language files, and other 
auxiliary files. Frequently, an app also requires libraries which are not normally part of the operating system. In this case, the 
corresponding libraries have to be installed into the system prior to running the app. By using AppImages, all of this is abstracted 
by encapsulating each app with all the auxiliary files and libraries that it needs to run which are not part of the operating 
system.

The advantage of using AppImage files is that every app is one file and can therefore be intuitively managed by the user (e.g., 
installed, upgraded, removed, and moved to another machine). Also, by bundling the dependencies which are not part of the operating 
systems, several versions of the same app can be installed alongside, even if they require incompatible versions of dependencies.

### Files in $HOME

Since the operating system is run from a live system, changes to the running system are non-persistent by default, which means that 
user data in $HOME is deleted whenever the machine is shut down. Hence, it is advisable to mount the $HOME directory from a 
persistent location, e.g., a data partition or data loopback file, or from a network share.

The advantage of using $HOME in this way is that user data is preserved between boots, while the rest of the system is in a clean 
state after every boot.

## The result

In the system proposed here, what does the typical end user see?

```
/boot
/boot/iso
/boot/iso/fedora.iso
/boot/customize/init
/boot/grub
/boot/grub/grub.cfg
/boot/bin/detect
/boot/extensions/b43firmware.ExtensionImage
/apps/
/apps/Firefox.AppImage
/apps/OpenOffice.AppImage
/apps/VLC.AppImage
```

Some additional bootloader and helper files are left out here for brevity, but the total set of files to be managed is much more 
concise than on a traditional operating system, and in the hundreds rather than in the hundreds of thousands.

Also, "regular users" get the freedom to do things never imagined before:

```
/boot/iso/fedora.iso
/boot/iso/ubuntu_32bit.iso
/boot/iso/ubuntu_64bit.iso
/apps/Firefox_20.AppImage
/apps/Firefox_24.AppImage
/apps/Firefox_25_nightly.AppImage
```

The system proposed here allows not only for substantial complexity reduction by a factor of thousand, but also allows normal end 
users to try out operating systems and apps more easily, without having to "commit" to them (in the form of "installing"). This is 
done by removing the tight coupling between and by encapsulating operating systems, operating system extensions, applications, customizations, and user data. 
Unlike with system-level virtualization, the performace overhead involved is relatively minor.

## References

https://wiki.archlinux.org/index.php/Multiboot_USB_drive#Workstation_live_medium GRUB2 loopback examples for many types of Live ISOs
