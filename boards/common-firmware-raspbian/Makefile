#
# Download the raspbian firmware package
#

CLEAN_FILES = $(TAG) $(RASPBIAN) $(BUILD)/firmware.cpio $(BUILD)/firmware.lzma

# Directories
RASPBIAN = $(BUILD)/raspbian

BUILD_DEPENDS = \
    multistrap \
    fakeroot \
    xz-utils \

all: $(BUILD)/firmware.cpio

include ../common.mk

$(RASPBIAN): $(TAG)/raspbian
$(TAG)/raspbian: raspbian.multistrap
	mkdir -p $(RASPBIAN)
	fakeroot /usr/sbin/multistrap -d $(RASPBIAN) -f $<
	$(call tag,raspbian)

# Add the kernel specific binaries to this cpio file
$(BUILD)/firmware.cpio: $(TAG)/raspbian
	( \
            cd $(RASPBIAN); \
            find lib/firmware -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@

