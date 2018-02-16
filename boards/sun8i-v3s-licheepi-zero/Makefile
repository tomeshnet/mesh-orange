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

CLEAN_FILES = $(TAG) $(ZIP) $(BOOT) $(BUILD)/root.fs.tmp

# Directories
ZIP = $(BUILD)/zero_imager

TOP_DIR ?= $(abspath ../..)

all: image

include $(TOP_DIR)/mk/common.mk
include $(TOP_DIR)/boards/common-partitions.mk
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

$(DISK_IMAGE): $(SRC_SPL) $(BUILD)/mtoolsrc $(BOOT_FILES) $(BOOT_DTB_FILES) $(BUILD)/root.fs
	$(call image_file_create,$@.tmp)
	$(call image_create_partitions)
	$(call allwinner_spl,$(SRC_SPL),$@.tmp)
	$(call image_format_partition1)
	$(call uboot_dirs,$(BUILD)/mtoolsrc,z:,$(BOOT_FILES),$(BOOT_DTB_FILES))
	truncate --size=$$(( $(PART3_BEGIN_SEC)*512 )) $@.tmp
	cat $(BUILD)/root.fs >> $@.tmp
	mv $@.tmp $@

# Misc make infrastructure below here

clean:
	rm -rf $(CLEAN_FILES)
	sudo rm -rf $(BUILD)/root.fs.dir

