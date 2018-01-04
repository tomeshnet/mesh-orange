#
# Download the cjdns binary add-on via the hacky method
#

ifeq ($(DEBIAN_ARCH),armhf)

../../cjdns/hack/build/cjdns.cpio:
	$(MAKE) -C ../../cjdns/hack DEBIAN_ARCH=$(DEBIAN_ARCH) build/cjdns.cpio

# Temporary disable:
# Something is wrong with the ban.ai server - when using wget or curl,
# it sends the wrong SSL certificate (it is sending the cert for the server
# hosting the site: prone.ws)
#
#INITRD_PARTS += ../../cjdns/hack/build/cjdns.lzma

endif
