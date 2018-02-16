#
# Build a Banana Pi install
#

DEBIAN_VER = stretch
DEBIAN_ARCH = armhf

# which uboot and device tree is this being built for
ARMBIAN_UBOOT_PKG = linux-u-boot-bananapi-dev
UBOOT = linux-u-boot-dev-bananapi_5.31_armhf
BOARD = sun7i-a20-bananapi
# FIXME - it would be nice if the uboot name was related to the dtb name

SRC_SPL = $(ARMBIAN)/usr/lib/$(UBOOT)/u-boot-sunxi-with-spl.bin

CLEAN_FILES += $(TAG) $(ARMBIAN) $(BOOT)

# Directories
ARMBIAN = $(BUILD)/armbian

BUILD_DEPENDS = \
    xz-utils \

TOP_DIR ?= $(abspath ../..)

all: image

include $(TOP_DIR)/mk/common.mk
include $(TOP_DIR)/boards/common-partitions.mk
include $(TOP_DIR)/boards/common-uboot.mk
include $(TOP_DIR)/boards/common-allwinner.mk
include $(TOP_DIR)/boards/common-kernel-local.mk
include $(TOP_DIR)/boards/common-firmware-armbian.mk
include $(TOP_DIR)/mk/common-armbian.mk
include $(TOP_DIR)/boards/common-cjdns-hack.mk
include $(TOP_DIR)/boards/common-initrd.mk

image: $(DISK_IMAGE)
	mkdir -p $(TOP_DIR)/output
	cp $< $(TOP_DIR)/output/$(BOARD).img

test:
	echo this board must be tested by flashing the output
	false

# Everything below this line is HW specific Armbian u-Boot startup code

$(TAG)/armbian:
	$(TOP_DIR)/scripts/get_deb $(DEBIAN_ARCH) $(ARMBIAN_KEY) $(ARMBIAN_REPO) $(ARMBIAN) $(ARMBIAN_UBOOT_PKG)
	$(call tag,armbian)

$(BOOT): $(TAG)/boot
$(TAG)/boot:
	mkdir -p $(BOOT)
	$(call tag,boot)

$(BOOT)/.next: $(TAG)/boot
	touch $@

# TODO
# - stop using our local version of these files. (See the Makefile in
#   boards/sun8i-h2-plus-orangepi-zero/ for more details)

$(BOOT)/boot.scr: $(TAG)/boot
$(BOOT)/boot.scr: boot.scr
	cp $< $@
CLEAN_FILES += boot.scr

$(BOOT)/armbianEnv.txt: $(TAG)/boot
$(BOOT)/armbianEnv.txt: armbianEnv.txt
	cp $< $@

$(BOOT)/zImage: $(LOCAL_KERNEL)
	cp $< $@
	cp $(dir $<)/.config $(dir $@)

$(BOOT)/uInitrd: $(TAG)/boot
$(BOOT)/uInitrd: $(BUILD)/combined.uInitrd
	cp $< $@
CLEAN_FILES += $(BUILD)/combined.uInitrd

BOOT_FILES = \
    $(BOOT)/boot.scr $(BOOT)/armbianEnv.txt \
    $(BOOT)/.next \
    $(BOOT)/zImage \
    $(BOOT)/uInitrd \

BOOT_DTB_FILES = \
    $(BOOT)/dtb/$(BOARD).dtb

boot: $(BOOT_FILES) $(BOOT_DTB_FILES)

# Everything below this line is packing the built boot dir into a disk image

$(SRC_SPL): $(TAG)/armbian

# FIXME - the env file is a hack

$(DISK_IMAGE): $(SRC_SPL) $(BUILD)/mtoolsrc $(BOOT_FILES) $(BOOT_DTB_FILES) env
	$(call image_file_create)
	$(call image_create_partitions)
	$(call allwinner_spl,$(SRC_SPL),$@.tmp)
	$(call image_format_partition1)
	$(call image_confdir)
	$(call uboot_copyfiles,$(BUILD)/mtoolsrc,z:,$(BOOT_FILES),$(BOOT_DTB_FILES))
	dd if=env of=$@.tmp conv=notrunc bs=$$((0x088000)) seek=1
	mv $@.tmp $@
