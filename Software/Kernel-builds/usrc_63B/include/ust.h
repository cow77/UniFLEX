          pag** User Table** One entry in table for each active task.* Contains all data for task which may be swapped* out when task is not running.  The user block* resides at location USERBL in the user address* space.  This space is at least 4K in size and* contains space for the system stack.*          base    USERBLust       equ     ** struct userdummy   rmb     3       expansionustksz  rmb     1       user process interrupt stack sizeuargp   rmb     2       user process argument pointeruswi2v  rmb     2       SWI2 vector storage*usp       rmb     2          user stack pointer storageurelod    rmb     1          mem map reload flagumapno    rmb     1          mem map numberumem      rmb     MAXPAGES   memory map for taskurglst    rmb     REGSIZ     user register listuerror    rmb     1          error code returnedumark0    rmb     2          mark reg 0umark1    rmb     2          mark reg 1umark2    rmb     2          mark reg 2*utask     rmb     2          pointer to task structureuuid      rmb     2          effective user iduuida     rmb     2          actual user iducrdir    rmb     2          fdn ptr of current diruwrkbf    rmb     DIRSIZ     work buffer for path nameufdel     rmb     2          first deleted directoryufdn      rmb     2          current directory fdnudname    rmb     DIRSIZ     current dir entryulstdr    rmb     2          fdn of last dir searchedudperm    rmb     1          default file permissionsucname    rmb     2          pointer to command name argufiles    rmb     UNFILS*2   pointers to open filesusarg0    rmb     2          user argument 0usarg1    rmb     2          user argument 1usarg2    rmb     2          user argument 2usarg3    rmb     2          user argument 3uiosp     rmb     1          user i/o space flaguistrt    rmb     2          start address for I/Ouicnt     rmb     2          I/O byte counteruipos     rmb     2          I/O file offsetuipos2    rmb     2          rest of offsetumaprw    rmb     1          read write mapping flagunxtbl    rmb     3          read ahead blockuinter    rmb     1          interrupt error flagutimu     rmb     3          task user timeutims     rmb     3          user system timeutimuc    rmb     4          total childs user timeutimsc    rmb     4          total childs system timeusizet    rmb     1          text size (*PAGSIZ)usized    rmb     1          data size (*PAGSIZ)usizes    rmb     1          stack size (*PAGSIZ)usigs     rmb     SIGCNT*2   condition of all signalsuprfpc    rmb     2          profile pcuprfbf    rmb     2          profile bufferuprfsz    rmb     2          buffer sizeuprfsc    rmb     2          profile scaleustart    rmb     4          task start timeuexnam    rmb     2          exec'd file name pointerumxmem    rmb     1          max mem usageuiocnt    rmb     2          io block countupostb    equ     urglst+UPB sys call post byteUSTSIZ    equ     *          user structure size