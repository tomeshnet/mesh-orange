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
# There are a lot of assumptions wrapped up in these definitions
# some of these are:
# - MBR partitioning
# - dosfs for uboot partition
# - the filesystem label and disk id are fixed as "boot" and "1"


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
define image_file_create
    truncate --size=$$((0x200)) $(DISK_IMAGE).tmp   # skip past the MBR
    date -u "+%FT%TZ" >>$(DISK_IMAGE).tmp           # add a build date
    git describe --long --dirty >>$(DISK_IMAGE).tmp # and describe the repo
endef

# Create the partitions
#
define image_create_partitions
    MTOOLSRC=$(BUILD)/mtoolsrc mpartition -I z:
    MTOOLSRC=$(BUILD)/mtoolsrc mpartition -c -b $(PART1_BEGIN_SEC) z:
    if [ -n "$(PART2_SIZE_MEGS)" ]; then \
        MTOOLSRC=$(BUILD)/mtoolsrc mpartition -c -T0x82 -b $(PART2_BEGIN_SEC) y:; \
    fi
    if [ -n "$(PART3_SIZE_MEGS)" ]; then \
        MTOOLSRC=$(BUILD)/mtoolsrc mpartition -c -T0x83 -b $(PART3_BEGIN_SEC) x:; \
    fi
endef

# Wipe and format the first partition - used for the boot files
#
# FIXME - the truncate should calculate its size
#
define image_format_partition1
    truncate --size=">1025K" $@.tmp    # ensure the FAT bootblock is mapped
    MTOOLSRC=$(BUILD)/mtoolsrc mpartition -a z:
    MTOOLSRC=$(BUILD)/mtoolsrc mformat -v boot -N 1 z:
endef

# Create an empty configuration directory
#
define image_confdir
    MTOOLSRC=$(BUILD)/mtoolsrc mmd z:conf.d
endef

# Perform the "normal" image creation/partition/boot filesystem steps
#
define image_normal
    $(call image_file_create)
    $(call image_create_partitions)
    $(call image_format_partition1)
    $(call image_confdir)
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
