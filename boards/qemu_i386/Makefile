#
# Build a working qemu i386 install
#
# TODO:
# - this is actually a reasonably portable i386 system, so it could produce
#   an image build - this could end up needing more complications than is
#   worth it (EFI boot or BIOS boot, CDROM image or hard drive image, etc)
#


DEBIAN_VER = stretch
DEBIAN_ARCH = i386

# TODO - this is unwieldly
DEBIAN = ../../debian/build/debian.$(DEBIAN_VER).$(DEBIAN_ARCH).cpio

# Directories
BUILD = build

all: image

image:
	echo as a virtual system, there is no way to build an image
	false

# install any packages needed for this builder
build-depends:
	true

# we might need to go and make the debian
# Note: this has no dependancy checking, and will simply use what ever
# file is there
$(DEBIAN):
	$(MAKE) -C ../../debian build/debian.$(DEBIAN_VER).$(DEBIAN_ARCH).cpio  CONFIG_DEBIAN_ARCH=$(DEBIAN_ARCH)

$(BUILD)/vmlinuz:
	mkdir -p build
	wget -O $@ http://ftp.debian.org/debian/dists/stretch/main/installer-i386/current/images/netboot/debian-installer/i386/linux
	touch $@

$(BUILD)/orig.initrd.gz:
	mkdir -p build
	wget -O $@ http://ftp.debian.org/debian/dists/stretch/main/installer-i386/current/images/netboot/debian-installer/i386/initrd.gz
	touch $@

$(BUILD)/modules.cpio: $(BUILD)/orig.initrd.gz
	( \
            mkdir -p $(basename $@); \
            cd $(basename $@); \
            gzip -dc | cpio --make-directories -i lib/modules/*; \
            find lib -print0 | cpio -0 -H newc -R 0:0 -o \
	) <$< >$@

$(BUILD)/combined.cpio: $(DEBIAN) $(BUILD)/modules.cpio
	cat $^ >$@

test: $(BUILD)/vmlinuz $(BUILD)/combined.cpio
	qemu-system-i386 -enable-kvm -m 512 \
		-kernel $(BUILD)/vmlinuz \
		-initrd $(BUILD)/combined.cpio \
		-netdev type=user,id=e0 -device virtio-net-pci,netdev=e0 \
		-append console=ttyS0 \
		-nographic

# Misc make infrastructure below here

clean:
	rm -rf $(BUILD)/orig.initrd.gz $(BUILD)/modules $(BUILD)/modules.cpio

reallyclean:
	rm -rf $(BUILD)

