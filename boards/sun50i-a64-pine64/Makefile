#
# Build a pine64
#

DEBIAN_VER = stretch
DEBIAN_ARCH = armhf

# TODO - this is unwieldly
DEBIAN = ../../debian/build/debian.$(DEBIAN_VER).$(DEBIAN_ARCH).lzma

# which uboot and device tree is this being built for
UBOOT = linux-u-boot-dev-pine64_5.25_arm64
BOARD = sun50i-a64-pine64-plus
# FIXME - it would be nice if the uboot name was related to the dtb name

SRC_SPL = $(ARMBIAN)/usr/lib/$(UBOOT)/u-boot-sunxi-with-spl.bin
SRC_FDT = $(ARMBIAN)/usr/lib/linux-image-dev-pine64/allwinner/sun50i-a64-pine64-plus.dtb

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

# TODO
# - stop using our local version of these files.
# These two files ( boot.scr and armbianEnv.txt ) are copied from the
# armbian git repo.  They are also found in one of the armbian packages
# ( linux-jessie-root-dev-orangepizero ) this package has dependancies that
# make it annoying to install in the ARMBIAN dir and has a rather annoying mix
# of installed files that meant that it was not suitable to be installed in
# the DEBOOT either.

$(BOOT)/boot.scr: $(TAG)/boot
$(BOOT)/boot.scr: armbian/lib/config/bootscripts/boot-pine64-default.cmd
	mkimage -A arm -T script -C none -d $< $@

$(BOOT)/armbianEnv.txt: $(TAG)/boot
$(BOOT)/armbianEnv.txt: armbian/lib/config/bootenv/pine64-default.txt
	cp $< $@

$(BOOT)/Image: $(TAG)/boot $(TAG)/armbian
	cp $(ARMBIAN)/boot/Image-* $@
	cp $(ARMBIAN)/boot/config-* $(BOOT)

dtb: $(TAG)/dtb
$(TAG)/dtb: $(TAG)/boot
	mkdir -p $(BOOT)/dtb
	$(call tag,dtb)

$(SRC_FDT): $(TAG)/armbian

$(BOOT)/dtb/$(BOARD).dtb: $(TAG)/dtb
$(BOOT)/dtb/$(BOARD).dtb: $(SRC_FDT)
	cp $< $@

# Combine the various modules to make one big cpio file
$(BUILD)/combined.initrd: $(DEBIAN) $(BUILD)/modules.lzma $(BUILD)/firmware.lzma
	cat $^ >$@

$(BOOT)/uInitrd: $(TAG)/boot
$(BOOT)/uInitrd: $(BUILD)/combined.initrd
	mkimage -C lzma -A arm -T ramdisk -d $< $@

BOOT_FILES = \
    $(BOOT)/boot.scr $(BOOT)/armbianEnv.txt \
    $(BOOT)/Image \
    $(BOOT)/uInitrd \

BOOT_DTB_FILES = \
    $(BOOT)/dtb/$(BOARD).dtb \

boot: $(BOOT_FILES) $(BOOT_DTB_FILES)

# Everything below this line is packing the built boot dir into a disk image

$(SRC_SPL): $(TAG)/armbian

$(BUILD)/mtoolsrc: Makefile
	echo 'drive z: file="$(DISK_IMAGE).tmp" cylinders=$(PART_SIZE_MEGS) heads=64 sectors=32 partition=1 mformat_only' >$@

$(DISK_IMAGE): $(SRC_SPL) $(BUILD)/mtoolsrc $(BOOT_FILES) $(BOOT_DTB_FILES)
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

