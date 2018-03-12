#
# Common rules and definitions for building a fully installed, non ramdisk
# system ("xD" - where "x" is "anything except Ram")
#

# Note that this make fragment needs to be included /after/ anything that adds
# more values to the INITRD_PARTS variable, in order to ensure that the
# dependancies are right when the rule uses that variable below

ifndef INITRD_PARTS
$(variable INITRD_PARTS needs to be defined)
endif

# Build a list of all the cpio files comprising our root filesystem
# We convert from lzma extensions to cpio extensions so we dont need
# to compress/decompress (the installed system does not use compressed
# files)
# We are also a little paranoid and ensure that the first archive
# to process will be the main debian archive
#
CPIO_FILES = $(addsuffix .cpio,$(basename $(DEBIAN).lzma $(filter-out $(DEBIAN).lzma,$(INITRD_PARTS))))

# A default disk image size that allows boot+swap+root to fit in 1G
# FIXME
# - this needs to be equal or smaller than the PART3_SIZE_MEGS!
PART_SIZE_ROOT_MEGS ?= 700


# Note that if we didnt want subvolumes, we could use the
# mkfs.btrfs "--rootdir" feature that avoids needing suid and loop mount

$(BUILD)/root.fs: $(CPIO_FILES)
	truncate --size=$$(( $(PART_SIZE_ROOT_MEGS) ))M $@.tmp
	mkfs.btrfs -L root $@.tmp
	mkdir -p $@.dir
	sudo mount -o loop $@.tmp $@.dir
	sudo btrfs subvolume create $@.dir/@.orig
	for i in $(CPIO_FILES); do \
            cat $$i | ( \
                cd $@.dir/@.orig; \
                sudo cpio --make-directories -i; \
            ); \
	done
	sudo mkdir $@.dir/@.orig/btrfs
	sudo rm $@.dir/@.orig/init.d/01welcome.sh
	sudo ln -s /init $@.dir/@.orig/sbin/init
	sudo btrfs subvolume snapshot $@.dir/@.orig/ $@.dir/@/
	sudo btrfs subvolume set-default $$(sudo btrfs subvolume list $@.dir/ |sort |tail -1 |cut -d" " -f2) $@.dir
	sudo umount $@.dir
	mv $@.tmp $@

# TODO
# boot:
# mount -o subvolid=5 $device /btrfs
# btrfs subvolume delete /btrfs/@.current/
# mv /btrfs/@ /btrfs/@.current
# btrfs subvolume snapshot /btrfs/@.orig/ /btrfs/@.new
# ID=$(btrfs subvolume list /btrfs/ |grep @.new |cut -d" " -f2)
# sudo btrfs subvolume set-default $ID /btrfs
# mv /btrfs/@.new /btrfs/@
# umount /btrfs

# TODO
# - cleanup
