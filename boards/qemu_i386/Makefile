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

CLEAN_FILES =

TOP_DIR ?= $(abspath ../..)

all: image

include $(TOP_DIR)/mk/common.mk
include $(TOP_DIR)/boards/common-kernel-debian.mk
include $(TOP_DIR)/boards/common-initrd.mk

image:
	echo as a virtual system, there is no way to build an image
	false

$(BUILD)/persistent.storage:
	truncate -s 2G $@

test: $(DEBIAN_KERNEL) $(BUILD)/combined.initrd $(BUILD)/persistent.storage
	qemu-system-i386 -enable-kvm -append console=ttyS0 \
		-m 512 \
		-kernel $(DEBIAN_KERNEL) \
		-initrd $(BUILD)/combined.initrd \
		-netdev type=user,id=e0 -device virtio-net-pci,netdev=e0 \
		-drive if=virtio,format=raw,file=$(BUILD)/persistent.storage \
		-nographic
