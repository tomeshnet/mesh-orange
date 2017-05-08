#
# Build a debian and armbian based initramfs system
#

# TODO:
# - Convert the minimalisation step into an excludes file generator
#   and use that file in the cpio step
# - Add a real minimalisation engine
# - Add the same for fixups
# - Add config file list / save to sdcard / load from sdcard package

CONFIG_DEBIAN = stretch
CONFIG_DEBIAN_ARCH = armhf

CONFIG_ROOT_PASS = root

# which uboot and device tree is this being built for
CONFIG_UBOOT = linux-u-boot-dev-orangepizero_5.25_armhf
CONFIG_BOARD = sun8i-h2plus-orangepi-zero
# FIXME - it would be nice if the uboot name was related to the dtb name

# Directories
BUILD = build
TAG = $(BUILD)/tags
DEBOOT = $(BUILD)/debian.$(CONFIG_DEBIAN).$(CONFIG_DEBIAN_ARCH)
BOARD_DIR = $(BUILD)/$(CONFIG_BOARD)
BOOT = $(BUILD)/boot
DISK_IMAGE = $(BUILD)/$(CONFIG_BOARD).img

BUILD_DEPENDS = \
    multistrap \
    binfmt-support \
    qemu-user-static \
    u-boot-tools \
    xz-utils \
    mtools \

SRC_SPL = $(BOARD_DIR)/usr/lib/$(CONFIG_UBOOT)/u-boot-sunxi-with-spl.bin
SRC_FDT = $(BOARD_DIR)/usr/lib/linux-image-dev-sun8i/$(CONFIG_BOARD).dtb

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
$(TAG)/multistrap-pre: debian.$(CONFIG_DEBIAN).multistrap multistrap.configscript
$(TAG)/multistrap-pre: $(DEBOOT)/dev/urandom
	sudo /usr/sbin/multistrap -d $(DEBOOT) --arch $(CONFIG_DEBIAN_ARCH) -f debian.$(CONFIG_DEBIAN).multistrap
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
	echo root:$(CONFIG_ROOT_PASS) | sudo chpasswd -c SHA256 -R $(realpath $(DEBOOT))
	$(call tag,fixup)

# TODO: consider what password should be default

# TODO:
# basic customisation
# A make task to add/remove/edit config files in the image to configure
# it to be useful (in contrast to fixing what is broken in the "fixup"
# above).  E.G: configuring daemons to start on bootup, or installing
# a set of ssh authorised keys

debian: $(TAG)/debian
$(TAG)/debian: $(TAG)/minimise $(TAG)/fixup
	$(call tag,debian)

$(BUILD)/debian.$(CONFIG_DEBIAN).$(CONFIG_DEBIAN_ARCH).cpio: $(TAG)/debian
	( \
            cd $(DEBOOT); \
            sudo find . -print0 | sudo cpio -0 -H newc -R 0:0 -o \
	) > $@

# Everything above this line is a generic Debian armhf builder

# Everything below this line is HW specific virtual qemu test environment

# Quick and dirty emulated environment to test debian images
#

$(BUILD)/arm_virt: $(TAG)/arm_virt_dir
$(TAG)/arm_virt_dir:
	mkdir -p $(BUILD)/arm_virt
	$(call tag,arm_virt_dir)

$(BUILD)/arm_virt/vmlinuz: $(TAG)/arm_virt_dir
	wget -O $@ http://httpredir.debian.org/debian/dists/stretch/main/installer-armhf/current/images/netboot/vmlinuz
	touch $@

$(BUILD)/arm_virt/initrd.gz: $(TAG)/arm_virt_dir
	wget -O $@ http://httpredir.debian.org/debian/dists/stretch/main/installer-armhf/current/images/netboot/initrd.gz
	touch $@

$(BUILD)/arm_virt.cpio: $(BUILD)/arm_virt/initrd.gz
	( \
            cd $(BUILD)/arm_virt; \
            gzip -dc | cpio --make-directories -i lib/modules/*; \
            find lib -print0 | cpio -0 -H newc -R 0:0 -o \
	) <$< >$@

$(BUILD)/arm_virt.initrd: $(BUILD)/debian.$(CONFIG_DEBIAN).$(CONFIG_DEBIAN_ARCH).cpio $(BUILD)/arm_virt.cpio
	cat $^ >$@

test-arm_virt: $(BUILD)/arm_virt/vmlinuz $(BUILD)/arm_virt.cpio
test-arm_virt: $(BUILD)/arm_virt.initrd
	qemu-system-arm -M virt -m 512 \
		-kernel $(BUILD)/arm_virt/vmlinuz \
		-initrd $< \
		-netdev user,id=net0 \
		-device virtio-net-device,netdev=net0 \
		-nographic

# Everything below this line is HW specific Armbian u-Boot startup code

$(BOARD_DIR): $(TAG)/$(CONFIG_BOARD)_dir
$(TAG)/$(CONFIG_BOARD)_dir: $(CONFIG_BOARD).multistrap
	mkdir -p $(BOARD_DIR)
	sudo /usr/sbin/multistrap -d $(BOARD_DIR) -f $<
	$(call tag,$(CONFIG_BOARD)_dir)

# Add the kernel specific binaries to this cpio file
$(BUILD)/$(CONFIG_BOARD).cpio: $(TAG)/$(CONFIG_BOARD)_dir
	( \
            cd $(BOARD_DIR); \
            sudo find lib -print0 | sudo cpio -0 -H newc -R 0:0 -o \
	) > $@

$(SRC_FDT): $(TAG)/$(CONFIG_BOARD)_dir

$(BOOT): $(TAG)/boot_dir
$(TAG)/boot_dir:
	mkdir -p $(BOOT)
	$(call tag,boot_dir)

$(BOOT)/.next: $(TAG)/boot_dir
	touch $@

# TODO
# - stop using our local version of these files.
# These two files ( boot-sunxi.cmd and armbianEnv.txt ) are copied from the
# armbian git repo.  They are also found in one of the armbian packages
# ( linux-jessie-root-dev-orangepizero ) this package has dependancies that
# make it annoying to install in the BOARD_DIR and has a rather annoying mix
# of installed files that meant that it was not suitable to be installed in
# the DEBOOT either.

$(BOOT)/boot.scr: $(TAG)/boot_dir
$(BOOT)/boot.scr: armbian/lib/config/bootscripts/boot-sunxi.cmd
	mkimage -A arm -T script -C none -d $< $@

$(BOOT)/armbianEnv.txt: $(TAG)/boot_dir
$(BOOT)/armbianEnv.txt: armbian/lib/config/bootenv/sunxi-default.txt
	cp $< $@

kernel_suffix = $(shell ls $(BOOT)/vmlinuz-* |sed -e 's/vmlinuz-//')

$(BOOT)/zImage: $(TAG)/boot_dir $(TAG)/$(CONFIG_BOARD)_dir
	cp $(BOARD_DIR)/boot/vmlinuz-* $(BOOT)/zImage
	cp $(BOARD_DIR)/boot/config-* $(BOOT)

dtb_dir: $(TAG)/dtb_dir
$(TAG)/dtb_dir: $(BOOT)/zImage
	mkdir -p $(BOOT)/dtb
	$(call tag,dtb_dir)

$(BOOT)/dtb/$(CONFIG_BOARD).dtb: $(TAG)/dtb_dir
$(BOOT)/dtb/$(CONFIG_BOARD).dtb: $(SRC_FDT)
	cp $< $@

# Combine the various modules to make one big cpio file
$(BUILD)/$(CONFIG_BOARD).initrd: $(BUILD)/debian.$(CONFIG_DEBIAN).$(CONFIG_DEBIAN_ARCH).lzma $(BUILD)/$(CONFIG_BOARD).lzma
	cat $^ >$@

$(BOOT)/uInitrd: $(TAG)/boot_dir
$(BOOT)/uInitrd: $(BUILD)/$(CONFIG_BOARD).initrd
	mkimage -C lzma -A arm -T ramdisk -d $< $@

BOOT_FILES = \
    $(BOOT)/boot.scr $(BOOT)/armbianEnv.txt \
    $(BOOT)/.next \
    $(BOOT)/zImage \
    $(BOOT)/uInitrd \

BOOT_DTB_FILES = \
    $(BOOT)/dtb/$(CONFIG_BOARD).dtb \

boot: $(BOOT_FILES) $(BOOT_DTB_FILES)

# Everything below this line is packing the built boot dir into a disk image

$(SRC_SPL): $(TAG)/$(CONFIG_BOARD)_dir

PART_SIZE_MEGS = 1000

$(BUILD)/mtoolsrc: Makefile
	echo 'drive z: file="$(DISK_IMAGE)" cylinders=$(PART_SIZE_MEGS) heads=64 sectors=32 partition=1 mformat_only' >$@

$(DISK_IMAGE): $(SRC_SPL) $(BUILD)/mtoolsrc boot
	truncate --size=$$((0x200)) $@  # skip past the MBR
	date -u "+%FT%TZ " >>$@         # add a build date
	git describe --long --dirty >>$@ # and describe the repo
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

%.lzma: %.cpio
	lzma <$< >$@

clean:
	sudo rm -rf $(DEBOOT) $(BOOT) $(TAG) $(BOARD_DIR)

define tag
	@echo Touching tag $1
	@mkdir -p $(TAG)
	@touch $(TAG)/$1
endef

