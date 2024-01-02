          sttl    Sleep      and Wakeup routines          pag** wakeup** Wakeup all tasks waiting the event designated* in the y register.  The x reg is preserved.*wakeup    pshs    cc,d,x,u   save registers          seti    mask       interupts          ldu     #slplst          ldx     tsslnk,u   point to sleep list          beq     wakeu4*wakeu2    cmpy    tsevnt,x   check event          beq     wakeu5          leau    0,x        mark this entry*wakeu3    ldx     tsslnk,x   follow chain          bne     wakeu2     end of list?*wakeu4    puls    cc,d,x,u,pc return*wakeu5    pshs    x,y,u      save registers          ldd     tsslnk,x   remove from list          std     tsslnk,u          bsr     makrdy     put on ready list          puls    u,x,y          bra     wakeu3     repeat          pag** sleep** Sleep will put this task to sleep with priority* specified in the b register.  On entry, y is pointing* to the event which will be awakened.*sleep     pshs    cc,x,u     save registers          ldx     utask      point to task          tst     tssgnl,x   any signals waiting?          bne     sleep7*          seti    mask       ints          stb     tsprir,x   set priority          sty     tsevnt,x   set event          lda     #TSLEEP    set status          sta     tsstat,x          ldd     slplst+tsslnk get head of list          std     tsslnk,x   set new link          stx     slplst+tsslnk set new head          lbsr    rsched     reschedule cpu20        ldx     utask      get task entry          tst     tssgnl,x   any signals waiting?          bne     sleep7*          puls    cc,x,u,pc  return*sleep7    ldx     utask      reset signal          clr     tssgnl,x          ldd     umark1,x   stack reset point          puls    cc,x,u     reset cc and registers          tfr     d,s        change stacks          rts     return          pag** xmtint - Send an interrupt to a task*  X - Task entry*  jsr xmtint*xmtint    pshs    d,x,y,u    save registers          lda     tsstat,x   get task state          cmpa    #TRUN      running?          bne     10f        no - try something else*          lda     #1         set signal          sta     tssgnl,x          bra     99f        exit*10        cmpa    #TSLEEP    task sleeping?          bne     99f        no - can't send interrupt*          lda     #1         set signal          sta     tssgnl,x          ldy     tsevnt,x   wake task up          lbsr    wakeup*99        puls    d,x,y,u,pc return