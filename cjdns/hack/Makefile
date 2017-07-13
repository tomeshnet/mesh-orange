#
# This is a hack!
#
# Download a raspbian build of cjdns, extract its contents and remove the
# python tools (python is not installed in the minimal debian build)
#
# The raspbian binaries can be shown to work on a true armhf system, but it
# is not recommended
#

ifneq ($(DEBIAN_ARCH),armhf)
$(error no support for non armhf)
endif

# Annoyingly, this repo doesnt simply trust the key to provide a root of
# trust - we also need to install the apt driver for https
BUILD_DEPENDS = \
    apt-transport-https

REPOKEY = https://ban.ai/raspbian/brrpi.pubkey
REPO = "deb https://ban.ai/raspbian/ cjdns cjdns"

PKG = cjdns

# Directories
BUILD = build
CJDNS = $(BUILD)/cjdns

CLEAN_FILES = $(BUILD)/cjdns.cpio

all: cjdns

build-depends: Makefile
	sudo apt-get -y install $(BUILD_DEPENDS)

cjdns: $(CJDNS).cpio

$(CJDNS):
	../../scripts/get_deb $(DEBIAN_ARCH) $(REPOKEY) $(REPO) $@ $(PKG)

$(CJDNS).cpio: $(CJDNS)
	( \
            cd $(CJDNS); \
            find etc lib usr/bin -type f -print0 | cpio -0 -H newc -R 0:0 -o \
	) > $@

clean:
	rm -rf $(CLEAN_FILES) $(CJDNS)

reallyclean:
	rm -rf $(BUILD)
