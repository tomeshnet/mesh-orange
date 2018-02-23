#
# functions and definitions that are common across users of u-boot
#

ifneq ($(DEBIAN_ARCH),armhf)
$(error No infrastructure to support u-boot on non-armhf)
endif

# There are a lot of assumptions wrapped up in these definitions
# some of these are:
# - dosfs for uboot partition

# Create boot directory and copy the lists of files
#
# $1 is the mtools config file
# $2 is the mtools drive letter
# $3 is the list of files for the /boot dir
define uboot_copy_bootfiles
    MTOOLSRC=$1 mmd $2boot
    MTOOLSRC=$1 mcopy $3 $2boot
endef

# Create boot/dtb directory and copy the lists of files
#
# $1 is the mtools config file
# $2 is the mtools drive letter
# $3 is the list of files for the /boot/dtb dir
define uboot_copy_dtbfiles
    MTOOLSRC=$1 mmd $2boot/dtb
    MTOOLSRC=$1 mcopy $3 $2boot/dtb
endef

# Create boot/dtb/overlay directory and copy the lists of files
#
# $1 is the mtools config file
# $2 is the mtools drive letter
# $3 is the list of files for the /boot/dtb/overlay dir
define uboot_copy_overlayfiles
    MTOOLSRC=$1 mmd $2boot/dtb/overlay
    MTOOLSRC=$1 mcopy $3 $2boot/dtb/overlay
endef

# Overwrite the internet uboot default environment
# Usually expected to be used to work around strange environment
# issues.
#
# TODO
# - The image file is a key=value text file with defined separators
#   and a CRC, so we should be creating the binary from a text input
#   and not just jamming a blob into another blob
#
# $1 is the replacement env
# $2 is the image file
define uboot_overwrite_environment
    dd if=$1 of=$2 conv=notrunc bs=$$((0x088000)) seek=1
endef

BUILD_DEPENDS += mtools


# convert the initrd into the special uboot container format
%.uInitrd: %.initrd
	mkimage -C lzma -A arm -T ramdisk -d $< $@

%.scr: %.cmd
	mkimage -C none -A arm -T script -d $< $@

BUILD_DEPENDS += u-boot-tools

