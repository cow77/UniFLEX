*
* generic defines for unibug ROM
*
        opt        nol

* Macro definitions

seti    macro
        orcc #$50
        endm

clri    macro
        andcc #!$50
        endm

pshsw   macro
        fdb     $1038
        endm


* System equates
romadr  equ     $f800   starting rom address
hirom   equ     $fe10   start of interrupt handlers
usrvec  equ     $ffe0   user vector addresses
vector  equ     $fff0   vector addresses
romstk  equ     $be80   rom stack start
*
sysram  equ     $0100   kernel memory map table

* CPU board
datsiz  equ     1024    dat box size
datbox  equ     $f400   dat box address
cuddwn  equ     $fe01   lower hardware irq counter/fuse
k_u_map equ     $fe02   kernel/usermap select
tlatch  equ     $fe03   task select register
*

KILLI   equ     5       kill signal
FALTI   equ     7       fault signal
TIMEI   equ     9       timeout signal
DIVZRO  equ     255     divide by zero trap
ILGOPC  equ     255     illegal opcode trap

* System space segment definitions

sysseg  equ     0       system tables
txtseg  equ     5       system text
usrseg  equ     11      stack segment
bufseg  equ     12      I/O buffers
tfrseg  equ     13      transfer buffers
ioseg   equ     14      map-able IO
romseg  equ     15      rom/ basic IO

* Hard defined physical addresses

rammap  equ     $0100   8K of ram at address $00000
rommap  equ     $feff   I/O and ROM at $fe000
nomap   equ     $fd     black hole segments (void space)

DATSENSE equ    00      true DAT
BLKHOL   equ    $FD     blackhole

* Memory map definitions

segadr  equ     16      number of segments per address space
segmax  equ     256     max number of segments
segsiz  equ     4096    segment size in bytes

* monitor variables
* temp equates, vars in stack
dlen     equ     28             temp size in bytes

ascii    equ     0-dlen         ascii data buffer
segmnt   equ     16-dlen     active segment number
offset   equ     17-dlen     active segment offset
limit    equ     19-dlen     extended address limits
count    equ     22-dlen     local count field
digit    equ     23-dlen     temp
lowadr   equ     24-dlen     dump address (low addr)
hiadr    equ     26-dlen

*
* HD interface
*
brdbas0 equ     $f100               first board
brdbas1 equ     $f120               (second) board
*
bootorg equ     $0800               where boot sector will reside

* BIT defines
L_DREAD equ     %10000000           DMA read IDE, write MEM
L_DMAEN equ     %01000000           DMA enable
L_INTEN equ     %00100000           DMA/IDE IRQ enable
L_CSEL  equ     %00010000           IDE CSEL
L_ADDR  equ     %00001111           ADRESS mask

* bits in ideadr3
IDE_LBA equ     %01000000           LBA enable bit
IDE_DSL equ     %00010000           DRIVE SELECT bit

* bits in status
IDEIO16 equ     %00000001           IDE_IOCS16-
IDEIORY equ     %00000010           IDE_IORDY
IDEIRQ  equ     %00000100           IRQ to CPU
IDEDMRQ equ     %01000000           IDE_DMARQ
IDEINTR equ     %10000000           IDE_INTRQ

* bit in IDE status register
IDEBSY  equ     %10000000           busy bit
IDERDY  equ     %01000000           ready bit
IDEDSC  equ     %00010000           drive seek completed
IDEERR  equ     %00000001           error bit

* BYTE defines
IDERSTR equ     %00010000           restore disk
IDEDRD  equ     %11001000           DMA read block
IDEDWR  equ     %11001010           DMA write block


* IO defines
idedat  equ     $0              data register
ideerft equ     $2              error / feature register
idescnt equ     $4              sector count 0=256
ideadr0 equ     $6              LBA block address 0...7
ideadr1 equ     $8              LBA block address 8...15
ideadr2 equ     $a              LBA block address 16...23
ideadr3 equ     $c              LBA block address 24...27, drvsel, LBA_ENB, DRVSEL
idecmst equ     $e              status/command register
*
dmaadh  equ     $10             DMA address bits 15...8
dmaadl  equ     $11             DMA address bits 7...0
dmaltc  equ     $13             DMA address bits 19...16, CSEL, INTEN, DMAEN, DMADIR
*
idestat equ     $18             status bits, IOCS16, IORDY, DMARQ, IRQ

*
* memory
*
tstpat  equ     $99AA       memory test pattern
tstloc  equ     (tfrseg<<12)+$f0 test position
useres  equ     $0001       user resident page
sysres  equ     $0000       system resident page
LSTPAG  equ     $F7         last RAM page for test (downwards)

*
* system console
*
* terminal I/O equates
acia    equ     $f000           base address for acia

* timer / trap / lights pia
monpdra equ     $f004           data/dir/timer
monpcra equ     $f005           control/status
monpdrb equ     $f006           data/dir/lights/b
monpcrb equ     $f007           control status

PIRQMSK equ     %10000000       IRQ mask
PATIME  equ     %00000001       PIA A timer enable
PATIMR  equ     %10000000       PIA A timer bits
PBLGHT  equ     %11111111       PIA B LIGHTS
PBMTRP  equ     %10000000       PIA B memory trap

* rom functions
rrinit  equ     $f800           rom rom monitor start
rtinit    equ        $f802            rom console setup
rinchk  equ     $f804           rom console input char ready
rinch    equ        $f806            rom input character
routch  equ     $f808           rom output character
rpdata  equ     $f80a           rom print string
rhexbyt equ     $f80c           rom print hex byte
*

stkcnt	equ		$fe00			stack depth count

* kernel debugger, page $FE, at choice
DEBSIG    equ        $a55a            kernel debugger signature
dbsign    equ        $e800            if signature is there, debugger present
debnmi    equ        $e802            debugger entry for nmi
debini  equ        $e804            debugger initialisation

        opt     lis
