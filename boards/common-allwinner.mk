#
# functions and definitions that are common across several allwinner systems
#

# Create an empty disk image file with the uboot SPL in the right place
# for the allwinner SOCs
#
# $1 is the SPL
# $2 is the output board file
define allwinner_spl
    truncate --size=$$((0x2000)) $2  # skip to correct offset for SPL
    cat $1 >>$2                      # add the SPL+uboot binary
endef


