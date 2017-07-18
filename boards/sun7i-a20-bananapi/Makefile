#
# Build a Banana Pi install
#

DEBIAN_VER = stretch
DEBIAN_ARCH = armhf

# which uboot and device tree is this being built for
ARMBIAN_UBOOT_PKG = linux-u-boot-bananapi-dev
ARMBIAN_KERNEL_PKG = linux-image-dev-sunxi
UBOOT = linux-u-boot-dev-bananapi_5.31_armhf
BOARD = sun7i-a20-bananapi
# FIXME - it would be nice if the uboot name was related to the dtb name

SRC_SPL = $(ARMBIAN)/usr/lib/$(UBOOT)/u-boot-sunxi-with-spl.bin
SRC_DTBDIR = $(ARMBIAN)/usr/lib/linux-image-dev-sunxi
SRC_DTB = $(SRC_DTBDIR)/$(BOARD).dtb

PART_SIZE_MEGS = 1000

INITRD_PARTS += $(BUILD)/modules.lzma
CLEAN_FILES += $(BUILD)/modules.lzma

CLEAN_FILES += $(TAG) $(ARMBIAN) $(BOOT) $(BUILD)/mtoolsrc

# Directories
ARMBIAN = $(BUILD)/armbian

BUILD_DEPENDS = \
    xz-utils \

all: image

include ../common.mk
include ../common-uboot.mk
include ../common-allwinner.mk
include ../common-firmware-armbian.mk
include ../common-armbian.mk
include ../common-cjdns-hack.mk
include ../common-initrd.mk

image: $(DISK_IMAGE)
	mkdir -p ../../output
	cp $< ../../output/$(BOARD).img

test:
	echo this board must be tested by flashing the output
	false

# Everything below this line is HW specific Armbian u-Boot startup code

$(TAG)/armbian:
	../../scripts/get_deb $(DEBIAN_ARCH) $(ARMBIAN_KEY) $(ARMBIAN_REPO) $(ARMBIAN) $(ARMBIAN_UBOOT_PKG) $(ARMBIAN_KERNEL_PKG)
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
$(BOOT)/armbianEnv.txt: armbianEnv.txt
	cp $< $@

$(BOOT)/zImage: $(TAG)/boot $(TAG)/armbian
	cp $(ARMBIAN)/boot/vmlinuz-* $(BOOT)/zImage
	cp $(ARMBIAN)/boot/config-* $(BOOT)

dtb: $(TAG)/dtb
$(TAG)/dtb: $(TAG)/boot
	mkdir -p $(BOOT)/dtb
	$(call tag,dtb)

$(SRC_DTB): $(TAG)/armbian

$(BOOT)/dtb/$(BOARD).dtb: $(TAG)/dtb
$(BOOT)/dtb/$(BOARD).dtb: $(SRC_DTB)
	cp $< $@

dtbo: $(TAG)/dtbo
$(TAG)/dtbo: $(TAG)/dtb
	mkdir -p $(BOOT)/dtb/overlay
	$(call tag,dtbo)

$(BOOT)/dtb/overlay/%.dtbo: $(TAG)/armbian $(TAG)/dtbo
	cp $< $@

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

$(BUILD)/mtoolsrc: Makefile
	echo 'drive z: file="$(DISK_IMAGE).tmp" cylinders=$(PART_SIZE_MEGS) heads=64 sectors=32 partition=1 mformat_only' >$@

$(DISK_IMAGE): $(SRC_SPL) $(BUILD)/mtoolsrc $(BOOT_FILES) $(BOOT_DTB_FILES)
	$(call allwinner_spl,$(SRC_SPL),$@.tmp)
	truncate --size=1025K $@.tmp    # ensure the FAT bootblock is mapped
	$(call uboot_bootdir,$(BUILD)/mtoolsrc,z:,$$((0x100000/512)),$(BOOT_FILES),$(BOOT_DTB_FILES))
	mv $@.tmp $@
