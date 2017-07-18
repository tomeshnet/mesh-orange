#
# Common rules and definitions for building a initrd image, combining from
# multiple parts
#

# Note that this make fragment needs to be included /after/ anything that adds
# more values to the INITRD_PARTS variable, in order to ensure that the
# dependancies are right when the rule uses that variable below

ifndef INITRD_PARTS
$(variable INITRD_PARTS needs to be defined)
endif

# Combine the various modules to make one big cpio file
$(BUILD)/combined.initrd: $(INITRD_PARTS)
	cat $(DEBIAN).lzma $(filter-out $(DEBIAN).lzma,$(INITRD_PARTS)) >$@
CLEAN_FILES += $(BUILD)/combined.initrd

