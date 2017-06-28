#
# functions and definitions expected to be used my many or all systems
#

# install any packages needed for the builder
build-depends: $(TAG)/build-depends
$(TAG)/build-depends: Makefile
	sudo apt-get -y install $(BUILD_DEPENDS)
	$(call tag,build-depends)

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

