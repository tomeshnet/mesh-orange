#
# Build a working qemu armhf install
#


DEBIAN_VER = stretch
DEBIAN_ARCH = armhf

# TODO - this is unwieldly
DEBIAN = ../../debian/build/debian.$(DEBIAN_VER).$(DEBIAN_ARCH).cpio

# Directories
BUILD = build

all: image

image:
	echo as a virtual system, there is no way to build an image
	false

# install any packages needed for this builder
build-depends:
	true

# we might need to go and make the debian
# Note: this has no dependancy checking, and will simply use what ever
# file is there
$(DEBIAN):
	$(MAKE) -C ../../debian build/debian.$(DEBIAN_VER).$(DEBIAN_ARCH).cpio  CONFIG_DEBIAN_ARCH=$(DEBIAN_ARCH)

$(BUILD)/vmlinuz:
	mkdir -p build
	wget -O $@ http://httpredir.debian.org/debian/dists/stretch/main/installer-armhf/current/images/netboot/vmlinuz
	touch $@

$(BUILD)/orig.initrd.gz:
	mkdir -p build
	wget -O $@ http://httpredir.debian.org/debian/dists/stretch/main/installer-armhf/current/images/netboot/initrd.gz
	touch $@

$(BUILD)/modules.cpio: $(BUILD)/orig.initrd.gz
	( \
            mkdir -p $(basename $@); \
            cd $(basename $@); \
            gzip -dc | cpio --make-directories -i lib/modules/*; \
            find lib -print0 | cpio -0 -H newc -R 0:0 -o \
	) <$< >$@

$(BUILD)/combined.cpio: $(DEBIAN) $(BUILD)/modules.cpio
	cat $^ >$@

test: $(BUILD)/vmlinuz $(BUILD)/combined.cpio
	qemu-system-arm -M virt -m 512 \
		-kernel $(BUILD)/vmlinuz \
		-initrd $(BUILD)/combined.cpio \
		-netdev type=user,id=e0 -device virtio-net-device,netdev=e0 \
		-nographic

# Misc make infrastructure below here

clean:
	rm -rf $(BUILD)/orig.initrd.gz $(BUILD)/modules $(BUILD)/modules.cpio

reallyclean:
	rm -rf $(BUILD)

