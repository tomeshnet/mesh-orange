#
# Download the cjdns binary add-on via the hacky method
#

ifeq ($(DEBIAN_ARCH),armhf)

../../cjdns/hack/build/cjdns.cpio:
	$(MAKE) -C ../../cjdns/hack DEBIAN_ARCH=$(DEBIAN_ARCH) build/cjdns.cpio

INITRD_PARTS += ../../cjdns/hack/build/cjdns.lzma

endif
