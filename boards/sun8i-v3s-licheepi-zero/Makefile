#
# Build a Lichee Pi Zero install
#
# Note that this is a little different from other systems - it only has 64M
# of ram, so cannot use a ramdisk
#

DEBIAN_VER = stretch
DEBIAN_ARCH = armhf

# which uboot and device tree is this being built for
UBOOT = u-boot-sunxi-with-spl_480800.bin
BOARD = sun8i-v3s-licheepi-zero
# FIXME - it would be nice if the uboot name was related to the dtb name

SRC_SPL = $(ZIP)/$(UBOOT)
SRC_DTB = $(ZIP)/$(BOARD).dtb

PART1_SIZE_MEGS = 100 # dosfs boot
PART2_SIZE_MEGS = 200 # reserved for swap
PART3_SIZE_MEGS = 500 # ext2 root

PART1_BEGIN_SEC = $$((0x100000/512))
PART2_BEGIN_SEC = $$(( $(PART1_BEGIN_SEC) + ($(PART1_SIZE_MEGS) *1024*1024) /512))
PART3_BEGIN_SEC = $$(( $(PART2_BEGIN_SEC) + ($(PART2_SIZE_MEGS) *1024*1024) /512))

IMAGE_SIZE_MEGS = $$(( 0x100000/1024/1024 + $(PART1_SIZE_MEGS) + $(PART2_SIZE_MEGS) + $(PART3_SIZE_MEGS) ))

CLEAN_FILES = $(TAG) $(ZIP) $(BOOT) $(BUILD)/mtoolsrc $(BUILD)/root.fs.tmp

# Directories
ZIP = $(BUILD)/zero_imager

BUILD_DEPENDS = \
    mtools \

TOP_DIR ?= $(abspath ../..)

all: image

include $(TOP_DIR)/mk/common.mk
include $(TOP_DIR)/boards/common-uboot.mk
include $(TOP_DIR)/boards/common-allwinner.mk
include $(TOP_DIR)/boards/common-kernel-local.mk

image: $(DISK_IMAGE)
	mkdir -p $(TOP_DIR)/output
	cp $< $(TOP_DIR)/output/$(BOARD).img

test:
	echo this board must be tested by flashing the output
	false

# Everything below this line is HW specific setup

$(BUILD)/zero_imager.zip:
	mkdir -p build
	wget -O $@ https://licheepizero.us/downloads/zero_imager.zip
	touch $@

$(ZIP): $(BUILD)/zero_imager.zip
	unzip -o $(BUILD)/zero_imager.zip -d $(BUILD)

$(BUILD)/root.fs: $(DEBIAN).cpio $(LOCAL_MODULES_CPIO) $(ZIP)
	truncate --size=$$(( $(PART3_SIZE_MEGS)*1 ))M $@.tmp
	/sbin/mkfs.ext4 -L root $@.tmp
	mkdir -p $@.dir
	sudo mount -oloop $@.tmp $@.dir
	cat $(DEBIAN).cpio | ( \
            cd $@.dir; \
            sudo cpio --make-directories -i; \
	)
	sudo rm $@.dir/init.d/01welcome.sh
	sudo ln -s /init $@.dir/sbin/init
	cat $(LOCAL_MODULES_CPIO) | ( \
            cd $@.dir; \
            sudo cpio --make-directories -i; \
	)
	sudo cp -r $(ZIP)/overlay_rootfs-base/lib/firmware/ $@.dir/lib/firmware/
	sudo umount $@.dir
	mv $@.tmp $@

$(BOOT): $(TAG)/boot
$(TAG)/boot:
	mkdir -p $(BOOT)
	$(call tag,boot)

$(BOOT)/boot.scr: $(TAG)/boot
$(BOOT)/boot.scr: boot.scr
	cp $< $@
CLEAN_FILES += boot.scr

$(BOOT)/zImage: $(LOCAL_KERNEL)
	cp $< $@
	cp $(dir $<)/.config $(dir $@)

dtb: $(TAG)/dtb
$(TAG)/dtb: $(TAG)/boot
	mkdir -p $(BOOT)/dtb
	$(call tag,dtb)

$(SRC_DTB): $(ZIP)

$(BOOT)/dtb/$(BOARD).dtb: $(TAG)/dtb
$(BOOT)/dtb/$(BOARD).dtb: $(SRC_DTB)
	cp $< $@

BOOT_FILES = \
    $(BOOT)/boot.scr \
    $(BOOT)/zImage \

BOOT_DTB_FILES = \
    $(BOOT)/dtb/$(BOARD).dtb \

boot: $(BOOT_FILES) $(BOOT_DTB_FILES)

# Everything below this line is packing the built boot dir into a disk image

$(SRC_SPL): $(ZIP)

$(BUILD)/mtoolsrc: Makefile
	echo 'drive z: file="$(DISK_IMAGE).tmp" cylinders=$(PART1_SIZE_MEGS) heads=64 sectors=32 partition=1 mformat_only' >$@
	echo 'drive y: file="$(DISK_IMAGE).tmp" cylinders=$(PART2_SIZE_MEGS) heads=64 sectors=32 partition=2 mformat_only' >>$@
	echo 'drive x: file="$(DISK_IMAGE).tmp" cylinders=$(PART3_SIZE_MEGS) heads=64 sectors=32 partition=3 mformat_only' >>$@

$(DISK_IMAGE): $(SRC_SPL) $(BUILD)/mtoolsrc $(BOOT_FILES) $(BOOT_DTB_FILES) $(BUILD)/root.fs
	$(call allwinner_spl,$(SRC_SPL),$@.tmp)
	truncate --size=1025K $@.tmp    # ensure the FAT bootblock is mapped
	$(call uboot_dirs,$(BUILD)/mtoolsrc,z:,$(PART1_BEGIN_SEC),$(BOOT_FILES),$(BOOT_DTB_FILES))
	MTOOLSRC=$(BUILD)/mtoolsrc mpartition -c -T0x82 -b $(PART2_BEGIN_SEC) y:
	MTOOLSRC=$(BUILD)/mtoolsrc mpartition -c -T0x83 -b $(PART3_BEGIN_SEC) x:
	truncate --size=$$(( $(PART3_BEGIN_SEC)*512 )) $@.tmp
	cat $(BUILD)/root.fs >> $@.tmp
	mv $@.tmp $@

# Misc make infrastructure below here

clean:
	rm -rf $(CLEAN_FILES)
	sudo rm -rf $(BUILD)/root.fs.dir

