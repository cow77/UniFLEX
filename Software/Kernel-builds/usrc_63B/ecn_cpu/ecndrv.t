** ECNDRV, ROM code for CPU09GPP with 09ECN add-on****            runs with Interrupts disabled**        lib     ./ecndrv.h        lib     ./ecndpr.h        ifc     &a,'DBG'romots  equ  $f804romoth  equ  $f802romotc  equ  $f806        endif        org     RAMBASE*state   rmb     1               statecurcmd  rmb     1        rmb     STACKSZromstck equ     *RAMEND  equ     *        org     BUFFER** receive buffer, transmit buffer*rcvbuf  rmb     ECNFSZxmtbuf  rmb     ECNFSZ        org     ROMBASE** configuration constants*** cold start*reset   equ     *        seti        lds     #romstck        clra        tfr     a,dp        fcb     $11,$3d,$03     LDMD #3  6309*        ldx     #ecndpr         go clear the Dual Port Ram        clrd*01      std     0,x++        cmpx    #ecndpr+ecntgpp*        blo     01b*        ldx     #RAMBASE02      std     0,x++        cmpx    #RAMEND        blo     02b*        jsr     ecnini          init hardware*** normally the driver loops here*warm    equ     *        seti        lds     #romstck        clr     state*01      jsr     ecncmd          new message from main CPU        beq     01b             wait        sta     curcmd          save it        bita    #ECNWRI        bne     netwr        bita    #ECNRDI        bne     netrd        anda    #255-(ECNWRI|ECNRDI)        sta     ecndpr+ecn_dprF command present?        bra     01b** on return: B=flag, X=last, Y=first*netrd   inc state        ldy     #rcvbuf        leax    ECNFSZ,y        clr     ecnrer        jsr     rxFrame        tstb                    result        bne     rerr1** check addressing*        ldd     0,y     get dstnet and dst adr        cmpd    ecndpr+ecnset        beq     netro1        cmpd    #$FFFF        bne     netrd           drop frame*netro1  subr    Y,X             X - Y -> X        trfr    X,W        stx     ecnrct        ldx     #ecndpr+ecnrff        tfm1    Y,X        bra     netr1*rerr1   sta     ecnrernetr1   lda     #ECNRDI        bra     fend***netwr   inc     state        ldd     ecnwct        trfr    D,W        ldy     #xmtbuf        ldx     #ecndpr+ecnrff        tfm1    X,Y        ldy     #xmtbuf        leax    d,y        jsr     txFrame        tstb        beq     netw1        sta     ecnwernetw1   lda     #ECNWRI        bra     fend****fend    ldb     #7        stb     statefend1   nop        bsr     ecnack          tell main CPU about it*        jmp     warm**  write POSTBOX to other CPU I'm done*ecnack  ldb     #8        stb     state        clr     curcmd        sta     ecndpr+ecn_cpuF        clr     ecndpr+ecn_dprF        rts** flpcmd, test INTBOX for new data from main CPU*ecncmd  lda     ecndpr+ecn_dprF command present?        rts        lib     ecnadlc.t* all process registers stackednmihnd  equ     *        if      (DBG=1)        rti        endifrtiend  nop        inc     $03f0        rti        org     VECTORS        fdb     rtiend        fdb     rtiend        fdb     rtiend        fdb     rtiend        fdb     rtiend        fdb     rtiend        fdb     nmihnd        fdb     reset        end