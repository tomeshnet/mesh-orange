#
# Build a debian and armbian based initramfs system
#

BUILD = build
DEBOOT = $(BUILD)/debian
TAG = $(BUILD)/tags

BUILD_DEPENDS = \
    multistrap \
    binfmt-support \
    qemu-user-static \
    u-boot-tools \
    xz-utils \

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

$(BUILD)/initrd.lzma: $(TAG)/fixup
	( \
            cd $(DEBOOT); \
            sudo find . -print0 | sudo cpio -0 -H newc -R 0:0 -o -V \
	) | lzma > $@

$(BUILD)/uInitrd: $(BUILD)/initrd.lzma
	mkimage -C lzma -A arm -T ramdisk -d $< $@

clean:
	sudo rm -rf $(DEBOOT) $(TAG)

define tag
	@echo Touching tag $1
	@mkdir -p $(TAG)
	@touch $(TAG)/$1
endef

