---
date: 2011-12-28
title: Building a Kernel for the Beaglebone
---

I wanted to get some extra hardware enabled on my [Beaglebone][bone]. As far
as I known this means building a new kernel. The only references I
found were talking about rebuilding the entire system. I tried doing
this with the default [Angstrom][angstrom] distribution. I couldn't
get this to build the kernel at all.

I give up on Angstrom and looked for an alternative.
[Buildroot][buildroot] looked very promising. 

There are two kernel trees of interest. Beagleboard have a
[tree][beagle-kernel] with some Beaglebone specific hardware set up.
There is also [tree][ti-am33x] hosted by TI where the SoC work
happens. In theory the beagleboard tree is based on the TI tree. In
practise there seem to be patches in the TI tree that haven't made
into the beagleboard tree. I used the TI tree and cherry picked the
patches I was interested in[^fn1]

# Building the Kernel

Earlier I mention buildroot and Angstrom. After I got buildroot going
I found if all you want is a kernel this is unnecessary. The kernel
build system has direct support for cross compiling.

## Configuring

~~~~{.sh}
make ARCH=arm CROSS-COMPILE= menuconfig
~~~~ 

## Building

~~~~{.sh}
make -j2 ARCH=arm CROSS-COMPILE= uImage
make -j2 ARCH=arm CROSS-COMPILE= modules
~~~~

## Installing

~~~~{.sh}
cp arch/arm/boot/uImage /media/boot
make TODO=/media/rootfs module_install
~~~~


[^fn1]: I think only the LED step up was the only thing I bothered grabbing.

[bone]: http://beagleboard.org/bone
[angstrom]: http://www.angstrom-distribution.org/
[buildroot]: http://buildroot.uclibc.org/
[ti-am33x]: http://arago-project.org/git/projects/?p=linux-am33x.git;a=summary
[beagle-kernel]: https://github.com/beagleboard/linux
[crosstool]: http://
[linaro]: http://
