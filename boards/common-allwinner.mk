#
# functions and definitions that are common across several allwinner systems
#

include $(TOP_DIR)/boards/common-uboot.mk

# Create an empty disk image file with the uboot SPL in the right place
# for the allwinner SOCs
#
# $1 is the SPL
# $2 is the output board file
define allwinner_spl
    truncate --size=">$$((0x2000))" $2  # ensure large enough file for SPL
    dd if=$1 of=$2 conv=notrunc bs=$$((0x2000)) seek=1
endef

# Do the 'normal' steps needed for an allwinner system
#
# $1 is the disk image file
# $2 is the SPL
# $3 is the mtoolsrc
# $4 is the mtools driver letter
# $5 is the /boot files
# $6 is the /boot/dtb files
define allwinner_normal
    $(call allwinner_spl,$2,$1)
    $(call uboot_copy_bootfiles,$3,$4,$5)
    $(call uboot_copy_dtbfiles,$3,$4,$6)
endef
