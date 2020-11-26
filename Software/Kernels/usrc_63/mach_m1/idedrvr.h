        lib     ../include/blktab.h        pag* BIT definesL_DREAD equ     %10000000           DMA read IDE, write MEML_DMAEN equ     %01000000           DMA enableL_INTEN equ     %00100000           DMA/IDE IRQ enableL_CSEL  equ     %00010000           IDE CSELL_ADDR  equ     %00001111           ADRESS mask* bits in ideadr3IDE_LBA equ     %01000000           LBA enable bitIDE_DSL equ     %00010000           DRIVE SELECT bit* bits in statusIDEIO16 equ     %00000001           IDE_IOCS16-IDEIORY equ     %00000010           IDE_IORDYIDEINTR equ     %00000100           IDE_INTRQIDEDMRQ equ     %01000000           IDE_DMARQIDEIRQ  equ     %10000000           IRQ to CPU low=active!* bit in IDE status registerIDEBSY  equ     %10000000           busy bitIDERDY  equ     %01000000           ready bitIDEDSC  equ     %00010000           drive seek completedIDEERR  equ     %00000001           error bit* bits in sdens, assume $FF is DMA capableDRVDMA  equ     %00000000           drive can do DMADRVPIO  equ     %10000000           drive can do PIO* BYTE definesIDERSTR equ     %00010000           restore diskIDEDRD  equ     %11001000           DMA read blockIDEDWR  equ     %11001010           DMA write blockIDEPRD  equ     %00100000           PIO read blockIDEPWR  equ     %00110000           PIO write blockMAXIDE  equ     7                   max drives* IO definesidedat  equ     $0          data registerideerft equ     $2          error / feature registeridescnt equ     $4          sector count 0=256ideadr0 equ     $6          LBA block address 0...7ideadr1 equ     $8          LBA block address 8...15ideadr2 equ     $a          LBA block address 16...23ideadr3 equ     $c          LBA block address 24...27, drvsel, LBA_ENBidecmst equ     $e          status/command register*dmaadh  equ     $10         DMA address bits 15...8dmaadl  equ     $11         DMA address bits 7...0dmaltc  equ     $13         DMA address bits 19...16, CSEL, INTEN, DMAEN, DMADIR*idestat equ     $18         status bits, IOCS16, IORDY, DMARQ, IRQbasead0 equ     $f100   base address controller 0basead1        equ     $f120   base address controller 1       data