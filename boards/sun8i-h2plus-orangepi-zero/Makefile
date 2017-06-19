#
# Build a Orange Pi Zero install
#

DEBIAN_VER = stretch
DEBIAN_ARCH = armhf

# TODO - this is unwieldly
DEBIAN = ../../debian/build/debian.$(DEBIAN_VER).$(DEBIAN_ARCH).lzma

# which uboot and device tree is this being built for
UBOOT = linux-u-boot-dev-orangepizero_5.31_armhf
BOARD = sun8i-h2plus-orangepi-zero
# FIXME - it would be nice if the uboot name was related to the dtb name

SRC_SPL = $(ARMBIAN)/usr/lib/$(UBOOT)/u-boot-sunxi-with-spl.bin
SRC_DTBDIR = $(ARMBIAN)/usr/lib/linux-image-dev-sun8i
SRC_FDT = $(SRC_DTBDIR)/$(BOARD).dtb
SRC_DTBO = $(SRC_DTBDIR)/overlay

PART_SIZE_MEGS = 1000

# Directories
BUILD = build
TAG = $(BUILD)/tags
ARMBIAN = $(BUILD)/armbian
BOOT = $(BUILD)/boot

DISK_IMAGE = $(BUILD)/disk.img

BUILD_DEPENDS = \
    multistrap \
    fakeroot \
    u-boot-tools \
    xz-utils \
    mtools \

all: $(DISK_IMAGE)

image: $(DISK_IMAGE)
	mkdir -p ../../output
	cp $< ../../output/$(BOARD).img

test:
	echo this board must be tested by flashing the output
	false

# install any packages needed for this builder
build-depends: $(TAG)/build-depends
$(TAG)/build-depends:
	sudo apt-get -y install $(BUILD_DEPENDS)
	$(call tag,build-depends)

# we might need to go and make the debian
# Note: this has no dependancy checking, and will simply use what ever
# file is there
$(DEBIAN):
	$(MAKE) -C ../../debian build/debian.$(DEBIAN_VER).$(DEBIAN_ARCH).lzma  CONFIG_DEBIAN_ARCH=$(DEBIAN_ARCH)

# Everything below this line is HW specific Armbian u-Boot startup code

$(ARMBIAN): $(TAG)/armbian
$(TAG)/armbian: armbian.multistrap
	mkdir -p $(ARMBIAN)
	fakeroot /usr/sbin/multistrap -d $(ARMBIAN) -f $<
	$(call tag,armbian)

# Add the kernel specific binaries to this cpio file
$(BUILD)/modules.cpio: $(TAG)/armbian
	( \
            cd $(ARMBIAN); \
            find lib/modules -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@

# Add the kernel specific binaries to this cpio file
$(BUILD)/firmware.cpio: $(TAG)/armbian
	( \
            cd $(ARMBIAN); \
            find lib/firmware -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@

$(BOOT): $(TAG)/boot
$(TAG)/boot:
	mkdir -p $(BOOT)
	$(call tag,boot)

$(BOOT)/.next: $(TAG)/boot
	touch $@

# TODO
# - stop using our local version of these files.
# These two files ( boot-sunxi.cmd and armbianEnv.txt ) are copied from the
# armbian git repo.  They are also found in one of the armbian packages
# ( linux-jessie-root-dev-orangepizero ) this package has dependancies that
# make it annoying to install in the ARMBIAN dir and has a rather annoying mix
# of installed files that meant that it was not suitable to be installed in
# the DEBOOT either.

$(BOOT)/boot.scr: $(TAG)/boot
$(BOOT)/boot.scr: armbian/lib/config/bootscripts/boot-sunxi.cmd
	mkimage -A arm -T script -C none -d $< $@

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

# Since the uboot and kernel versions are mismatched, we have this
# hack here to line up the two names. TODO - remove when possible
$(BOOT)/dtb/sun8i-h2-plus-orangepi-zero.dtb: $(BOOT)/dtb/$(BOARD).dtb
	cp $< $@

dtbo: $(TAG)/dtbo
$(TAG)/dtbo: $(TAG)/dtb
	mkdir -p $(BOOT)/dtb/overlay
	$(call tag,dtbo)

$(BOOT)/dtb/overlay/%.dtbo: $(SRC_DTBO)/%.dtbo $(TAG)/dtbo
	cp $< $@

# Combine the various modules to make one big cpio file
$(BUILD)/combined.initrd: $(DEBIAN) $(BUILD)/modules.lzma $(BUILD)/firmware.lzma
	cat $^ >$@

$(BOOT)/uInitrd: $(TAG)/boot
$(BOOT)/uInitrd: $(BUILD)/combined.initrd
	mkimage -C lzma -A arm -T ramdisk -d $< $@

BOOT_FILES = \
    $(BOOT)/boot.scr $(BOOT)/armbianEnv.txt \
    $(BOOT)/.next \
    $(BOOT)/zImage \
    $(BOOT)/uInitrd \

# This should use the $(BOARD).dtb when we can upgrade to the current
# kernel TODO - remove when possible
BOOT_DTB_FILES = \
    $(BOOT)/dtb/sun8i-h2-plus-orangepi-zero.dtb \

BOOT_DTBO_FILES = \
    $(BOOT)/dtb/overlay/sun8i-h3-usbhost0.dtbo \
    $(BOOT)/dtb/overlay/sun8i-h3-usbhost2.dtbo \
    $(BOOT)/dtb/overlay/sun8i-h3-usbhost3.dtbo \

boot: $(BOOT_FILES) $(BOOT_DTB_FILES) $(BOOT_DTBO_FILES)

# Everything below this line is packing the built boot dir into a disk image

$(SRC_SPL): $(TAG)/armbian

$(BUILD)/mtoolsrc: Makefile
	echo 'drive z: file="$(DISK_IMAGE).tmp" cylinders=$(PART_SIZE_MEGS) heads=64 sectors=32 partition=1 mformat_only' >$@

$(DISK_IMAGE): $(SRC_SPL) $(BUILD)/mtoolsrc $(BOOT_FILES) $(BOOT_DTB_FILES) $(BOOT_DTBO_FILES)
	truncate --size=$$((0x200)) $@.tmp   # skip past the MBR
	date -u "+%FT%TZ " >>$@.tmp          # add a build date
	git describe --long --dirty >>$@.tmp # and describe the repo
	truncate --size=$$((0x2000)) $@.tmp  # skip to correct offset for SPL
	cat $(SRC_SPL) >>$@.tmp              # add the SPL+uboot binary
	MTOOLSRC=$(BUILD)/mtoolsrc mpartition -I z:
	MTOOLSRC=$(BUILD)/mtoolsrc mpartition -c -b $$((0x100000/512)) z:
	truncate --size=1025K $@.tmp    # ensure the FAT bootblock is mapped
	MTOOLSRC=$(BUILD)/mtoolsrc mformat -v boot -N 1 z:
	MTOOLSRC=$(BUILD)/mtoolsrc mmd z:boot
	MTOOLSRC=$(BUILD)/mtoolsrc mcopy $(BOOT_FILES) z:boot
	MTOOLSRC=$(BUILD)/mtoolsrc mmd z:boot/dtb
	MTOOLSRC=$(BUILD)/mtoolsrc mcopy $(BOOT_DTB_FILES) z:boot/dtb
	MTOOLSRC=$(BUILD)/mtoolsrc mmd z:boot/dtb/overlay
	MTOOLSRC=$(BUILD)/mtoolsrc mcopy $(BOOT_DTBO_FILES) z:boot/dtb/overlay
	mv $@.tmp $@

# Misc make infrastructure below here

%.lzma: %.cpio
	lzma <$< >$@

clean:
	rm -rf $(TAG) $(ARMBIAN) $(BUILD)/modules.cpio $(BUILD)/modules.lzma $(BUILD)/firmware.cpio $(BUILD)/firmware.lzma $(BOOT) $(BUILD)/mtoolsrc

reallyclean:
	rm -rf $(BUILD)

define tag
	@echo Touching tag $1
	@mkdir -p $(TAG)
	@touch $(TAG)/$1
endef

