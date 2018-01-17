#
# A master make file - currently just to help with build-depends and clean
#

SUBDIRS += debian/
SUBDIRS += firmware/
SUBDIRS += linux/

# The boards/* subdirs should probably be controlled from a boards/Makefile
# - maybe later

QEMUDIRS += boards/qemu_armhf/
QEMUDIRS += boards/qemu_i386/
SUBDIRS += $(QEMUDIRS)

BOARDDIRS += boards/raspberrypi2/
BOARDDIRS += boards/sun4i-a10-cubieboard/
BOARDDIRS += boards/sun7i-a20-bananapi/
BOARDDIRS += boards/sun8i-h2-plus-orangepi-zero/
BOARDDIRS += boards/sun8i-h3-orangepi-lite/
BOARDDIRS += boards/sun8i-v3s-licheepi-zero/
SUBDIRS += $(BOARDDIRS)

# This is a list of files that only exist after any submodules are initialised
SUBMODULES += debian/Makefile

all:
	$(error This Makefile currently has no default build target)

build-depends clean reallyclean: $(SUBMODULES)
	$(foreach dir,$(SUBDIRS),$(MAKE) -C $(dir) $@ &&) true

image: $(SUBMODULES)
	$(foreach dir,$(BOARDDIRS),$(MAKE) -C $(dir) $@ &&) true

# Ensure that the submodules are actually present
$(SUBMODULES):
	git submodule update --init
