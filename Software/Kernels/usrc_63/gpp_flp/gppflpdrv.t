*
* GPPFLPDRV, ROM code for CPU09GPP with 09FLP add-on
*
* supports:  read block 128,256,512 byte size
*            write block 128,256,512 byte size
*            read track 125kBit, 250kBit, 500 kBit rate
*            write track 125kBit, 250 kBit, 500 kBit rate
*
*            supports 8", 5.25" and 3.5" in single /
*            double side and single / double / high density
*
*
*            runs with Interrupts disabled
*
*
        lib     gppflpdrv.h

        ifc     &a,'DBG'
romots  equ  $f804
romoth  equ  $f802
romotc  equ  $f806
        endif

        org     RAMBASE

side    rmb     1       work side
dens    rmb     1       work dens
lside   rmb     1       actual latch side
track   rmb     1
sector  rmb     1
latch   rmb     1       latch backup
lstdrv  rmb     1       last selected drive
unbias  rmb     1       unbiased sectors
trktab  rmb     4       track numbers / drive

*
step    rmb     1       debug for progress
wrkprm  rmb     2       pointer to drive info table entry
retry   rmb     1       retry count



        rmb     STACKSZ
romstck equ     *

RAMEND  equ     *

        org     BUFFER
trkbuf  rmb     12500           track buffer

        org     ROMBASE

*
* configuration constants
*
steprt  fcb     0               step rate modifier
rretry  fcb     2
drvsel  fcb     LA_DS0,LA_DS1,LA_DS2,0 driver select bytes
*
parstab fcb     CMDRSC,0
        fdb     do_rdsc
        fcb     CMDWSC,0
        fdb     do_wrsc
        fcb     CMDRTK,0
        fdb     do_rdtk
        fcb     CMDWTK,0
        fdb     do_wrtk
        fdb     0,0             end of table

*
* cold start
*
reset   equ     *
        seti
        lds     #romstck
        clra
        tfr     a,dp
*
        ldx     #flpdpr         go clear the Dual Port Ram
        clrd
01      std     0,x++
        cmpx    #flpdpr+flptel
        blo     01b
*
        ldx     #RAMBASE
02      std     0,x++
        cmpx    #RAMEND
        blo     02b
        ldx     #flpdfl
        stx     wrkprm          set pointer
*
* normally the driver loops here
*
warm    equ     *
        seti
        lds     #romstck
*
01      jsr     flpcmd          new message from main CPU
        beq     01b             wait
*
        ldy     #fdcbas         floppy HW base address
        ldb     flpdpr+fldriv   get drive  0,1,2
        ldx     #drvsel
        abx
        ldb     latch
        andb    #$f8            leave these intact
        pshs    b
        ldb     0,x
        orb     0,s+
        stb     latch           clean higher bits
* update other information
        lda     rretry
        sta     retry
* test DD
        lda     flpdpr+fltden
        anda    #%00000001      DD?
        sta     dens
* test DS, + unbiased
setd0   lda     flpdpr+fltsid
        clr     unbias
        bita    #%00000010
        beq     setd11
        inc     unbias           unbiased
setd11  anda    #%00000001       2 sided
        sta     side             set side capabilities
* test 5"/8"
        lda     flpdpr+fltsid
        bita    #%01000000      5/8" select
        beq     setd2
        oime    LA_8_5,latch
        bra     setd3
*
setd2   aime    255-LA_8_5,latch  set 8" (latch bit = 0)
setd3   oime    $80,latch
        ldb     latch
setd9   stb     fo4lat,y        set latch
*
* everything is set
*
        jsr     chkrdy          see if drive is on-line
        tsta
        bne     flerr
* if new open force restore
        lda     flpdpr+flnwop   new open?
        beq     04f             yes, skip forced restore
*
* retry loops here
*
skretry jsr     restore         restore drive
        anda    #%00010101
        cmpa    #%00000100      should be there
        bne     flerr
*
04      clr     flpdpr+flnwop   remove flag
*
        ldb     #1              set progress
        stb     step
*
        clr     flpdpr+flstat   initialize return status
*
        jsr     chkrdy          drive still ready?
        tsta
        bne     flerr
*
06      jsr     srchpm          scan drive table
*
        ldb     #2
        stb     step
        lda     flpdpr+flrflg   check command for valid
        anda    #CMDMSK
        ldx     #parstab        search function
21      cmpa    0,x
        beq     20f
        leax    4,x
        tst     0,x
        bne     21b
*
        lda     #FD_ERR+63
        sta     flpdpr+flstat
        bra     fend1
*
20      jsr     [2,x]
*
flerr   sta     flpdpr+flstat
*
fend    ldb     #7
        stb     step
        tsta                    error
        beq     fend1
        dec     retry
        lbne    skretry
fend1   nop
        bsr     flpack          tell main CPU about it
*
        jmp     warm

*
*  write POSTBOX to other CPU I'm done
*
flpack  ldb     #8
        stb     step
        clr     flpdpr+flptel   acknowledge main CPU
        lda     #$ff
        sta     flpdpr+flpint   tell him I'am done
        rts

*
* flpcmd, test INTBOX for new data from main CPU
*
flpcmd  lda     flpdpr+flptel   command present?
        rts

*
* Y = fdcbase
*
do_rdsc equ     *
        ldb     #3
        stb     step
*
        jsr     clcpos          block# -> trk/sec/sid
        tsta
        bne     frder           error
*
        ldb     #4
        stb     step
        jsr     fseek
        tsta
        bne     frder
*
        ldb     #5
        stb     step
        ldu     #flpdpr+flpfifo
        lda     #FD_SRD
        jsr     frdblk
*
frder   rts

*
* Y = fdcbase
*
do_wrsc equ     *
        ldb     #3
        stb     step
*
        jsr     clcpos          block# -> trk/sec/sid
        tsta
        bne     fwder           error
*
        ldb     #4
        stb     step
        jsr     fseek
        tsta
        bne     fwder
*
        ldb     #5
        stb     step
        ldu     #flpdpr+flpfifo
        lda     #FD_SWR
        jsr     fwrblk
*
fwder   rts

*
*TODO
*
do_rdtk equ     *
        ldu     #trkbuf
        lda     #FD_RTR
        jsr     frdblk

        jsr     flpack
        rts

*
* We arrive here when the DPR contains the first BUFSIZ
* bytes of the track image
*
do_wrtk equ     *
        pshs    x,y,u
        ldx     #trkbuf
* copy DPR data to trkbuf
03      nop
        ldu     #flpdpr+flpfifo
        ldwi    BUFSIZ
        tfm1    U,X
        ldd     flpdpr+fltxfr
        cmpd    flpdpr+fltsiz   we have all
        bhs     02f
        clra
        jsr     flpack          tell hime I took it
*
01      tst     fo4sta,y        keep motor running
        jsr     flpcmd          wait for next data
        beq     01b             postbox empty
        bra     03b             loop until all
* all data present
02      nop                     TRAP
        ldx     0,s             old X
        ldb     #3
        stb     step
*
        lda     flpdpr+flblkl   track address << 1 + side bit
        clrb
        lsra                    strip side bit
        bcc     08f
        incb
08      stb     lside           format track on other side
*
        sta     track
        bne     18f             make sure we  start at track 00
        jsr     restore         restore if target is 0
*
18      lda     #1
        sta     sector
*
        ldb     #4
        stb     step
        jsr     fseek
        tsta
        bne     10f
*
* restore the registers for the write
*
        ldb     #5
        stb     step
        ldu     #trkbuf
        lda     #FD_WTR
        jsr     fwrblk
*
10      puls    x,y,u,pc

*
* code routine, to read one dataset from FDC
* U = buffer address,
* Y = base address hardware
* A = command
*
* can read sector or track
* drive select, density and such alreay set up
* time out from INT fdc
*
frdblk  equ     *
        pshs    x,y,u
        ldb     #15  very long              create timeout
        ldx     #0              65536*2*25/4 cycles
*
        eora    #EOR4FDC
        sta     fo2cmd,y
*
01      orcc    #$50            disable ints
        bra     03f
* loop here
02      lda     fo2dat,y         get data
        eora    #EOR4FDC
        sta     0,u+             transfer
* poll fdc for DRQ
03      lda     fo4sta,y
        bmi     02b             DRQ
        leax    1,x             count up
        bne     11f
        decb                    at zero dec B
        beq     98f             if zero abort
11      bita    #ST_INT         INT
        beq     03b
*
97      lda     fo2cmd,y        read status
        eora    #EOR4FDC
*
99      puls    x,y,u,pc

98      lda     #FD_FI0         force interrupt
        eora    EOR4FDC
        sta     fo2cmd,y
        jsr     delay
        bra     97b

*
* code routine, to write one dataset to the FDC
* U = buffer address
* Y = hardware base
* A = command
*
* drive select, density and such alreay set up
* time out from INT fdc
*
fwrblk  equ     *
        pshs    x,y,u
*
        eora    #EOR4FDC
        sta     fo2cmd,y
*
01      orcc    #$50            disable ints
        bra     03f

02      lda     0,u+
        eora    #EOR4FDC
        sta     fo2dat,y        put data
*
03      lda     fo4sta,y
        bmi     02b
        bita    #ST_INT         INT
        beq     03b
*
        lda     fo2cmd,y        read status
        eora    #EOR4FDC
*
99      puls    x,y,u,pc

*
* clcpos, transfer block# into track/sector/side
*
* Y = fdcbase
*
clcpos  equ     *
        pshs    x,y,u
        clr     lside           result side of calc
        ldd     flpdpr+flblkm   block no M/L
*
        ldx     flpdpr+fltsiz   check special addressing
        cmpx    #256
        beq     21f
        cmpx    #128
        bne     20f
*
*  absolute addressing
*
21      sta     track
        stb     sector
        ldx     wrkprm
        cmpb    4,x             sec/trk
        bls     22f
        tst     side
        beq     91f             illegal sector?
        inc     lside           set flag
        tst     unbias
        beq     22f
        subb    4,x             start with 1 again
22      stb     sector
        bra     08f
*
* regular block to track/sector
*
20      ldx     wrkprm          fresh copy of drive params
*
        clr     track           track = 0
*
02      subd    3,x             sec/trk
        bmi     01f
*
        inc     track           up track #
        bra     02b
*
01      addd    3,x             adjust
* sector in B, track# on stack
        tst     side            is double sided?
        beq     05f             no
*
        lsr     track          track# / 2
        bcc     05f            even track
* odd track, add bias
        inc     lside
* TEST Biased here!
        tst     unbias
        bne     05f             yes
        addb    4,x            biased sector#
*
05      incb                    1 relative
        stb     sector          set sector#
*
08      lda     track
        cmpa    2,x             test against max
        bhi     91f
        clra                    set OK
        puls    x,y,u,pc
* errors
91      lda     #FS_SKER        track > max
        puls    x,y,u,pc

*
* fseek, move head to track#, set registers
* Y = hardware base
*
fseek   equ     *
        pshs    x,y,u
        tst     lside
        beq     lsk1
        oime    LA_SID,latch     1 = side 1
        bra     lsk2
lsk1    aime    !LA_SID,latch 0 = side 0
*
lsk2    lda     latch
        pshs    a
        tst     dens
        bne     lsk3
        oime    LA_SDN,latch
        bra     lsk4
lsk3    aime    !LA_SDN,latch
*
lsk4    lda     latch
        cmpa    0,s+
        beq     lsk5
        anda    #$7f
        sta     fo4lat,y
        exg     x,x
        ora     #$80
*
lsk5    sta     fo4lat,y
*
        lda     sector
        eora    #EOR4FDC
        sta     fo2sec,y        set sector register
*
        lda     track
        eora    #EOR4FDC
        cmpa    fo2trk,y
        beq     04f
*
        sta     fo2dat,y
        lda     #FD_SEK
        ora     steprt          update steprate
        eora    #EOR4FDC
        sta     fo2cmd,y
*
01      lda     fo4sta,y
        bita    #ST_INT
        beq     01b
*
04      lda     fo2cmd,y
        eora    #EOR4FDC

        anda    #!(FS_TRK0|FS_IDX|FS_HLD)    remove these from status
* check if we need to pass write protect
        ldb     flpdpr+flrflg
        bitb    #%00010000           command is read
        beq     02f
        anda    #!FS_WRP
*
02      puls    x,y,u,pc

*
* chkrdy, check if drive is ready
* Y = fdcbase
*
chkrdy  ldb     #7              multiply
*
10      ldx     #$7fff          long delay
*
11      lda     latch
        sta     fo4lat,y
        lda     fo2cmd,y
        eora    #EOR4FDC
        bpl     12f
*
        leax    -1,x            decrement counter
        bne     11b
*
        decb                    multiply
        bne     10b
*
        lda     #FS_NRDY
        rts
*
12      clra
        rts

*
* restore, set drive at track 0
* Y = fdcbase
*
restore lda     #FD_RST
        ora     steprt          adjust
        eora    #EOR4FDC
        sta     fo2cmd,y
20      lda     fo4sta,y
        tst     fo4lat,y       ??
        bita    #ST_INT
        beq     20b
        lda     fo2cmd,y
        eora    #EOR4FDC
        bita    #00000100
        bne     21f
        clr     track           update info
21      rts

*
* delay, spend some time , no registers affected
*
delay   bsr     del1
del1    bsr     del2
del2    pshs    d,x,y,u
        puls    d,x,y,u,pc

*
* srchpm, search drive param table, used for track/sector calculations
* Y = fdcbase
*
srchpm  pshs    x,y,u
        ldx     #fltabl         start table
        ldd     flpdpr+fltsid   get ttyset/ttyget bytes
        anda    #%01000000      side bits
        andb    #%11000001      dens bits
31      cmpd    0,x
        beq     30f
        leax    6,x             size of entry
        tst     2,x
        bne     31b
        ldx     #flpdfl
*
30      stx     wrkprm
        puls    x,y,u,pc

fltabl  equ     *
flpdfl  fcb     $00,$00,76,0,8,0      FD-XS
        fcb     $00,$01,76,0,16,0     FD-DX
        fcb     $40,$00,79,0,5,0      F5-SX
        fcb     $40,$01,79,0,9,0      F5-XD
        fcb     $40,$41,79,0,10,0     F5-XDE
        fcb     $00,$81,79,0,18,0     F3-XD
        fcb     $00,$c1,79,0,20,0     F3-XH
        fcb     0,0,0,0,0,0

        ifc     &a,'DBG'
* print HEX via MON ROM
tellit1 pshs    d,x,y,u
        jsr [romoth]
        jsr [romots]
        puls    d,x,y,u,pc

tellit  pshs    d,x,y,u
        jsr [romoth]
        lda #$d
        jsr [romotc]
        lda #$a
        jsr [romotc]
        puls    d,x,y,u,pc
        endif


* all process registers stacked
nmihnd  equ     *
        if      (DBG=1)

        rti
        endif

*
* signal any interrupt at location in DPR
*
rtiend  lda     #$55
        sta     flpdpr+$03f8    give warning in DPR
        rti

        org     VECTORS

        fdb     rtiend
        fdb     rtiend
        fdb     rtiend
        fdb     rtiend
        fdb     rtiend
        fdb     rtiend
        fdb     nmihnd
        fdb     reset

        end