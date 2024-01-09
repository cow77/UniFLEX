          lib     ./environment.h          opt     nol          lib     ../include/macdefs.h          lib     ../include/inttab.h          lib     ../include/task.h          lib     ../include/tty.h          lib     ../include/sysdefs.h          opt     lis          lib     ../include/dpr.h          lib     ../include/fio_codes.h          sttl    DPR        Interface          pag          global  NUM_TRM,NUM_TSKDPR_COST  set     2          Activity cost for DPR transaction          data          global  dpr_int          global  dpr_open,dpr_close,dpr_write,dpr_read,dpr_spcl          global  dpr_waitdpr_wait  fcb     0          Count of tasks waiting for this DPR access (global)*         lib     ./dpr.t** dpr_int - Process DPR interrupt*   Y - DPR Control structure*mbx_getdpr_int   pshs    x,y          ldx     dpr_dba,y  point to base address          leay    dpr_tran,y point to transaction list          ldb     NUM_TRAN   # transactions          pshs    b15        lda     dpr_seq,x  check transaction #          cmpa    tran_seq,y match?          beq     20f        yes - go*          leay    TRAN_SIZ,y next transaction          dec     0,s        any more?          bne     15b* -- Unsolicited response!          puls    b          bra     99f        exit*20        ldd     dpr_val0,x          std     tran_val0,y          ldd     dpr_val2,x          std     tran_val2,y          ldd     dpr_val4,x          std     tran_val4,y          ldd     dpr_val6,x          std     tran_val6,y*          lda     dpr_cpuF,x get response code          clr     dpr_cpuF,x indicate message received*20        puls    b          clean up stack          sta     tran_resp,y save response code          jsr     wakeup     wake up sender99        puls    x,y,pc     return** dpr_msg - Send a value via the DPR Mailbox & wait for response*   X - transaction slot*   Y - Interlock table*   B - command*   jsr dpr_msg*   D - Value returned (B = Error response, A = Specific data)** dpr_putdpr_msg   pshs    cc,d,x,y,u save registers* -- Find an empty transaction box10        seti               turn off interrupts          ldy     5,s        get DPR control structure address          jsr     MBX_lock   get access to DPR*15          ldb     0,s        enable (old) interrupts          tfr     b,cc          ldy     5,s        restore IOP structure pointer          ldy     dpr_dba,y  base address hardware          lbsr    dpr_send          ldy     5,s          jsr     MBX_unlock release mailbox*20        ldy     3,s        get transaction slot address          seti    mask       interrupts          tst     tran_resp,y any response yet?          bne     30f        yes - go process*          ldx     5,s        get IOP control address          ldd     dpr_fifo,x does this task own the FIFO?          bne     25f        yes - don't allow interrupts!*          pshs    y,u        save registers          ldd     umark1     set up to allow interruptable sleep          pshs    d          ldx     #27f       interrupt handling label          pshs    x          sts     umark1          ldb     #TTYIPR    set interruptable priority          jsr     A_sleep    wait for IOP response          puls    d,x,y,u    restore registers          stx     umark1     restore interrupt point          bra     30f        continue*27        puls    x,y,u      Interrupt happened! - (D) already popped          stx     umark1     restore stack mark          lda     #E_ABORT   aborted transaction!          sta     tran_resp,y          ldb     #O_INTRPT          pshs    y          save transaction slot pointer          ldy     7,s        restore IOP control pointer          jsr     MBX_lock   get access to mailbox          jsr     fio_send          jsr     MBX_unlock release mailbox          ldy     5,s        restore transaction slot pointer          bra     30f*25        ldb     #IOPPRI          pshs    x,y,u      save registers          jsr     A_sleep          puls    x,y,u      restore registers*30        ldx     utask          seti    turn       off interrupts while fiddling with transaction slots* -- See if there is a response.  It is possible to* -- get here without one if an interrupt happened which* -- was being ignored.  In this case, the IOP doesn't* -- need to be notified of any interrupt, but we must* -- wait for the IOP response to actually arrive.          ldb     tran_resp,y get response code          bne     35f        jump if response present*          pshs    y          reset stack          bra     20b        wait for response*35          cmpb    #E_ABORT          bne     50f        no - continue*          lds     umark1     yes - get out          rts*50        puls    cc,d,x,y,u,pc return** gettslot - find a transaction slot*   Y - DPR control address*   jsr gettslot*   Y - Transaction slot*   <NE> if none available*gettslot pshs     cc,b,x,y save register05        seti                  no interrupts here* search for MY transaction first          leay    dpr_tran,y point to transactions          ldb     NUM_TRAN          stb     1,s*10        lda     utask+1    check for busy entries          ora     #1          cmpa    tran_seq,y          beq     35f        yes - use it!          leay    TRAN_SIZ,y          dec     1,s        any more?          bne     10b*          ldy     4,s        restore DPR pointer          leay    dpr_tran,y point to transactions          ldb     NUM_TRAN          stb     1,s* next find free slot20        lda     tran_seq,y entry busy?          beq     30f        no - use it!          leay    TRAN_SIZ,y          dec     1,s        any more?          bne     20b*          leay    iop_tflg,y    sleep on transaction slots          ldb     #IOPPRI          jsr     Q_sleep       wait for available message slot          ldy     4,s           restore DPR pointer          bra     05b*30        lda     utask+1       allocate          ora     #1          sta     tran_seq,y35        sty     4,s        return value*99        puls    cc,b,x,y,pc   clean stack & return** puttslot, return transaction slot to pool* Y = DPR pointer**puttslot  pshs    y          clra          sta     tran_seq,y          sta     tran_resp,y          leay    iop_tflg,y    wake anybody waiting for this slot          jsr     wakeup        on Y          puls    y,pc** MBX_lock - Lock the DPR interface*    Y - IOP Control address*MBX_lock  pshs    cc,d,x,y,u save registers          seti    mask       interrupts          ldx     utask      get task pointer          ldd     dpr_mbx,y  mailbox already locked?          beq     10f        no - go check FIFO*          cmpd    tstid,x    locked by me?          bne     20f        no - must wait*10        ldd     dpr_fifo,y FIFO locked?          beq     50f        no - go lock mailbox*          cmpd    tstid,x    locked by me?          beq     50f        yes - still OK*20        inc     dpr_wait          ldb     #IOPPRI          pshs    y          preserve register          jsr     Q_sleep    yes - sleep until available          puls    y          restore register          dec     dpr_wait          puls    cc,d,x,y,u restore environ          bra     MBX_lock   try again*50        ldd     tstid,x    lock mailbox          std     dpr_mbx,y          clr     dpr_int,y  no missed interrupts*99        puls    cc,d,x,y,u,pc return** MBX_unlock - unlock the DPR interface**    Y - IOP Control address*MBX_unlock pshs    cc,d,x,y,u          seti    turn       off interrupts          lda     dpr_int,y  did we miss an interrupt?          beq     05f        no - continue*          jsr     dpr_int    yes - pretend we're seeing it now!*05        clr     dpr_int,y  reset flag          ldd     #0          std     dpr_mbx,y  reset lock          jsr     wakeup     wake up anybody waiting on this IOP          ldy     5,s        restore pointer          lda     dpr_wait   was anybody waiting?          beq     10f        no - exit          ldx     utask      reset priority          jsr     fixpri          jsr     change     let somebody else run*10        puls    cc,d,x,y,u,pc return** DPRF_lock - Lock the DPR FIFO buffer*    Y - DPR Control address*DPRF_lock pshs    cc,d,x,y,u save registers          seti               mask       interrupts          ldx     utask      get task pointer          ldd     dpr_fifo,y FIFO locked?          beq     10f        no - go check mailbox*          cmpd    tstid,x    locked by me?          bne     20f        no - must wait*10        ldd     dpr_mbx,y  mailbox already locked?          beq     50f        no - go lock FIFO*          cmpd    tstid,x    locked by me?          beq     50f        yes - still OK*20        ldb     #IOPPRI          inc     dpr_wait   mark somebody waiting          pshs    y          save pointer          jsr     Q_sleep    yes - sleep until available          puls    y          restore pointer          dec     dpr_wait          puls    cc,d,x,y,u restore environ          bra     FIFO_lock  try again*50        ldd     tstid,x    lock FIFO          std     dpr_fifo,y*99        puls    cc,d,x,y,u,pc return** DPRF_unlock - unlock the DPR FIFO buffer**    Y - IOP Control address*DPRF_unlock pshs    cc,d,x,y,u          seti                 turn       off interrupts          ldd     #0          std     dpr_fifo,y reset lock          jsr     wakeup     wake up anybody waiting on this FIFO          ldy     5,s        restore pointer          lda     dpr_wait   was anybody waiting?          beq     10f        no - exit          ldx     utask      reset priority          jsr     fixpri          jsr     change     let somebody else run*10        puls    cc,d,x,y,u,pc return** Q_sleep - Sleep until event with decreased activity*Q_sleep   jmp     sleep** A_sleep - Sleep until event with no decrease in activity*A_sleep   jsr     sleep      wait for event          pshs    a,x        upgrade activity          ldx     utask          lda     tsact,x          adda    #DPR_COST          bcc     00f*          lda     #$FF*00        sta     tsact,x          puls    a,x,pc** dpr_fdv - Find device info for DPR channel*    D - device #*    jsr dpr_fdv*    B - device # (0..N)*    U - Sequence #/Terminal #*    Y - FIO interlock*    <Carry> if illegal device #*dpr_fdv   pshs    d          save device #          ldu     0,s        get device code          ldy     #DPR0          clc     no         error99        puls    d,pc       return** find_dn - compute device # for a channel on an DPR*   B - relative device #*   Y - IOP control address*   jsr find_dn*   D - absolute device #*find_dn   pshs    d,x,y,u    save registers          clra          std     0,s        set return value          puls    d,x,y,u,pc return*p_dpr_bsy pshs    d,x,y,u          ldx     #00f          jsr     Pdata          ldx     #$FFFF10        leax    -1,x          bne     10b*99        puls    d,x,y,u,pc*00        fcc     $d,'DPR Saturated!',0        defineDPR0    rzb     DPR_SIZENUM_TRAN fcb    0 #transactions allowed        enddef        enddef          end