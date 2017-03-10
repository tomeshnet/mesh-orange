This is the rough set of notes for the steps I followed:

* install armbian image
    FIXME - link
* change to debian stretch
* * upgrade all
* change armbian to beta
* * upgrade kernel
* * FIXME - instructions from armbian
* set fq_codel as default packet scheduler
* Stop using the crazy name generateor for "stable" interface names
* Apply fix to uboot to enable SMP
* install and configure hostap for onboard wifi access point (plus iptables)
* create mesh network with available wlan devices
* compile cjdns and start it
* mactelnet (I used this, possibly not needed for a standard image)
* bunches of tools installed

Future things I think should exist:
* config storage (spi flash?, just a magic file in /boot?)
* auto hostname
* change initial password
* add udev persistent-net-generator.rules - style network interface naming
* autoconfiguration for plugged in wifi devices
* use a known prefix for tunnel names to allow stable iptables rules and
  coexistance with other tunnel systems
* IPFS
* debian root filesystem autobuilder, generating initramfs images
* u-boot rules to boot of one or the other of the initramfs images

Disk image layout
-----------------

This information has been mostly taken from pulling apart the armbian build
scripts, but it also matches the various other references on allwinner chips
I remember reading in the past.

Micro-SD card disk image:
* 0x000000 - 0x00004f : Some Intel 8086 machine code to boot first active MBR
* 0x0001b8 - 0x0001bb : MBR PTUUID - a 32bit little-endian "disk id"
* 0x0001be - 0x0001fd : Standard MBR partition table
* 0x0001fe - 0x0001ff : 0x55 0xaa - magic number for the boot block
* 0x002000 - 0x06fdcf : SPL and U-Boot  - From the armbian deb linux-u-boot-orangepizero-dev use file $DIR/u-boot-sunxi-with-spl.bin
* 0x088000 - 0x088003 : crc32(0, data, ENV_SIZE) - checksum of the env
* 0x088004 - 0x0a8000 : saved environment (\0 terminated name=value, \0\0 ends)
* 0x100000 - end      : data partition (ext4 in armbian, the U-Boot also supports FAT)

