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

# Create and write files to boot partition
#
# $1 is the mtools config file
# $2 is the mtools drive letter
# $3 is the list of files for the /boot dir
# $4 is the list of files for the /boot/dtb dir
define uboot_dirs
    $(call uboot_bootdir,$1,$2,$3,$4)
    $(call uboot_confdir,$1,$2)
endef

# Create boot directory and copy the lists of files
#
# $1 is the mtools config file
# $2 is the mtools drive letter
# $3 is the list of files for the /boot dir
# $4 is the list of files for the /boot/dtb dir
define uboot_bootdir
    MTOOLSRC=$1 mmd $2boot
    MTOOLSRC=$1 mmd $2boot/dtb
    MTOOLSRC=$1 mcopy $3 $2boot
    MTOOLSRC=$1 mcopy $4 $2boot/dtb
endef

# Create an empty configuration directory
#
# $1 is the mtools config file
# $2 is the mtools drive letter
define uboot_confdir
    MTOOLSRC=$1 mmd $2conf.d
endef

BUILD_DEPENDS += mtools


# convert the initrd into the special uboot container format
%.uInitrd: %.initrd
	mkimage -C lzma -A arm -T ramdisk -d $< $@

%.scr: %.cmd
	mkimage -C none -A arm -T script -d $< $@

BUILD_DEPENDS += u-boot-tools

