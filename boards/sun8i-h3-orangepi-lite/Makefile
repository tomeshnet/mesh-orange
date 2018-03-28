#
# Build a Orange Pi Lite install
#

DEBIAN_VER = stretch
DEBIAN_ARCH = armhf

# which uboot and device tree is this being built for
ARMBIAN_UBOOT_PKG = linux-u-boot-orangepilite-dev
ARMBIAN_KERNEL_PKG = linux-image-dev-sun8i=5.35
UBOOT = linux-u-boot-dev-orangepilite_5.38_armhf
BOARD = sun8i-h3-orangepi-lite
# FIXME - it would be nice if the uboot name was related to the dtb name

SRC_SPL = $(ARMBIAN)/usr/lib/$(UBOOT)/u-boot-sunxi-with-spl.bin
SRC_DTBDIR = $(ARMBIAN)/usr/lib/linux-image-dev-sun8i
SRC_FDT = $(SRC_DTBDIR)/$(BOARD).dtb
SRC_DTBO = $(SRC_DTBDIR)/overlay

INITRD_PARTS += $(BUILD)/modules.lzma
CLEAN_FILES += $(BUILD)/modules.lzma

CLEAN_FILES += $(TAG) $(ARMBIAN) $(BOOT)

# Directories
ARMBIAN = $(BUILD)/armbian

BUILD_DEPENDS = \
    xz-utils \

TOP_DIR ?= $(abspath ../..)

all: image

include $(TOP_DIR)/mk/common.mk
include $(TOP_DIR)/boards/common-partitions.mk
include $(TOP_DIR)/boards/common-allwinner.mk
include $(TOP_DIR)/boards/common-firmware-armbian.mk
include $(TOP_DIR)/mk/common-armbian.mk
include $(TOP_DIR)/boards/common-cjdns-hack.mk
include $(TOP_DIR)/boards/common-initrd.mk

test:
	echo this board must be tested by flashing the output
	false

# Everything below this line is HW specific Armbian u-Boot startup code

$(TAG)/armbian:
	$(TOP_DIR)/scripts/get_deb $(DEBIAN_ARCH) $(ARMBIAN_KEY) $(ARMBIAN_REPO) $(ARMBIAN) $(ARMBIAN_UBOOT_PKG) $(ARMBIAN_KERNEL_PKG)
	$(call tag,armbian)

# Add the kernel specific binaries to this cpio file
$(BUILD)/modules.cpio: $(TAG)/armbian
	( \
            cd $(ARMBIAN); \
            find lib/modules -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@
CLEAN_FILES += $(BUILD)/modules.cpio

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
$(BOOT)/armbianEnv.txt: armbian/lib/config/bootenv/sunxi-default.txt
	cp $< $@

$(BOOT)/zImage: $(TAG)/boot $(TAG)/armbian
	cp $(ARMBIAN)/boot/vmlinuz-* $(BOOT)/zImage
	cp $(ARMBIAN)/boot/config-* $(BOOT)

dtb: $(TAG)/dtb
$(TAG)/dtb: $(TAG)/boot
	mkdir -p $(BOOT)/dtb
	$(call tag,dtb)

$(SRC_FDT): $(TAG)/armbian

$(BOOT)/dtb/$(BOARD).dtb: $(TAG)/dtb
$(BOOT)/dtb/$(BOARD).dtb: $(SRC_FDT)
	cp $< $@

dtbo: $(TAG)/dtbo
$(TAG)/dtbo: $(TAG)/dtb
	mkdir -p $(BOOT)/dtb/overlay
	$(call tag,dtbo)

$(BOOT)/dtb/overlay/%.dtbo: $(TAG)/armbian $(TAG)/dtbo
	touch $@ # FIXME
	#cp $< $@

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

BOOT_DTBO_FILES = \
    $(BOOT)/dtb/overlay/sun8i-h3-usbhost0.dtbo \
    $(BOOT)/dtb/overlay/sun8i-h3-usbhost2.dtbo \
    $(BOOT)/dtb/overlay/sun8i-h3-usbhost3.dtbo \

boot: $(BOOT_FILES) $(BOOT_DTB_FILES) $(BOOT_DTBO_FILES)

# Everything below this line is packing the built boot dir into a disk image

$(SRC_SPL): $(TAG)/armbian

$(DISK_IMAGE): $(SRC_SPL) $(BUILD)/mtoolsrc $(BOOT_FILES) $(BOOT_DTB_FILES) $(BOOT_DTBO_FILES)
	$(call image_normal)
	$(call allwinner_normal,$@.tmp,$(SRC_SPL),$(BUILD)/mtoolsrc,z:,$(BOOT_FILES),$(BOOT_DTB_FILES))
	$(call uboot_copy_overlayfiles,$(BUILD)/mtoolsrc,z:,$(BOOT_DTBO_FILES))
	mv $@.tmp $@
