#
# Build a raspberry pi install
#
# This works on the 2b and 3b and should work for the cm3 (but I have
# not tested that) as they are all using ARMv7+ CPUs that are compatible
# with the Debian "armhf" architecture definition.
#
# The other raspberry pi systems (the older ones and the Zeros) all use
# an ARMv6+VFP cpu, which is incompatible with the Debian "armhf" - do
# not be fooled by the fact that raspbian uses an architecture called
# "armhf", they have simply (and confusingly) redefined their architecture
# to match their needs.
#
# The most annoying bit about this is that the world now has two
# Debian-ish architectures named armhf that are only compatible in one
# direction (Raspbian armhf binaries should work on Debian armhf systems -
# just slightly slower) and no clear naming to tell them apart, thus
# making multiarch impossible to use to fix this.
#
# The upshot is that the build system could build images for the other
# raspberry pi systems, but it would need the debian builder to build
# one based on raspbian.
#

DEBIAN_VER = stretch
DEBIAN_ARCH = armhf

BOARD = raspberrypi2

RASPBIAN_BOOT_PKG = raspberrypi-bootloader
RASPBIAN_KERNEL_PKG = raspberrypi-kernel

PART_SIZE_MEGS = 1000

INITRD_PARTS += $(BUILD)/modules.lzma
CLEAN_FILES += $(BUILD)/modules.lzma

CLEAN_FILES += $(TAG) $(RASPBERRYPI) $(BOOT) $(BUILD)/mtoolsrc

# Directories
RASPBERRYPI = $(BUILD)/raspberrypi

BUILD_DEPENDS = \
    xz-utils \
    mtools \

TOP_DIR ?= ../..

all: image

include $(TOP_DIR)/mk/common.mk
include $(TOP_DIR)/boards/common-firmware-raspbian.mk
include $(TOP_DIR)/mk/common-raspbian.mk
include $(TOP_DIR)/boards/common-cjdns-hack.mk
include $(TOP_DIR)/boards/common-initrd.mk

image: $(TOP_DIR)/output/$(BOARD).img

$(TOP_DIR)/output/$(BOARD).img: $(DISK_IMAGE)
	mkdir -p $(dir $@)
	cp $< $@

test:
	echo this board must be tested by flashing the output
	false

$(TAG)/raspberrypi:
	$(TOP_DIR)/scripts/get_deb $(DEBIAN_ARCH) $(RASPBIAN_KEY) $(RASPBIAN_REPO) $(RASPBERRYPI) $(RASPBIAN_BOOT_PKG) $(RASPBIAN_KERNEL_PKG)
	$(call tag,raspberrypi)

# Add the kernel specific binaries to this cpio file
$(BUILD)/modules.cpio: $(TAG)/raspberrypi
	( \
            cd $(RASPBERRYPI); \
            find lib/modules -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@
CLEAN_FILES += $(BUILD)/modules.cpio

$(BUILD): $(TAG)/build
$(TAG)/build:
	mkdir -p $(BUILD)
	$(call tag,build)

$(BOOT): $(TAG)/boot
$(TAG)/boot:
	mkdir -p $(BOOT)
	$(call tag,boot)

$(BOOT)/kernel7.img: $(TAG)/boot $(TAG)/raspberrypi
	cp $(RASPBERRYPI)/boot/kernel7.img $@

$(BOOT)/initrd: $(TAG)/boot
$(BOOT)/initrd: $(BUILD)/combined.initrd
	cp $< $@

$(BOOT)/cmdline.txt: $(TAG)/boot Makefile
	echo "dwc_otg.lpm_enable=0 console=ttyAMA0,115200 console=tty1 elevator=deadline" >$@

$(BOOT)/config.txt: $(TAG)/boot Makefile
	echo "" >$@
	echo "initramfs initrd followkernel" >>$@
	echo "gpu_mem=16" >>$@
	echo "enable_uart=1" >>$@
	echo "dtdebug=1" >>$@

$(BOOT)/%: $(RASPBERRYPI)/boot/% $(TAG)/boot
	cp $< $@

# What an annoying array of dependancies
# TODO - make this more automatic

$(RASPBERRYPI)/boot/bootcode.bin: $(TAG)/raspberrypi
$(RASPBERRYPI)/boot/fixup_cd.dat: $(TAG)/raspberrypi
$(RASPBERRYPI)/boot/start_cd.elf: $(TAG)/raspberrypi
$(RASPBERRYPI)/boot/COPYING.linux: $(TAG)/raspberrypi
$(RASPBERRYPI)/boot/LICENCE.broadcom: $(TAG)/raspberrypi
$(RASPBERRYPI)/boot/bcm2709-rpi-2-b.dtb: $(TAG)/raspberrypi
$(RASPBERRYPI)/boot/bcm2710-rpi-3-b.dtb: $(TAG)/raspberrypi
$(RASPBERRYPI)/boot/bcm2710-rpi-cm3.dtb: $(TAG)/raspberrypi

$(BOOT)/bootcode.bin: $(RASPBERRYPI)/boot/bootcode.bin
$(BOOT)/fixup_cd.dat: $(RASPBERRYPI)/boot/fixup_cd.dat
$(BOOT)/start_cd.elf: $(RASPBERRYPI)/boot/start_cd.elf
$(BOOT)/COPYING.linux: $(RASPBERRYPI)/boot/COPYING.linux
$(BOOT)/LICENCE.broadcom: $(RASPBERRYPI)/boot/LICENCE.broadcom
$(BOOT)/bcm2709-rpi-2-b.dtb: $(RASPBERRYPI)/boot/bcm2709-rpi-2-b.dtb
$(BOOT)/bcm2710-rpi-3-b.dtb: $(RASPBERRYPI)/boot/bcm2710-rpi-3-b.dtb
$(BOOT)/bcm2710-rpi-cm3.dtb: $(RASPBERRYPI)/boot/bcm2710-rpi-cm3.dtb

BOOT_FILES = \
    $(BOOT)/bootcode.bin \
    $(BOOT)/start_cd.elf \
    $(BOOT)/fixup_cd.dat \
    $(BOOT)/kernel7.img \
    $(BOOT)/initrd \
    $(BOOT)/cmdline.txt \
    $(BOOT)/config.txt \
    $(BOOT)/COPYING.linux \
    $(BOOT)/LICENCE.broadcom \
    $(BOOT)/bcm2709-rpi-2-b.dtb \
    $(BOOT)/bcm2710-rpi-3-b.dtb \
    $(BOOT)/bcm2710-rpi-cm3.dtb \

boot: $(BOOT_FILES)

# Everything below this line is packing the built boot dir into a disk image

$(BUILD)/mtoolsrc: Makefile $(TAG)/build
	echo 'drive z: file="$(DISK_IMAGE).tmp" cylinders=$(PART_SIZE_MEGS) heads=64 sectors=32 partition=1 mformat_only' >$@

$(DISK_IMAGE): $(BUILD)/mtoolsrc $(BOOT_FILES)
	truncate --size=$$((0x200)) $@.tmp   # skip past the MBR
	date -u "+%FT%TZ " >>$@.tmp          # add a build date
	git describe --long --dirty >>$@.tmp # and describe the repo
	MTOOLSRC=$(BUILD)/mtoolsrc mpartition -I z:
	MTOOLSRC=$(BUILD)/mtoolsrc mpartition -c -b $$((0x100000/512)) z:
	truncate --size=1025K $@.tmp    # ensure the FAT bootblock is mapped
	MTOOLSRC=$(BUILD)/mtoolsrc mformat -v boot -N 1 z:
	MTOOLSRC=$(BUILD)/mtoolsrc mcopy $(BOOT_FILES) z:
	mv $@.tmp $@
