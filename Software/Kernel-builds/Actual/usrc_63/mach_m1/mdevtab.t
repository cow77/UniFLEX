        lib     mdevtab.h        sttl    Device Driver Tables        pag        name    devtab        data* important to export these GLOBAL symbols        define** Interrupt Handler Table*    Used to decide which device generated an interrupt* and how to process it.*inttab        fcb     N_intdev        number of interrupt devices* tty 0 (syscon)        fcb     0,0             ACIA        fcb     %10000000       int mask        fdb     BASACI+$00      status register        fdb     0,0             No Baud Rate Generators        fdb     tintr           tty interrupt routine        fdb     0               device number*        if      (NOACIA=0)* tty 1        fcb     0,7             ACIA        fcb     %10000000       int mask        fdb     BASACI+$10      status register        fdb     $000f,tbrbu1    low nibble, backup byte 1        fdb     tintr           tty interrupt routine        fdb     1               device number* tty 2        fcb     0,5             ACIA        fcb     %10000000       int mask        fdb     BASACI+$14      status register        fdb     $00f0,tbrbu1        fdb     tintr           tty interrupt routine        fdb     2               device number* tty 3        fcb     0,5             ACIA        fcb     %10000000       int mask        fdb     BASACI+$18      status register        fdb     $000f,tbrbu2        fdb     tintr           tty interrupt routine        fdb     3               device number* tty 4        fcb     0,7             ACIA        fcb     %10000000       int mask        fdb     BASACI+$1C      status register        fdb     $00f0,tbrbu2        fdb     tintr           tty interrupt routine        fdb     4               device number*        endif**N_intdev equ    (*-inttab-1)/INTSIZ*        if      (IOP=1)        if      (N_intdev>=IOPTDMIN)        err     "tty table conflict with IOP, check mdevtab.t"        endif        endifintend  equ     *** fnttab** Interrupt table for firq type interrupts.  It is* the same as inttab above.*fnttab  equ     *        fcb     0               # of entriesfntend  equ     * pag******************************************************************** Device tables** Character tablechrtab* tty device  [0]LCLTTY  equ     (*-chrtab)/DEVSIZ        fdb     ttopn           tty open routine        fdb     ttcls           tty close routine        fdb     ttrd            tty read routine        fdb     ttwr            tty write routine        fdb     ttspc           special routine* mem device  [1]        fdb     nuldev          mem open        fdb     nuldev          mem close        fdb     mdrd            mem read        fdb     mdwr            mem write        fdb     nodev           mem special* null device [2]        fdb     nuldev          null dev open        fdb     nuldev          null dev close        fdb     nuldrd          null device read        fdb     nuldwr          null device write        fdb     nodev           null special* ide character drivers  [3]        if      (IDE=1)        fdb     idecop          ide open        fdb     ideccl          ide close        fdb     idecrd          ide read        fdb     idecwr          ide write        fdb     idecsp          special        else        fdb     nodev        fdb     nodev        fdb     nodev        fdb     nodev        fdb     nodev        endif* acia speed setting driver [4]        fdb     tspdopn         open (exclusive)        fdb     tspdcls         close        fdb     nuldev          read (void)        fdb     nuldev          write (void)        fdb     tspdspcl        special (real action)*        if      (IOP=1)IOPTTY  equ     (*-chrtab)/DEVSIZ* IOP serial port devices   [5]        fdb     iop_open        fdb     iop_close        fdb     iop_read        fdb     iop_write        fdb     iop_spcl        elseIOPTTY  equ     LCLTTY          disable test        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        endif*        if      (FLP=1)FLPCHAR equ     (*-chrtab)/DEVSIZ* floppy character devices  [6]        fdb     flopen        fdb     flclos        fdb     flread        fdb     flwrit        fdb     flspcl        else        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        endif*        if      (UIO=1)UIOCHAR equ     (*-chrtab)/DEVSIZ* UIO device               [7]        fdb     uio_open        fdb     uio_close        fdb     uio_read        fdb     uio_write        fdb     uio_spcl        else        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        endif        if      (GPPDBG=1)* GPP DEBUG ports           [8]        fdb     gppdop        fdb     gppdcl        fdb     gppdrd        fdb     gppdwr        fdb     gppdst        else        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        endif        if      (ECN=1)* ECN devices               [9]        fdb     ecn_open        fdb     ecn_close        fdb     ecn_read        fdb     ecn_write        fdb     ecn_spcl        else        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        endif        if      (LOOP=1)* LOOP devices              [10]        fdb     lpcopen        fdb     lpcclos        fdb     nodev        fdb     nodev        fdb     lpcspcl        else        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        endif        if      (VID=1)* VIDEO device          [11]        fdb     vdopen        fdb     vdclos        fdb     vdread        fdb     vdwrit        fdb     vdspcl        else        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        endif        if      (RAMDSK=1)* RAM DISK              [12]        fdb     ramcop        fdb     ramccl        fdb     ramcrd        fdb     ramcwr        fdb     ramspc        else        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        endif        if      (NET=1)* NETWORK DEVICE        [13]        fdb     wzopn        fdb     wzcls        fdb     wzrdd        fdb     wzwrd        fdb     wzspc        else        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        fdb     nodev           null special        endifCHRDEV  equ     (*-chrtab)/DEVSIZ        fdb     0******************************************************************** Block device table*blktab        if      (IDE=1)IDEmajor equ    (*-blktab)/BLKSIZ       [0]        fdb     BDopen,IDEopen          open routine        fdb     BDclose,IDEclose        close routine        fdb     BDio,IDEio              main io routine        fdb     idedt                  device table pointer        fcb     IDEmax        endif        if      (LOOP=1)LPMajor equ     (*-blktab)/BLKSIZ       [1]        fdb     BDopen,LPopen        fdb     BDclose,LPclose        fdb     BDio,LPio        fdb     loopdt        fcb     LPMAX        endif        if      (RAMDSK=1)              [2]RMmajor equ     (*-blktab)/BLKSIZ        fdb     BDopen,RMopen        fdb     BDclose,RMclose        fdb     BDio,RMio        fdb     rambdt        fcb     MXRDEV        endif        if      (FLP=1)FLmajor equ    (*-blktab)/BLKSIZ        [3]        fdb     BDopen,FLopen        fdb     BDclose,FLclose        fdb     BDio,FLio        fdb     flpdt        fcb     FLMAX        endif*BLKDEV  equ     (*-blktab)/BLKSIZ** distinct entries for each minor*        if      (IDE=1)* Block Device 0 Open tableIDEopenIDEminor equ  (*-IDEopen)/2        fdb     ideopen                 hd0        fdb     ideopen                 hd1        fdb     ideopen        fdb     ideopen        fdb     ideopen        fdb     ideopen        fdb     ideopen        fdb     ideopen        fdb     ideopen        fdb     ideopen        fdb     ideopen        fdb     ideopen        fdb     ideopen        fdb     ideopen        fdb     ideopen        fdb     ideopenIDEmax  equ     (*-IDEopen)/2* Block Device 0 Close TableIDEclose        fdb     ideclose                hd0        fdb     ideclose                hd1        fdb     ideclose        fdb     ideclose        fdb     ideclose        fdb     ideclose        fdb     ideclose        fdb     ideclose        fdb     ideclose        fdb     ideclose        fdb     ideclose        fdb     ideclose        fdb     ideclose        fdb     ideclose        fdb     ideclose        fdb     ideclose* Block Device 0 I/O TableIDEio        fdb     ideio                   hd0        fdb     ideio                   hd1        fdb    ideio        fdb    ideio        fdb    ideio        fdb    ideio        fdb    ideio        fdb    ideio        fdb    ideio        fdb    ideio        fdb    ideio        fdb    ideio        fdb    ideio        fdb    ideio        fdb    ideio        fdb    ideio        endif        if      (FLP=1)** floppy drive table*FLopenFLminor equ    (*-FLopen)/2        fdb     flpopen        fdb     flpopen        fdb     flpopen        fdb     flpopenFLMAX   equ     (*-FLopen)/2*FLclose        fdb     flpclos        fdb     flpclos        fdb     flpclos        fdb     flpclos*FLio        fdb     flpio        fdb     flpio        fdb     flpio        fdb     flpio*fchbuf  rzb     HDRSIZ          floppychar driver        endif        if      (LOOP=1)** LOOP device*LPopenLPminor equ     (*-LPopen)/2        fdb     loopopn        fdb     loopopnLPMAX   equ     (*-LPopen)/2*LPclose        fdb     loopcls        fdb     loopcls*LPio        fdb     loopio        fdb     loopio** information tables for each loop device*loopopt equ     *loopo   rzb     LOPSIZ          pseudo fdn'sloop1   rzb     LOPSIZ        endif        if      (RAMDSK=1)** RAMdisk*RMopenRMminor equ     (*-RMopen)/2        fdb     ramopn        fdb     ramopnMXRDEV  equ     (*-RMopen)/2*RMclose        fdb     ramcls        fdb     ramcls*RMio        fdb     ramio        fdb     ramio*rchbuf  rzb     HDRSIZ          floppychar driver*        endif** non existent devices*bdnopn  equ     *bdncls  equ     *bdnio   fdb     nodevbdnptr  rzb     2** IOP data structures*        if      (IOP=1)*IOP0      rzb   2          fio_mbx lock   Task id of locker          rzb   2          fio_fifo lock  Task id of locker          fdb   IOP0BASE   fio_dba          lib              ../include/iop_ini.h          rzb   1          fio_int Set non-zero if message interrupt was missed          rzb   1          fio_tflg Waiting on transaction slot semaphore          rzb   24*TRAN_SIZE        endif** UIO data structures*        if      (UIO=1)UIO0    rzb     2          fio_mbx lock    task ID of locker        rzb     2          fio_fifo lock   task ID of locker        fdb     UIO0BASE   fio_dba        lib     ../include/uio_ini.h        rzb     1          fio_int Set non-zero if interrupt was missed        rzb     1          fio_tflg        waiting on transaction slot        rzb     2        endif** NET datastructures*        if      (NET=1)*NWP0    rzb     2          fio_mbx_lock    task ID of locker        rzb     2          fio_fifo_lock   task ID of locker        fdb     NWP0BASE   fio_dba        lib     ../include/nwp_ini.h        rzb     1          fio_int         non-zero if interrupt was missed        rzb     1          fio_tflg        waiting for transaction slot        rzb     8*TRAN_SIZE        endif** ECN datastructures*        if      (ECN=1)*ECN0    rzb     2          fio_mbx_lock    task ID of locker        rzb     2          fio_fifo_lock   task ID of locker        fdb     ECN0BASE   fio_dba        lib     ../include/ecn_ini.h        fdb     512        fio_fsz  fifo data size        fdb     1024       fio_dsz        fcb     8          fio_mxtrn        rzb     1          fio_int         non-zero if interrupt was missed        rzb     1          fio_tflg        waiting for transaction slot        rzb     8*TRAN_SIZE        endif if  (ROMDBG=1)** ROM routines*Pdata lda ,x+ get next character beq 99f exit at null bsr Pchar print it bra Pdata continue99 rtsPhex pshs cc seti jsr [$F80C] puls cc,pcPspace pshs a lda #$20  space char bsr Pchar puls a,pcPchar pshs cc seti jsr [$F808] puls cc,pcTinit pshs cc seti jsr [$F802] puls cc,pcPhex2 pshs b bsr Phex puls a bra Phex        endif  enddef  end