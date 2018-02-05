#
# functions and definitions related to partitioning/formatting and using
# diskimages
#

# The automatically created partition layout is always the same:
# - part1, vfat, containing boot files and initrd
# - part2, optional swap partition
# - part3, optional linux partition.  At end of disk to allow expanding to fill
#       the whole sdcard.  Could contain the root filesystem on a non-ramdisk
#       image, or just bulk persistant storage for something in the ramdisk
#

PART1_SIZE_MEGS ?= 1000
#PART2_SIZE_MEGS ?= 1000 # reserved for swap
#PART3_SIZE_MEGS ?= 1000 # ext2 root

PART1_BEGIN_SEC = $$((0x100000/512))
ifdef PART2_SIZE_MEGS
PART2_BEGIN_SEC = $$(( $(PART1_BEGIN_SEC) + ($(PART1_SIZE_MEGS) *1024*1024) /512))
ifdef PART3_SIZE_MEGS
PART3_BEGIN_SEC = $$(( $(PART2_BEGIN_SEC) + ($(PART2_SIZE_MEGS) *1024*1024) /512))
endif
endif

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
	echo 'drive z: file="$(DISK_IMAGE).tmp" cylinders=$(PART1_SIZE_MEGS) heads=64 sectors=32 partition=1 mformat_only' >$@
	if [ -n "$(PART2_SIZE_MEGS)" ]; then \
            echo 'drive y: file="$(DISK_IMAGE).tmp" cylinders=$(PART2_SIZE_MEGS) heads=64 sectors=32 partition=2 mformat_only' >>$@; \
	fi
	if [ -n "$(PART3_SIZE_MEGS)" ]; then \
            echo 'drive x: file="$(DISK_IMAGE).tmp" cylinders=$(PART3_SIZE_MEGS) heads=64 sectors=32 partition=3 mformat_only' >>$@; \
	fi

CLEAN_FILES += $(BUILD)/mtoolsrc
