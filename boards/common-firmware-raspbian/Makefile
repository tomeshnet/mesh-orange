#
# Download the raspbian firmware package
#

DEBIAN_ARCH ?= armhf

CLEAN_FILES = $(TAG) $(RASPBIAN) $(BUILD)/firmware.cpio $(BUILD)/firmware.lzma

# firmware for wifi dongle
RASPBIAN_FIRMWARE_PKG = firmware-ralink

# Directories
RASPBIAN = $(BUILD)/raspbian

BUILD_DEPENDS = \
    xz-utils \

all: firmware

include ../common.mk
include ../common-raspbian.mk

firmware: $(BUILD)/firmware.cpio

$(TAG)/raspbian:
	../../scripts/get_deb $(DEBIAN_ARCH) $(RASPBIAN_REPOURI) $(RASPBIAN_REPOSUITE) $(RASPBIAN) $(RASPBIAN_FIRMWARE_PKG)
	$(call tag,raspbian)

# Add the kernel specific binaries to this cpio file
$(BUILD)/firmware.cpio: $(TAG)/raspbian
	( \
            cd $(RASPBIAN); \
            find lib/firmware -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@

