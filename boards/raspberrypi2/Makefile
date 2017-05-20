#
# Build a raspberry pi install
#
# This works on the 2b and should work for the 3b and cm3 (but I have
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

# TODO - this is unwieldly
DEBIAN = ../../debian/build/debian.$(DEBIAN_VER).$(DEBIAN_ARCH).lzma

BOARD = raspberrypi2

PART_SIZE_MEGS = 1000

# Directories
BUILD = build
TAG = $(BUILD)/tags
RASPBERRYPI = $(BUILD)/raspberrypi
BOOT = $(BUILD)/boot

DISK_IMAGE = $(BUILD)/disk.img

BUILD_DEPENDS = \
    multistrap \
    fakeroot \
    xz-utils \
    mtools \

all: $(DISK_IMAGE)

image: ../../output/$(BOARD).img

../../output/$(BOARD).img: $(DISK_IMAGE)
	mkdir -p $(dir $@)
	cp $< $@

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


$(RASPBERRYPI): $(TAG)/raspberrypi
$(TAG)/raspberrypi: raspberrypi.multistrap
	mkdir -p $(RASPBERRYPI)
	fakeroot /usr/sbin/multistrap -d $(RASPBERRYPI) -f $<
	$(call tag,raspberrypi)

# Add the kernel specific binaries to this cpio file
$(BUILD)/modules.cpio: $(TAG)/raspberrypi
	( \
            cd $(RASPBERRYPI); \
            find lib/modules -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@

$(BUILD)/firmware.cpio: $(TAG)/raspberrypi
	( \
            cd $(RASPBERRYPI); \
            find lib/firmware -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@

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

# Combine the various modules to make one big cpio file
$(BUILD)/combined.initrd: $(DEBIAN) $(BUILD)/modules.lzma $(BUILD)/firmware.lzma
	cat $^ >$@

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

# Misc make infrastructure below here

%.lzma: %.cpio
	lzma <$< >$@

clean:
	rm -rf $(TAG) $(RASPBERRYPI) $(BUILD)/modules.cpio $(BUILD)/modules.lzma $(BUILD)/firmware.cpio $(BUILD)/firmware.lzma $(BOOT) $(BUILD)/mtoolsrc

reallyclean:
	rm -rf $(BUILD)

define tag
	@echo Touching tag $1
	@mkdir -p $(TAG)
	@touch $(TAG)/$1
endef

