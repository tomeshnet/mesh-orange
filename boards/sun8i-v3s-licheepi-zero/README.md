This file collects notes and information relevant to the Lichee Pi Zero board.

As this board has such a small amount of RAM available (only 64Meg),
it is not possible to run it with a ramdisk.  The disk image created by
this builder is one that with a standard root filesystem - created from
the debian ramdisk image.

Power Usage
-----------

During testing, I measured the power used.

| Setup                                        | Max    | CC/CV  | Idle   |
|----------------------------------------------|-------:|-------:|-------:|
| MMCdisk, nothing else plugged in             |  187mA |  162mA |   92mA |

TODO
----
* Make the hostname less unclear (currently has prefix "ramdisk")
* Add support for USB gadget bits (serial console, ethernet, maybe blockdev)
* Try using the armbian allwinner kernel with the licheepi-zero dtb
* Ensure that the lichee official SDIO WIFI works
* Add drivers and firmware for TOP-GS07 WIFI
* Maybe automatically detect and use the swap partition?
