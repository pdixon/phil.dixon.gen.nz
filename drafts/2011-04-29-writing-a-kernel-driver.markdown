---
title: Writing a Linux Kernel Driver
description: 
tags: kernel, coding
---

Recently I've been working writing a Linux Device Driver.

## Getting it Building

It took me some time to work out 

~~~

~~~

- a minimal out of tree make file.
- getting it running.

I was working on a driver for a USB to CAN interface. The driver ends
involving three sets of kernel APIs.

- Module handling
- USB Device handling
- candev which is built on top of and exposes some of netdev.
