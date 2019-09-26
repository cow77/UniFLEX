   lib maphndlrs.h sttl Map and Mapping Handlers pag name map_handlers global swtchu,xmapsp,mapbuf,mapxbf,mapsbf global mapupg,mapupg2,instbf global mapspg,mapbpt,mapbf2** All routines in this file are machine dependent.* Most of them deal with the memory swapping* scheme.*** swtchu** Switch users top page*swtchu puls y get return address stb usrtop set new top page stb DATBOX+USRLOC set map reg stb sysmap+USRLOC set new system map lds umark0 reset sp's jmp 0,y do return** xmapsp** Map in new user-block which is in B.*xmapsp puls x get return address stb DATBOX+USRLOC set new user loc stb sysmap+USRLOC set in system map stb usrtop set user top too ****** ?? ******* 4-11-80 jmp 0,x return pag** mapbuf** Map a system buffer into SBUFFR space.  On* entry, x is pointing to a system buffer header.*mapbuf ldd bfxadr,x get extended part of addrmapbf2 andb #$f0 mask top 4 bits eorb DATsense make bits true sld 4 shift left 4 timesmapsbf sta DATBOX+SBUF set into sbuffr rts return** mapxbf** Map a user segment into the XBUFFR soace.*  Returns carry set if illegal page.*mapxbf cmpa BLKHOL legal page? bne 00f yes - jump pshs d,x no - blow the guy away ldb #FALTS ldx utask jsr xmtint puls d,x lda WHTHOL use a good page sec bra 01f00 clc no mapping errors01 sta DATBOX+XBUF set into xbuffr sta sysmap+XBUF save in system map copy rts return** mapspg** Map the segment in b into system space at A offset.*mapspg pshs x save x ldx #DATBOX point to datbox stb a,x set in segment puls x,pc return** mapbpt** Map in buffer in X.  Return X pointing to buffer* in SBUFFER and D has offset.*mapbpt bsr mapbuf map in buffer ldd bfadr,x get address anda #$0f mask top bits ldx #SBUFFR point to SBUFFR leax d,x point to buffer rts return** mapupg** Return the extended address bits in b which* represent the physical address of the virtual* address in D.*mapupg ldx #umem point to memory mapmapupg2 tfr a,b save a andb #$F mask low 4 bits pshs b save it lsra git segment number lsra lsra lsra ldb a,x get actual page number pshs b save it eorb DATsense lslb get back to bigh nibble lslb lslb lslb orb 1,s or in with low part stb 1,s save result puls d lsra get 4 bits only lsra lsra lsra rts return pag** instbf** Install the next available buffer into the* buffer header pointed to by Y.  Systmp points* to the current segment address and sbpag* has the current segment offset.*instbf ldx systmp point to segment lda sbpag get offset cmpa #8 end of segment? bne instb2 clr sbpag reset to 0 offset leax 1,x point to next segment stx systmp save pointerinstb2 clr bfadr+1,y low word of address is always 0 ldb 0,x get segment number clra get into machine dependent form sld 4 eorb DATsense andb #$F0 lsl sbpag orb sbpag lsr sbpag std bfxadr,y set in extended address inc sbpag bump offset byte rts return