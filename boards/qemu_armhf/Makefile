#
# Build a working qemu armhf install
#


DEBIAN_VER = stretch
DEBIAN_ARCH = armhf

BUILD_DEPENDS = qemu-system-arm

CLEAN_FILES =

TOP_DIR ?= $(abspath ../..)

all: image

include $(TOP_DIR)/mk/common.mk
include $(TOP_DIR)/boards/common-kernel-local.mk
include $(TOP_DIR)/boards/common-cjdns-hack.mk
include $(TOP_DIR)/boards/common-initrd.mk

image:
	echo as a virtual system, there is no way to build an image
	false

test: $(LOCAL_KERNEL) $(BUILD)/combined.initrd
	qemu-system-arm -M virt \
		-m 512 \
		-kernel $(LOCAL_KERNEL) \
		-initrd $(BUILD)/combined.initrd \
		-netdev type=user,id=e0 -device virtio-net-device,netdev=e0 \
		-nographic
