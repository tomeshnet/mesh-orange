#
# Build a debian and armbian based initramfs system
#

# TODO:
# - Convert the minimalisation step into an excludes file generator
#   and use that file in the cpio step
# - Add a real minimalisation engine
# - Add the same for fixups
# - Add config file list / save to sdcard / load from sdcard package

# which uboot and device tree is this being built for
CONFIG_UBOOT = linux-u-boot-dev-orangepizero_5.25_armhf
CONFIG_FDT = sun8i-h2plus-orangepi-zero.dtb

DEBIAN_VER = stretch
DISK_IMAGE = $(BUILD)/allwinner-h2.raw

# Directories
BUILD = build
TAG = $(BUILD)/tags
DEBOOT = $(BUILD)/debian
BOOT = $(BUILD)/boot

BUILD_DEPENDS = \
    multistrap \
    binfmt-support \
    qemu-user-static \
    u-boot-tools \
    xz-utils \
    mtools \

SRC_SPL = $(DEBOOT)/usr/lib/$(CONFIG_UBOOT)/u-boot-sunxi-with-spl.bin
SRC_FDT = $(DEBOOT)/usr/lib/linux-image-dev-sun8i/$(CONFIG_FDT)

all: $(DISK_IMAGE)

# install any packages needed for this builder
build-depends: $(TAG)/build-depends
$(TAG)/build-depends:
	sudo apt-get -y install $(BUILD_DEPENDS)
	$(call tag,build-depends)

# some of the debian packages need a urandom to install properly
$(DEBOOT)/dev/urandom:
	mkdir -p $(DEBOOT)/dev
	sudo mknod $(DEBOOT)/dev/urandom c 1 9

# multistrap-pre runs the basic multistrap program, installing the packages
# until they need to run native code
$(TAG)/multistrap-pre: multistrap.conf multistrap.configscript
$(TAG)/multistrap-pre: $(DEBOOT)/dev/urandom
	sudo /usr/sbin/multistrap -d $(DEBOOT) -f multistrap.conf
	$(call tag,multistrap-pre)

# TODO: if TARGET_ARCH == BUILD_ARCH, dont need to copy qemu
$(DEBOOT)/usr/bin/qemu-arm-static: /usr/bin/qemu-arm-static
	sudo cp /usr/bin/qemu-arm-static $(DEBOOT)/usr/bin/qemu-arm-static

# multistrap-post runs the package configure scripts under emulation
multistrap-post: $(TAG)/multistrap-post
$(TAG)/multistrap-post: $(DEBOOT)/usr/bin/qemu-arm-static $(TAG)/multistrap-pre
	sudo chroot $(DEBOOT) ./multistrap.configscript
	$(call tag,multistrap-post)

# TODO
# - search for and kill any daemons started by the dpkg configure:
#       sudo killall dropbear
#       sudo umount $(DEBOOT)/proc

# perform the debian install
multistrap: $(TAG)/multistrap
$(TAG)/multistrap: $(TAG)/multistrap-pre $(TAG)/multistrap-post
	$(call tag,multistrap)

# very basic minimalisation of the image size
# This just hits the very basic directories.  A more comprehensive system
# could use a specific hit-list for each package - this exists, but I dont
# want to complicate things too much (at first)
minimise: $(TAG)/minimise
$(TAG)/minimise: $(TAG)/multistrap
	sudo rm -rf $(DEBOOT)/usr/share/locale/*
	sudo rm -rf $(DEBOOT)/usr/share/zoneinfo/*
	sudo rm -f $(DEBOOT)/lib/udev/hwdb.bin
	sudo rm -f $(DEBOOT)/multistrap.configscript $(DEBOOT)/dev/mmcblk0
	#sudo rm -f $(DEBOOT)/usr/bin/qemu-arm-static
	$(call tag,minimise)

# very basic fixup
# This is the changes needed to make the image actually bootable, or to
# fix error conditions caused by the minimalisation.  Similar to the
# minimiser, this could be improved.
fixup: $(TAG)/fixup
$(TAG)/fixup: $(TAG)/multistrap
	sudo ln -sf lib/systemd/systemd $(DEBOOT)/init       # allow booting
	sudo perl -pi -e 's/:\*:/::/' $(DEBOOT)/etc/shadow   # empty password
	$(call tag,fixup)

# FIXME: obviously, an empty password should not go live

# TODO:
# basic customisation
# A make task to add/remove/edit config files in the image to configure
# it to be useful (in contrast to fixing what is broken in the "fixup"
# above).  E.G: configuring daemons to start on bootup, or installing
# a set of ssh authorised keys

debian: $(TAG)/debian
$(TAG)/debian: $(TAG)/minimise $(TAG)/fixup
	$(call tag,debian)

$(BUILD)/debian.$(DEBIAN_VER).cpio: $(TAG)/debian
	( \
            cd $(DEBOOT); \
            sudo find . -print0 | sudo cpio -0 -H newc -R 0:0 -o -V \
	) > $@

%.lzma: %.cpio
	lzma <$< >$@

$(BOOT): $(TAG)/boot_dir
$(TAG)/boot_dir:
	mkdir -p $(BOOT)
	$(call tag,boot_dir)

$(BOOT)/uInitrd: $(TAG)/boot_dir
$(BOOT)/uInitrd: $(BUILD)/debian.stretch.lzma
	mkimage -C lzma -A arm -T ramdisk -d $< $@

# Everything above this line is a generic Debian armhf builder

# Everything below this line is HW specific Armbian u-Boot startup code

$(BOOT)/.next: $(TAG)/boot_dir
	touch $@

$(SRC_FDT): $(TAG)/multistrap

# FIXME - we would like the minimise step to remove the DEBOOT/boot dir, but
# we have this dependancy on that dir, so it means we break things. (I think
# we need an exclude list for the cpio files list)
$(DEBOOT)/boot/zImage: $(TAG)/multistrap

# If we install the linux-jessie-root-dev-orangepizero package, we get these
# two boot pre-requisites, but we also get a heap of other junk
#$(DEBOOT)/usr/share/armbian/boot.cmd: $(TAG)/multistrap
#$(DEBOOT)/usr/share/armbian/armbianEnv.txt: $(TAG)/multistrap

$(BOOT)/boot.scr: $(TAG)/boot_dir
$(BOOT)/boot.scr: armbian/lib/config/bootscripts/boot-sunxi.cmd
	mkimage -A arm -T script -C none -d $< $@

$(BOOT)/armbianEnv.txt: $(TAG)/boot_dir
$(BOOT)/armbianEnv.txt: armbian/lib/config/bootenv/sunxi-default.txt
	cp $< $@

$(BOOT)/zImage: $(TAG)/boot_dir
$(BOOT)/zImage: $(DEBOOT)/boot/zImage
	cp `realpath $<` $(BOOT)/`readlink $<`
	cp $(DEBOOT)/boot/config-* $(BOOT)
	cp -d $< $(BOOT)/zImage

dtb_suffix = $(shell readlink $(BOOT)/zImage |sed -e 's/vmlinuz-//')
dtb_dir: $(TAG)/dtb_dir
$(TAG)/dtb_dir: $(BOOT)/zImage
	mkdir -p $(BOOT)/dtb-$(dtb_suffix)
	ln -sf dtb-$(dtb_suffix) $(BOOT)/dtb
	$(call tag,dtb_dir)

$(BOOT)/dtb/$(CONFIG_FDT): $(TAG)/dtb_dir
$(BOOT)/dtb/$(CONFIG_FDT): $(SRC_FDT)
	cp $< $@

BOOT_FILES = \
    $(BOOT)/boot.scr $(BOOT)/armbianEnv.txt \
    $(BOOT)/.next \
    $(BOOT)/zImage \
    $(BOOT)/uInitrd \

BOOT_DTB_FILES = \
    $(BOOT)/dtb/$(CONFIG_FDT) \

boot: $(BOOT_FILES) $(BOOT_DTB_FILES)

# Everything below this line is packing the built boot dir into a disk image

$(SRC_SPL): $(TAG)/multistrap

PART_SIZE_MEGS = 1000

$(BUILD)/mtoolsrc:
	echo 'drive z: file="$(DISK_IMAGE)" cylinders=$(PART_SIZE_MEGS) heads=64 sectors=32 partition=1 mformat_only' >$@

$(DISK_IMAGE): $(SRC_SPL) $(BUILD)/mtoolsrc boot
	truncate --size=$$((0x2000)) $@ # skip to correct offset for SPL
	cat $(SRC_SPL) >>$@             # add the SPL+uboot binary
	MTOOLSRC=$(BUILD)/mtoolsrc mpartition -I z:
	MTOOLSRC=$(BUILD)/mtoolsrc mpartition -c -b $$((0x100000/512)) z:
	truncate --size=1025K $@        # ensure the FAT bootblock is mapped
	MTOOLSRC=$(BUILD)/mtoolsrc mformat -v boot -N 1 z:
	MTOOLSRC=$(BUILD)/mtoolsrc mmd z:boot
	MTOOLSRC=$(BUILD)/mtoolsrc mcopy $(BOOT_FILES) z:boot
	MTOOLSRC=$(BUILD)/mtoolsrc mmd z:boot/dtb
	MTOOLSRC=$(BUILD)/mtoolsrc mcopy $(BOOT_DTB_FILES) z:boot/dtb

# Misc make infrastructure below here

clean:
	sudo rm -rf $(DEBOOT) $(BOOT) $(TAG)

define tag
	@echo Touching tag $1
	@mkdir -p $(TAG)
	@touch $(TAG)/$1
endef

