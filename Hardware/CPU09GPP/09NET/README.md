
 This is the new 09NET module

 
 ![09NET-board](./20231220_092242.jpg)
 
* works with CPU09GPP
* works with UniFLEX kernel with 'sockets' added to kernel
* wzdrvr/socket should be in kernel boot image

The module in combination with the CPU09GPP provides TCP/IP communications
for UniFLEX 6X09. The software however is tailored for the HD63C09 CPU.

The module provides up to 8 socket connections.

The network connection is UTP connector.

In the kernel a few Berkely (TCP/IP) calls are added:

socket(), connect(), bind() and listen(), accept(), read(), write(), close,
so that both client and server applications can be served.

Additionally recfrom() and sendto() calls (UDP) are also implemented

Also a socklib.r is being created, that allows the Mc Cosh C compiler to
build programs with networking capabilities.

Hm, yes, I used a few SMT components, the ones to serve as 3V3 power source
for the W5500 module. The IO pin's are 5 V tolerant.

The scope screenshot shows the nice timing of the SPI clocks versus the data bits.
Here the SPI address was 0003 (big endian)


