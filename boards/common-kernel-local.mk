#
# Rules to use the local kernel build dir
#

# FIXME
# - add an arch to the zImage

LOCAL_KERNEL = ../../linux/build/linux/zImage
LOCAL_MODULES = ../../linux/build/modules-$(DEBIAN_ARCH).lzma

$(LOCAL_KERNEL):
	$(MAKE) -C ../../linux build/linux/zImage DEBIAN_ARCH=$(DEBIAN_ARCH)

$(addsuffix .cpio,$(basename $(LOCAL_MODULES))):
	$(MAKE) -C ../../linux build/modules-$(DEBIAN_ARCH).cpio DEBIAN_ARCH=$(DEBIAN_ARCH)

# FIXME - this should have a dep on the extracted linux dtbs, but something in
# that is failing ?!?
$(BUILD)/boot/dtb/%.dtb: $(LOCAL_KERNEL)
	mkdir -p $(dir $@) 
	cp ../../linux/build/linux/dtb/$(notdir $@) $@

INITRD_PARTS += $(LOCAL_MODULES)
