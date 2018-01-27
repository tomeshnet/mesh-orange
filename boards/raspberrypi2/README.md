Automated builder for various Raspberry Pi boards
=================================================

Please note!  This project will not be able to support Raspberry Pi Zero,
Compute Module 1, Raspberry Pi 1A or Raspberry Pi 1B boards without major
changes to the debian-minimal-builder submodule - this is due to hardware
incompatibilities and is unlikely to change.

Supported Boards
----------------

This works on the 2b and 3b and should work for the cm3 (but I have
not tested that) as they are all using ARMv7+ CPUs that are compatible
with the Debian "armhf" architecture definition.

The other Raspberry Pi systems (the older ones and the Zeros) all use
an ARMv6+VFP cpu, which is incompatible with the Debian "armhf" - do
not be fooled by the fact that Raspbian uses an architecture called
"armhf", they have simply (and confusingly) redefined their architecture
to match their needs.


Raspbian vs Debian in the Raspberry Pi World
--------------------------------------------

The most annoying bit about this is that the world now has two
Debian-ish architectures named armhf that are only compatible in one
direction (Raspbian armhf binaries should work on Debian armhf systems -
just slightly slower) and no clear naming to tell them apart, thus
making multiarch impossible to use to fix this.

The upshot is that the build system could build images for the other
Raspberry Pi systems, but it would need the debian builder to build
one based on Raspbian.

