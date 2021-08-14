** debug device for DUAL PORT RAM* environments** it is doing very simple byte-banging to/from the dual port* RAM. If the IO RAM does not support a debug environment* no harm will be done, data is just disgarded.* when the dual port RAM is absent, the device refuse to open* table with 'IO' addresses* ext to cpu is FRM, cpu to ext is FRM+1IOP0FRM equ     $f2fc   data from iop to cpuIOP1FRM equ     $f3fcGPP1FRM equ     $e3fc   data from gpp to cpuGPP2FRM equ     $e7fcGPP3FRM equ     $ebfcGPP4FRM equ     $effc        lib     environment.h        lib     ../include/macdefs.h        if      (GPPDBG=1)        global          gppdop,gppdcl,gppdrd,gppdwr,gppdstioadtb  fdb     IOP0FRM        fdb     IOP1FRM        fdb     GPP1FRM        fdb     GPP2FRM        fdb     GPP3FRM        fdb     GPP4FRMMXDBDV  equ     (*-ioadtb)/2   max devices** open port and check if it is present*gppdop  equ     *       B holds minor        bsr     gppdsp  set port parameters        bne     gppder  invalid port        rts** close port*gppdcl  equ     *        bsr     gppdsp        bne     gppder        rtsgppder  lda     #EIO        sta     uerror        rts** do sanity checks*gppdsp  pshs    b        cmpb    #MXDBDV        bls     gppds2        bsr     gppder        bra     gppds1* set X register for IO referencesgppds2  ldx     #ioadtb ioaddress table        aslb        abx        ldx     0,x        ldb     1,x     test if there is a remote cpu        beq     gppds1gppds1  puls    b,pc** read, return one character*gppdrd  equ     *        bsr     gppdsp        ldb     0,x        pshs    x        jsr     passc        puls    x        clr     0,x        rts** write, put onde character*gppdwr  equ     *        bsr     gppdsp        pshs    x        jsr     cpass        puls    x        stb     1,x        rts** stty/gtty, do nothing here*gppdst  rts        endif