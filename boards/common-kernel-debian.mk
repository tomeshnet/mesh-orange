#
# Rules to download the debian kernel and matching modules
#

# Of course, since I am misusing the debian archives, I cannot complain
# that there is no standard URL for fetching the bits

ifeq ($(DEBIAN_ARCH),armhf)
    DEBIAN_KERNEL_URL = http://httpredir.debian.org/debian/dists/$(DEBIAN_VER)/main/installer-$(DEBIAN_ARCH)/current/images/netboot/vmlinuz
    DEBIAN_INITRD_URL = http://httpredir.debian.org/debian/dists/$(DEBIAN_VER)/main/installer-$(DEBIAN_ARCH)/current/images/netboot/initrd.gz
else ifeq ($(DEBIAN_ARCH),i386)
    DEBIAN_KERNEL_URL = http://httpredir.debian.org/debian/dists/$(DEBIAN_VER)/main/installer-$(DEBIAN_ARCH)/current/images/netboot/debian-installer/$(DEBIAN_ARCH)/linux
    DEBIAN_INITRD_URL = http://httpredir.debian.org/debian/dists/$(DEBIAN_VER)/main/installer-$(DEBIAN_ARCH)/current/images/netboot/debian-installer/$(DEBIAN_ARCH)/initrd.gz
endif

DEBIAN_KERNEL = $(BUILD)/debian.$(DEBIAN_VER).$(DEBIAN_ARCH).kernel
DEBIAN_INITRD = $(BUILD)/debian.$(DEBIAN_VER).$(DEBIAN_ARCH).initrd.gz
DEBIAN_MODULES = $(BUILD)/debian.$(DEBIAN_VER).$(DEBIAN_ARCH).modules.cpio

$(DEBIAN_KERNEL):
	mkdir -p $(dir $@)
	wget -O $@ $(DEBIAN_KERNEL_URL)
	touch $@
CLEAN_FILES += $(DEBIAN_KERNEL)

$(DEBIAN_INITRD):
	mkdir -p $(dir $@)
	wget -O $@ $(DEBIAN_INITRD_URL)
	touch $@
CLEAN_FILES += $(DEBIAN_INITRD)

$(DEBIAN_MODULES): $(DEBIAN_INITRD)
	( \
	    mkdir -p $(basename $@); \
	    cd $(basename $@); \
	    gzip -dc | cpio --make-directories -i lib/modules/*; \
	    find lib -print0 | cpio -0 -H newc -R 0:0 -o \
	) <$< >$@
CLEAN_FILES += $(DEBIAN_MODULES) $(basename $(DEBIAN_MODULES))

INITRD_PARTS += $(DEBIAN_MODULES)
