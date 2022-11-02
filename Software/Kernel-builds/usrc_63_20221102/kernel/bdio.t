          lib     environment.h          sttl    Block      Device I/O Handlers          pag          name    BD_io          global  BDopen,BDclose,BDio,BDioend** BDopen**   Call the appropriate open routine for a block device*BDopen    cmpb    blkmdm,x   legal minor device?          lbhs    BDioerr2   no - error          leas    -2,s       make room for routine address          pshs    x          ldx     blkopn+2,x pick up handler table address          leax    b,x        adjust by minor device number          leax    b,x          ldy     ,x         pick up handler address          sty     2,s        place on stack          puls    x          restore table address          jmp     [,s++]     call handler** BDclose*BDclose   cmpb    blkmdm,x   legal minor device?          lbhs    BDioerr    no - error          leas    -2,s       make room for routine address          pshs    x          ldx     blkcls+2,x pick up handler table address          leax    b,x        adjust by minor device number          leax    b,x          ldy     ,x         pick up handler address          sty     2,s        place on stack          puls    x          restore table address          jmp     [,s++]     call handler** BDio** Main routine to do io through block device.  The buffer* header has all needed information and is pointed* at by Y upon entry.  All that is done in this* routine is to put the transaction record (the* buffer header) on the io queue for this device.* X=blktab* Y=bufhdr*BDio      seti                mask interrupts          inc     bdiocnt    bump active count          LEDON   LB_BLKIO   turn on "I/O" bit          ldu     blktpt,x   pick up device table address          ldd     dtqfl,u    get first transaction from q          bne     BDio1      is it null?          sty     dtqfl,u    put in list          bra     BDio2BDio1     pshs    x          save block table address          ldx     dtqbl,u    add to tail of list          sty     dtqfl,x          puls    x          restore addressBDio2     sty     dtqbl,u    set back link          ldd     #0         zero out forward link          std     dtqfl,y          if      0          bsr     prt_dtq    print device transaction queue          endif          lda     dtbusy,u   is device busy?          bne     BDio6          lda     bfdvn+1,y  pick up minor device #          cmpa    blkmdm,x   legal minor device?          bhs     BDioerr    no - error          pshs    y          leas    -2,s       make room for routine address          pshs    x          ldx     blkio+2,x  pick up handler table address          lsla          leax    a,x        adjust by minor device number          ldd     ,x         pick up handler address          std     2,s        place on stack          puls    x          restore table address          jsr     [,s++]     call handler          puls    yBDio6     clri               clear interrupts          rts     returnBDioend          ldd     stablk+2   update count of blocks transfered          addd    #1          std     stablk+2          bne     0f          ldd     stablk          addd    #1          std     stablk0         dec     bdiocnt    update count          bne     0f          LEDOFF  LB_BLKIO    turn off "I/O" bit0         ldu     blktpt,x   restore device table address          ldd     dtqfl,y    get next transaction          std     dtqfl,u          pshs    x,u        save registers          lbsr    rlsio      release io buffer          puls    x,u        restore registers          ldy     dtqfl,u    get first transaction          bne     BDioend2          rts     none       here, so returnBDioend2  lda     bfdvn+1,y  pick up minor device #          cmpa    blkmdm,x   legal minor device?          bhs     BDioerr    no - error          leas    -2,s       make room for routine address          pshs    x          ldx     blkio+2,x  pick up handler table address          lsla          leax    a,x        adjust by minor device number          ldd     ,x         pick up handler address          std     2,s        place on stack          puls    x          restore table address          jmp     [,s++]     call handlerBDioerr   lda     bfflag,y   mark error in buffer header          ora     #BFERR          sta     bfflag,yBDioerr2  lda     #EBARG     bad parameter          sta     uerror          bra     BDio6      exit          if      0* Print device transaction queue for device (U)prt_dtq   pshs    d,x,y,u    save registers          ldx     #00f          jsr     Pdata          lda     dtbusy,u          jsr     Phex0         ldy     dtqfl,u    get buffer header          beq     99f          bsr     prt_bh     print buffer header          leau    0,y          bra     0b99        puls    d,x,y,u,pc return00        fcc     $d,'Device queue: - Busy = ',0prt_bh    pshs    d,x,y,u          ldx     #00f          jsr     Pdata          ldd     bfdvn,y          bsr     phex2          ldx     #01f          jsr     Pdata          lda     bfflag,y          jsr     Phex          ldx     #02f          jsr     Pdata          lda     bfblch,y          jsr     Phex          ldd     bfblck,y          bsr     phex2          puls    d,x,y,u,pc*phex2     pshs    d          jsr     Phex          lda     1,s          jsr     Phex          puls    d,pc*00        fcc     $d,'Block I/O, Device = ',001        fcc     ', Flags = ',002        fcc     ', Block = ',0          endifbdiocnt   fcb     0