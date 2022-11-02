** declaration for  ecndrvr.t** MAKE these contents MATCH with ../ecn_cpu/ecndpr.h*ECNFSZ  equ     520             ECN fifo size 512 data + 8 headerECNPRI  set     15ECNRDI  equ     %01000000       read IRQ flagECNRII  equ     %00010000       aborted readECNWRI  equ     %10000000       write IRQ flagECNWII  equ     %00100000       aborted writedprecn  equ     $e400           where DPR sits in kernel space        base    0        base   $00e0** read side of DPR** read mailboxecnrct  rmb     2               read countecnrxf  rmb     2               read xferredecnrer  rmb     1               read errorecnrda  rmb     1               read acknowledgeecndm1  rmb     10** write side of DPR** write mailboxecnwct  rmb     2               write countecnwxf  rmb     2               write xferred        rmb     1ecnwra  rmb     1               write acknowledge[Aecndm2  rmb     10*        base    $0100ecnrff  rmb     ECNFSZ                base $03f0ecnset  rmb     4ecnget  rmb     4                base $03fc*DEV2CPU equ     *ecnfgpp rmb     1CPU2DEV equ     *ecntgpp rmb     1* INT and message locationsecn_cpuF rmb    1              non-zero when mailbox has dataecn_dprF rmb    1               non-zero when mailbox has data*