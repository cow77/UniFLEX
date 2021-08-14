 pag** System block io buffers** All block io is done through the system buffer* cache.  This cache consists of some fixed number* of 512 byte buffers.  These buffers are kept* in two lists, the free list, headed by 'buflst',* and the busy list, headed by the associated* device's device table.** struct bfhdr buffer header base 0bfdfl  rmb     2           device assoc list fwd linkbfdbl  rmb     2           device assoc list back linkbfffl  rmb     2           free list fwd linkbffbl  rmb     2           free list back linkbfflag rmb     1           header flags * see below *bfflg2 rmb     1           spare flags byte*bfdvn  rmb     2           device number assoc with bufferbfblch rmb     1           device block number (High)bfblck rmb     2           device block number (Mid, Low)bfxadr rmb     1           extended part of buffer address A19-A16bfadr  rmb     2           actual buffer main address      A15-A0bfxfc  rmb     2           device transfer countbfstat rmb     1           device error status*bfspr  rmb     3           spare header bytes (future use)HDRSIZ equ * size of buffer header* header flags definitionsBFALOC equ     %00000001   buffer allocated to device blockBFIOF  equ     %00000010   i/o complete flagBFERR  equ     %00000100   i/o error flagBFREQ  equ     %00001000   buffer request flagBFRWF  equ     %00010000   read/write flag (read=1)BFNOW  equ     %00100000   no wait for i/o completionBFLAT  equ     %01000000   perform i/o laterBFSPC  equ     %10000000   perform special i/o