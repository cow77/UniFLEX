 pag** ACIA Structure** struct acia        ifc     &a,IOPCPU        org     0        else        base    0        endifcsr rmb 1 control - statusdbuf rmb 1 data bufferbrr rmb  1  baudrate latch** status codes*AS_RDRF equ     %00000001       receive data register fullAS_TDRE equ     %00000010       transmit data register emptyAS_NDCD equ     %00000100       DCD status bit, 1 is inactiveAS_NCTS equ     %00001000       CTS bit, 1 is inactive TX IRQ offAS_FRME equ     %00010000       receive framing errorAS_OVRN equ     %00100000       receive overrunAS_PERR equ     %01000000       receive parity errorAS_IRQ  equ     %10000000       INT flag, 1 is active** control codes*AC_DIV0 equ     %00000001       counter divide bit 0 :1/:16/:64/resetAC_DIV1 equ     %00000010       counter divide bit 1AC_WS0  equ     %00000100       word select 0 7E2/7O2/7E1/7O1AC_WS1  equ     %00001000       word select 1 8N2/8N1/8E1/8O1AC_WS2  equ     %00010000       word select 2AC_TEIN equ     %00100000       transmit control 0  NRTS/NINT,NRTS/INTEAC_DRTS equ     %01000000       transmit control 1  RTS/NINT,NRTS/SBRK/NINTAC_REIN equ     %10000000       receive enable IRQ*AC_DV16 equ     %00000001       setting for clk/16AC_MRES equ     AC_DIV1+AC_DIV0 master resetAC_8N1  equ     AC_WS2+AC_WS0   select for 8N1AC_SET  equ     AC_8N1+AC_DV16  ACIA default setup