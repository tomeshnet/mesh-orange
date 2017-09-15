#
# Download all the firmware blobs
#

DEBIAN_ARCH ?= armhf

CLEAN_FILES = $(TAG)

# Mostly because this is a good place to find the xr819 firmware
ARMBIAN_FIRMWARE_PKG = armbian-firmware

# firmware for wifi dongle (note, some overlap with armbian-firmware)
RASPBIAN_FIRMWARE_PKG = firmware-ralink

# Directories
ARMBIAN = $(BUILD)/armbian
RASPBIAN = $(BUILD)/raspbian

BUILD_DEPENDS = \
    xz-utils \

all: firmware

include ../mk/common.mk
include ../mk/common-armbian.mk
include ../mk/common-raspbian.mk

firmware: $(BUILD)/firmware-raspbian.cpio $(BUILD)/firmware-armbian.cpio

$(TAG)/armbian:
	../scripts/get_deb $(DEBIAN_ARCH) $(ARMBIAN_KEY) $(ARMBIAN_REPO) $(ARMBIAN) $(ARMBIAN_FIRMWARE_PKG)
	$(call tag,armbian)

# Add the kernel specific binaries to this cpio file
$(BUILD)/firmware-armbian.cpio: $(TAG)/armbian
	( \
            cd $(ARMBIAN); \
            find lib/firmware -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@

CLEAN_FILES += $(ARMBIAN) $(BUILD)/firmware-armbian.cpio $(BUILD)/firmware-armbian.lzma


$(TAG)/raspbian:
	../scripts/get_deb $(DEBIAN_ARCH) $(RASPBIAN_KEY) $(RASPBIAN_REPO) $(RASPBIAN) $(RASPBIAN_FIRMWARE_PKG)
	$(call tag,raspbian)

# Add the kernel specific binaries to this cpio file
$(BUILD)/firmware-raspbian.cpio: $(TAG)/raspbian
	( \
            cd $(RASPBIAN); \
            find lib/firmware -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@

CLEAN_FILES += $(RASPBIAN) $(BUILD)/firmware-raspbian.cpio $(BUILD)/firmware-raspbian.lzma
