#
# functions and definitions expected to be used my many or all systems
#

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

