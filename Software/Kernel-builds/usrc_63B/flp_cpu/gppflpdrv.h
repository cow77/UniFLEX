******        opt     nol                                                           |        lib     ../mach_m1/sysconfig.h        lib     ../include/macdefs.h                                          |        lib     ../include/flpdrvr.h                                          |        lib     ./gppflp.h        lib     ../include/params.h        opt     lis,exp                                                       |        opt     nop**  for DEBUG program is RAM based*        ifc     &a,'DBG'ROMBASE equ     $4000        elseROMBASE equ     $E000        endifVECTORS equ     $FFF0RAMBASE equ     $0400           just above Dual Port RamBUFFER  equ     $0800           track bufferSTACKSZ equ     64              enough?RDYWAIT equ     40000           delay count* hardware dependent valuesLA_DS0  equ     LA_SEL0|LA_MOT  drive select 0LA_DS1  equ     LA_SEL1|LA_MOT  drive select 1LA_DS2  equ     LA_SEL2|LA_MOT  drive select 2** DPR, command exchange withe kernel*CMDMSK  equ     %10010001       command maskCMDRSC  equ     %00010001       read sectorCMDWSC  equ     %00000001       write sectorCMDRTK  equ     %10010001       read trackCMDWTK  equ     %10000001       write track**