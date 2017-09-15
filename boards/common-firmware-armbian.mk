#
# Provide device firmware from the armbian repository
#

ARMBIAN_FIRMWARE = ../../firmware/build/firmware-armbian.lzma

$(addsuffix .cpio,$(basename $(ARMBIAN_FIRMWARE))):
	$(MAKE) -C ../../firmware DEBIAN_ARCH=$(DEBIAN_ARCH) build/firmware-armbian.cpio

INITRD_PARTS += $(ARMBIAN_FIRMWARE)

