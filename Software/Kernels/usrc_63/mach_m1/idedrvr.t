        lib     gendrvr.h        lib     idedrvr.h        global  parttbl** drives partition table, filled in by IDE-boot*parttbl equ     *               partition tables* drive 0        fdb     $a500,$0000,$a5ff,$ffff,$a5ff,$ffff,$a5ff,$ffff  drive 0* drive 1        fdb     $a5ff,$ffff,$a5ff,$ffff,$a5ff,$ffff,$a5ff,$ffff  drive 1*        if      (IDE=1)        sttl     IDE Drivers        pag        name    idedrvr        global  ideopen,ideclose,ideio,ideint        global  ideop,idecl,idesp,idecio,iderd,idewr        global  idedt,idechb* Device Tables** dtdfl rmb     2       device buffer fwd link* dtdbl rmb     2       device buffer bwd link* dtqfl rmb     2       device io queue fwd link* dtqbl rmb     2       device io queue bwd link* dtbusy        rmb     1       device busy flag* dtrtry        rmb     1       device error retry count* dtspr rmb     2       device spare byteidedt   rzb     DVTSIZ          device table* buffer header for character deviceidechb  rzb     HDRSIZ          buffer header*ideopt  fcb     0,0,0,0,0,0,0,0                             ide open tableidecmd  fcb     0               IDE last command byteidedrv  fcb     0               drive select bitidecur  fcb     0               current drive selectidelcp  fcb     0               copy of latch contentsidebase fdb     basead0         one controlleridepart fdb    parttbl          pointer to partition infoBDtable fdb     0               Block Device Table address** open the ide disk drive - insure the device is online, etc.* B contains device minor*ideopideopen        bsr     ide_dn          set up        tst     ideopt,x        already open?        beq     ideop2        inc     ideopt,x        bra     idertsideop2  inc     ideopt,x        set open status        pshs    x        ldx     idepart        ldd     0,x        bne     idepr1* check if no partition AND drive 0/4        ldb     1,s             minor        bitb    #%00000011        bne     ideop4          should NOT be drives 1,2,3/5,6,7*idepr1  cmpd    #$a5ff        beq     ideop4          yes, error* check if drive is on-line        ldu     idebase        clra        ldb     idedrv        std     ideadr3,u       select drive*        ldd     idecmst,u       get status        tstb        beq     ideop4          not ready        cmpb    #IDERDY+IDEDSC        bne     ideop4        puls    x,pcideop4  puls    xideop3  lda     #EIO            indicate device offline        sta     uerror          stuff into user error flag        clr     ideopt,x        clear open statusidespiderts  rts* ide closeideclideclose        bsr     ide_dn          set up        dec     ideopt,x        dec open counter        bpl     iderts        clr     ideopt,x        clear open status        rts                     return** preset important variables*ide_dn        clra        stb     idecur          save select        pshs    d        bitb   #%00000100       drive select        beq    01f        lda    #IDE_DSL01      sta    idedrv        aslb                    size of one partition entry        aslb        ldx     #parttbl        abx        stx    idepart          set partition base        puls    x,pc** fire up IDE operation to initiate transfer*ideio   stx     BDtable         save Block Device Table address        inc     idedt+dtbusy    mark busy        ldb     bfdvn+1,y       get device #        bsr     ide_dn          set up for drive        ldu     idebase*        ldd     bfxfc,y         get transfer count        cmpd    #512            is it regular block transfer?        bne     ideswap          if not - do swap*        ldd     #1              1 sector        std     idescnt,u        ldd     bfadr,y        std     dmaadh,u        A15...A0*        lda     bfxadr,y        high address in core** common part for normal R/W and swapping in a LOOP*idecon  anda    #$0f            save address bits* set address and mode A19...A16        ldb     bfflag,y get buffer flags        bitb    #BFRWF          (read=1)        bne     l003        ora     #L_DMAEN+L_INTEN   write        ldb     #IDEDWR        bra     l004l003    ora     #L_DREAD+L_DMAEN+L_INTEN        ldb     #IDEDRDl004    stb     idecmd          set command        sta     idelcp          keep copy        sta     dmaltc,u        A19...A16 + control bits* disk block #        ldx     idepart point to partition info        ldd     bfblck,y        block address 15..0        addd    2,x        pshs    a        lda     #0              don't touch carry        std     ideadr0,u        puls    b        std     ideadr1,u        ldb     bfblch,y        block address 23..16        adcb    1,x        std     ideadr2,u        ldb     #IDE_LBA        orb     idedrv        std     ideadr3,u*        ldab    idecmdl001    std     idecmst,u        rts** take care of ide swap request*ideswap        cmpd    #16        bhi     iderr1          error        lda     bfflag,y        check special io        bmi     iderr1* memory address        ldx     bfadr,y         get swap map table        ldb     0,x+        stx     bfadr,y        cmpb    DSKTRM          always end of list marker!        beq     idedon          done*        lda     #16             shift 4 bits left        mul        pshs    a        tfr     b,a        clrb        std     dmaadh,u        ldd     #8              4K block        std     idescnt,u        puls    a        bra     idecon          A holds A19...A16B** interrupt process*ideint        ldu     idebase        controller address        lda     idelcp          get copy        anda    #255-(L_DMAEN)        sta     idelcp          save new        staa    dmaltc,u        kill any pending action        ldb     idedrv         std     ideadr3,u      select drive        ldd     idecmst,u   get status into B        lda     idedt+dtbusy        bne     idei01idefin  rtsidei01  ldy     idedt+dtqfl     get last transacion        beq     idefin        bitb    #IDEERR         error bit?        bne     iderr1        ldd     bfxfc,y         are we swapping        cmpd    #512        bne     nxtswp        bra     idedoniderr1  lda     bfflag,y        ora     #BFERR        sta     bfflag,y*idedon  clr     idedt+dtbusy    set unbusy        clr     idecmd          no pending action        ldx     BDtable        jmp     BDioendnxtswp  ldd     bfblck,y        update block address        addd    #8              4K        std     bfblck,y        lda     bfblch,y        adca    #0        sta     bfblch,y        ldd     bfxfc,y         get transfer count        bra     ideswap sttl IDE Winchester Character Drivers pag** open - close - and special**ideop   jmp     ideopen         same as block device*idecl   jmp     ideclose        same as block*idesp   rts                     nops here** read*iderd   pshs    d               save device number        ldy     #idechb         local character buffer        jsr     blkgtb          get buffer header        puls    d               reset dev number        jsr     idecn           go configure header        tst     uerror          any errors?        beq     iderd4        pshs    y        ldy     #idechb        jsr     blkfrb          release buffer        puls    y,pc            error returniderd4  pshs    a               save task info        orb     #BFRWF          set read mode        andb    #!BFSPC&$ff     clear special mode        stb     bfflag,y        save in buffer        bra     idecio           go do it** write*idewr   pshs    d               save device number        ldy     #idechb         local character buffer        jsr     blkgtb          configure buffer        puls    d        jsr     idecn           go configure header        tst     uerror          any errors?        beq     idewr4        pshs    y        ldy     #idechb        jsr     blkfrb          release buffer        puls    y,pc            error returnidewr4  pshs    a               save task statusidecio  ldb     #IDEmajor        bra     blkcio          fall thru** idecnf** Configure the buffer header pointed at by Y.* This routine sets up the character device info* from the user block and puts it in the buffer* header such that the device drivers can use* the information for the data transfer.* this routine is specific for the IDE device*idecn   std     bfdvn,y         save device number        ldd     uicnt           get xfr count        std     bfxfc,y         save in header        cmpd    #512            is it 512 byte op?        beq     idecn3          if not - error        lda     #EBARG          set error        sta     uerror        rts                     returnidecn2  lda     bfflag,y        get flags        ora     #BFSPC          set special bit for drivers        sta     bfflag,y        save new flagsidecn3  jmp     blkcnf        endif        if      ((IDE|FLP)=1)        global  blkcio,blkgtb,blkfrb,blkcnf** these are generic routines used for block device character* drivers** blkcio** Perform the io specified by the buffer header* Y= buffer header* B =block device major*blkcio  pshs    y               save buffer        lda     #BLKSIZ        mul        ldx     #blktab        abx        jsr     [blkio,x]       call block io routine        ldy     0,s             reset buffer        jsr     fnshio          finish io        jsr     wakbuf          awakeb buffer sleepers        puls    y               reset ptr        lda     bfflag,y        get flags        anda    #!(BFALOC|BFREQ|BFSPC)&$ff clear out busy bits        sta     bfflag,y        save new flags        puls    a               get task modes        ldx     utask           get task entry location        sta     tsmode,x        save task modes        ldd     #0              reset data count to 0        std     uicntfchio6  rts                     return** blkgtb** Get the character buffer header.  If it is busy,* Y =  buffer header* if busy, sleep on it.*blkgtb  equ     *        pshs    cc              save status        seti        lda     bfflag,y        get buffer flags        bita    #BFALOC         is buffer busy?        beq     idegb2        ora     #BFREQ          set request buffer bit        sta     bfflag,y        puls    cc              reset status        ldb     #BUFPR          set priority        jsr     sleep           go sleep for buffer        bra     blkgtb          repeatidegb2  lda     #BFALOC         set busy status        sta     bfflag,y        puls    cc,pc           return** blkfrb  - free Character buffer* Y = buffer header*blkfrb  pshs    d,x,u         save registers        lda     bfflag,y        get flags        anda    #!(BFALOC|BFREQ|BFSPC)&$ff clear out busy bits        sta     bfflag,y        save new flags        jsr     wakbuf          awake buffer sleepers        puls    d,x,u,pc      return** block generic config routine*blkcnf  ldd     uipos2          get file position        std     bfblck,y        save as block number        lda     uipos+1         store upper part        sta     bfblch,y        ldd     uistrt          get start address of xfr        std     bfadr,y         save in header        jsr     mapupg          find user page        std     bfxadr,y        save in header        ldx     utask           point to task entry        lda     tsmode,x        get mode bits        pshs    a               save        ora     #TLOCK          set lock bit (keep in mem)        sta     tsmode,x        save new mode        ldb     bfflag,y        get flags        puls    a,pc            return        endif        end