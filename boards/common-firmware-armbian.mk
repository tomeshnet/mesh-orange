#
# Provide device firmware from the armbian repository
#

ARMBIAN_FIRMWARE = ../common-firmware-armbian/build/firmware.lzma

$(addsuffix .cpio,$(basename $(ARMBIAN_FIRMWARE))):
	$(MAKE) -C ../common-firmware-armbian build/firmware.cpio

