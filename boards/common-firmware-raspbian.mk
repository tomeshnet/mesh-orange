#
# Provide device firmware from the armbian repository
#

RASPBIAN_FIRMWARE = ../../firmware/build/firmware-raspbian.lzma

$(addsuffix .cpio,$(basename $(RASPBIAN_FIRMWARE))):
	$(MAKE) -C ../../firmware DEBIAN_ARCH=$(DEBIAN_ARCH) build/firmware-raspbian.cpio

INITRD_PARTS += $(RASPBIAN_FIRMWARE)
