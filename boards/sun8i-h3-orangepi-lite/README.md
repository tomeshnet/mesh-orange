This file collects notes and information relevant to the Orange Pi Zero board.

Power Usage
-----------

During testing, I measured the power used for several scenarios using the
Orange Pi Zero.

| Setup                                                 | Bootup | Idle   |
|-------------------------------------------------------|-------:|-------:|
| Ramdisk, Ethernet plugged in, Wifi AP, TOP-GS07 mesh  |  793mA |  548mA |
| Ramdisk, Ethernet plugged in, Wifi AP                 |  417mA |  266mA |
| Ramdisk, Ethernet unplugged and if down, Wifi AP      |        |  250mA |
| Ramdisk, Ethernet plugged in, Wifi if down            |        |  163mA |
| Ramdisk, Ethernet if down, Wifi if down               |        |  145mA |
| Ramdisk, all if down, cpufreq 120Mhz                  |        |  109mA |
| Ramdisk, all if down, cpufreq 120Mhz, 3 CPUs offline  |        |   97mA |

* Bootup is the current that must be available for a successful boot
  without crashing.  "Not crashing" is defined as can login and run status
  commands with no error or freeze for 5 minutes.  If the test was done
  with changes after bootup, this value will be blank.  Note that this
  is a bare minimum measured value - add at least 10% for safe normal use.
* Idle is the average current that the board uses after completing booting.
  (Mean value over 10 seconds)
* All tests were done at 5v using a power supply that lowers this
  voltage if the configured current limit is reached (This is expected
  to be similar to what your usual Micro-USB plug pack will do, but
  probably not exactly the same)
  More specifically, a CC/CV (Constant-Current/Constant-Voltage) bench
  power supply was used with the current limit adjusted to find the
  bootup minimum current.  It was not configured to trip if the max
  current was reached, thus allowing occasional opperation in CC mode.


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

Old, original test build
------------------------

This is the rough set of notes for the steps I originally followed to make
a working orange pi zero build (before this autobuilder was done)

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

