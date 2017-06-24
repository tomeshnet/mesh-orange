setenv bootargs console=ttyS0,115200 panic=5 console=tty0 rootwait root=/dev/mmcblk0p3 earlyprintk rw
load mmc 0:1 0x41000000 boot/zImage
load mmc 0:1 0x41800000 boot/dtb/sun8i-v3s-licheepi-zero.dtb
bootz 0x41000000 - 0x41800000

