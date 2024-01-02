NET       set     1          ttl     SWTPc      Intelligent I/O Processor          sttl    Hardware   Definitions          opt     exp          abs          pag          lib     environment.h          sttl    CPU        Vectors          pag          org     CPUtraps          fdb     rom_trap   Unused          fdb     rom_swi3   SWI3          fdb     rom_swi2   SWI2          fdb     rom_firq   FIRQ          fdb     IRQ_han    IRQ          fdb     rom_swi    SWI          fdb     rom_nmi  Background debug          fdb     rom_init   Reset          sttl    System     RESET Code          pag          org     ROMLOorgDBmsg00   fcc     $d,'NWP ROM',0DBmsg01   fcc     $d,'System Initialization Complete',0DBmsg02   fcc     $d,'CPU RESET Complete',0CPU_down  fcc     $d,$d,'System CPU not functioning',0* share settings with kernel driver codefio_fsz   equ     *        device fifo sizefio_dsz   equ     *+2      device RAM sizemax_trn   equ     *+4      max transactions          lib     ../include/nwp_ini.h** System RESET code*rom_init  lds     #ROMstack  initialize stack pointer          ldmd    3** for background debugger***        lda     #$15**        sta     ACIAC         init debug acia**        clr     bdbsta        echo on          ldx     #IRQ_han    IRQ          stx    $7f00        GPPMON vector20        lbsr    stbinit    go initialize system memory30        lds     tsktab     Task 0 Stack          leas    TSKSIZ,s          lbsr    fio_reset          lbsr    timerin** Initialization complete - Start executing commands*fio_start10        jmp     rsched          sttl    ROM        Interrupt Fielders          pagrom_nmi   bsr     rom_int          fcc     'NMI',0rom_firq  bsr     rom_int          fcc     'FIRQ',0rom_swi   bsr     rom_int          fcc     'SWI',0rom_swi2  bsr     rom_int          fcc     'SWI2',0rom_swi3  bsr     rom_int          fcc     'SWI3',0rom_trap  bsr     rom_int          fcc     'TRAP',0rom_int   ldx     #ROM_ERR          jsr     DB_pdata          puls    x          jsr     DB_pdatarom_bad   bra     **ROM_ERR   fcc     $d,'ROM Error: ',0