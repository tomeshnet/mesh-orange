#
# functions and definitions expected to be used my many or all systems
#

# Calculate the basename of the debian build file
DEBIAN_BASENAME = debian.$(DEBIAN_VER).$(DEBIAN_ARCH)
DEBIAN = ../../debian/build/$(DEBIAN_BASENAME)

# Standardised directory names
BUILD = build
TAG = $(BUILD)/tags
BOOT = $(BUILD)/boot

# install any packages needed for the builder
build-depends: $(TAG)/build-depends
$(TAG)/build-depends: Makefile
	sudo apt-get -y install $(BUILD_DEPENDS)
	$(call tag,build-depends)

# Rules to go and make the debian installed root
# Note: this has no dependancy checking, and will simply use what ever
# file is there
$(DEBIAN).cpio:
	$(MAKE) -C ../../debian build/$(DEBIAN_BASENAME).cpio CONFIG_DEBIAN_ARCH=$(DEBIAN_ARCH)
$(DEBIAN).lzma:
	$(MAKE) -C ../../debian build/$(DEBIAN_BASENAME).lzma CONFIG_DEBIAN_ARCH=$(DEBIAN_ARCH)

%.lzma: %.cpio
	lzma <$< >$@

clean:
	rm -rf $(CLEAN_FILES)

reallyclean:
	rm -rf $(BUILD)

define tag
	@echo Touching tag $1
	@mkdir -p $(TAG)
	@touch $(TAG)/$1
endef

