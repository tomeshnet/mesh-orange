#
# Build a debian and armbian based initramfs system
#

# TODO:
# - Convert the minimalisation step into an excludes file generator
#   and use that file in the cpio step
# - Add config file list / save to sdcard / load from sdcard package

# Default to just looking in the local directory for config files
CONFIGDIRS ?= .

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

# A default target to tell you what other targets might work
all:
	$(info Build a platform neutral debian install)
	$(info Try: $(MAKE) build/debian.stretch.armhf.cpio CONFIG_DEBIAN_ARCH=armhf)
	$(info or other variations for i386)

# install any packages needed for this builder
build-depends: $(TAG)/build-depends
$(TAG)/build-depends:
	sudo apt-get -y install $(BUILD_DEPENDS)
	$(call tag,build-depends)

# some of the debian packages need a urandom to install properly
$(DEBOOT)/dev/urandom:
	mkdir -p $(DEBOOT)/dev
	sudo mknod $(DEBOOT)/dev/urandom c 1 9

$(DEBOOT)/usr/sbin/policy-rc.d: policy-rc.d
	sudo mkdir -p $(dir $@)
	sudo cp $< $@

# a list of files, which contain additional packages to install
packages_lists = $(wildcard $(addsuffix /packages.txt,$(CONFIGDIRS)))

# the actual list of these additional packages
packages = $(shell sed -e 's/\#.*//' $(packages_lists))

MULTISTRAP_CONF=$(BUILD)/debian.$(CONFIG_DEBIAN).multistrap

$(MULTISTRAP_CONF): debian.$(CONFIG_DEBIAN).multistrap $(package_lists)
	cat $< >$@
	echo >>$@
	echo packages=$(packages) >>$@

# multistrap-pre runs the basic multistrap program, installing the packages
# until they need to run native code
$(TAG)/multistrap-pre.$(CONFIG_DEBIAN_ARCH): $(DEBOOT)/usr/sbin/policy-rc.d
$(TAG)/multistrap-pre.$(CONFIG_DEBIAN_ARCH): $(MULTISTRAP_CONF)
$(TAG)/multistrap-pre.$(CONFIG_DEBIAN_ARCH): multistrap.configscript
$(TAG)/multistrap-pre.$(CONFIG_DEBIAN_ARCH): $(DEBOOT)/dev/urandom
	sudo /usr/sbin/multistrap -d $(DEBOOT) --arch $(CONFIG_DEBIAN_ARCH) \
	    -f $(MULTISTRAP_CONF)
	$(call tag,multistrap-pre.$(CONFIG_DEBIAN_ARCH))

# TODO: if TARGET_ARCH == BUILD_ARCH, dont need to copy qemu
# TODO: the qemu arch is not always the debian arch, handle this
$(DEBOOT)/usr/bin/qemu-arm-static: /usr/bin/qemu-arm-static
	sudo cp /usr/bin/qemu-arm-static $(DEBOOT)/usr/bin/qemu-arm-static

# multistrap-post runs the package configure scripts under emulation
$(TAG)/multistrap-post.$(CONFIG_DEBIAN_ARCH): $(DEBOOT)/usr/bin/qemu-arm-static $(TAG)/multistrap-pre.$(CONFIG_DEBIAN_ARCH)
	sudo chroot $(DEBOOT) ./multistrap.configscript
	$(call tag,multistrap-post.$(CONFIG_DEBIAN_ARCH))

# perform the debian install
$(TAG)/multistrap.$(CONFIG_DEBIAN_ARCH): $(TAG)/multistrap-pre.$(CONFIG_DEBIAN_ARCH) $(TAG)/multistrap-post.$(CONFIG_DEBIAN_ARCH)
	$(call tag,multistrap.$(CONFIG_DEBIAN_ARCH))

# TODO
# - the make targets using the ./packages.runscripts system should
#   be depending on all the packages.d/ scripts.  Need to add a auto
#   dep system to do this.

# TODO - use dpkg config to avoid installing the locale files:
# eg:
# --path-exclude=/usr/share/doc/*
# --path-include=/usr/share/doc/*/copyright



# minimise the image size
$(TAG)/minimise.$(CONFIG_DEBIAN_ARCH): $(TAG)/multistrap.$(CONFIG_DEBIAN_ARCH)
	sudo --preserve-env=CONFIGDIRS ./packages.addextra $(DEBOOT) $(CONFIG_DEBIAN_ARCH) minimise
	sudo --preserve-env=CONFIGDIRS ./packages.runscripts $(DEBOOT) $(CONFIG_DEBIAN_ARCH) minimise
	sudo rm -f $(DEBOOT)/multistrap.configscript $(DEBOOT)/dev/mmcblk0
	#sudo rm -f $(DEBOOT)/usr/bin/qemu-arm-static
	$(call tag,minimise.$(CONFIG_DEBIAN_ARCH))

# fixup the image to actually boot
$(TAG)/fixup.$(CONFIG_DEBIAN_ARCH): $(TAG)/multistrap.$(CONFIG_DEBIAN_ARCH)
	sudo --preserve-env=CONFIGDIRS ./packages.addextra $(DEBOOT) $(CONFIG_DEBIAN_ARCH) fixup
	sudo --preserve-env=CONFIGDIRS ./packages.runscripts $(DEBOOT) $(CONFIG_DEBIAN_ARCH) fixup
	sudo rm $(DEBOOT)/usr/sbin/policy-rc.d
	$(call tag,fixup.$(CONFIG_DEBIAN_ARCH))

# image customisation - setting the default config.
$(TAG)/customise.$(CONFIG_DEBIAN_ARCH): $(TAG)/multistrap.$(CONFIG_DEBIAN_ARCH)
	sudo --preserve-env=CONFIGDIRS ./packages.addextra $(DEBOOT) $(CONFIG_DEBIAN_ARCH) customise
	sudo --preserve-env=CONFIGDIRS ./packages.runscripts $(DEBOOT) $(CONFIG_DEBIAN_ARCH) customise
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

%.lzma: %.cpio
	lzma <$< >$@

clean:
	rm -f $(MULTISTRAP_CONF) $(TAG)/*
	sudo rm -rf $(BUILD)/debian.$(CONFIG_DEBIAN).*

reallyclean:
	rm -rf $(BUILD)

define tag
	@echo Touching tag $1
	@mkdir -p $(TAG)
	@touch $(TAG)/$1
endef

