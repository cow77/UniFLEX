** System Parameters - adjust accordingly*CPUID   set     6309        if      CPUID=6809CPUTYP  equ     $00     6809STKREG  equ     12        else        if      CPUID=6309CPUTYP  equ     $03     6309STKREG  equ     14        else        error   "NO CPU ID set"        endif        endifSSIZE equ 1 initial stack size (*PAGSIZ)MAXJOB equ 20 maximum simult user tasksNBLKS equ 16 Accessable pages in address spaceUSRHIP equ NBLKS-1 User's highest addressable pageUSRHIP_4 equ USRHIP<<4USRHIP_FC equ USRHIP_4+$C    largest absolute program size* terminal i/o constantsOQHI equ 119 outq upper limitOQLO equ 15  outq lower limitCHRLIM equ 254 max characters on q*LIGHTS equ $f006LB_FIO0         equ     %10000000LB_BLKIO        equ     %00001000LB_SWOUT        equ     %00000100LB_SWPIN        equ     %00000010LB_IDLE         equ     %00000001** Machine constants*DATBOX equ $F400 memory mapper regsCLOCK equ $F004 CPU09 clock baseCLKSEL equ CLOCK+1 clock select and status registerCLKLAT equ CLOCK clock timer latchCLKCON equ %00000001 clock control (gimix)CLKMSK equ %10000000 clock interrupt maskHZTIM   equ     100/10-1  interrupt rate (50Hz)**  Special device addresses*BASACI equ $F000** PIA on MONitor card serves also for* timer control (100Hz) on port A* and memory trap signalling on port B*timctrl equ $F005     control registertimdata equ $F004          data registertrpctrl equ $F007          control registertrpdata equ $F006          dataregister*uisctr  equ     $FE00   interrupt depth counter (read)cuddwn  equ     $FE01   interrupt nest counter        (write)k_u_map equ     $FE02   user/kernel map and vectors   (write)tlatch  equ     $FE03   task select latch             (write)*** IOP and GPP boards**IOP0BASE equ     $f200   IOP device*UIO0BASE equ     $f300   UIO device*SPI0BASE equ     $E000   1Kx8 dualport RAMFLP0BASE equ     $E000   1Kx8 dual port RAM Floppy interface*NWP0BASE equ     $E800   1kx8 dual port RAM NETWORK CPU*RAM0BASE equ     $EC00   HW: 512 byte buffer and 512 (2) control locations*