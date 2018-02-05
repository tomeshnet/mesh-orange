#
# functions and definitions related to partitioning/formatting and using
# diskimages
#

PART_SIZE_MEGS ?= 1000

BUILD_DEPENDS += mtools

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

$(BUILD)/mtoolsrc: Makefile
	mkdir -p $(dir $@)
	echo 'drive z: file="$(DISK_IMAGE).tmp" cylinders=$(PART_SIZE_MEGS) heads=64 sectors=32 partition=1 mformat_only' >$@
CLEAN_FILES += $(BUILD)/mtoolsrc
