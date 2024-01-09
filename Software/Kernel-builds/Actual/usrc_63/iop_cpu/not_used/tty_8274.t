          sttl    8274       interface routines          pag     * The routines in this file are specific to an 8274.* They are called from the "ttyhan" and "ttydrv" files.* constantscont      equ     2          control regdata      equ     0          data regCTSBIT    equ     $20        Clear To Send bit in status reg.DCDBIT    equ     $08        Data Carrier Detect bit in status reg.OPN_WOC   equ     0          -- support for open without carrier** 8274 Device table*DEV_8274            fdb     bad_cmd    0 -          fdb     open_tty   1 -          fdb     close_tty  2 -          fdb     ttyset     3 -          fdb     ttyget     4 -          fdb     req_write  5 -          fdb     write_data 6 -          fdb     wrt_sc     7 -          fdb     req_read   8 -          fdb     read_data  9 -          fdb     bad_cmd    10 -          fdb     bad_cmd    11 -          fdb     bad_cmd    12 -          fdb     bad_cmd    13 -          fdb     bad_cmd    14 -          fdb     clock_on   15 -          fdb     S4_IRQ              fdb     S4_init             fdb     S4_test   *          fdb     S4ttconf            fdb     S4ttputc            fdb     S4ttgetc            fdb     S4ttenxr            fdb     S4ttdisx            fdb     S4ttenr             fdb     S4ttenx             fdb     S4ttenno            fdb     S4ttxbsy            fdb     S4tttstx            fdb     S4ttiscts           fdb     S4tttstr            fdb     S4tttstb            fdb     S4tttsts            fdb     S4tttstc            fdb     S4tttstd            fdb     S4tttste            fdb     S4ttend             fdb     S4ttwcts            fdb     S4ttwdcd  ** S4_IRQ - Interrupt poller/handler for MP-S4 device*   D - Device #*   X - Device address*S4_IRQ    pshs    d,x,y,u    save registers in case no interrupt          bitb    #1         second device? - skip out          bne     20f                 lda     #2         poll the device          sta     3,x                 lda     3,x        get response          ldb     2,x                 bitb    #%00000010 interrupt pending?          beq     15f        no - jump          pshs    d          place device status on stack for handler          bita    #$04       channel B (second device)?          bne     12f                 leax    1,x        get side B address          inc     2+1,s      change device #          ldb     2,x        get proper status for B side          stb     1,s        place on stack12        lda     0,s                 anda    #!$04               sta     0,s                 ldd     2,s        get device #          if      DBG_TRMI&DEBUG_CONTROL          jsr     DB_msg              fdb     DBG_TRMI,13f          pshs    d,x,y,u             ldx     #IRQmsg00           lbsr    DB_pdata            ldd     2,s                 lbsr    DB_phex2            ldx     #IRQmsg01           lbsr    DB_pdata            ldd     4,s                 lbsr    DB_phex2            ldx     #IRQmsg02           lbsr    DB_pdata            ldd     8,s                 lbsr    DB_phex2            puls    d,x,y,u             endif   13        jsr     tintr      go process interrupt          leas    2,s        clean up stack (remove device status)          puls    d,x,y,u    clean up stack          sec     interrupt  processed!          rts     15        puls    d,x,y,u    restore registers          incb    consume    2 slots          leau    DEV_SIZE,u          bra     99f       20        puls    d,x,y,u    restore registers99        clc     no         interrupt serviced          rts     ** Initialize 8274 port*   B - Device number*   X - Port address*S4_init   pshs    d,x,y,u             bitb    #1         don't initialize B side this way...          bne     30f                 tfr     x,y        save device port address          jsr     ttftab     get TTY table address          lda     #$18       send initialize code          sta     2,y                 sta     3,y                 pshs    d          delay          puls    d                   lda     2,y        check response00        ldu     #cnfstr    point to configuration string20        lda     0,u+       send to port          beq     30f                 bmi     25f                 sta     2,y                 ldb     ,u+                 stb     2,y                 lbsr    S4_setreg           bra     20b       25        anda    #$7F       strip high bit          sta     3,y                 ldb     ,u+                 stb     3,y                 pshs    x                   leax    TTYSIZ,x            lbsr    S4_setreg           puls    x                   bra     20b       30        puls    d,x,y,u,pc return* configuration datacnfstr    fcb     $02,$14,$04,$4c,$03,$E1,$05,$ea,$01,$04,$10,$30,$28,$F8          fcb     $82,$00,$84,$4c,$83,$E1,$85,$ea,$81,$04,$90,$30,$A8,$F8          fcb     0         ** Test for presence of 8274 device*   D - Port address*   Y - Device table address*   CS - Device not an 8274*S4_test   pshs    d,x,u               tfr     d,u        get port address          lda     #$18       send initialize code          sta     2,u                 sta     3,u                 pshs    d          delay          puls    d                   lda     2,u        check response          anda    #$87                cmpa    #$04       check for "xmit buffer empty"          beq     00f                 clc               bra     99f        exit not an 827400        lda     NUM_TRM    compute device table address          ldb     #DEV_SIZE           mul               ldy     #dev_tab            leay    d,y                 ldd     0,s        set device table          ldx     #DEV_8274           std     dev_addr,y          stx     dev_type,y          leay    DEV_SIZE,y          addd    #1                  std     dev_addr,y          stx     dev_type,y          leay    DEV_SIZE,y          ldd     0,s                 addd    #4                  std     dev_addr,y          stx     dev_type,y          leay    DEV_SIZE,y          addd    #1                  std     dev_addr,y          stx     dev_type,y          leay    DEV_SIZE,y          lda     NUM_TRM    count terminals          adda    #4                  sta     NUM_TRM             sec     99        puls    d,x,u,pc   return** ttconf** Configure the port pointed at by the Y register.  The X* register is pointing to the terminal table.  All registers* except D should be preserved.*          if      DBG_OPEN&DEBUG_CONTROLttconfm0  fcc     $d,'TTY Open Dev: ',0ttconfm1  fcc     ', Stat: ',0          endif   *S4ttconf            lbsr    clstat     reset status          ldb     #$ee       load configuration byte          lbsr    setupx     do auto enable and DTR/RTS          lbsr    clstat     reset status          lda     cont,y     read status          if      DBG_OPEN&DEBUG_CONTROL          jsr     DB_msg              fdb     DBG_OPEN,10f          pshs    d,x,y               ldx     #ttconfm0           lbsr    DB_pdata            ldd     4,s                 lbsr    DB_phex2            ldx     #ttconfm1           lbsr    DB_pdata            lda     0,s                 lbsr    DB_phex             puls    d,x,y               endif   10        bita    #CTSBIT    is CTS on?          bne     ttcnf2     skip if on          clc     Zero       bit already set, no Carry->no CTS          rts     ttcnf2              if      OPN_WOC             pshs    d                   ldd     usarg1     get open type          cmpd    #3         is it special open?          puls    d                   beq     ttcnf3     skip if special open          endif             bita    #DCDBIT    is DCD on?          bne     ttcnf4     skip if on          sec     Zero       bit already set, Carry->no DCD          rts               if      OPN_WOC   ttcnf3    lda     #3         select control reg. 3          sta     cont,y              lda     #$C1       turn off auto enables          sta     cont,y              lda     tstate3,x  get open status          ora     #TOPWOC    show special open          sta     tstate3,x           endif   ttcnf4              lda     tbaud,x    get port configuration          anda    #$1C                lsra              pshs    u                   ldu     #config_8274          ldu     a,u       *-- Set registers based on configuration          lda     #3                  ldb     #$3F                bsr     S4_chgreg *          lda     #4                  ldb     #$F0                bsr     S4_chgreg *          lda     #5                  ldb     #$9F                bsr     S4_chgreg *          puls    u                   lbsr    reset      reset pending interrupts          lda     #1         select interrupt cntrl reg          ldb     #$1F       turn on interrupts          sta     cont,y              stb     cont,y              bsr     S4_setreg           lbra    S4true     return true** Set 8274 register (image)*   A - Register #*   B - Value*   X - TTY Table*   bsr S4_setreg*S4_setreg pshs    x                   cmpa    #$07       valid register #          bhi     99f        no - don't screw up...          if      DBG_OPEN&DEBUG_CONTROL          jsr     DB_msg              fdb     DBG_OPEN,10f          pshs    d,x                 ldx     #00f                jsr     DB_pdata            lda     0,s                 jsr     DB_phex             ldx     #01f                jsr     DB_pdata            lda     1,s                 jsr     DB_phex             ldx     #02f                jsr     DB_pdata            ldd     2,s                 jsr     DB_phex2            puls    d,x                 endif   10        leax    tregs,x             stb     a,x       99        puls    x,pc       return** Update 8274 register*   A - Register #*   B - Mask of bits to save*   U - Bits to be added*   X - TTY Table address*   Y - Port address*   bsr S4_chgreg*   U modified*S4_chgreg pshs    b,x                 sta     cont,y              leax    tregs,x             leax    a,x        point to copy of registers          ldb     0,x        get old value          if      DBG_OPEN&DEBUG_CONTROL          jsr     DB_msg              fdb     DBG_OPEN,10f          pshs    d,x                 ldx     #00f                jsr     DB_pdata            lda     0,s                 jsr     DB_phex             ldx     #01f                jsr     DB_pdata            lda     1,s                 jsr     DB_phex             puls    d,x                 endif   10        andb    ,s+                 orb     ,u+                 stb     cont,y     set new value          stb     0,x        save in table          if      DBG_OPEN&DEBUG_CONTROL          jsr     DB_msg              fdb     DBG_OPEN,10f          pshs    d,x                 ldx     #02f                jsr     DB_pdata            ldd     4,s                 jsr     DB_phex2            ldx     #03f                jsr     DB_pdata            lda     1,s                 jsr     DB_phex             puls    d,x                 endif   10        puls    x,pc       return          if      DBG_OPEN&DEBUG_CONTROL00        fcc     $d,'Set Reg: ',001        fcc     ', Val:',002        fcc     ', TTY: ',003        fcc     ', New: ',0          endif   config_8274          fdb     00f        7 Data, 2 Stop, Even          fdb     01f        7 Data, 2 Stop, Odd          fdb     02f        7 Data, 1 Stop, Even          fdb     03f        7 Data, 1 Stop, Odd          fdb     04f        8 Data, 2 Stop, None          fdb     05f        8 Data, 1 Stop, None          fdb     06f        8 Data, 1 Stop, Even          fdb     07f        8 Data, 1 Stop, Odd00        fcb     $40,$0F,$2001        fcb     $40,$0D,$2002        fcb     $40,$07,$2003        fcb     $40,$05,$2004        fcb     $C0,$0C,$6005        fcb     $C0,$04,$6006        fcb     $C0,$07,$6007        fcb     $C0,$05,$60** ttputc** Send the character in the B register to the ACIA.  All* registers should be preserved.  Y points to the device.*S4ttputc  stb     data,y     send character          rts     return    ** ttgetc** Get the character from the device and return in the B* register.  Y points to the device and all registers* should be preserved.*S4ttgetc  ldb     data,y     get the character          rts     ** ttenxr** Enable the transmit interrupts and leave the receive* interrupt enabled (it is enabled upon routine entry).* Y points to the device and X points to to the terminal* table entry.  Preserve all registers but D.**S4ttenxr  rts     ** ttenr** Enable the receive interrupts only.  The transmit* interrupts should be turned off.  Y points to the device* and X point to the terminal table entry.  Preserve all* but the D register.*S4ttenr   rts     ** ttenx** Enable the transmit interrupts only.  The receive* interrupts should be left disabled.  Y points to the* device and X points to the terminal table entry.* All registers but D shoud be preserved.*S4ttenx   rts     do         nothing for now** ttdisx** Disable the transmit interrupt and leave the receive* interrupt enabled.  Y points to the device and X points* to the terminal table entry.  Preserve all but D.*S4ttdisx            lda     #$28       reset transmit interrupt command          sta     cont,y              rts     ** ttenno** Disable all interrupts from device and drop the RTS* line.  Y points to the device and X points to the* terminal table entry.  Preserve all but D register.*S4ttenno  lda     #1         select interrupt cntrl reg          sta     cont,y     select reg 1          lda     #4         clear all bits (except "interrupt affects vector")          sta     cont,y              ldb     #$6c       turn off DTR and RTSsetupx    pshs    u                   andb    #$9F       isolate important bits          pshs    b                   lda     #3         select register 3          ldb     #$FF                ldu     #S4_auto   set to restore auto enables          lbsr    S4_chgreg           lda     #5         select xmit control reg          ldb     #$60                leau    0,s                 lbsr    S4_chgreg           puls    b,u,pc     return*S4_auto   fcb     $20        Auto enable mode** ttxbsy** Test if the transmit buffer is empty.  Return TRUE if* it is empty (N.E. status). Y points to the device and* all but A needs preserved.*S4ttxbsy            lda     cont,y              bita    #4                  rts     ** tttstx** Test device pointed at by Y for a transmit interrupt.* Return TRUE if interrupt present.  Preserve all but* the A register.*S4tttstx            cmpa    #0                  bne     S4false    is it xmit int?          bra     S4true    ** ttiscts** Test device pointed at by X for "Clear to Send"* -- Return TRUE (not equal) if yes*S4ttiscts lda     cont,x     check for CTS          bita    #%00100000 is CTS down?          beq     S4false   S4true    clz     no         - return TRUE          rts     ** tttstr** Test device pointed at by Y for a receive interrupt.* Return TRUE if interrupt present.  Preserve all* registers.*S4tttstr            cmpa    #2         is it rcv int?          bne     S4false             bra     S4true    ** tttstb** Test device pointed at by Y for a "break" condition.* Return TRUE if found.  Preserve all registers* and return NULL in B (for break character).*S4tttstb            cmpa    #1         is it break condition?          bne     S4false             bitb    #$80                bne     clsint     clear int. & show trueS4false   sez     yes        - return FALSE          rts     * Test device pointed at by Y for a "CTS" interrupt.*S4tttsts            cmpa    #1         is it special interrupt?          bne     S4false             lda     #CTSBIT    use CTS bit position          bsr     hilo       see if bit went hi          beq     clsint     if lo, go clear int.          bsr     chkopn     was terminal open?          bne     clsint     clear int & exit if so          bsr     wake       wakeup blocked open** clear interrupt and return true status*clsint    lda     #1         select int. control reg.          sta     cont,y              lda     cont,y     clear interruptclstat    lda     #$10       reset port          sta     cont,y              rts     return     true** check for device open*chkopn    pshs    a                   lda     tstate,x            bita    #TOPEN              puls    a,pc      ** tttstd** Test device for change in DSR status.*S4tttstd            sez     --         not supported          rts     ** tttstc** Test device pointed at by Y for drop "Carrier Detect"* type interrupt.  Return TRUE if so.  Preserve all registers* but A.*S4tttstc            cmpa    #1         special interrupt type?          bne     S4false    exit if not          lda     #DCDBIT    setup DCD bit position          bsr     hilo       see if bit went hi or lo          bne     3f         branch if high          bsr     chkopn     was terminal open?          beq     flsclr     if not, clear int. & show false          bra     clsint     clr int & show true (HANGUP)3         bsr     chkopn     was terminal open?          bne     flsclr     if so, clr int & show false          bsr     wake       waken blocked openflsclr    pshs    a                   bsr     clsint     clear interrupt          puls    a                   bra     S4false    show false response** See if bit in position supplied in a went high or low*hilo      pshs    a          save bit position          tfr     b,a                 eora    tstate3,x  see if bit has changed          anda    0,s        look at only the desired bit          bne     1f         branch if changed          leas    3,s        remove return address          lda     #1         restore interrupt type          bra     S4false    go straight to false1         lda     tstate3,x  preload saved bits          bitb    0,s        did bit go high?          bne     2f         branch if went high          com     0,s        prepare to clear bit          anda    0,s+       clear saved bit          bsr     3f         put back          lbra    S4false    show bit went low2         ora     0,s+       set saved bit3         sta     tstate3,x           lda     #1         restore interrupt type          rts     (returning true (NE))** wakeup routine for CTS and DCD*wake      pshs    d,x,y,u             ldy     tqout,x    get address for wakeup          jsr     wakeup              puls    d,x,y,u,pc** tttste** Test device pointed at by Y for error conditions.* Handle all errors local to this routine - no status* returned.  Preserve all but A.*S4tttste            cmpa    #1         special condition?          beq     flsclr     yes - jump          cmpa    #0                  lbeq    S4false             lda     #1         reset error condition          sta     cont,y              lda     cont,y              lda     #$30                sta     cont,y              lda     data,y     read data register - just to be sure          lbra    clstat     clear status** reset impending interrupts and determine current* status of CTS and DCD*reset     lbsr    clsint     clear interrupts          lda     cont,y     get status          anda    #CTSBIT|DCDBIT just CTS and DCD          ldb     tstate3,x           andb    #!(CTSBIT|DCDBIT) turn off          stb     tstate3,x           ora     tstate3,x  add in new bits          sta     tstate3,x ret       rts     ** ttend** Terminate i/o operation for device pointed at by Y.* Preserve all but D.*S4ttend   pshs    d,y        save port address          ldd     2,s        compute base address for chip          andb    #$FE                tfr     d,y                 lda     #$38       reset port          sta     cont,y              puls    d,y,pc     return** ttwcts** Wait for CTS to go high.  (Sleep on it).** Same as ttwdcd, so fall through** ttwdcd** Wait for DCD to go high.  (Sleep on it).*S4ttwcts  lda     #CTSBIT             bra     ttw2      S4ttwdcd  lda     #DCDBIT   ttw2      pshs    a                   bsr     reset      reset impending interrupts          lda     #1         select interrupt control reg.          sta     cont,y              lda     #$05       enable only ext/status interrupts          sta     cont,y              lbsr    clstat              lda     cont,y     get status          anda    0,s+                bne     ret                 ldb     #TTYOPR    set priority          ldy     tqout,x    point to something          jmp     sleep      sleep on DCD