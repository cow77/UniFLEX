          sttl    Parallel   Printer Driver          pag     ** MP-L2 Parallel Printer*DEV_L2              fdb     bad_cmd    0 -          fdb     ppopn      1 -          fdb     ppcls      2 -          fdb     bad_cmd    3 -          fdb     bad_cmd    4 -          fdb     preq_write 5 -          fdb     pwrite_data 6 -          fdb     pwrt_sc    7 -          fdb     bad_cmd    8 -          fdb     bad_cmd    9 -          fdb     bad_cmd    10 -          fdb     bad_cmd    11 -          fdb     bad_cmd    12 -          fdb     bad_cmd    13 -          fdb     bad_cmd    14 -          fdb     clock_on   15 -          fdb     ppint               fdb     pp_init             fdb     pp_test   ** ppopn** Open device*ppopn               bsr     ppsel      go select printer          tst     ppopen,y   is the device already open?          bne     20f        yes - error          ldu     ppadr,y    get PIA address          clra    reset      pia          sta     1,u                 lda     #$ff       set direction in pia          sta     0,u        send to pia          leax    ppbuf,y    set in & out ptrs          stx     ppipt,y             stx     ppopt,y             clr     ppcnt,y    clear out count          clr     ppcnt+1,y           clr     ppbusy,y            lda     #1         set open flag          sta     ppopen,y            lda     0,u        clear any ints          lda     #PPCONE    enable interrupts and configure          sta     1,u                 ldb     #R_OPEN    - Device Opened OK          rts     return    *10        ldb     #E_BADDEV  Illegal device #          rts     *20        ldb     #E_DEVBSY  Device already open          rts     ** ppsel - select a printer*   set Y to point to printer control structure*ppsel     ldy     PPstr      point at ppr structures          subb    #MAX_TTY   make number relative to printers          beq     20f       10        leay    PPSIZ,y             decb              bne     10b       20        rts     ** ppcls** Close routine*ppcls     pshs    b          save device #          bsr     ppsel      get control structure          clr     ppopen,y   device not open any more...          puls    a          restore device #          jsr     int_all    interrupt any associated tasks          ldb     #R_CLOSE   - Close OK          rts     return    ** ppwrt** Write to parallel printer*ppwrt     pshs    cc         turn off interrupts          seti    10        ldb     fifo_cnt   anything in FIFO?          beq     20f        no - get out          lbsr    FIFO_get   fetch character          bsr     ppout      output char to q          bra     10b        repeat20        tst     ppbusy,y   busy?          bne     20f                 bsr     ppstrt     kick port20        puls    cc,pc      return** ppout** Output character to q.*ppout     ldx     ppipt,y    get input pointer          stb     0,x+       put char in q          leau    ppbnd,y    end of buffer?          pshs    u                   cmpx    ,s++                bne     ppout2              leax    ppbuf,y    reset pointerppout2    stx     ppipt,y    save pointer          pshs    d                   ldd     ppcnt,y    count zero?          beq     ppout4              addd    #1                  std     ppcnt,y    bump count          puls    d                   cmpb    #$d        is it cr?          bne     ppout3              ldb     #$a        set up line feed          bra     ppout     ppout3    rts     return    ppout4    addd    #1                  std     ppcnt,y    bump count          puls    d                   pshs    cc,b       save status          seti    mask       ints          tst     ppbusy,y   printer busy?          bne     ppout6              bsr     ppstrt     kick portppout6    puls    cc,b                cmpb    #$d        is it cr?          bne     ppout3              ldb     #$a        setup line feed          bra     ppout     ** ppstrt** Start output on the parallel port*          if      DBG_TRMI&DEBUG_CONTROL00        fcc     $d,'PPR Start, Y: ',001        fcc     ', U: ',0          endif   ppstrt    ldu     ppadr,y    get PIA address          if      DBG_TRMI&DEBUG_CONTROL          pshs    d,x,y,u             jsr     DB_msg              fdb     DBG_TRMI,10f          ldx     #00b                jsr     DB_pdata            ldd     4,s                 jsr     DB_phex2            ldx     #01b                jsr     DB_pdata            ldd     6,s                 jsr     DB_phex2  10        puls    d,x,y,u             endif             lda     0,u        clear out interrupt          clr     ppbusy,y            ldd     ppcnt,y    check char count          beq     ppstr4              ldx     ppopt,y    get output ptr          ldb     0,x+       get a char          pshs    u          save PIA address          leau    ppbnd,y    end of q?          pshs    u                   cmpx    ,s++                puls    u          restore PIA address          bne     ppstr2              leax    ppbuf,y    reset pointerppstr2    stx     ppopt,y    save output ptr          pshs    d                   ldd     ppcnt,y    dec the count          subd    #1                  std     ppcnt,y             puls    d                   stb     0,u        output character          inc     ppbusy,y   set busy statusppstr4    rts     return    ** ppint** Parallel driver interrupt routine*  D - Device #*  X - Device address*  Return CS if interrupt processed*          if      DBG_TRMI&DEBUG_CONTROL00        fcc     $d,'PPR Int, Status: ',0          endif   ppint     pshs    d,x,y,u    save registers          lda     1,x        get status register          ldb     0,x        clear interrupt if present          bita    #%10000000 any interrupt?          beq     80f        no - get out          if      DBG_TRMI&DEBUG_CONTROL          pshs    d,x                 jsr     DB_msg              fdb     DBG_TRMI,05f          ldx     #00b                jsr     DB_pdata            ldb     0,s        -- status          lda     1,s        -- data          jsr     DB_phex2  05        puls    d,x        restore registers          endif             ldd     0,s        restore device #          lbsr    ppsel      select printer structure          lbsr    ppstrt     output a character          ldd     ppcnt,y    check count          beq     10f                 cmpd    #PPLOC     low water?          bne     90f       10        jsr     wakeup     awaken          bra     90f       80        clc     return     - no interrupt here          bra     99f       90        sec     return     - interrupt processed99        puls    d,x,y,u,pc          pag     ** preq_write - Request permission to write data*preq_writejsr     ppsel      get printer table          pshs    cc         mask interrupts while fiddling10        seti              ldd     ppcnt,y    get queue length          addd    #FIFO_SIZE and assume the CPU will send this many more          cmpd    #PPHI      space available?          ble     20f        yes - OK          pshs    d,x,y,u    no - save registers          ldb     #TTYSPR             jsr     sleep               puls    d,x,y,u    restore registers          bra     10b        try again20        ldb     #R_REQOK   request granted code          puls    cc,pc      return** pwrite_data - Write data to a printer*pwrite_data          jsr     ppsel      get printer control table pointer          jsr     ppwrt      go consume data          ldb     #R_WRITE            rts     return    ** Write single character*  -- Character passed via transaction message*pwrt_sc   pshs    cc         save interrupt state          seti              jsr     ppsel      compute printer table address00        ldd     ppcnt,y    check for overrun          cmpd    #PPHI               bls     10f        jump if space          ldb     #TTYOPR    wait a while          jsr     sleep               bra     00b        try again10        ldx     utask      fetch character          ldb     tstval,x            jsr     ppout      send to output queue          ldb     #R_WRITE            puls    cc,pc      return** Initialize MP-L2 device*   B - Device number*   X - Device address*pp_init   pshs    d,x,u,y             lbsr    ppsel      get control structure          stx     ppadr,y             lda     #$2e       set up pia          sta     1,x                 pshs    d          delay          puls    d                   lda     0,x                 pshs    d                   puls    d                   tst     1,x                 puls    d,x,y,u,pc** Decide if a device is an MP-L2*   D - Device address*   Y - Device table*   CS - Device is not MP-L2*pp_test   pshs    d,x,u               tfr     d,u                 lda     #$2E       set up pia          sta     1,u                 sta     3,u        -- check both sides          pshs    d          delay          puls    d                   lda     1,u        must come back the same          anda    #$3F       -- ignore interrupt bits          cmpa    #$2E                bne     10f        not MP-L2          lda     3,u                 anda    #$3F       -- ignore interrupt bits          cmpa    #$2E                bne     10f                 cmpu    #PIA_SLOT  is this an L2?          beq     05f        no - won't have a latch          lda     #$0F       Initialize direction latch          sta     15,u      05        lda     NUM_PPR    compute device table address          adda    #MAX_TTY            ldb     #DEV_SIZE           mul               ldy     #dev_tab            leay    d,y                 tfr     u,d        set up device table          addd    #2                  std     dev_addr,y          ldx     #DEV_L2             stx     dev_type,y          inc     NUM_PPR    adjust device count          sec               bra     99f       *10        clc     99        puls    d,x,u,pc  