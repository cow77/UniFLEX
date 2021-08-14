 lib environment.h lib ../include/macdefs.h        lib     ../include/sysdefs.h sttl System Startup Task pag name strtup global strtup** strtup** Startup regular system.  This is task 1.*strtup  seti                    mask interrupts        lda     #$FF            make sure kernal flag is OK        sta     kernel* copy from kernel space while we still can        ldx     maptbl          point to maps        inc     1,x             set map 1 busy* build stack for rti to process, always in 63X09 mode        ldd     #strtcd        pshs    d               PC        ldd     #0        pshs    d               U        pshs    d               Y        pshs    d               X        pshs    b               DP        pshs    d               W        pshs    d               D        lda     #$80        pshs    a               CC* copy our map table to DAT        ldx     #umem        ldu     #DATBOX+$10     task 1        ldb     #1601      lda     0,x+        sta     0,u+        decb        bne     01b* last settings in kernel context        ldb     #1              set map no        stb     urelod          force reload maps        ldb     #1        stb     umapno        stb     $fe03           set latch for this task* now we loose our powers        ldb     #$80            set user        stb     $fe02           user map/vectors        stb     $fe01           fuse        rti** we shoulde never end up here1*        ldx     #bfhwms        jmp     blowupbfhwms  fcc     'UGH!',0** execute this code as the new process 1*strtcd  seti        ifc     &b,'BINSH'** start /bin/shell*        swi3        fcb     10             open        fdb     strsh1,2       RW        bcs     disast        ldd     #0             stdin        swi3                   sys        fcb     16             dup        bcs     disast        ldd     #1             stdout        swi3                   sys        fcb     16             dup        bcs     disast        swi3                   sys        fcb     2              exec        fdb     strsh3         shell        fdb     strsh4         args        else** start /etc/init*        swi3                    system call        fcb     2               execw1        fdb     strtu4w2        fdb     strtu5        endif*disast  seti                    error!        lbra    **strtu4  fcc     '/etc/init',0strtu5  fdb     strtu6,0strtu6  fcc     'tty_wait',0*strsh1  fcc     '/dev/tty00',0strsh3  fcc     '/bin/shell',0strsh4  fdb     strsh5,0strsh5  fcc     'shell',0codend  equ     *