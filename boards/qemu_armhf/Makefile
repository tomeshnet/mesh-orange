#
# Build a working qemu armhf install
#


DEBIAN_VER = stretch
DEBIAN_ARCH = armhf

BUILD_DEPENDS = qemu-system-arm

CLEAN_FILES = $(BUILD)/orig.initrd.gz $(BUILD)/modules $(BUILD)/modules.cpio

all: image

include ../common.mk

image:
	echo as a virtual system, there is no way to build an image
	false

$(BUILD)/vmlinuz:
	mkdir -p build
	wget -O $@ http://httpredir.debian.org/debian/dists/stretch/main/installer-armhf/current/images/netboot/vmlinuz
	touch $@

$(BUILD)/orig.initrd.gz:
	mkdir -p build
	wget -O $@ http://httpredir.debian.org/debian/dists/stretch/main/installer-armhf/current/images/netboot/initrd.gz
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
	qemu-system-arm -M virt -m 512 \
		-kernel $(BUILD)/vmlinuz \
		-initrd $(BUILD)/combined.cpio \
		-netdev type=user,id=e0 -device virtio-net-device,netdev=e0 \
		-nographic
