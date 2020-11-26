 opt nol lib environment.h lib ../include/acia.h lib ../include/tty.h lib ../include/inttab.h opt lis data sttl ACIA interface routines pag name tty_acia global ttconf,ttputc,ttgetc,ttenxr,ttdisx,ttenr,ttenx,ttenno global ttxbsy,tttstx,tttstr,tttstb,tttstc,tttste,ttend,ttsbrg global tty_acia,ttiscts,ttwcts,ttwdcd,tttsts,ttfbrg global tbrbu1,tbrbu2,tbrbu3,tbrbu4 global AC_SETtty_acia equ $0001* The routines in this file are specific to an ACIA (6850).* They are called from the "ttyhan" and "ttydrv" files.* baudrate latch backup bytes, for 2 acia's each** CB B2 B1 B0 CA A2 A1 A0       C=/CTS override, 0 = active* X2 X1 X0 are baudrate select bits 0K3/0K6/1K2/2K4/4K8/9K6/19K2/38K4* 111 is highest baudrate, 000 is lowest.*tbrbu1  fcb     0               acia 1 and 2tbrbu2  fcb     0               acia 3 and 4tbrbu3  fcb     0               acia 5 and 6tbrbu4  fcb     0               acia 7 and 8** ttconf** Configure the port pointed at by the Y register.  The X* register is pointing to the terminal table.  All registers* except D should be preserved.*ttconf lda #AC_MRES reset the acia sta csr,y pshs d delay some here puls d lda csr,y get status - see if acia is really here beq 2f if 0 status - then ok bita #$f3 see if funny status is ok bne 4f* ACIA found, check it's status2 lda tbaud,x get configuration word from table ora #AC_DV16 set up full configuration sta csr,y (no ints enabled & RTS brought high) lda csr,y get new status anda #(AS_NCTS|AS_NDCD) is DCD/CTS ok? rora rora              shift them to TT_NCTS/TT_NDCD position clz set true status  A contains DCD/CTS FLAG rts return* entering here is NO acia4 sez set false status rts return** ttputc** Send the character in the B register to the ACIA.  All* registers should be preserved.  Y points to the device.*ttputc stb dbuf,y send character rts return** ttgetc** Get the character from the device and return in the B* register.  Y points to the device and all registers* should be preserved.*ttgetc ldb dbuf,y get the character rts return** ttenxr** Enable the transmit interrupts and leave the receive* interrupt enabled (it is enabled upon routine entry).* Y points to the device and X points to to the terminal* table entry.  Preserve all registers but D.**ttenxr lda tbaud,x get configuration ora #AC_TEIN+AC_REIN+AC_DV16 enable int bits sta csr,y send to acia rts return** ttdisx** Disable the transmit interrupt and leave the receive* interrupt enabled.  Y points to the device and X points* to the terminal table entry.  Preserve all but D.*ttdisx lda tbaud,x get configuration word ora #AC_REIN+AC_DV16  set bits sta csr,y send to acia rts return** ttenr** Enable the receive interrupts only.  The transmit* interrupts should be turned off.  Y points to the device* and X point to the terminal table entry.  Preserve all* but the D register.*ttenr lda tbaud,x get configuration word ora #AC_REIN+AC_DV16 set bits sta csr,y send to acia rts return** ttenx** Enable the transmit interrupts only.  The receive* interrupts should be left disabled.  Y points to the* device and X points to the terminal table entry.* All registers but D shoud be preserved.*ttenx lda tbaud,x get configuration word ora #AC_TEIN+AC_DV16 set bits sta csr,y send to acia rts return** ttenno** Disable all interrupts from device and drop the RTS* line.  Y points to the device and X points to the* terminal table entry.  Preserve all but D register.*ttenno lda tbaud,x get configuration word ora #AC_DRTS+AC_DV16  set bits sta csr,y send to acia rts return** ttxbsy** Test if the transmit buffer is empty.  Return TRUE if* it is empty (N.E. status). Y points to the device and* all but A needs preserved.*ttxbsy lda csr,y get status bita #AS_TDRE is it busy? rts              NE=action return** ttiscts** Test device pointed at by X for "Clear to Send"* -- Return TRUE (not equal) if yes*ttiscts lda csr,x check for CTS bita #AS_NCTS is CTS down? bne falsetrue   clz               no - return TRUE       rtsfalse  sez               yes - return FALSE       rts*********************************************************** tttstb** Test device pointed at by Y for a "break" condition.** Return TRUE if found.  Preserve all registers but A* and return NULL in B (for break character).*tttstb lda csr,y  read status bita #AS_OVRN+AS_FRME check for break condition beq 2f     == false ldb dbuf,y get character from acia pshs d,x,y,u delay some here puls d,x,y,u lda dbuf,y get next garbage char if any clz set true2 rts return** tttstc** Test device pointed at by Y for drop "Carrier Detect"* type interrupt.  Return TRUE if so.  Preserve all registers* but A.*tttstc bita #AS_NDCD check for carrier drop beq 1f jump if no error == false ldb dbuf,y read reg to reset status clz return true1  rts return** tttstr** Test device pointed at by Y for a receive interrupt.* Return TRUE if interrupt present.  Preserve all but* the A register.* RDRF, /DCD, OVRN*tttstr  bita #AS_RDRF check status  bne true  bra false************************************************************* tttsts** Test device for "CTS" interrupt.*tttsts lda csr,y get status      bita #AS_NCTS      bra false not currently implemented** tttstx** Test device pointed at by Y for a transmit interrupt.* Return TRUE if interrupt present.  Preserve all but* the A register.*tttstx bita #AS_TDRE bne true bra false************************************************************* tttste** Test device pointed at by Y for error conditions.* Handle all errors local to this routine - no status* returned.  Preserve all but A.*tttste lda dbuf,y read data register to clear any interrupt conditions clz              return true rts return** ttend** Terminate i/o operation for device pointed at by Y.* Preserve all but D.*ttend rts return (nothing for acia)** ttfbrg, find baudrate setting info** Determine the addresses of the baud rate generators* for a given ACIA port (if any).*    (X) - ACIA address*    jsr findBRG*    (Y) - baudrate backup maskbits*    (U) - baudrate backup data address*ttfbrg pshs     x         save registers       ldx      #inttab     search interrupt table       ldb     ,x+          get length of table       pshs     b10     ldd      instat,x   check address       cmpd     1,s        match ACIA address?       beq      20f        yes - exit       leax     INTSIZ,x   move to next entry       dec      0,s       bne      10b       ldu     #0       bra     30f*20     ldy     inbrmsk,x   get mask bits       ldu     inbrbu,x    get backup location30     leas    1,s         clean up stack       puls    x,pc      return** ttsbrg** Set up the baud rate generators - if defined.  On entry,* Y holds to mask bits and U points to the backup location* X is pointing to the terminal table entry (tbaud2,x has* byte for baud rate generator).*ttsbrg  pshs    y        stu     -2,s    check if valid        beq     03f     no, skip        lda     0,u     latch image bits        cmpy    #$000f  low bits        bne     01f        anda    #$f0    right nibble        sta     0,u        lda     tbaud2,x        bra     02f01      anda    #$0f        sta     0,u        lda     tbaud2,x        rola            left nibble        rola        rola        rola02      ora     0,u        sta     0,u        ldy     taddr,x        sta     2,y     point to latch03      puls    y,pc** ttwcts** Wait for CTS to go high (sleep on it).*ttwcts lbsr ttenx enable xmit ints only ldb #TTYOPR set priority ldy tqout,x point to output q jmp sleep sleep on CTS** ttwdcd** Wait for DCD to go high (sleep on it).*ttwdcd rts currently not implemented