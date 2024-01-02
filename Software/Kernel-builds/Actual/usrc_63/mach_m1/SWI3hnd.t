          opt    nol          lib    environment.h        lib     ../include/sysdefs.h        lib     ../include/ust.h          opt    lis          sttl   kernel SWI3 Handler          pag          data          global  swi3han** SWI3 (System call) interrupt handler*  -- Fetch remaining arguments and place in User Block*  -- Call system call handler*  -- Store return parameters on stack*  -- Return to program (via ROM)* 14* 13  PCL* 12  PCH* 11  UL        PCL* 10  UH        PCH* 9   YL        UL* 8   YH        UH* 7   XL        YL* 6   XH        YH* 5   DP        XL* 4   F         XH* 3   E         DP* 2   B         B* 1   A         A* 0   CC        CC*swi3han   ldx     usp        get user stack pointer** get the syscal byte via the PC on stack, bump it, put it back*          ldb     ustksz      if set, take this          bne     02f          ldb     #STKREG     if NOT set,force kernel stacksize02        subb    #2         offset stacksize to PC          abx          pshs    x          save address for later          jsr     gtuwrd     get the pc          pshs    d          save it          tfr     d,x        point to pc location          jsr     gtubyt     get post byte          stb     upostb     save in user block          puls    d          get pc back          addd    #1         bump past post byte          std     urglst+UPC save in user block          puls    x          jsr     ptuwrd     set back on stack*          jsr     syscl      process system call** put result registers, CC, D, X, PC back in user stack*          ldx     usp        point to user stack          ldb     urglst+UCC get CC-codes          jsr     ptubyt     put on stack          leax    1,x        point to d reg          ldd     urglst+UD  get d reg          jsr     ptuwrd     put on stack          ldb     ustksz      if set, take it          bne     02f          ldb     #STKREG02        subb    #9         point to X reg          abx          ldd     urglst+UX  get x reg          jsr     ptuwrd     put on stack          leax    6,x        point to pc          ldd     urglst+UPC get user pc          jsr     ptuwrd     put on stack          rts     return