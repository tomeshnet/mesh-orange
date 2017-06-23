#
# Build a Lichee Pi Zero install
#
# Note that this is a little different from other systems - it only has 64M
# of ram, so cannot use a ramdisk
#

DEBIAN_VER = stretch
DEBIAN_ARCH = armhf

# TODO - this is unwieldly
DEBIAN = ../../debian/build/debian.$(DEBIAN_VER).$(DEBIAN_ARCH).cpio

# which uboot and device tree is this being built for
UBOOT = u-boot-sunxi-with-spl_480800.bin
BOARD = sun8i-v3s-licheepi-zero
# FIXME - it would be nice if the uboot name was related to the dtb name

SRC_SPL = $(ZIP)/$(UBOOT)
SRC_DTB = $(ZIP)/$(BOARD).dtb

PART1_SIZE_MEGS = 1000 # dosfs boot
PART2_SIZE_MEGS = 1000 # reserved for swap
PART3_SIZE_MEGS = 1000 # ext2 root

PART1_BEGIN_SEC = $$((0x100000/512))
PART2_BEGIN_SEC = $$(( $(PART1_BEGIN_SEC) + ($(PART1_SIZE_MEGS) *1024*1024) /512))
PART3_BEGIN_SEC = $$(( $(PART2_BEGIN_SEC) + ($(PART2_SIZE_MEGS) *1024*1024) /512))

IMAGE_SIZE_MEGS = $$(( 0x100000/1024/1024 + $(PART1_SIZE_MEGS) + $(PART2_SIZE_MEGS) + $(PART3_SIZE_MEGS) ))

# Directories
BUILD = build
TAG = $(BUILD)/tags
ZIP = $(BUILD)/zero_imager
BOOT = $(BUILD)/boot
DEBOOT = $(BUILD)/deboot

DISK_IMAGE = $(BUILD)/disk.img

BUILD_DEPENDS = \
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
	$(MAKE) -C ../../debian build/debian.$(DEBIAN_VER).$(DEBIAN_ARCH).cpio  CONFIG_DEBIAN_ARCH=$(DEBIAN_ARCH)

# Everything below this line is HW specific setup

$(BUILD)/zero_imager.zip:
	mkdir -p build
	wget -O $@ https://licheepizero.us/downloads/zero_imager.zip
	touch $@

# extract debian and merge the firmware and modules into the debian root dir
$(DEBOOT): $(DEBIAN) $(BUILD)/zero_imager.zip
	unzip $(BUILD)/zero_imager.zip -d $(BUILD)
	mkdir -p $@
	cat $(DEBIAN) | ( \
            cd $@; \
            cpio --make-directories -i --nonmatching dev/urandom; \
	)
	mkdir -p $(DEBOOT)/lib/firmware
	cp -r $(ZIP)/overlay_rootfs-base/lib/firmware/ $(DEBOOT)/lib/firmware/
	mkdir -p $(DEBOOT)/lib/modules
	cp -r $(ZIP)/overlay_rootfs-base/lib/modules/ $(DEBOOT)/lib/modules/

$(BOOT): $(TAG)/boot
$(TAG)/boot:
	mkdir -p $(BOOT)
	$(call tag,boot)

$(BOOT)/boot.scr: $(TAG)/boot
$(BOOT)/boot.scr: boot.cmd
	mkimage -A arm -T script -C none -d $< $@

$(BOOT)/zImage: $(TAG)/boot $(ZIP)
	cp $(ZIP)/zImage $(BOOT)/zImage

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

$(DISK_IMAGE): $(SRC_SPL) $(BUILD)/mtoolsrc $(BOOT_FILES) $(BOOT_DTB_FILES)
	truncate --size=$$((0x200)) $@.tmp   # skip past the MBR
	date -u "+%FT%TZ " >>$@.tmp          # add a build date
	git describe --long --dirty >>$@.tmp # and describe the repo
	truncate --size=$$((0x2000)) $@.tmp  # skip to correct offset for SPL
	cat $(SRC_SPL) >>$@.tmp              # add the SPL+uboot binary
	MTOOLSRC=$(BUILD)/mtoolsrc mpartition -I z:
	MTOOLSRC=$(BUILD)/mtoolsrc mpartition -c -b $(PART1_BEGIN_SEC) z:
	MTOOLSRC=$(BUILD)/mtoolsrc mpartition -c -b $(PART2_BEGIN_SEC) y:
	MTOOLSRC=$(BUILD)/mtoolsrc mpartition -c -b $(PART3_BEGIN_SEC) x:
	truncate --size=$(IMAGE_SIZE_MEGS)M $@.tmp    # map the whole image
	MTOOLSRC=$(BUILD)/mtoolsrc mformat -v boot -N 1 z:
	MTOOLSRC=$(BUILD)/mtoolsrc mcopy $(BOOT_FILES) z:/
	MTOOLSRC=$(BUILD)/mtoolsrc mmd z:/dtb
	MTOOLSRC=$(BUILD)/mtoolsrc mcopy $(BOOT_DTB_FILES) z:/dtb
	mv $@.tmp $@

# Misc make infrastructure below here

clean:
	rm -rf $(TAG) $(ZIP) $(BOOT) $(BUILD)/mtoolsrc

reallyclean:
	rm -rf $(BUILD)

define tag
	@echo Touching tag $1
	@mkdir -p $(TAG)
	@touch $(TAG)/$1
endef

