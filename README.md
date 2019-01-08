A small ramdisk system running modern Debian
============================================

[![Build Status](https://travis-ci.org/tomeshnet/mesh-orange.svg?branch=master)](https://travis-ci.org/tomeshnet/mesh-orange)
[![GitHub release](https://img.shields.io/github/release/tomeshnet/mesh-orange.svg)](https://github.com/tomeshnet/mesh-orange/releases)

This project will create system images for installing a Debian-based
router.

There are several supported target boards - for a quick list, look at
the subdirectories in the boards directory.  Note that with the standard
ramdisk confg used (using "tmpfs"), the images will not work with boards
that have less than 512Meg of RAM.

In the future, it will create a fully working mesh node, with cjdns
and IPFS software installed.


Documentation Index
-------------------

There documentory README files in most directories with explanations as
to what that directory is used for.  These files are located where they
are so as to stay close to the code and config that they are documenting.
Be sure to read this main README and all the other ones to get a full view
of the project.  There are also some diagrams showing some of the build
process in the docs directory.


TOP-GS07 RT5572 WiFi adapter Note
---------------------------------

During the testing of this adaptor, it was found to get very hot.  If
insufficient cooling is provided, this adaptor could overheat and fail
to work properly.  In a subtropical summer environment, it was found
that this would occur within a couple of minutes of use.  Removing the
plastic cover allows some cooling and was enough to complete at least
half an hour of successful light testing.

Building the image
------------------

Multiple board targets are supported, but they all use the same basic
process.  The following commands will build for the Orange Pi Zero:

    make build-depends

    make -C boards/sun8i-h2-plus-orangepi-zero image

First, any packages required to complete the build are installed -
this needs to be done for both the Debian environment and the specific
board environment, which is why there are two lines.

The last command builds the image.  Once the disk image is completed,
it will placed in the `output` dir.

Starting a clean build
----------------------

Most of the files in this repository have dependancy tracking, so that
changing one of them will rebuild just the appropriate parts.  Due to
the interaction with downloading external packages and building entire
Debian root dirs, those dependancies do not cover all possible changes.

Therefore, it is sometimes important to "clean" the repository to force
a full build to be done.  Note though that it should always be considered
a bug when a missing dependancy is found.

You should never need to completely delete your repository and do a new
clone from upstream!

There are two different targets provided to clean out the repository:

    make clean
    make reallyclean

If both are to be run, they should be done in that order, or just combined
into one command:

    make clean reallyclean

The "clean" target trys to remove the minimum set of files to produce
a clean rebuild.  It trys not to delete any large downloads, thus
speeding up the following build.  It also takes care to use sudo to
remove some files that will have been created with different owners.

The "reallyclean" target just nukes everything from each build dir.


Using the image
---------------

Once the image is built, and you have the disk image file from above,
write to the raw sdcard with a command line tool like `dd` or a
graphical tool like [Etcher](https://etcher.io).

For `dd`:

    lsblk -d -o NAME,SIZE,LABEL
    echo "Verify and run: sudo dd if=output/$IMAGE of=$DISK"

`Warning`: Don't overwrite the wrong disk!

Booting and using the system
----------------------------

A wireless access point will be automatically started on all detected
wifi adaptors - including those hot-plugged after bootup.  Any internet
connection plugged into the ethernet port will be shared out over the
access point.

`Note`: There is currently a bug with stopping/restarting the hostapd,
so if you unplug an adaptor, it will not automatically work again until
a reboot is done.

During testing the following default settings are used:

* wifi ssid: **test2**
* wifi passphrase: **bbbbbbbb**
* user: **root**
* pass: **root**

An ssh server is started on bootup, so the simplest way to login is to
connect to the wifi and use the root password.

During development and debugging, it is very helpful to use a serial
console to see the boot messages and login.  It may also be useful
to read the section below on running this image in an emulator.

`Note`: uncompressing the (currently approximately 120Meg uncompressed) initrd
will take a noticeable amount of time.  The network will not be setup until
that has been done, so nothing will happen for a while.  For some reason, this
also applies to the kernel messages.

Tests on one orange pi zero show that the time from power on until a login
prompt on the serial console is about 1 minute.


Applying persistent configurations
----------------------------------

Mesh communities may wish to customize nodes by distributing configuration
files to specify local network information and hardware settings. The system
image supports loading of these persistent configuration files at runtime.
Please refer to the _Runtime Configuration_ section in
[hamishcoleman/debian-minimal-builder](https://github.com/hamishcoleman/debian-minimal-builder)
for details.


Test the Debian image using Qemu
--------------------------------

It is possible to boot the Debian system up in an emulator.  This is
useful during development to speed up testing, but is also useful for
exploring the system and learning its features before committing to the
purchase of any hardware.

### Testing with the armhf architecture

The armhf architecture is an environment that is closer to the real-life
Single Board Computers that are expected to be used - and it uses exactly
the same binaries that would be used on those.  However, it is usually
a slower emulator.

    make build-depends

    make -C boards/qemu_armhf test

Once the build has completed, it will boot up inside the emulator.  The
console of the emulator is connected to your terminal window.

To exit the emulator, use `Ctrl-A` then `x`.

### Testing with the i386 architecture

While this is not the expected architecture for most physical hardware,
it is a much faster emulation.  Additionally, all the debian packages,
configuration and customisation is the same as the armhf architecture.

    make build-depends

    make -C boards/qemu_i386 test

The i386 test also creates a 2G persistent storage that shows up as
`/dev/vda`. To use this virtual disk, create and format a partition, any
data written to that partition will persist across `systemctl reboot`.

    fdisk /dev/vda        # Follow instructions to create a partition
    mkfs.vfat /dev/vda1   # Format the created partition as vfat
    mount /dev/vda1 /mnt  # Mount the formatted partition onto /mnt

To exit the emulator, use `Ctrl-A` then `x`.

Debian ramdisk builder
----------------------

The debian directory contains the Debian builder - see the README in
that dir for more details.
