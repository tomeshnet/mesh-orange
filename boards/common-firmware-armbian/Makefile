#
# Download the armbian firmware package
#

DEBIAN_ARCH ?= armhf

CLEAN_FILES = $(TAG) $(ARMBIAN) $(BUILD)/firmware.cpio $(BUILD)/firmware.lzma

ARMBIAN_FIRMWARE_PKG = armbian-firmware

# Directories
ARMBIAN = $(BUILD)/armbian

BUILD_DEPENDS = \
    xz-utils \

all: firmware

include ../common.mk
include ../common-armbian.mk

firmware: $(BUILD)/firmware.cpio

$(TAG)/armbian:
	../../scripts/get_deb $(DEBIAN_ARCH) $(ARMBIAN_KEY) $(ARMBIAN_REPO) $(ARMBIAN) $(ARMBIAN_FIRMWARE_PKG)
	$(call tag,armbian)

# Add the kernel specific binaries to this cpio file
$(BUILD)/firmware.cpio: $(TAG)/armbian
	( \
            cd $(ARMBIAN); \
            find lib/firmware -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@

