        ttl     gpp_flp*       abs        opt     nol        lib     ../include/macdefs.h        lib     ../include/flpdrvr.h        opt     lis,exp        opt     nopdebram  equ     $0380program equ     $4000LA_DS0  equ     %00001001         org     debram        debug locations in DPR RAM*  now debug in DPR RAMdummy   rzb     16side    rzb     1dens    fcb     1track   rzb     1sector  rzb     1latch   rzb     1*wrkprm  fdb     fltabl*step    rzb     1retry   fcb     4bf1ptr  rzb     2bf1siz  rzb     2bf2ptr  rzb     2bf2siz  rzb     2        org     program** code space*start   equ    *        orcc    #$50        lda     flpdpr+flptel        lbeq    loop*        lda     #4        sta     retry        lda     #LA_DS0        sta     fdcbas+fo4lat        sta     latch        jsr     chkrdy        lbne    08f22      lda     flpdpr+flnwop        beq     24f*        clr     flpdpr+flnwop47      jsr     restore*24      ldb     #1        stb     step07      clr     flpdpr+flstat        lda     latch        sta     fdcbas+fo4lat        ldy     #5000021      lda     fdcbas+fo2cmd        bpl     20f            ready        leay    -1,y        bne     21b        lda     #$81        jmp     08f20      ldx     wrkprm        ldd     0,x        cmpd    flpdpr+fltsid        beq     30f        jsr     srchpm*       bra     20b30      ldb     #2        stb     step        jsr     clcpos         block -> track/sector        bne     08f        ldx     #fdcbas        ldb     #3        stb     step        jsr     fseek        bne     08f        ldu     #flpdpr+flpfifo        ldx     #fdcbas        ldb     #4        stb     step        jsr     frdsec        sta     flpdpr+flstat        beq     08f        cmpa    #%10010000        bne     15f        dec     retry        bpl     47b        bra     08f15      dec     retry        bpl     07b*08      sta     flpdpr+flstat        ldb    #5        stb     step        nop        clr    flpdpr+flptel   remove request        lda     #$ff           tell CPU we did it        sta     flpdpr+flpint*loop    nop        tst     $03fd       debug acia data        beq     04f10      swi04      jmp     start** chkrdy, check if drive is ready, wait a short period for it*chkrdy  pshs    b,y        ldy     #$7fff        ldb     #$0721      lda     fdcbas+fo2cmd        bpl     24f            ready  (FS_NRDY)        lda     latch        sta     fdcbas+fo4lat        leay    -1,y        bne     21b        decb        bne     21b        lda     #$81        bra     22f24      clra22      puls    b,y,pc*** restore*restore equ     *        lda     #FD_RST         restore        eora    #EOR4FDC        sta     fdcbas+fo2cmd        jsr     dlytim01      lda     fdcbas+fo2cmd        bita    #%00000001        bne     01b        clr     track        rts** The FDC needs some time for a command to enter, hence delay*dlytim  bsr     dly1dly1    bsr     dly2dly2    bsr     dly3dly3    exg     x,x        rts** code routine, to read one sector from FDC* U holds buffer address, count from data address mark* drive select, density and such alreay set up* time out from INT fdc*frdsec  equ     *        pshs    cc,x,y,u*        lda     #FD_SRD         start read operation        eora    #EOR4FDC        sta     fo2cmd,x        jsr     dlytim*01      orcc    #$50            disable ints        bra     03f02      lda     fo2dat,x         get data        eora    #EOR4FDC        sta     0,u+03      lda     fo2cmd,x        follow next        eora    #EOR4FDC        bita    #FS_DRQ        bne     02b        bita    #FS_BUSY        bne     03b*98      ldy     5,s        subr    Y,U             get count        cmpu    #512        beq     97f        lda     #%00010000         rnf        bra     96f             count in X97      lda     fo2cmd,x        read status        anda    #(FS_NRDY|FS_RNF|FS_CRC)        beq     99f96      ora     #$8099      puls    cc,x,y,u,pc** code routine, to write one sector to the FDC* U holds buffer address, count from data address mark* drive select, density and such alreay set up* time out from INT fdc*fwrsec  equ     *        pshs    cc,x,y,u*        lda     #FD_SWR         start write operation        eora    #EOR4FDC        sta     fo2cmd,x        jsr     dlytim*01      orcc    #$50            disable ints        bra     03f02      lda     0,u+        eora    #EOR4FDC        sta     fo2dat,x        put data03      lda     fo2cmd,x        follow next        eora    #EOR4FDC        bita    #FS_DRQ        bne     02b        bita    #FS_BUSY        bne     03b*98      ldy     5,s        subr    Y,U             get count        cmpu    #512        beq     97f        lda     #%00010000      rnf        bra     96f             count in X97      lda     fo2cmd,x        read status        anda    #(FS_NRDY|FS_RNF|FS_CRC)        beq     99f96      ora     #$8099      puls    cc,x,y,u,pc** clcpos, transfer block# into track/sector/side*clcpos  equ     *        ldd     flpdpr+flblkm   block no        clr     0,-s02        subd    3,x             sectrk        blo     01f        inc     0,s             up track #        bra     02b01      addd    3,x* sec in B,track# on stack        pshs    b        ldb     0,x            is double side?        andb    #%00000001        puls    b        beq     05f             no*        lsr     0,s            track#        bcc     05f            even track* odd track, add bias        addd    3,x        pshs    b        ldb     latch        orb     #LA_SID        select side 1        stb     latch        puls    b*05      incb                    1 relative03      stb     sector*        puls    a        sta     track        cmpa    2,x        bhi     91f        clra        rts90      lda     #%10000001        rts91      lda     #%10000000        rts*** fseek,*fseek   equ     *        pshs    x,y,u        lda     latch        sta     fo4lat,x        lda     sector        sta     fo2sec,x        lda     track        cmpa    fo2trk,x        beq     80f*        sta     fo2dat,x        lda     #FD_SEK        sta     fo2cmd,x        jsr     dlytim*       ldy     #5000001      lda     fo2cmd,x        bita    #FS_BUSY        beq     80f*       leay    -1,y*       bne     01b        bra     01b        lda     #$81        bra     02f80      lda     latch        sta     fo4lat,x        clra02      puls    x,y,u,pcsrchpm  equ     *        ldx     #fltabl03      ldd     0,x        beq     01f             end of table        cmpd    flpdpr+fltsid        beq     01f        leax    6,x        bra     03b01      stx     wrkprm        rtsfltabl  equ     *        fcb     $11,$c1,79,0,20,0       F3-DH80        fcb     $00,$c1,79,0,20,0       F3-SH80        fcb     $11,$01,79,0,16,0       F8-DD80        fcb     $00,$01,79,0,16,0       F8-SD80        fcb     $01,$01,79,0,16,0       FD-DD        fcb     $00,$01,79,0,16,0       FD-SD        fcb     $01,$00,79,0,8,0        FD-DS        fcb     $51,$01,79,0,9,0        F5-DD80        fcb     $51,$00,79,0,5,0        F5-DS80flpdfl  fcb     $00,$00,79,0,8,0        FD-SS