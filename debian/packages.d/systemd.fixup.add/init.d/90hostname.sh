# A default hostname
#
# Copyright (C) 2017 Hamish Coleman <hamish@zot.org>



# Only do this if there is not already a hostname configured
if [ ! -f /etc/hostname ]; then

    # First, Try to create a stable hostname from our ethernet addr
    hostid=`ip link show dev eth0 |grep ether`

    if [ -z "$hostid" ]; then
        # No ethernet, try a stable name from the first wifi addr
        hostid=`ip link show dev wlan0 |grep ether`
    fi

    if [ -z "$hostid" ]; then
        # Nothing worked, use some (bogus this soon after boot) randomness
        hostid=`dd if=dev/urandom bs=16 count=1`
    fi

    hash=`echo $hostid | sha1sum | cut -c1-8`

    echo "ramdisk-$hash" >/etc/hostname
fi


