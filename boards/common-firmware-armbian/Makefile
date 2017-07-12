#
# Download the armbian firmware package
#

DEBIAN_VER = stretch
DEBIAN_ARCH = armhf

CLEAN_FILES = $(TAG) $(ARMBIAN) $(BUILD)/firmware.cpio $(BUILD)/firmware.lzma

# Directories
ARMBIAN = $(BUILD)/armbian

BUILD_DEPENDS = \
    multistrap \
    fakeroot \
    xz-utils \

all: $(BUILD)/firmware.cpio

include ../common.mk

$(ARMBIAN): $(TAG)/armbian
$(TAG)/armbian: armbian.multistrap
	mkdir -p $(ARMBIAN)
	fakeroot /usr/sbin/multistrap -d $(ARMBIAN) -f $<
	$(call tag,armbian)

# Add the kernel specific binaries to this cpio file
$(BUILD)/firmware.cpio: $(TAG)/armbian
	( \
            cd $(ARMBIAN); \
            find lib/firmware -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@

