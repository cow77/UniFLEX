          sttl    Device     Table Structure          pag** Possible module types table*          org     $0mod_type  rmb     2          device control table addressmod_name  rmb     2          pointer to module name*MOD_SIZE  rmb     0** Device table structure*          org     0dev_addr  rmb     2          Device base addressdev_type  rmb     2          Device type tabledev_brbu  rmb     2          baudrate backup loc*DEV_SIZE  rmb     0          Size of device entry** Control structure for a device*          org     $0000          rmb     2          0D_OPEN    rmb     2          1D_CLOSE   rmb     2          2D_RQWR    rmb     2          3D_WRITE   rmb     2          4D_RQRD    rmb     2          5D_SEND    rmb     2          6D_INTRPT  rmb     2          7          rmb     2          rmb     2D_GETD    rmb     2          AD_SETD    rmb     2          B          rmb     2          CD_TTYS    rmb     2          DD_TTYG    rmb     2          ED_WRC     rmb     2          FD_inthan  rmb     2          10 Interrupt poller/handlerD_init    rmb     2          11 Device initializationD_test    rmb     2          12 Test for device present*D_END     rmb     0          End of common handlers** TTY Specific device routines*          org     D_ENDD_ttconf  rmb     2D_ttputc  rmb     2D_ttgetc  rmb     2D_ttenxr  rmb     2D_ttdisx  rmb     2D_ttenr   rmb     2D_ttenx   rmb     2D_ttenno  rmb     2D_ttxbsy  rmb     2D_tttstx  rmb     2D_ttiscts rmb     2D_tttstr  rmb     2D_tttstb  rmb     2D_tttsts  rmb     2D_tttstc  rmb     2D_tttstd  rmb     2D_tttste  rmb     2D_ttend   rmb     2D_ttwcts  rmb     2D_ttwdcd  rmb     2