This is the rough set of notes for the steps I followed:

* install armbian image
    FIXME - link
* change to debian stretch
* * upgrade all
* change armbian to beta
* * upgrade kernel
* * FIXME - instructions from armbian
* set fq_codel as default packet scheduler
* Stop using the crazy name generateor for "stable" interface names
* Apply fix to uboot to enable SMP
* install and configure hostap for onboard wifi access point (plus iptables)
* create mesh network with available wlan devices
* compile cjdns and start it
* mactelnet (I used this, possibly not needed for a standard image)
* bunches of tools installed

Future things I think should exist:
* config storage (spi flash?, just a magic file in /boot?)
* auto hostname
* change initial password
* add udev persistent-net-generator.rules - style network interface naming
* autoconfiguration for plugged in wifi devices
* use a known prefix for tunnel names to allow stable iptables rules and
  coexistance with other tunnel systems
* IPFS
* debian root filesystem autobuilder, generating initramfs images
* u-boot rules to boot of one or the other of the initramfs images

