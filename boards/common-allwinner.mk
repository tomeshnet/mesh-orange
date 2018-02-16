#
# functions and definitions that are common across several allwinner systems
#

# Create an empty disk image file with the uboot SPL in the right place
# for the allwinner SOCs
#
# $1 is the SPL
# $2 is the output board file
define allwinner_spl
    truncate --size=">$$((0x2000))" $2  # ensure large enough file for SPL
    dd if=$1 of=$2 conv=notrunc bs=$$((0x2000)) seek=1
endef

