          lib     environment.h          sttl    Miscellaneous System Routines          pag          name    hmisc          global  status,ofstat,alarm,stop,time,stime          global  ttime,filtim,suid,guid,setpr,defacc          global  spint,cpint,ttyget,ttyset,stack,break          global  profil,lrec,urec,cdata,lock          global  systat,ttynum,sacct          global  gtid,trap,doprof,ulft          global  mutlck,mutunl** status** Status system call*status    ldb     #1         set user space          lbsr    pthnm      process pathname          cmpx    #0         file found?          lbeq    open3      if not, report error          pshs    x          save fdn pointer          ldy     usarg1     get user buffer address          bsr     givst      go report status          puls    x          get fdn pointer          lbra    frefdn     free up the fdn** ofstat** Open file status system call*ofstat          ldd     urglst+UD  get file descriptor          lbmi    setfdnx    special case for "set execute only"          lbsr    getdes     find file          cmpx    #0         file found?          bne     ofsta2     if not, error          rts     return     errorofsta2    ldx     ofnodp,x   point to fdn          ldy     usarg0     point to user buffer* fall thru to givst routine          pag** givst** Report the status of a file to the user.  On* entry, x points to the fdn of the file and* Y points to an address in the user's space.*givst     pshs    x,y        save data          lbsr    updfdn     update the fdn on disk          lbsr    fdnbf      read the fdn into a buffer          beq     givst2     error?          puls    x,y,pc     if so, returngivst2    ldy     2,s        point to user buffer          leay    4,y        skip first 4 bytes          pshs    x,y,u      save data          ldd     #ffmap-fmode set byte count          lbsr    cpybtu     copy to user buffer          ldx     2,s        make sure "execute only" doesn't get out          leax    5,x          jsr     gtubyt          andb    #$7F       remove execute only bit          jsr     ptubyt          ldx     2,s        get user address ptr          lbsr    gtubyt     get mode byte from user          bitb    #FSBLK|FSCHR is it a device?          beq     givst4     if not - skip this stuff          puls    x,y,u      reset regs          pshs    x,y,u          leay    (fsize-fmode+2),y point to 'size'+2 (dev num)          leau    ffmap-fmode,u point to device number          ldd     #2         set xfr count          lbsr    cpybtu     copy device numbergivst4    puls    x,y,u      reset data          leay    ffmap-fmode,y bump user pointer          ldd     #8         set data count          leau    FDNSIZ-fmode,u bump past map in fdn          pshs    x          save pointer          lbsr    cpybtu     copy data to user          puls    y          get data buffer          lbsr    freebf     free the buffer          puls    y          reset initial pointers          puls    x          ldb     #4         set data count          leay    fdevic,y   point into fdn** mvtusr** Move data pointed at by Y to user space pointed* at by X.  Move the number of bytes in B.*mvtusr    pshs    b,x,y      save datamvtus2    ldy     3,s        get data pointer          ldb     0,y+       get a byte          sty     3,s        save pointer          lbsr    ptubyt     put in user space          ldx     1,s        get user pointer          leax    1,x        bump by one          stx     1,s        save new value          dec     0,s        dec the byte counter          bne     mvtus2     repeat?          puls    b,x,y,pc   return          pag** alarm** Set system alarm system call.*alarm     ldx     utask      point to task entry          ldd     tsalrm,x   get old value          ldu     urglst+UD  get new value (seconds)          stu     tsalrm,x   save in task entry          std     urglst+UD  return old in D          rts     return** stop** Stop for an indefinite period of time (system call)*stop      ldy     #nmivec    point to vector          ldb     #SLEPPR    set priority          lbsr    sleep      sleep on vector          bra     stop       (no one awakens nmivec!)** time** Get system time (system call)*time      ldx     usarg0     get user address          ldy     #stimh     point to time data          ldb     #dstflg+1-stimh set byte count          bra     mvtusr     move data to user & exit** stime** Set system time (system call)*stime     lbsr    tstsu      is this system manager?          bne     stime2     if not, error          ldd     urglst+UD  get low time          ldx     urglst+UX  get hi time          stx     stimh      set hi time          std     stiml      set low time          stx     sbttim     set boot time          std     sbttim+2          clr     hertz      clear fine countstime2    rts     return** ttime** Get task times (system call)*ttime     ldx     usarg0     get user buffer address          ldy     #utimu     point to time data          ldb     #utimsc+4-utimu set byte count          bra     mvtusr     go move data** filtim - set file access time** System call to set the "last access" time on a file.* Time is in (X,D)*filtim    lbsr    tstsu      check for system manager          bne     filti4     if not, error          ldb     #1         indicate "user space"          lbsr    pthnm      search for file          leax    0,x        check response          lbeq    open3      if not found, error          lda     frefct,x   check reference count          deca          bne     filti1     if open by someone else          pshs    x          save pointer          ldd     fdevic,x   find the sir          lbsr    fndsir          lda     swprot,x   check for read-only          bne     filti6     if read-only          ldx     0,s        restore fdn pointer          lda     fstat,x    lock the fdn          ora     #FLOCK          sta     fstat,x          lbsr    fdnbf      find the fdn buffer          bne     filti5     if error          pshs    x          save header address          pshs    x,u        save header address and offset          lbsr    cpystb     copy the fdn          puls    x,u        restore header address and offset          ldd     urglst+UD  put time on stack          pshs    d          ldd     urglst+UX          pshs    d          leay    0,s        point to time          leau    FDNSIZ-fmode,u point to time area          ldd     #4         set length          jsr     cpystb     copy into buffer          leas    4,s        remove time from stack          puls    y          restore header pointer          lbsr    wbflat     write the buffer          puls    x          restore fdn pointer          lbsr    unlfdn     unlock the fdn          bra     filti3     free the fdnfilti1    lda     #EBSY      set "file busy"filti2    sta     uerrorfilti3    lbra    frefdn     release the fdnfilti4    rtsfilti5    puls    x          clear lock          lbsr    unlfdn     unlock the fdn          bra     filti3     update the fdnfilti6    puls    x          restore fdn pointer          lda     #EPRM      return "permission error"          bra     filti2** suid** Set user id system call*suid      ldd     urglst+UD  get new user id          cmpd    uuida      is it this user?          beq     suid2      if so, ok          pshs    d          save id          lbsr    tstsu      is it super user?          puls    d          reset id          bne     suid6      if not, errorsuid2     std     uuid       set user id          std     uuida      set actual user id          ldx     utask      point to task entry          std     tsuid,x    save in task entry          rts     returnsuid4     lda     #EPRM      set error          sta     uerrorsuid6     rts     return     error** guid** Get user id system call*guid      ldd     uuida      get actual id          std     urglst+UD  return in D          ldd     uuid       get effective id          std     urglst+UX  return in x          rts     return          pag** gtid** Get task id system call*gtid      ldx     utask      point to task entry          ldd     tstid,x    get task id          std     urglst+UD  return in D          rts     return** setpr** Set user priority bias (system call)*setpr     ldd     urglst+UD  get bias          cmpd    #25        check range          bgt     setpr5     too high?          cmpd    #-25       check low end          blt     setpr5     too low?          ldx     utask      point to task entry          tstb    is         it negative?          bpl     setpr4     if not, go set          pshs    b          save priority          lbsr    tstsu      is this super user?          puls    b          bne     setpr5     if not, exitsetpr4    stb     tsprb,x    set new pr biassetpr5    rts     return** defacc** Set default permissions (system call)*defacc    ldb     udperm     get default byte          comb          clra    make       16 bits          std     urglst+UD  return old in D          ldd     usarg0     get new value          andb    #$3f       mask off          comb          stb     udperm     set new value          rts     return          pag** spint** Send program interrupt (system call)*spint     ldd     usarg0     get interrupt number          pshs    d          save it          ldy     utask      point to task entry          clr     0,-s       zero a counter          lda     #$ff       set task 0,1 counter          pshs    a          save on stack          ldd     urglst+UD  get task id          ldx     tsktab     point to task tablespint2    cmpd    #-1        is id -1?          bne     spint3          ldu     uuid       get user id          bne     spint9     is it super user?          tst     0,s        is it task 0 or 1?          ble     spint7     if so, skip          tst     tsstat,x   this entry used?          bne     spint6     go send interrupt          bra     spint7     skip if notspint3    cmpd    #0         is id 0?          bne     spint4          ldu     tstty,x    get controlling tty          cmpu    tstty,y    same as callers?          bne     spint7     if not, skip          tst     0,s        task 0 or 1?          ble     spint7     if so, skip          bra     spint5     go send interruotspint4    cmpd    tstid,x    task ids match?          bne     spint7spint5    ldu     uuid       get user id          beq     spint6     if su, go ahead          cmpu    tsuid,x    does it match the tasks?          bne     spint7     if not, skipspint6    inc     1,s        bump count (found one)          pshs    d,x,y          ldd     8,s        get interrupt number          lbsr    xmtint     send the interrupt          puls    d,x,yspint7    inc     0,s        bump task counter          leax    TSKSIZ,x   bump to next entry          cmpx    tskend     end of list?          bne     spint2     if not, repeat          puls    b          clean off stack          ldb     0,s+       get find counter          beq     spint8     if 0, found none, error          puls    d,pc       returnspint8    lda     #ENTSK     set error          sta     uerror          puls    d,pc       return errorspint9    leas    2,s        clean up stack          bra     spint8     set error & exit** cpint** Catch a program interrupt (system call)*cpint     ldd     usarg0     get interrupt number          beq     cpint6     cant be 0!          cmpd    #SIGCNT    is it in range?          bhi     cpint6          cmpd    #KILLS     is it kill?          beq     cpint6     cant catch 'kill'!          tst     SWTPCvii          beq     0f          cmpd    #TIMES     cant catch time either          beq     cpint60          ldx     #usigs     point to interrupts          pshs    b          save number          decb    remove     bias          aslb    calculate  position          leax    b,x        point to int slot          ldd     0,x        get old value          std     urglst+UD  return in D          ldd     usarg1     get address          std     0,x        set in interrupt          ldx     utask      get task entry          lda     tssgnl,x   current interrupt?          anda    #$7f       mask special bit          cmpa    0,s+          bne     cpint4          clr     tssgnl,x   if so, clear it out!cpint4    rts     returncpint6    lda     #EBARG     set error          sta     uerror          rts     error      return          pag** ttyget** Get the tty status words. (system call)*ttyget    leas    -6,s       space for result          leay    0,s        point to buffer          bsr     gstty      get status          tst     uerror     errors?          bne     ttyge6ttyge2    ldx     usarg0     point to status words          leay    0,s        point to status buffer          ldb     #6         set count          lbsr    mvtusr     xfr status words to userttyge6    leas    6,s        clean up stack          rts** ttyset** Set the tty status (system call)*ttyset    ldx     usarg0     get user arg pointer          pshs    x          lbsr    gtuwrd     get the word from user          std     usarg0     save it          ldx     0,s        get users pointer          leax    2,x        bump to next entry          lbsr    gtuwrd     get word from user          std     usarg1     save it          puls    x          get users pointer          leax    4,x        point to 3rd word          lbsr    gtuwrd     get word from user          std     usarg2     save it          ldy     #0         set null pointer* fall thru to next routine          pag** gstty** Common code for ttyget and ttyset.*gstty     pshs    y          save pointer          ldd     urglst+UD  get file descriptor          lbsr    getdes     get associated file          cmpx    #0         no file there?          beq     gstty4     if not, error          ldx     ofnodp,x   point to its fdn          lda     fmode,x    get fdn modes          bita    #FSCHR     is it character special?          bne     gstty5     if not, error          lda     #ENTTY     set error          sta     uerrorgstty4    puls    y,pc       error returngstty5    ldd     ffmap,x    get device number          pshs    d          ldy     #chrtab    point to character table          ldb     #DEVSIZ    calculate this guys position          mul     in         the table          leay    d,y        point to his entry          puls    d,x        reset info** do device SPECIFIC function*          jmp     [devspc,y] call special routine          pag** stack** System call to set the stack boundary.*stack     ldb     urglst+UX  arg is in x          lsrb    get        seg number          lsrb          lsrb          lsrb          pshs    b          save page number          ldb     #NBLKS     get block count          subb    0,s+       get new stack size          tfr     b,a          subb    usizes     compare against current          lbgt    grows      need to grow?          bne     stack4          rts     return     do nothing!stack4    pshs    a          ldb     usizes     get stack seg count          subb    0,s+          lda     usizes          nega          ldx     #umem+NBLKS point to end of mem list          leax    a,x        point to 1st stack cell          jmp     unmems     release unused stack space** break** System call to extend the data section of memory.* *** The original code prevents the use of the top* 3.5KByte for use, this is a waste of memory* this modified version extends the break call up to $fe00*break     ldd     usarg0     check high limit          cmpd    #((SYSBLK<<12)+USTKO)  ($fe00)          bhs     break8     error          exg     a,b        bring in at the right place*          lsrb    get        seg number          lsrb          lsrb          lsrb*          cmpb    #SYSBLK-1          bls     break2          ldb     #SYSBLK-1  keep tests happybreak2    incb    add        in bias          lda     usizet     get text size          adda    usized     add in data size          pshs    b          temp on stack          cmpa    0,s+       do we need expansion?          lblo    growd      if so, go do it          pshs    d          save info          suba    1,s        get difference          bne     break4     release some?          puls    d,pc       returnbreak4    tfr     a,b        save count          puls    a          get text and data size          leas    1,s          cmpb    usized     trying to free text space?          bls     break6          rts     returnbreak6    ldx     #umem      point to mem list          leax    a,x        point to end of data          jmp     unmemd     release memory*break8    lda    #EDTOF          sta    uerror          rts          pag** profile** System call for program profiling.*profil    ldd     usarg0     get profile pc          std     uprfpc     save it          ldd     usarg1     get buffer address          std     uprfbf     save it          ldd     usarg2     get buffer size          std     uprfsz     save it          ldd     usarg3     get profile scale factor          clra    clear      high byte          lsrb    scale      it          std     uprfsc     save it          rts     return** doprof** Do the actual profile count.  This routine called* from the clock interrupt handler.*doprof    lda     uprfsc+1   get scale          pshs    a          save the scale          ldx     usp        point to user stack          ldb     ustksz          subb    #2         offset to PC in stack          abx          lbsr    gtuwrd     get his pc          subd    uprfpc     subtract low pc          tst     0,s        need to scale it?          beq     dopro4dopro2    lsra    divide     by scale          rorb          lsr     0,s          bne     dopro2dopro4    leas    1,s        clean up stack          lslb    now        mult by 2          rola          cmpd    uprfsz     is it in buffer?          bhs     dopro6     if not, exit          ldx     uprfbf     point to buffer          leax    d,x        point to selected word          pshs    x          save pointer          lbsr    gtuwrd     get the word          addd    #1         bump by 1          puls    x          get buffer address          lbsr    ptuwrd     put new word backdopro6    rts     return          pag** lrec** System call for locking sections of files.  Note that* the file is only locked if the 'lrec' and 'urec' calls* are used.*lrec      ldb     urglst+UB  get file desc          clra          lbsr    getdes     get file table entry          beq     lrec2      error?          lda     ofmode,x   get file mode          bita    #OFPIPE    is it a pipe?          bne     lrec1      if so - error!          ldu     ofnodp,x   get fdn pointer          lda     fmode,u    get fdn mode bits          bita    #FSBLK|FSCHR is it a device?          beq     lrec3      if so - error!lrec1     lda     #EBADF     set bad file error          sta     uerrorlrec2     rts     returnlrec3     pshs    x          save file pointer          ldu     0,s          lbsr    ulft       unlock any locked for this guy          puls    u          get file pointer          bsr     chklc      check if file locked          beq     lrec2      if so - error!          ldy     ofnodp,u   get fdn pointer          sty     lkofp,x    set file ptr in entry          std     lktid,x    save task id          ldd     usarg0     get count (argument)          std     lkcnt,x    set in entry          ldd     ofpost,u   get current file position          std     lkadr,x    save in entry          ldd     ofpos2,u   get lo part          std     lkadr+2,x          rts     return          pag** chklc** Check for locked file section.  Preserve D in here* (it has task id).  U has file pointer.  Exit 'eq'* if error, else exit with X pointing to usable lock* table entry.*chklc     ldx     lkbeg      get lock table start          pshs    d          save task id          leas    -4,s       save room on stack          ldy     ofnodp,u   get fdn pointerchklc2    cmpy    lkofp,x    look for same file          bne     chklc5          ldd     ofpos2,u   get current pos          subd    lkadr+2,x  get difference          std     2,s          ldd     ofpost,u          sbcb    lkadr+1,x          sbca    lkadr,x          std     0,s        save result          beq     chklc4     is result positive?          cmpd    #-1          bne     chklc5          ldd     2,s        get lo part of result          beq     chklc5     if 0 - ok          coma    get        2's comp.          comb          addd    #1          cmpd    usarg0     compare to count          blo     chklc7     error?          bra     chklc5     ok if herechklc4    ldd     2,s        get lo part          beq     chklc7     if 0 - error          cmpd    lkcnt,x    compare to previous count          blo     chklc7     if lower - error!chklc5    leax    LKTSIZ,x   bump to next entry          cmpx    lkend      end of table?          bne     chklc2     if not - repeat          ldx     lkbeg      point to table beginchklc6    ldd     lkofp,x    look for empty entry          beq     chklc8     find one?          leax    LKTSIZ,x   get to next entry          cmpx    lkend      end of table?          bne     chklc6chklc7    lda     #ELOCK     set lock error          sta     uerror          sez     set        error status          leas    6,s        clean off stack          rts     returnchklc8    leas    4,s        clean house          clz     set        status          puls    d,pc       return          pag** urec** Unlock record system call.*urec      ldb     urglst+UB  get file desc          clra          lbsr    getdes     get file pointer          bne     urec2      error?          rts     return     - errorurec2     tfr     x,u        setup file pointer** ulft** Unlock all entries with task id of [D] and file* matching U.*ulft      ldy     #0         set up null ptr          ldu     ofnodp,u   get fdn pointer          ldx     utask      get task entry          ldd     tstid,x    get task id          ldx     lkbeg      point to lock tableulft2     cmpu    lkofp,x    check for matching file          bne     ulft3          cmpd    lktid,x    same task?          bne     ulft3          sty     lkofp,x    zero out entryulft3     leax    LKTSIZ,x   get to next entry          cmpx    lkend      end of table?          bne     ulft2          rts     return** mutlck, aquire lock on a mutex, X point to mutex location*mutlck    pshs    b,x,y02        inc     0,x           should go from ff to 00          beq     01f          tfr     x,y          ldb     #PIPEPR          jsr     sleep          bra     02b01        puls    b,x,y,pc** mutunl, release the lock on a mutex, X point to mutex location*mutunl    pshs    x,y          dec     0,x          tfr     x,y          jsr     wakeup          puls    x,y,pc          pag** cdata** System call for requesting contiguous data memory.* Form is same as 'break'.*cdata     jsr     tstsu      is this super guy?          bne     cdata6          ldb     usarg0     get segment number          lsrb    get        to low half          lsrb          lsrb          lsrb          incb    bump       by one          lda     usizet     get size of text          adda    usized     add in data size          pshs    b          save it          cmpa    0,s+       do we need to grow?          bhs     cdata6          pshs    d          save info about sizes          subb    0,s        how many do we need?          cmpb    corcnt     do we have that many?          bhi     cdata4     if not - error          cmpb    #8         is it in range?          bhi     cdata4          cmpb    #1         only need 1?          beq     cdata3          pshs    b          save count          bsr     mvmtab     move memory table          pshs    u          save end of table          leau    -1,u       point to last element          bsr     sortm      sort the new list          ldu     0,s        point to table end          ldb     2,s        get segment count          bsr     fcont      find contiguous memory          tst     uerror     error?          bne     cdata5          jsr     arngm      arrange new memory list          leas    3,s        clean off stackcdata3    puls    d          reset size info          jmp     growd      grow the data sectioncdata4    lda     #EDTOF     set error          sta     uerror          puls    d,pc       returncdata5    leas    5,s        clean off stackcdata6    rts     return          pag** mvmtab** Copy system memory list to buffer 'prcbuf'.*mvmtab    ldu     #prcbuf    point to buffer space          ldx     memfst     point to start of avail memorymvmta2    lda     0,x+       get a page          sta     0,u+       move it          cmpx    lstmem     end of table?          bne     mvmta4          ldx     #memtab    reset to startmvmta4    cmpx    memlst     end of avail memory?          bne     mvmta2     repeat          rts     return** sortm** Sort the list of available memory pages in* descending order so we can look for contiguous* segments.*sortm     pshs    u          save list end pointer          leas    -1,s       save a slot on stacksortm1    clr     0,s        clear switch flag          ldx     #prcbuf    point to listsortm2    lda     0,x        get a segment number          tst     DATsense          bne     0f         jump for screwy SWTPC DAT          cmpa    1,x        need to switch?          bls     sortm4          bra     1f0         cmpa    1,x        need to switch?          bhs     sortm41         ldb     1,x        switch the items          stb     0,x          sta     1,x          inc     0,s        set flagsortm4    leax    1,x        bump to next element          cmpx    1,s        end of list?          bne     sortm2          tst     0,s        any switched?          bne     sortm1     if so - repeat          puls    a,u,pc     return          pag** fcont** Find B contiguous memory pages in 'prcbuf' buffer.* Return X point to items or uerror set.*fcont     pshs    b,u        save params          ldx     #prcbuf    point to table          pshs    x          save starting posfcont2    clrb    clear      counterfcont3    lda     0,x+       get a segment number          tst     DATsense   check DAT form          bne     0f          inca          pshs    a          cross 64K boundary?          anda    #$0F          puls    a          beq     fcont5     yes - no match          bra     1f0         deca    dec        it          pshs    a          cross 64K boundary?          anda    #$0F          cmpa    #$0F          puls    a          beq     fcont5     yes - no match1         cmpa    0,x        does it match?          bne     fcont5          incb    bump       match counter          cmpb    2,s        do we have enough?          beq     fcont6          cmpx    3,s        end of list?          bne     fcont3fcont4    lda     #EDTOF     set error          sta     uerror          leas    5,s        clean stack          rts     returnfcont5    cmpx    3,s        end of list?          beq     fcont4          stx     0,s        save new starting pos          bra     fcont2     repeatfcont6    puls    x          get starting pos          puls    b,u,pc     return          pag** arngm** Arrange memory list so contiguous memory is first* in the list of avail.*arngm     pshs    b,x        save params          leau    0,s        point to paramsarngm2    lda     0,x+       get a segment number          pshs    a          save on stack          decb    dec        the count          bne     arngm2          ldy     #prcbuf    point to memory buffer list          ldx     1,u        get start pos          ldb     0,u        get countarngm4    lda     0,y+       get a segment          sta     0,x+       move in the list          decb    dec        the count          bne     arngm4          ldb     0,u        reset count          ldx     #prcbuf    point to list start          leax    b,xarngm6    puls    a          get a segment          sta     0,-x       save in list          decb    dec        the count          bne     arngm6          ldx     #memtab    reset memory pointers          stx     memfst     save head of list          ldb     corcnt     get core count          ldu     #prcbuf    point to rearranged listarngm8    lda     0,u+       get a segment          sta     0,x+       save in regular list          decb    dec        the count          bne     arngm8          stx     memlst     save end of list ptr          puls    b,u,pc     return          pag** lock** Lock task in memory system call.*lock      jsr     tstsu      system man?          bne     lock3          ldx     utask      get task entry          ldd     usarg0     get arg          beq     lock4      is it zero?          lda     tsmode,x   get task modes          ora     #TLOCK     set lock bit          sta     tsmode,x   reset modeslock3     rts     returnlock4     lda     tsmode,x   get task modes          anda    #!TLOCK    clear lock bit          sta     tsmode,x   reset modes          rts     return** trap** Trap system call.  Sets up the swi2 vector.*trap          ldd     uswi2v     get swi2 vector          std     urglst+UD  return old in D          ldd     usarg0     get arg          std     uswi2v     set new vector          rts     return** systat** Return system status - version info, etc.*systat    ldx     usarg0     get buffer location          ldy     #univer    point to version          ldb     #8         set size count          lbra    mvtusr     go move to user & return** ttynum** Return the tty device number in D-reg.*ttynum    ldx     utask      get task entry          ldx     tstty,x    get tty entry          ldd     tdevic,x   get device number     cmpa #IOPTTY     bne  01f     lda  #LCLTTY     correct for IOP tty's01        std     urglst+UD  return in D          rts     return** sacct** Enable or disable system accounting.*sacct     jsr     tstsu      must be system manager          bne     sacct3     if not - error          clr     uerror     reset error status          ldd     usarg0     get argument          beq     sacct4     turn off accoiunting?          std     ucname     save name pointer          ldd     actfil     accounting in progress?          beq     sacct2          lda     #EFLX      set error          sta     uerror          rts     returnsacct2    ldb     #1         set to user space          jsr     pthnm      process file name          cmpx    #0         file found?          beq     sacct6     if not - error          lda     fmode,x    get file modes          bita    #FSDIR|FSCHR|FSBLK is it regular file?          bne     sacct7          lda     #1         set for write access          ldy     #saofbf    point to accounting file table          sty     actfil     save pointer          sta     ofmode,y   save write mode          stx     ofnodp,y   save fdn pointer          sta     ofrfct,y   set ref count          pshs    x,y          jsr     unlfdn     unlock fdn          puls    x,y        get regs back          ldd     fsize,x    set starting position          std     ofpost,y          ldd     fsize+2,x          std     ofpos2,ysacct3    rts     returnsacct4    ldx     actfil     active accounting?          beq     sacct3     if not - return          tst     sabbsy     is buffer busy?          beq     sacct5          ldy     #sabbsy    sleep on buffer          ldb     #BUFPR          jsr     sleep          bra     sacct4sacct5    ldd     #0         turn off acct          std     actfil          ldy     ofnodp,x   get fdn pointer          jsr     lckfdn     lock the fdn          tfr     y,x        point to fdn          jsr     frefdn     free the fdn          rts     returnsacct6    lda     #ENOFL     set error          sta     uerror          rts     returnsacct7    lda     #EBADF     set error          sta     uerror          rts     return