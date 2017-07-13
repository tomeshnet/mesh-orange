#
# Provide device firmware from the armbian repository
#

ARMBIAN_FIRMWARE = ../common-firmware-armbian/build/firmware.lzma

$(addsuffix .cpio,$(basename $(ARMBIAN_FIRMWARE))):
	$(MAKE) -C ../common-firmware-armbian DEBIAN_ARCH=$(DEBIAN_ARCH) build/firmware.cpio

INITRD_PARTS += $(ARMBIAN_FIRMWARE)

