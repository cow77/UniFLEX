          sttl    IO         Command Handler          pag*** IO_han - I/O Command Handler*   This routine comprises the main processing loop* for each task in the system.  Whenever an I/O command* is detected (via the message interrupt), a task will* be scheduled to process it.  This is that task.*   The command is saved in the "tscmd" field of the* task control block.*IO_han    seti                block interrupts** we execute the task belonging to the transaction*10        clri          ldx     utask      get task control block address          lda     tscmd,x    get I/O command** The command byte is shifted and used as an index* in a DEV_XXXX tab*          lsra                  isolate    command          lsra          lsra**        lsra          cmpa    #MAX_S_NUM          bhi     bad_cmd*          lsla                  --   word index on command          pshs    x          ldx     #dev_tab          ldx     dev_type,x get handler table address          ldy     a,x        get processor address          puls    x          pshs    y          ldy     tsagin,x   if 0, d nothing          beq     05f        else it is target ponter          sty     0,s          ldy     #0          sty     tsagin,x   reset pointer05        puls    y          change address          clra*          ldx     #IO_end    interrupt handler address          pshs    x          ldx     utask      task pointer          sts     umark1,x          ldu     tsdev,x    get sock refernce          exg     d,u          anda    #%00000111 mask off address bits          exg     d,u** CALL HANDLER: X=utask, Y=handler address, U=sock address*          jsr     0,y        perform operation & return status          leas    2,s        clean up stack** on return, Y= flag. -1 is resched, else end task*          ldx     utask      restore task pointer          cmpy    #$ffff          bne     20f* task is NOT done yet          lda     #POLPRI          sta     tsprir,x   at lower prio          jsr     change          bra     91f        just escape (and come back)** A=transaction value, B=response code, U=device reference* X = task pointer* in fio_response the task ID is added as sequence reference* SEND the response to the host CPU**20        jsr     fio_response** task is done*IO_end    seti    mask       interrupts          ldx     utask      restore task control block address          sta     tstval,x   remember transaction value sent          stb     tscmd,x    and command response          lda     #TFREE     mark task "terminated & free"          sta     tsstat,x          lda     #$FF       disassociate from any terminal          sta     tsdev,x          sta     tsdev+1,x          clr     tssgnl,x   no waiting signals** exit here to rescheduling*90        jsr     rsched     run other tasks91        lbra    IO_han** Illegal command*bad_cmd          ldb     #E_BADCMD  error code          rts