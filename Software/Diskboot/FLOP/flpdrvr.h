        pag** This is the header file for the kernel flpdrvr.t and* for gppflpdrvr.t** BIT defines* IO defines        ifc     &b,'GPPFLP'flpdpr  equ     $0000        else        global  flpdpr,flpintflpdpr  equ     $e000   base address controller 0        endif** OFFSET's in Dual Port Ram*flrflg  equ     0       transaction read/write flag (copy of bfflag)flblkh  equ     1       block address high (unused)flblkm  equ     2       midflblkl  equ     3       lowfltsiz  equ     4       transaction size (total bytes)fltxfr  equ     6       transferred data size (actual bytes)flstat  equ     8       result status (error)fldriv  equ     9       which driveflnwop  equ     10      driver new open flag* ttyget/ttyset byte parameters for the selected drivefltsid  equ     11      side      floppy ttyget/set bytesfltden  equ     12      density* DPR_DMAX sets the locationflpfifo equ     $20     offset to DPR fifo buffer* disk hardware parametersflpstp  equ     $3f0    step rate* last 16 bytes are specialfio2cp  equ     $3fc    debug port data from IO to CPUfcp2io  equ     $3fd    debug port data from CPU to IO* 'postbox' locations between the 2 sides of the DPR* set INT when written (and enabled)flpint  equ     $3fe   IOP tells you it did somethingflptel  equ     $3ff   tell IOP you want something*