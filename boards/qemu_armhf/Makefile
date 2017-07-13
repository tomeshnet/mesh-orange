#
# Build a working qemu armhf install
#


DEBIAN_VER = stretch
DEBIAN_ARCH = armhf

BUILD_DEPENDS = qemu-system-arm

CLEAN_FILES =

all: image

include ../common.mk
include ../common-kernel-debian.mk
include ../common-cjdns-hack.mk
include ../common-initrd.mk

image:
	echo as a virtual system, there is no way to build an image
	false

test: $(DEBIAN_KERNEL) $(BUILD)/combined.initrd
	qemu-system-arm -M virt \
		-m 512 \
		-kernel $(DEBIAN_KERNEL) \
		-initrd $(BUILD)/combined.initrd \
		-netdev type=user,id=e0 -device virtio-net-device,netdev=e0 \
		-nographic
