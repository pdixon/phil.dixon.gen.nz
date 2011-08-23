---
title: Debugging an STM32 With OpenOCD and GDB
tags: embedded
---

## Hooking GDB to OpenOCD

OpenOCD implements the GDB remote protocol. Typically OpenOCD serves up a port
on localhost, GDB then connects to this. In this arrangement there are two
process involved in the debugging and they need to managed separately. This is
a pain and tends led to scripts with `pskill` in them [^1].

It turn out that this isn't the only way for GDB to communicate with the
remote. The remote target can also be run as a child process.

    target remote | openocd -p

By doing things this way we now only have one set of processes to manage (no
more `pskill`).

## Watchpoints

The Cortex M3 has hardware watch points in it's onboard debugging unit
(see [Cortex M3 Specifications][cortex-m3]).
OpenOCD and GDB both support watch points. Setting watch points using the
`watch` command in GDB doesn't seem to work. Setting the watch points in
OpenOCD using monitor commands does seem to work.

    monitor rwp [address] length

Watchpoints are removed with:

    monitor rwp [address]

{% gist 1124914 %}

[^1]: `pskill` in scripts always makes me feel a bit uncomfortable.

[cortex-m3]: http://www.arm.com/products/processors/cortex-m/cortex-m3.php
