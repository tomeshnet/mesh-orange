#
# Provide device firmware from the armbian repository
#

RASPBIAN_FIRMWARE = ../common-firmware-raspbian/build/firmware.lzma

$(addsuffix .cpio,$(basename $(RASPBIAN_FIRMWARE))):
	$(MAKE) -C ../common-firmware-raspbian build/firmware.cpio

