#
# functions and definitions related to partitioning/formatting and using
# diskimages
#

# Create an empty disk image file with no partition table
#
# TODO - adding the build date here makes reproducible binaries impossible
#
# $1 is the output disk image
define image_file_create
    truncate --size=$$((0x200)) $1   # skip past the MBR
    date -u "+%FT%TZ" >>$1           # add a build date
    git describe --long --dirty >>$1 # and describe the repo
endef



