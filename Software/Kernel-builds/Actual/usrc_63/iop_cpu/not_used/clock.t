          sttl    Interval Timer Handler          pag** Clock structure*clock_on          sei     mask       interrupts during set up          ldx     utask      disassociate from any terminal          lda     #$FF          sta     tsdev,x*-- Determine clock rate (50/60 Hz)20        lda     #$ff       turn on clock          sta     CLOCK          sta     CLOCKI    reset interrupt** -- Wait for clock interrupt* send tick to main CPU (only)*10        ldy     #clock_tick          ldb     #CLOCKPR          jsr     sleep*20        ldb     #R_CLOCK   interrupt the CPU          jsr     fio_response          dec     clock_tick all ticks out?          bne     20b*          bra     10b** Process clock interrupt*clkint    ldy     #clock_tick wake up clock process          inc     0,y          jmp     wakeup