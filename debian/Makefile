#
# Build a debian and armbian based initramfs system
#

# which uboot and device tree is this being built for
CONFIG_UBOOT = linux-u-boot-dev-orangepizero_5.25_armhf
CONFIG_FDT = sun8i-h2plus-orangepi-zero.dtb

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

SRC_SPL = $(DEBOOT)/usr/lib/$(CONFIG_UBOOT)/u-boot-sunxi-with-spl.bin
SRC_FDT = $(DEBOOT)/usr/lib/linux-image-dev-sun8i/$(CONFIG_FDT)

all:
	echo until this makefile is complete, this fails here
	false

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

# very basic minimalisation
minimise: $(TAG)/minimise
$(TAG)/minimise: $(TAG)/multistrap
	sudo rm -f $(DEBOOT)/multistrap.configscript $(DEBOOT)/dev/mmcblk0
	#sudo rm -f $(DEBOOT)/usr/bin/qemu-arm-static
	$(call tag,minimise)

# very basic fixup
fixup: $(TAG)/fixup
$(TAG)/fixup: $(TAG)/multistrap
	sudo ln -sf lib/systemd/systemd $(DEBOOT)/init       # allow booting
	sudo perl -pi -e 's/:\*:/::/' $(DEBOOT)/etc/shadow   # empty password
	$(call tag,fixup)

# FIXME: obviously, an empty password should not go live

debian: $(TAG)/debian
$(TAG)/debian: $(TAG)/minimise $(TAG)/fixup
	$(call tag,debian)

$(BUILD)/initrd.lzma: $(TAG)/debian
	( \
            cd $(DEBOOT); \
            sudo find . -print0 | sudo cpio -0 -H newc -R 0:0 -o -V \
	) | lzma > $@

$(BOOT): $(TAG)/boot_dir
$(TAG)/boot_dir:
	mkdir -p $(BOOT)
	$(call tag,boot_dir)

$(BOOT)/uInitrd: $(TAG)/boot_dir
$(BOOT)/uInitrd: $(BUILD)/initrd.lzma
	mkimage -C lzma -A arm -T ramdisk -d $< $@

# Everything above this line is a generic Debian armhf builder

# Everything below this line is HW specific Armbian u-Boot startup code

$(BOOT)/.next: $(TAG)/boot_dir
	touch $@

$(SRC_SPL): $(TAG)/multistrap
$(SRC_FDT): $(TAG)/multistrap
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

zImage: $(TAG)/zImage
$(TAG)/zImage: $(TAG)/boot_dir
$(TAG)/zImage: $(DEBOOT)/boot/zImage
	cp `realpath $<` $(BOOT)/`readlink $<`
	cp -d $< $(BOOT)/zImage
	$(call tag,zImage)

dtb_suffix = $(shell readlink $(BOOT)/zImage |sed -e 's/vmlinuz-//')
dtb_dir: $(TAG)/dtb_dir
$(TAG)/dtb_dir: $(TAG)/zImage
	mkdir -p $(BOOT)/dtb-$(dtb_suffix)
	ln -sf dtb-$(dtb_suffix) $(BOOT)/dtb
	$(call tag,dtb_dir)

$(BOOT)/dtb/$(CONFIG_FDT): $(TAG)/dtb_dir
$(BOOT)/dtb/$(CONFIG_FDT): $(SRC_FDT)
	cp $< $@

boot: \
    $(BOOT)/boot.scr $(BOOT)/armbianEnv.txt \
    $(BOOT)/.next \
    dtb_dir $(BOOT)/dtb/$(CONFIG_FDT) \
    zImage \
    $(BOOT)/uInitrd

clean:
	sudo rm -rf $(DEBOOT) $(BOOT) $(TAG)

define tag
	@echo Touching tag $1
	@mkdir -p $(TAG)
	@touch $(TAG)/$1
endef

