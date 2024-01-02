** data handling routines** translate socket register in partial address* prepares bits [7...5][4...3]* E=socket#, F=lost, B=losttsk2rg  equ     *        trfr    E,B        decb                    wzenum= 1...8, sn= 0...7*        clc                     make reg bits + '01'        rolb                    socket register        sec        rolb                    xxx 01 ...*        trfr    B,F        rts** translate socket register in final address (data xfer)* prepares bit [7...0]*tsk2tx  equ     *        trfr    E,B        decb                    wzenum= 1...8, sn= 0...7*        sec                     make reg bits + '10'        rolb                    sock TX buffer        clc        rolb*        sec        rolb                    write bit     '1'*        lslb                    variable size '00'        lslb                    xxx 10 100****        trfr    B,F        rts** translate socket register in rx buffer address (data xfer)* prepares bit [7...0]*tsk2rx  equ     *        trfr    E,B        decb                    wzenum= 1...8, sn= 0...7*        sec                     make reg bits + '11'        rolb                    sock RX buffer        sec                     make reg bits + '11'        rolb*        clc        rolb                    read bit     '0'*        lslb                    variable size '00'        lslb                    xxx 11 000***        trfr    B,F        rts** rdsk2fb, read socket data in fifo buffer* Y=sock, U=sock info* E=socket#** return, D=xferred count*RDSK2FB pshs    d,x,y,u        jsr     GSRRXRS         Received size        cmpd    wzrqln,u        has fio max size incorporated        bls     01f        ldd     wzrqln,u        mandatory size01      tfr     D,X             size        std     0,s             save xfrerred old  D        std     wzxfer,u        beq     15f             no data*        jsr     GSRRXRP        pshs    d               save socket read pointer        tfr     D,Y*        ldu     #SPIBASE        pshs    cc        pshsw        pshs    u        orcc    #$50            disable interrupts        lda     #SPI_RST+SPI_SR_+SPI_CR_+SPI_AUT set CS low        sta     spicmd,u        sty     hibyta,u        start address        jsr     tsk2rx          SOCK# to buffer address        stb     hibyta,u        ldy     #fifo        stb     hibyta,u        shift out first data byte        leau    lobyta,u        lobyte is the first byte shifted in        trfr    X,W        tfm4    U,Y        puls    u        lda     #SPI_CS_+SPI_RST+SPI_SR_+SPI_CR_        sta     spicmd,u        pulsw                   restore E:F        puls    cc*        puls    d               old read pointer        addd    0,s             adjust transferred        jsr     PSRRXRP         update pointer*15      puls    d,x,y,u,pc** wrfb2sk,write fifo buffer to socket buffer* Y=sock* E=socket#* on return D= xferred count*WRFB2SK pshs    d,x,y,u        jsr     GSRTXFR         TX free size        cmpd    wzrqln,u        has fio max size incorporated        bls     01f        ldd     wzrqln,u01      tfr     d,x        std     0,s        std     wzxfer,u        report size        beq     15f*        jsr     GSRTXWP         write pointer        pshs    d        tfr     D,Y*        ldu     #SPIBASE        pshs    cc        pshsw                   save E:F        pshs    u        orcc    #$50        lda     #SPI_RST+SPI_SR_+SPI_CR_+SPI_AUT  set CS low        sta     spicmd,u        sty     hibyta,u        start address        jsr     tsk2tx        stb     hibyta,u        ldy     #fifo        leau    hibyta,u        the first to shift out        trfr    X,W        tfm3    Y,U        puls    u        lda     #SPI_CS_+SPI_RST+SPI_SR_+SPI_CR_        sta     spicmd,u        pulsw                   restore E:F        puls    cc*        puls    d               old write pointer        addd    0,s        jsr     PSRTXWP         update pointer* tell socket we processed receive data*15      puls    d,x,y,u,pc