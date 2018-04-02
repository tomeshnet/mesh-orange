#
# Download all the firmware blobs
#

DEBIAN_ARCH ?= armhf

CLEAN_FILES = $(TAG)

# Mostly because this is a good place to find the xr819 firmware
ARMBIAN_FIRMWARE_PKG = armbian-firmware

# firmware for wifi dongle (note, some overlap with armbian-firmware)
RASPBIAN_FIRMWARE_PKG = firmware-brcm80211 firmware-ralink firmware-atheros

# Directories
ARMBIAN = $(BUILD)/armbian
RASPBIAN = $(BUILD)/raspbian

BUILD_DEPENDS = \
    xz-utils \

TOP_DIR ?= ..
export TOP_DIR

all: firmware

include $(TOP_DIR)/mk/common.mk
include $(TOP_DIR)/mk/common-armbian.mk
include $(TOP_DIR)/mk/common-raspbian.mk

firmware: $(BUILD)/firmware-raspbian.cpio $(BUILD)/firmware-armbian.cpio

$(TAG)/armbian:
	$(TOP_DIR)/scripts/get_deb $(DEBIAN_ARCH) $(ARMBIAN_KEY) $(ARMBIAN_REPO) $(ARMBIAN) $(ARMBIAN_FIRMWARE_PKG)
	$(call tag,armbian)

# Add the kernel specific binaries to this cpio file
$(BUILD)/firmware-armbian.cpio: $(TAG)/armbian
	( \
            cd $(ARMBIAN); \
            find lib/firmware -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@

CLEAN_FILES += $(ARMBIAN) $(BUILD)/firmware-armbian.cpio $(BUILD)/firmware-armbian.lzma


$(TAG)/raspbian:
	$(TOP_DIR)/scripts/get_deb $(DEBIAN_ARCH) $(RASPBIAN_KEY) $(RASPBIAN_REPO) $(RASPBIAN) $(RASPBIAN_FIRMWARE_PKG)
	$(call tag,raspbian)

# Add the kernel specific binaries to this cpio file
$(BUILD)/firmware-raspbian.cpio: $(TAG)/raspbian
	( \
            cd $(RASPBIAN); \
            find lib/firmware/brcm -maxdepth 1 -type f ! -name "brcmfmac43430-sdio.*" -delete; \
            find lib/firmware -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@

CLEAN_FILES += $(RASPBIAN) $(BUILD)/firmware-raspbian.cpio $(BUILD)/firmware-raspbian.lzma
