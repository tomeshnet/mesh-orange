# Apply configurations from conf.d
#
# Copyright (C) 2018 Benedict Lau <benedict.lau@groundupworks.com>

CONFDIR=conf.d

try_partition() {
    # Create file system node from partition
    mknod /dev/$1 b $2 $3 2>/dev/null

    # Mount partition as read-only
    mount /dev/$1 /mnt -o ro

    # Find conf.d in root of partition and extract in alphabetical order each
    # tar.gz archive into the ramdisk /etc, overwriting any existing file
    if [ -d "/mnt/$CONFDIR" ]; then
        for conf in /mnt/$CONFDIR/*.tar.gz; do
            echo Applying configurations from /dev/$1: $conf
            tar --warning=no-timestamp --extract -f $conf -C /etc
        done
    fi

    # Unmount partition
    umount /mnt
}

# Mount proc
mount -t proc proc /proc

cat /proc/partitions | while read major minor size name; do
    # Check each partition matching sd*[0-9] (e.g. sda1) or mmcblk*p* (e.g. mmcblk0p1)
    case $name in
        sd*[0-9]|mmcblk*p*)
            echo Checking for configuration files on $name
            try_partition $name $major $minor
            ;;
    esac
done
