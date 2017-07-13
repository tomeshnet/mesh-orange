#
# functions and definitions that are common across users of u-boot
#

ifneq ($(DEBIAN_ARCH),armhf)
$(error No infrastructure to support u-boot on non-armhf)
endif

# There are a lot of assumptions wrapped up in these definitions
# some of these are:
# - MBR partitioning
# - dosfs for uboot partition
# - the disk image file has been already extended to at least 1M+1K in size
# - mtools config file built for us
# - the filesystem label and disk id are fixed as "boot" and "1"

# Add a boot partition to an existing image, format it and copy the lists of
# files
#
# $1 is the mtools config file
# $2 is the mtools drive letter
# $3 is the start sector for the partition
# $4 is the list of files for the /boot dir
# $5 is the list of files for the /boot/dtb dir
define uboot_bootdir
    MTOOLSRC=$1 mpartition -I $2
    MTOOLSRC=$1 mpartition -c -b $3 $2
    MTOOLSRC=$1 mformat -v boot -N 1 $2
    MTOOLSRC=$1 mmd $2boot
    MTOOLSRC=$1 mmd $2boot/dtb
    MTOOLSRC=$1 mcopy $4 $2boot
    MTOOLSRC=$1 mcopy $5 $2boot/dtb
endef

BUILD_DEPENDS += mtools


%.scr: %.cmd
	mkimage -C none -A arm -T script -d $< $@

BUILD_DEPENDS += u-boot-tools

