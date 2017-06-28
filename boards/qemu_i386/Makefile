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

BUILD_DEPENDS = qemu-system-x86

CLEAN_FILES = $(BUILD)/orig.initrd.gz $(BUILD)/modules $(BUILD)/modules.cpio

all: image

include ../common.mk

image:
	echo as a virtual system, there is no way to build an image
	false

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

$(BUILD)/combined.cpio: $(DEBIAN).cpio $(BUILD)/modules.cpio
	cat $^ >$@

test: $(BUILD)/vmlinuz $(BUILD)/combined.cpio
	qemu-system-i386 -enable-kvm -m 512 \
		-kernel $(BUILD)/vmlinuz \
		-initrd $(BUILD)/combined.cpio \
		-netdev type=user,id=e0 -device virtio-net-pci,netdev=e0 \
		-append console=ttyS0 \
		-nographic
