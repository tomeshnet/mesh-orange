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

# Directories
BUILD = build
TAG = $(BUILD)/tags
DEBOOT = $(BUILD)/debian.$(CONFIG_DEBIAN).$(CONFIG_DEBIAN_ARCH)

BUILD_DEPENDS = \
    multistrap \
    binfmt-support \
    qemu-user-static \


all: $(BUILD)/debian.cpio

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
$(TAG)/multistrap-pre.$(CONFIG_DEBIAN_ARCH): debian.$(CONFIG_DEBIAN).multistrap multistrap.configscript
$(TAG)/multistrap-pre.$(CONFIG_DEBIAN_ARCH): $(DEBOOT)/dev/urandom
	sudo /usr/sbin/multistrap -d $(DEBOOT) --arch $(CONFIG_DEBIAN_ARCH) -f debian.$(CONFIG_DEBIAN).multistrap
	$(call tag,multistrap-pre.$(CONFIG_DEBIAN_ARCH))

# TODO: if TARGET_ARCH == BUILD_ARCH, dont need to copy qemu
# TODO: the qemu arch is not always the debian arch, handle this
$(DEBOOT)/usr/bin/qemu-arm-static: /usr/bin/qemu-arm-static
	sudo cp /usr/bin/qemu-arm-static $(DEBOOT)/usr/bin/qemu-arm-static

# multistrap-post runs the package configure scripts under emulation
$(TAG)/multistrap-post.$(CONFIG_DEBIAN_ARCH): $(DEBOOT)/usr/bin/qemu-arm-static $(TAG)/multistrap-pre.$(CONFIG_DEBIAN_ARCH)
	sudo chroot $(DEBOOT) ./multistrap.configscript
	$(call tag,multistrap-post.$(CONFIG_DEBIAN_ARCH))

# TODO
# - search for and kill any daemons started by the dpkg configure:
#       sudo killall dropbear
#       sudo umount $(DEBOOT)/proc

# perform the debian install
$(TAG)/multistrap.$(CONFIG_DEBIAN_ARCH): $(TAG)/multistrap-pre.$(CONFIG_DEBIAN_ARCH) $(TAG)/multistrap-post.$(CONFIG_DEBIAN_ARCH)
	$(call tag,multistrap.$(CONFIG_DEBIAN_ARCH))

# TODO
# - the make targets using the ./packages.runscripts system should
#   be depending on all the packages.d/ scripts.  Need to add a auto
#   dep system to do this.

# minimise the image size
$(TAG)/minimise.$(CONFIG_DEBIAN_ARCH): $(TAG)/multistrap.$(CONFIG_DEBIAN_ARCH)
	sudo ./packages.runscripts $(DEBOOT) $(CONFIG_DEBIAN_ARCH) minimise
	sudo rm -rf $(DEBOOT)/usr/share/locale/*
	sudo rm -rf $(DEBOOT)/usr/share/zoneinfo/*
	sudo rm -f $(DEBOOT)/lib/udev/hwdb.bin
	sudo rm -f $(DEBOOT)/multistrap.configscript $(DEBOOT)/dev/mmcblk0
	#sudo rm -f $(DEBOOT)/usr/bin/qemu-arm-static
	$(call tag,minimise.$(CONFIG_DEBIAN_ARCH))

# fixup the image to actually boot
$(TAG)/fixup.$(CONFIG_DEBIAN_ARCH): $(TAG)/multistrap.$(CONFIG_DEBIAN_ARCH)
	sudo ./packages.runscripts $(DEBOOT) $(CONFIG_DEBIAN_ARCH) fixup
	$(call tag,fixup.$(CONFIG_DEBIAN_ARCH))

# image customisation - setting the default config.
$(TAG)/customise.$(CONFIG_DEBIAN_ARCH): $(TAG)/multistrap.$(CONFIG_DEBIAN_ARCH)
	sudo ./packages.runscripts $(DEBOOT) $(CONFIG_DEBIAN_ARCH) customise
	echo root:$(CONFIG_ROOT_PASS) | sudo chpasswd -c SHA256 -R $(realpath $(DEBOOT))
	$(call tag,customise.$(CONFIG_DEBIAN_ARCH))

# TODO: consider what password should be default

debian: $(TAG)/debian.$(CONFIG_DEBIAN_ARCH)
$(TAG)/debian.$(CONFIG_DEBIAN_ARCH): $(TAG)/minimise.$(CONFIG_DEBIAN_ARCH) $(TAG)/fixup.$(CONFIG_DEBIAN_ARCH) $(TAG)/customise.$(CONFIG_DEBIAN_ARCH)
	$(call tag,debian.$(CONFIG_DEBIAN_ARCH))

$(BUILD)/debian.$(CONFIG_DEBIAN).$(CONFIG_DEBIAN_ARCH).cpio: $(TAG)/debian.$(CONFIG_DEBIAN_ARCH)
	( \
            cd $(DEBOOT); \
            sudo find . -print0 | sudo cpio -0 -H newc -R 0:0 -o \
	) > $@

# Misc make infrastructure below here

clean:
	sudo rm -rf $(DEBOOT) $(TAG)

reallyclean:
	rm -rf $(BUILD)

define tag
	@echo Touching tag $1
	@mkdir -p $(TAG)
	@touch $(TAG)/$1
endef

