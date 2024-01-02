        lib     environment.h        lib     ../include/macdefs.h        lib     ../include/inttab.h        lib     ../include/sysdefs.h*       lib     ../include/dpr-wz.h        lib     idedrvr.h        if      (IOP|NET=1)        lib     ../include/fio_ctrl.h        endif        data        sttl    Device Interrupt Handlers        pag        name    inthan        global  irqhan,frqhan,idle_tsk** irqhan** Machine interrupt handler* The irg interrupt handler is called after initial* system setup to process an irq type interrupt.* priority: trap, timer, ide, iop, uio, flp, ecn, tty*** memory trap should be handled with highest priority*irqhan  equ     **        lda     #$80                     get clock mask        bita    trpctrl                   highest priority        bpl     nutrap** illegal memory access trap*        ldb    trpdata                  remove IRQ        tst    <kernel                  only if it came from user.....        bne     nutrap                  is kernel, skip over*        ldd     #FALTS        jmp     swiha2                  post SIGNAL* next check timer tick, this one arrives at 10 mS interval!nutrap  bita    timctrl                  check clock int        beq     irqha0                  no - try something else* handle debug acia, (polling)        if   (DBG=1)   jsr  debugi1        endif*        lda     timdata                 reset timer interrupt        jmp     clkint                  go process interrupt** check INT from serial devices (tty)*irqha0  ldx     #inttab                 point to table        lda     0,x+                    get count01      beq     irqha1        ldb     intype,x                check device type        ldb     inmask,x                get mask        andb    [instat,x]              check status        beq     02f                     jump if not interrupt        ldd     indev,x                 get device number        jmp     [inhand,x]              goto routine*02      leax    INTSIZ,x                get to next entry        deca                            dec the count        bra     01b                     repeat til done** check IDE controller*irqha1        if      (IDE=1)        ldu     idebase        lda     idestat,u        lbmi    ideint        endif** check IOP*        if      (IOP=1)        ldy     #IOP0        ldu     fio_dba,y        ldx     fio_dsz,y               find end of fio        leax    -2,x                    top - 2        addr    U,X                     U + X ->  X        ldb     0,x                     test interrupt        lbne    fio_irq*        else        lda     $f200+$fe            IOP->CPU        endif** check UIO*        if      (UIO=1)        ldy     #UIO0        ldu     fio_dba,y        ldx     fio_dsz,y        leax    -2,x                    top - 2        addr    U,X                     U + X -> X        ldb     0,x        lbne    uio_irq*        else        lda     $f300+$fe            UIO->CPU reset IRQ        endif** floppy interface GPP<->09FLP*        if      (FLP=1)              floppy interface        ldu     #flpdpr        lda     flpint,u        lbne    flpirq        else        lda     $E3FE               reset IRQ         endif** network*        if      (NET=1)        ldy     #NWP0        ldu     fio_dba,y        ldx     fio_dsz,y        leax    -2,x                 point to fio_cpuF        addr    U,X                  U + X -> X        ldb     0,x        lbne    fio_irq        endif** ECN, econet*        if      (ECN=1)        ldy     #ECN0                 base vars        ldu     fio_dba,y             device address        ldx     fio_dsz,y             device size        leax    -2,x                  top - 2        addr    U,X                    U + X -> X        lda     0,x                   interrupt flag        lbne    ecn_irq        else        lda     $E7FE                  reset IRQ        endif        lda     $EBFE                  reset IRQ        lda     $EFFE                  reset IRQ        rts                             *** Unexpected interrupt - what else to do?? **** frqhan** Handle the firq interrupt.  Works like irq.*frqhan  ldx     #fnttab                 point to table        lda     0,x+                    # entries01      beq     09f        ldb     inmask,x                get mask        andb    [instat,x]              address with status        beq     02f        ldd     indev,x                 device info        jmp     [inhand,x]              goto routine*02      leax    INTSIZ,x                next entry        deca        bra     01b*09      rts                             return** idle_tsk** CPU Idle task*idle_tsk pshs   d,x,y,u                 save registers        jsr     dorand                  update random registers99      puls    d,x,y,u,pc              return