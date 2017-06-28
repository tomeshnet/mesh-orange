#
# functions and definitions that are common across several allwinner systems
#

# Create an empty disk image file with the uboot SPL in the right place
# for the allwinner SOCs
#
# TODO - adding the build date here makes reproducible binaries impossible
#
# $1 is the SPL
# $2 is the output board file
define allwinner_spl
    truncate --size=$$((0x200)) $2   # skip past the MBR
    date -u "+%FT%TZ " >>$2          # add a build date
    git describe --long --dirty >>$2 # and describe the repo
    truncate --size=$$((0x2000)) $2  # skip to correct offset for SPL
    cat $1 >>$2                      # add the SPL+uboot binary
endef


