; Blizzard's Rift.
; (c) 2006/7 Jonathan Cauldwell.
; Sinclair ZX Spectrum 48K.

; Project started      20.11.2006 @ 19:10.
; Project completed    07.03.2007 @ 20:02.


; To do:

; Reorder calls to stop bullets wrapping when scrolling.


; Digby Blizzard.
; Order online on the outernet.
; Delivered by inter-dimensional Trebuchet.


; Compile this file first, then SAVE code 24000,41536.
; Then compile R1, R4 and R6, running each to create headerless
; blocks after the code file.
; R1 = USR 65520.
; R4 = USR 24000.
; R6 = USR 24000.



DRODIS equ 1               ; drone displacement (pixel speed).
MAXGUN equ 8               ; number of gun turrets per level.
MCOUNT equ 31              ; major event count.
LASTLV equ 32              ; last level.

P      equ 252             ; drone tile.
T      equ 5               ; gun turret.
A      equ 10              ; platform.
B      equ 11              ; trees.
C      equ 12
D      equ 13
E      equ 15
W      equ 14              ; bricks.
X      equ 254             ; level start position.
V      equ 253             ; black hole.
GALXY  equ 5250
;GALXY  equ 5450


CH001  equ 16425
CH002  equ 16425+32
CH003  equ 16425+64
CH004  equ 16425+96
CH005  equ 16425+128
CH006  equ 16425+160
CH007  equ 16425+192
CH008  equ 18441
CH009  equ 18441+32
CH010  equ 18441+64
CH011  equ 18441+96
CH012  equ 18441+128
CH013  equ 18441+160
CH014  equ 18441+192
CH015  equ 18441+224
CH016  equ 20489
CH017  equ 20489+32
CH018  equ 20489+64
CH019  equ 20489+96
CH020  equ 20489+128
CH021  equ 20489+160
CH022  equ 20489+192


LEVELS equ 49154
BAKPTR equ LEVELS+LASTLV*2
SYSNAM equ BAKPTR+LASTLV*2
NUMSYS equ 9               ; number of solar systems.



; map items.

TURRET equ T
PRIZE  equ 4               ; diamond.
TELEP  equ 3               ; teleporter.


; Start address to which we're compiling.
; Maximise the Spectrum's RAM by placing code at 24256.


       org 24000





; Load in RAM bank data.

       call guntab         ; ensure it's 128K.
       call ram1           ; ram 1 please.
       ld ix,49152         ; RAM bank address.
       ld de,16187         ; size of block to load.
       scf                 ; set carry flag.
       ld a,255            ; header length.
       call 1366           ; loading routine.
       call ram4           ; ram 4 please.
       ld ix,49152         ; RAM bank address.
       ld de,11739         ; size of block to load.
       scf                 ; set carry flag.
       ld a,255            ; header length.
       call 1366           ; loading block from tape.
       call ram6           ; ram 6 now.
       ld ix,49152         ; RAM bank address.
       ld de,3424          ; size of block to load.
       scf                 ; set carry flag.
       ld a,255            ; header length.
       call 1366           ; loading block from tape.
       call ram0           ; ram 0 now.


; Set up.

test   xor a               ; zero=black.
       call 8859           ; set border to black.
       ld hl,23658         ; cursor mode.
       ld (hl),8           ; set CAPS lock on.
       ld hl,23697         ; over control.
       ld (hl),3           ; set temporary and permanent XOR mode.
       ld hl,chrset-256    ; character set.
       ld (23606),hl       ; set new font.


; Main menu.
; Display options.

run    ld a,68             ; green on black.
       ld (23693),a        ; set permanent attributes.
       call 3503           ; clear attributes too.

       ld hl,22528         ; middle segment attributes.
       ld de,22529         ; next cell along.
       ld (hl),66          ; set to red on black.
       ld bc,160           ; bytes to colour.
       ldir                ; transfer attributes.

       ld hl,22720         ; middle segment attributes.
       ld de,22721         ; next cell along.
       ld (hl),70          ; set to cyan on black.
       ld bc,319           ; colour 10 lines of 32 chars.
       ldir                ; transfer attributes.

       ld de,gmtxt1        ; main menu text.
       ld bc,gmtxt2-gmtxt1 ; size of string.
       call htxt           ; display it.
       call togdis         ; display toggle status.

; Main menu loop.

       xor a               ; clear register.
       ld (23560),a        ; initialise last keypress system variable.
       ld b,250            ; delay = 10 seconds.
run0   push bc
       call random         ; mess with random number generator.
       call menkey         ; check keys.
       halt                ; no, wait for a couple
       halt                ; of interrupts.
       pop bc              ; restore loop counter.
       djnz run0           ; loop until key is pressed.

; Display high scores.

hiscrn call 3503           ; clear screen.
       call dishs          ; display high-score tables.
       xor a               ; clear register.
       ld (23560),a        ; initialise last keypress system variable.

; High score loop.

       ld b,250            ; delay = 10 seconds.
run2   push bc
       call menkey         ; menu keys.

       halt                ; no, wait for a couple
       call hsrol          ; roll high score attributes.
       halt                ; of interrupts.
       pop bc              ; restore loop counter.
       djnz run2           ; loop until key is pressed.

; Advert screen.

       call 3503           ; wipe screen clean.
       ld de,adtxt0        ; 8x8 charset text.
       ld bc,adtxt1-adtxt0 ; size of string.
       call 8252           ; display string.
       ld de,adtxt1        ; large charset text.
       ld bc,adtxt2-adtxt1 ; size of string.
       call htxt           ; display string.

       xor a               ; clear register.
       ld (23560),a        ; initialise last keypress system variable.

; Advert loop.

       ld b,250            ; delay = 10 seconds.
run3   push bc
       call menkey         ; menu keys.

       halt                ; no, wait for a couple
       halt                ; of interrupts.
       call ctwk           ; colour screen.
       pop bc              ; restore loop counter.
       djnz run3           ; loop until key is pressed.

       jp run




; Start the game.

run1   sub 49              ; 0=Keyboard, 1=Kempston joystick.
       ld (contrl),a       ; set control for game.
       call clrsc          ; screen effects.
       call 3503           ; clear screen.
       call box            ; draw box.
       call game           ; play the game.
       call clrsc          ; clear screen.
       call 3503           ; now do it properly.
       call tryhs          ; try high score table.
       jp hiscrn


menkey ld a,(23560)        ; fetch last keypress.
       cp 49               ; less than '1'?
       ret c               ; yes, nothing to do.
       cp 54               ; more than last option?
       ret nc              ; yes, nothing to do.
       pop de              ; remove return address from stack.
       pop bc              ; pop return counter.
       cp 53               ; is it '5'?
       jp z,togbg          ; toggle backgrounds.
       cp 52               ; is it '4'?
       jp z,redkey         ; option 4 - redefine keys.
       jr run1             ; options '1' to '3' start the game.


togbg  xor a               ; zero.
       ld (23560),a        ; reset keypress.
       ld a,(bgtog+1)      ; toggle value.
       xor 56              ; mask paper values.
       ld (bgtog+1),a      ; new setting.
       jp run

togdis ld a,(bgtog+1)      ; value.
       ld de,gmtxt2        ; default text.
       inc a               ; is it on?
       jr z,togd0          ; yes, display that text.
       ld de,gmtxt3        ; off text.
togd0  ld bc,gmtxt3-gmtxt2 ; length.
       jp htxt             ; show status.


; Try high score table to see if score qualifies.

tryhs  ld hl,hstab+78
       ld b,6
tryhs0 push bc
       ld de,points
       push hl             ; store position in table.
       ld b,6
tryhs3 ld a,(de)
       cp (hl)
       jr c,tryhs1         ; score is greater.
       jr nz,tryhs2        ; score is lower.
       inc hl              ; digit is the same - go to next column.
       inc de
       djnz tryhs3
       jr tryhs1           ; score is same, first one registered comes first.
tryhs2 pop hl
       ld de,65522         ; 65536 - 14.
       add hl,de           ; subtract 14 - next entry in table.
       pop bc
       djnz tryhs0
       ld hl,hstab+8

; top of table.

tryhs4 push hl
       ld de,65528
       add hl,de
       ld d,h
       ld e,l
       ld hl,hstab+84
       and a
       sbc hl,de
       ld b,h
       ld c,l
       ld hl,hstab+69
       ld de,hstab+83
       lddr
       pop hl
       ld de,points
       ex de,hl
       ld bc,6
       ldir
       ld hl,65522
       add hl,de
       ex de,hl            ; Address of name in de.
       push de
       call ent            ; enter name.
       pop de
       ld hl,buffer
       ld bc,8
       ldir
       ret
tryhs1 pop hl
       pop bc
       ld a,b
       cp 6                ; failed at bottom of table?
       ret z               ; yes - no high score then.
       ld de,14            ; next element down.
       add hl,de
       jr tryhs4           ; put in table at this point.

cwinx  defb 0
cwiny  defb 0

curon  ld hl,(txbuf)
       ld de,buffer-12
       and a
       sbc hl,de
       ld a,l
       ld (cwiny),a
       ld a,16
       ld (cwinx),a
       call atadd
       ex de,hl
       set 7,(hl)
       ld de,32
       add hl,de
       ld a,(hl)
       or 128
       ld (hl),a
       ret
curoff ld hl,(txbuf)
       ld de,buffer-12
       and a
       sbc hl,de
       ld a,l
       ld (cwiny),a
       ld a,16
       ld (cwinx),a
       call atadd
       ex de,hl
       res 7,(hl)
       ld de,32
       add hl,de
       ld a,(hl)
       and 127
       ld (hl),a
       ret
ent    call 3503           ; clear screen.
       ld de,hstxt2        ; high score text.
       ld bc,hstxt3-hstxt2
       call htxt
       ld hl,buffer        ; inputs line in buffer.
       ld (txbuf),hl
       ld de,buffer+1      ; second char of buffer.
       ld bc,7             ; 8 characters maximum.
       ld (hl),64          ; make first character a space.
       ldir                ; copy to rest of buffer.
       xor a
       ld (23560),a
ent00  call curon
       defb 33,16,12
       ld (cwinx),hl
       ld de,buffer        ; string we're typing in.
       ld bc,8             ; length = 8 chars.
       call htxt           ; display on screen.
       ld hl,23560
       ld a,(hl)
       cp 0
       jr z,ent00
       ld (hl),0
       ld c,a
       call curoff
       ld a,c
       cp 13               ; enter.
       jp z,ent13
       cp 8                ; left.
       jp z,ent08
       cp 9                ; right.
       jp z,ent09
       cp 12               ; delete.
       jp z,ent12
       cp 32
       call z,ent32        ; frig a space character.
       cp '@'              ; below space/letter 'A'?
       jr c,ent00          ; yes, don't accept.
       cp '['              ; above letter 'Z'?
       jr nc,ent00         ; yes, that's invalid.
ent00a ld a,(buffer+7)     ; last char.
       cp 64               ; is it space?
       jp nz,ent00         ; no more room on line.
       ld hl,(txbuf)
ent00b ld a,(hl)
       ld (hl),c
       ld c,a
       inc hl
       ld a,(hl)
       cp 255
       jr nz,ent00b
       ld hl,(txbuf)
       ld a,(dispy)
       cp 19
       jp z,ent00
       inc a
       ld (dispy),a
       inc hl
       ld (txbuf),hl
ent00x jp ent00
ent08  ld a,(dispy)
       cp 12
       jp z,ent00
       dec a
       ld (dispy),a
       ld hl,(txbuf)
       dec hl
       ld (txbuf),hl
       jr ent00x
ent09  ld a,(dispy)
       cp 19
       jr z,ent00x
       inc a
       ld (dispy),a
       ld hl,(txbuf)
       inc hl
       ld (txbuf),hl
       jr ent00x
ent12  ld a,(dispy)
       cp 12
       jr z,ent00x
       dec a
       ld (dispy),a
       ld hl,(txbuf)
       ld d,h
       ld e,l
       dec hl
       ld (txbuf),hl
ent12b ld a,(de)
       cp 255
       jr z,ent12a
       ld (hl),a
       inc hl
       inc de
       jr ent12b
ent12a ld (hl),64          ; space character.
       jr ent00x
ent13  ld hl,buffer        ; point to buffer.
       ld b,8              ; length.
ent13b ld a,(hl)           ; get char.
       cp 64               ; is it a space?
       jr nz,ent13a        ; no, something entered then.
       inc hl              ; next char.
       djnz ent13b         ; repeat for entire buffer.

; Oh dear, how boring.  Let's put something else in for him.

entemp ld hl,namep         ; blank name substitute.
entob0 ld de,buffer        ; text buffer.
       ld bc,8             ; number of chars to copy.
       ldir                ; copy name into buffer.
       ret

ent13a call word           ; find word in list.
       and a               ; is it recognised?
       ret z               ; no, it's okay as it is then.
       sub 2               ; is it naughty?
       jr z,entob          ; replace rudeness.
       sub 2               ; is it the cheat?
       ret nz              ; no, it's okay as it is then.
       ld a,(cheatb)       ; cheat byte.
       xor 12              ; toggle gravity on/off.
       ld (cheatb+1),a     ; set cheat mode.
       ld hl,namec         ; cheat name.
       jr entob0

entob  ld hl,name          ; obscenity substitute.
       jr entob0           ; use this name instead.


ent32  ld a,64             ; this is space char in our font.
       ld c,a              ; put it into c register as well.
       ret
buffer defb '@@@@@@@@'
       defb 255
txbuf  defw buffer         ; address of cursor in buffer.


; Check if a known word has been entered.
; On entry HL points to the buffer.

word   ld de,vocab             ; table of naughty words.
word4  ld hl,buffer            ; point to buffer.
word0  ld a,(de)               ; DE=char in vocabulary table.
       dec a
       inc de
       cp (hl)                 ; do they match?
       jr nz,word1             ; no - find next word.
       cp 254                  ; end of listed word?
       jr z,word2              ; yes - try next word in table.
       inc hl                  ; next buffer char.
       jr word0
word1  cp 254                  ; end of word?
       jr z,word5              ; yes - return verb number.
word2  ld a,(de)
       inc de
       cp 255                  ; have we reached end of word in table?
       jr nz,word2             ; no, loop round again.
       ld a,(de)               ; which word is this?
       inc de
       cp 255                  ; is it the last one?
       jr nz,word4             ; no.
       xor a                   ; return 0 (not found) in A.
       ret
word5  ld a,(de)               ; name number returned in A.
       ret

; This is the recognised naughty word list.


vocab  defb 'AAAAAAA',255,1    ; empty.
       defb 'GVDL',255,2       ; swear words.
       defb 'DVOU',255,2
       defb 'CPMMPDLT',255,2
       defb 'BSTF',255,2
       defb 'TIJU',255,2
       defb 'XBOL',255,2
       defb 'QJTT',255,2
       defb 'UXBU',255,2
       defb 'UJUT',255,2
       defb 'CGH',255,4        ; BFG cheat.
       defb 'KQN',255,4        ; JPM cheat.
       defb 255,255



game   xor a
       ld (sysno),a        ; start at first system.
       ld (oldsys),a       ; previous system.
       ld (planet),a       ; planet number.
       ld a,9              ; lives we start with.
       ld (lives),a        ; set lives.
       ld a,255            ; minus one.
       ld (lastdc),a       ; reset last level decompressed.

       ld hl,sammo         ; starting ammo.
       ld de,ammo          ; ammo.
       ld bc,5             ; digits.
       ldir                ; copy across.
       ld hl,sfuel         ; starting fuel.
       ld de,fuel          ; fuel.
       ld bc,5             ; digits.
       ldir                ; copy across.

       ld hl,plavis        ; planets visited.
       ld de,plavis+1      ; next byte.
       ld bc,32            ; number of bytes.
       ld (hl),b           ; clear first byte.
       ldir                ; clear remainder.

       ld hl,consum+1      ; fuel consumption.
       ld (hl),1           ; initial consumption is 1.
       ld hl,1024          ; initial power.
       ld (power0+1),hl    ; vertical power.
       ld (power1+1),hl    ; horizontal power.

       ld hl,score         ; score.
       ld de,score+1       ; next character.
       ld (hl),91          ; character code for zero in this font.
       ld bc,5             ; digits to copy minus one.
       ldir                ; zeroise score.
       ld hl,score         ; initialised score.
       ld de,points        ; other copy of score.
       ld bc,6             ; digits to transfer.
       ldir                ; zeroise second score.

       defb 33,'@','@'     ; two spaces.
       ld (boostl),hl      ; set default booster level.


newlev ld de,pantxt        ; panel text.
       ld bc,dfuel-pantxt  ; size of text.
       call htxt           ; show text.
       call dcraft         ; show craft remaining.
       call galax          ; galaxy selection.
       ld hl,sysno         ; new system.
       ld a,(hl)           ; get system.
       inc hl              ; old system.
       cp (hl)             ; are they different?
       call nz,travel      ; yes, need to travel there.
       call getlev         ; get level.
       ld (levnum),a       ; level number.
       cp 33               ; is it the casino?
       jp z,casino         ; yes, play that instead.
       call ram1           ; correct RAM bank.
       ld hl,LEVELS        ; list of levels.
       call levdis         ; put level pointer in de.

       ex de,hl            ; we need the answer in hl.

       call decom          ; decompress data into buffer.
       call flip           ; flip it if necessary.
       call pat            ; show background pattern.
       call ram0           ; restore bank 0.

samlev xor a
       ld (scrolc),a       ; set scroll counter.
       ld (dcount),a       ; reset "job done" counter.
       ld (pdead),a        ; player dead flag.
       ld (inxi),a         ; inertia x.
       ld (inxf),a         ; inertia x.
       ld (inyi),a         ; inertia y.
       ld (inyf),a         ; inertia y.
       ld (angle),a        ; ship's angle.
       ld (nangle),a       ; new angle.
       ld (hsleft),a       ; clear horizontal scrolling check.

       call dcraft         ; show craft remaining.

; Show next level on scanner and initialise drones.

       ld de,pandel        ; scanner clear.
       ld bc,pantxt-pandel ; size of text.
       call htxt           ; clear display.
       call initd          ; initialise the drones.
       call scdro          ; show drones on scanner.
       ld hl,(shipx)       ; ship position.
       ld (nshipx),hl      ; default next position.

       ld b,12             ; 12 columns to display.
poptil push bc
       ld de,window        ; data to scroll into window.
       ld hl,window+2      ; 16 pixels along.
       ld bc,cwndow-window ; size data to scroll.
       ldir                ; quick scroll 16 pixels.
       call tilel
       pop bc
       djnz poptil         ; repeat until tiles populate entire screen.

       ld a,(nangle)       ; new angle.
       ld (angle),a        ; ship points here now.
       ld hl,(nshipx)      ; new ship coords.
       ld (shipx),hl       ; new ship position.

       call psprit         ; display player sprite.
       call shodro         ; show the drones.
       call psprit         ; remove player sprite.
       call shodro         ; delete the drones.

       ld a,(23672)        ; clock low.
       ld (l23672),a       ; store value for delay loop.

cheatb ld a,12             ; gravity default.
       ld (gravty+1),a     ; set up gravity.
       ld hl,txfer         ; buffer screen routine.
       ld (trans+1),hl     ; set that up for shop exit routine.

       ld hl,bultab        ; bullet table.
       ld de,6
       ld b,18             ; maximum bullets player/turrets can fire + shrapnel.
init1  ld (hl),128
       add hl,de
       djnz init1

; Okay, initialisation is over so let's enter the main game loop.

       jp mloop





pscor  ld b,5              ; 5 digits to compare.
       ld hl,score         ; actual score.
       ld de,points        ; display score.
pscor3 ld a,(de)           ; fetch display score.
       cp (hl)             ; compare with actual score.
       inc hl
       inc de
       jr nz,sscor         ; increment shown score.
       djnz pscor3         ; repeat for all digits.
       ret

; Increment shown score.

sscor  ld hl,points+5      ; units column.
       ld b,5              ; increment to use.
       call uscor          ; up the display score.
       jp dscore           ; show new score.


nexlev ld hl,score         ; actual score.
       ld de,points        ; displayed score.
       ld bc,6             ; digits to transfer.
       ldir                ; copy them across.
       call dscore         ; show the score.
       ld b,50             ; delay of one second.
       call delay          ; pause.
       ld hl,dronet        ; drone table.
       ld de,dronet+1      ; next byte along.
       ld bc,31            ; gun table size minus one.
       ld (hl),c           ; reset first byte.
       ldir                ; clear rest of drone table.
       ld b,50             ; delay of one second.
       call delay          ; pause.
       call cwin           ; clear window.
       ld hl,points        ; displayed score.
       ld de,score         ; actual score.
       ld bc,6             ; digits to transfer.
       ldir                ; copy them across.

; Change system.

       jp newlev           ; restart.


; Delay loop, ensures game runs at constant speed.

haltr  ld a,(l23672)       ; last clock value.
       ld b,a
       ld a,(23672)        ; current clock value.
       sub b               ; subtract previous setting.
       add a,3
       cp 7                ; fastest speed.
       jr nc,haltr1
tfuel  ld hl,fuel+2        ; fuel digit.
       ld b,2              ; value for which to check.
       call cscor          ; check total is at least 200.
       call alert          ; warn player fuel is low.
       jr haltr

haltr1 ld a,(23672)        ; current clock value.
       ld (l23672),a       ; last clock value.
       ret

l23672 equ 23728

alert  ld a,68             ; default colour.
       jr nc,alert0        ; no trouble.
       ld a,66+128         ; red flashing.
alert0 ld hl,22786         ; cell address.
       ld de,22787
       ld (hl),a           ; set first cell colour.
       ld bc,4             ; rest of line.
       ldir
       ld hl,22786         ; top row.
       ld de,22818         ; second row.
       ld c,5              ; bytes to copy.
       ldir
       ret


; Initialise the drones and turrets.
; Analyse the level buffer for drone tiles, any we find are turned into
; empty space and a drone is generated at that point.

initd  ld hl,guntab        ; gun turret table.
       ld de,guntab+1      ; next byte along.
       ld bc,63            ; gun table size minus one.
       ld (hl),b           ; zero first byte.
       ldir                ; copy to rest of table.
       ld hl,guntab        ; gun table.
       ld (gunx),hl        ; store gun pointer.
       ld ix,dronet        ; drone pointer.
       ld hl,levbuf        ; level buffer.
       ld bc,768           ; number of tiles.
initd0 ld a,(hl)           ; get tile here.
       cp P                ; is it a drone?
       jr z,initd1         ; certainly is, create an entry for him.
       cp X                ; is it the start point?
       jr z,inits          ; initialise player's start position.
       cp T                ; is it a turret?
       jr z,initg          ; initialise gun turret.

initd3 push hl             ; store block position.
       ld a,(hl)           ; get block.
       and a               ; is it empty?
       call nz,bplot       ; no, plot block.
       pop hl              ; restore block.
initd2 inc hl              ; next tile.
       dec bc              ; tile counter.
       ld a,b              ; get high byte of counter.
       or c                ; combine with low byte.
       jr nz,initd0        ; repeat until all tiles counted.
       ret

initd1 ld (hl),0           ; clear tile.
       ld (ix),1           ; enable drone.
       ld (ix+2),l         ; tile address low.
       ld (ix+3),h         ; tile address high.
       ld (ix+4),0         ; position straddling tiles.
       ld (ix+7),224       ; put display coords out of way for now.
       push hl             ; store tile pointer.
       call random         ; fetch a random number.
       pop hl              ; restore tile pointer.
       and 3               ; want a direction 0-3.
       ld (ix+1),a         ; set drone's initial direction.
       ld de,8             ; size of drone table.
       add ix,de           ; move to next drone.
       jr initd2

initg  ex de,hl            ; store block position.
       ld hl,(gunx)        ; gun table pointer.
       ld (hl),1           ; enable turret.
       inc hl              ; angle.
       ld (hl),0           ; due north.
       inc hl              ; tile address.
       ld (hl),e           ; tile address low.
       inc hl              ; second byte.
       ld (hl),d           ; tile address high.
       inc hl              ; pointer to next entry.
       ld (gunx),hl        ; gun table pointer.
       ex de,hl            ; restore block.
       jr initd3


inits  ld (xptr),hl        ; store address of start pointer.
       xor a               ; zero.
       sub c               ; subtract row count.
       and 15              ; want result 0-15.
       push af             ; store result.
       neg                 ; make it negative.
       ld e,a              ; put into e.
       ld d,255            ; make d negative.
       push hl             ; store tile address.
       add hl,de           ; subtract row from address.
       ld de,65264         ; go back a few more columns.
       add hl,de           ; subtract that too.
       ld (levptr),hl      ; new level pointer.
       pop hl              ; restore tile address.
       ld (hl),0           ; set tile to blank space.
       pop af              ; restore row number.
       rlca                ; multiply by 16.
       rlca
       rlca
       rlca
       sub 16              ; one block up.
       ld (shipx),a        ; that's the player x coordinate.
       sub 64              ; middle of screen.
       jr nc,inits0        ; not near top so position is okay.
       xor a               ; top of level.
inits0 cp 80               ; past bottom of screen?
       jr c,inits1         ; no, we're okay.
       ld a,80             ; lowest point.
inits1 ld (viewx),a        ; set viewing vertical.
       ld a,96             ; middle of screen.
       ld (shipy),a        ; set y coord.
       jp initd3
xptr   defw 0              ; pointer to starting point.



; Generate background pattern for window.

pat    ld hl,BAKPTR        ; list of background pointers.
       call levdis         ; find displacement for level.
       ld (23728),de       ; store address temporarily.
       ld a,22             ; row counter.
       ex af,af'           ; switch to alternate set.
       ld hl,22569         ; window attributes.
pat2   ld de,(23728)       ; pointer to backgrounds.
       ld b,4              ; vertical count.
pat0   push bc
       ld b,22             ; horizontal count.
pat1   ld a,(de)           ; get source attribute.
bgtog  and 255             ; apply on/off mask.
       ld (hl),a           ; place on screen.
       inc de              ; next source byte.
       inc l               ; next screen attribute.
       djnz pat1           ; repeat for rest of row.
       ld bc,10            ; next attribute = 10 bytes along.
       add hl,bc           ; next row down.
       pop bc              ; pop row counter.
       ex af,af'           ; restore row counter.
       dec a               ; one less to do.
       ret z               ; done 'em all.
       ex af,af'           ; switch counter to alternate registers.
       djnz pat0           ; next row please.
       jp pat2             ; start pattern again.
levdis ld a,(levnum)       ; level number in a.
       rlca                ; multiply by 2.
       ld e,a              ; put sprite type in e.
       ld d,0              ; now in de.
       add hl,de           ; now pointing to a table of 2 pointers.
       ld e,(hl)           ; low byte of address.
       inc hl              ; next byte of pointer.
       ld d,(hl)           ; high byte of background address.
       ret


levptr defw 0              ; level data pointer.
sysno  defb 0              ; system we're in.
oldsys defb 0              ; previous system.

travel ld (hl),a           ; previous system.
       call wcol           ; set window colours.
       call ram4           ; page in the sub-game.
       call 49152          ; play the game.
       jp ram1             ; restore original bank.


galax  call cwin           ; clear window.
       ld hl,GALXY         ; random coordinates.
       ld b,90             ; stars to draw.
galax0 ld a,(hl)           ; x position.
       xor l
       xor b
       inc hl              ; point to next coord.
       cp 168              ; beyond range?
       jr nc,galax0        ; yes, find another.
       add a,8             ; minimum x.
       ld (dispx),a        ; set plot x.
galax1 ld a,(hl)           ; fetch y.
       xor l
       inc hl              ; point to next random position.
       cp 168              ; beyond range?
       jr nc,galax1        ; yes, find another.
       add a,72            ; minimum y.
       ld (dispy),a        ; set plot y.
       push hl             ; store pointer.
       push bc             ; remember star count.
       call splot          ; plot star.
       pop bc              ; restore count.
       pop hl              ; retrieve position pointer.
       djnz galax0
       call wcol           ; set window colour.

       ld b,NUMSYS         ; number of systems.
galax2 push bc             ; store system.
       ld a,b              ; system number.
       dec a               ; one less.
       call gsxy           ; get system x and y.
       call splot          ; plot star centre.
       ld hl,dispx         ; x position.
       inc (hl)            ; look down.
       call splot          ; plot point.
       ld hl,dispy         ; y position.
       inc (hl)            ; look right.
       call splot          ; plot point.
       ld hl,dispx         ; x position.
       dec (hl)            ; look up.
       call splot          ; plot point.
       pop bc              ; restore counter.
       djnz galax2         ; repeat for all systems.
galax4 call sysinf         ; system info.
       ld a,(sysno)        ; selected system.
       call gsxy           ; get coords.
       ld (curxy),de       ; set cursor coords.
       call dcur           ; display cursor.
       ld hl,0             ; zeroes.
       ld (curxf),hl       ; set fractions.

galax3 call joykey         ; control.
       rra                 ; right?
       jr c,mcr            ; rotate right.
       rra                 ; left?
       jr c,mcl            ; left.
       and 4               ; fire button?
       jp nz,solar         ; yes - bring up solar system.
       jr galax3

mcl    call sysinf         ; delete system info.
       ld hl,sysno         ; system number.
       dec (hl)            ; one less.
       ld a,(hl)           ; fetch system number.
       cp 255              ; past first one?
       jr nz,mcur          ; no.
       ld a,NUMSYS-1       ; last system.
       ld (hl),a           ; set new system number.
       jr mcur

mcr    call sysinf         ; delete system info.
       ld hl,sysno         ; present system.
       inc (hl)            ; one more.
       ld a,(hl)           ; fetch system number.
       cp NUMSYS           ; past last one?
       jr nz,mcur          ; no.
       xor a               ; first system.
       ld (hl),a           ; set new system number.
mcur   call gsxy           ; get system x and y.
       call mcur0
       jp galax4           ; repeat.

mcur0  ld a,(curxy)        ; current cursor x.
       ld h,a              ; integer byte.
       ld l,0              ; sign/fraction.
       ld d,e              ; new x integer.
       ld e,0              ; new x fraction.
       ex de,hl            ; switch 'em.
       call sub            ; do subtraction.
       ld de,16*256        ; integer 16.
       call div            ; divide difference by 16.
       ld (distx),hl       ; set distance x.

       ld a,(curxy+1)      ; current cursor y.
       ld h,a              ; integer byte.
       ld l,0              ; sign/fraction.
       ld a,(dispy)        ; target y.
       ld d,a              ; new y integer.
       ld e,0              ; new y fraction.
       ex de,hl            ; switch 'em.
       call sub            ; do subtraction.
       ld de,16*256        ; integer 16.
       call div            ; divide difference by 16.
       ld (disty),hl       ; set distance y.
       jp mvcur            ; move the cursor.

; Generate the solar system.

solar  call cwin           ; clear window.
       ld a,22             ; AT code.
       rst 16
       ld a,20             ; line number.
       rst 16
       ld a,10             ; column number.
       rst 16
       call ram1           ; data RAM bank.
       call dsys           ; display system name.
       ld de,systx3        ; system text.
       ld bc,systx4-systx3 ; length.
       call 8252           ; show text.
       call ram0           ; restore code RAM bank.

       xor a               ; zero in accumulator.
       ld (planet),a       ; reset selected planet.

       ld a,30             ; initial angle multiplier.
       ld (amult),a        ; set that up.
       ld ix,solxy+2       ; solar system coords.
       ld a,(sysno)        ; system number.
       ld l,a              ; low byte.
       ld h,13             ; high byte.
       ld (tmp0),hl        ; store pointer.
       call planum         ; number of planets in system.
solar0 push bc             ; store counter.
       call frand2         ; find random angle.
       push af             ; store angle.
       call sin            ; sine.
       ld a,(amult)        ; angle multiplier.
       ld h,a              ; integer.
       ld l,0              ; no sign.
       call mul            ; multiplication.
       ld de,84*256        ; x coord.
       call add            ; add integer part.
       ld (ix),h           ; set x.
       pop af              ; restore angle.
       call cos            ; cosine.
       ld a,(amult)        ; angle multiplier.
       ld h,a              ; integer.
       ld l,0              ; no sign.
       call mul            ; multiplication.
       ld de,156*256       ; y coord.
       call add            ; add integer part.
       ld (ix+1),h         ; set y.
       call frand2         ; random distance.
       and 7               ; 0 to 7.
       add a,10            ; 10 to 17.
       ld b,a              ; distance to next planet.
       ld a,(amult)        ; angle multiplier.
       add a,b             ; increment it.
       ld (amult),a        ; new value.
       inc ix              ; point to next planet.
       inc ix
       pop bc              ; restore counter.
       djnz solar0         ; repeat for all planets.

; Find planet details.

       ld a,(sysno)        ; system number.
       call sysad          ; fetch system address.

       ld (window),hl      ; store address of planet.


; Now display what we've generated.

       defb 33,88,160      ; coordinates.
       ld (dispx),hl       ; set up display position.
       ld hl,sun           ; sun image.
       call shift          ; display it.
       ld c,70             ; colour yellow.
       call csun           ; colour the sun.
       call planum         ; planets.
       ld ix,solxy+2       ; coordinates.
solar1 push bc             ; counter.
       ld a,(ix)           ; x coordinate.
       sub 6
       ld (dispx),a        ; set display coord.
       ld a,(ix+1)         ; y coord.
       sub 7
       ld (dispy),a        ; set display coord.


       ld hl,(window)      ; address of planet.
       ld a,(hl)           ; planet number.
       inc hl              ; point to next one.
       ld (window),hl      ; next planet.
       call getvis         ; visited it yet?
       ld a,(hl)           ; whether visited or not.
       ld hl,plgfx         ; virgin planet image.
       and a               ; zero means no.
       jr z,solar4         ; not visited yet.
       ld hl,plgfx+32      ; visited planet image.

solar4 call shift          ; draw planet.
       pop bc              ; restore counter from stack.
       inc ix              ; point to next planet.
       inc ix
       djnz solar1         ; rest of them.

       ld de,systx2        ; text.
       ld bc,systx3-systx2 ; length.
       call 8252           ; display it.
       xor a               ; planet.
       ld (planet),a       ; store planet number.

solar2 call dpln           ; display planet name.
       ld a,(planet)       ; selected system.
       call gpxy           ; get coords.
       ld (curxy),de       ; set cursor coords.
       call dcur           ; display cursor.
       ld hl,0             ; zeroes.
       ld (curxf),hl       ; set fractions.

solar3 call joykey         ; control.
       rra                 ; right?
       jr c,mcpr           ; rotate right.
       rra                 ; left?
       jr c,mcpl           ; left.
       and 4               ; fire button?
       jp nz,mplf          ; yes - planet selected.
       jr solar3

mcpl   call dpln           ; display planet name.
       call planum         ; number of planets.
       ld hl,planet        ; planet number.
       dec (hl)            ; one less.
       ld a,(hl)           ; fetch planet number.
       cp 255              ; past first one?
       jr nz,mplc          ; no.
       ld a,b              ; planet number.
       ld (hl),a           ; set new planet number.
       jr mplc

mcpr   call dpln           ; display planet name.
       call planum         ; number of planets.
       inc b               ; add one for exit.
       ld hl,planet        ; present planet.
       inc (hl)            ; one more.
       ld a,(hl)           ; fetch system number.
       cp b                ; past last one?
       jr nz,mplc          ; no.
       xor a               ; first system.
       ld (hl),a           ; set new system number.
mplc   call gpxy           ; get planet x and y.
       call mcur0          ; move cursor.
       jp solar2           ; repeat.

mplf   ld hl,planet        ; planet number.
       ld a,(hl)           ; fetch planet.
       and a               ; exit?
       jp z,mplf0          ; yes.
       dec (hl)            ; planets start at zero.
       ret

mplf0  ld c,71             ; colour.
       call csun           ; colour the sun.
       jp galax

csun   ld hl,22900         ; attributes.
       ld (hl),c           ; set colour.
       inc l               ; next cell.
       ld (hl),c           ; set colour.
       ld l,148            ; next cell down.
       ld (hl),c           ; set colour.
       inc l               ; next cell.
       ld (hl),c           ; set colour.
       ret


frand2 ld hl,(tmp0)        ; pointer.
       ld a,(hl)           ; fetch byte there.
       inc hl
       ld (tmp0),hl        ; store pointer.
       ret





mvcur  ld b,15             ; number of steps.
mvcur0 push bc
       halt                ; wait.
       call dcur           ; delete cursor.
       ld a,(curxy)        ; cursor x.
       ld h,a              ; integer part.
       ld a,(curxf)        ; x fraction.
       ld l,a              ; fraction part.
       ld de,(distx)       ; x distance.
       call add            ; next position.
       ld a,l              ; fraction.
       ld (curxf),a        ; new fraction.
       ld a,h              ; integer.
       ld (curxy),a        ; new integer.
       ld (dispx),a        ; display coord.
       ld a,(curxy+1)      ; cursor y.
       ld h,a              ; integer part.
       ld a,(curyf)        ; y fraction.
       ld l,a              ; fraction part.
       ld de,(disty)       ; y distance.
       call add            ; next position.
       ld a,l              ; fraction.
       ld (curyf),a        ; new fraction.
       ld a,h              ; integer.
       ld (curxy+1),a      ; new integer.
       ld (dispy),a        ; display coord.
       call dcur           ; display cursor.
       pop bc              ; restore counter.
       djnz mvcur0         ; repeat.
       halt                ; delay.
       jp dcur             ; delete cursor.

sysinf call ram1
       ld de,systx0        ; text.
       ld bc,systx1-systx0 ; length.
       call 8252           ; display it.
       call dsys           ; display system name.
sysin0 ld de,systx1        ; more text.
       ld bc,systx2-systx1 ; length of string.
       call 8252           ; display it.
       call planum         ; find number of planets.
       ld a,'0'            ; ASCII zero.
       add a,b             ; find digit.
       rst 16              ; display it.
       jp ram0

; Display system name.

dsys   ld a,(sysno)        ; system.
       rlca                ; multiple of 2.
       ld e,a              ; low byte.
       ld d,0              ; no high byte.
       ld hl,SYSNAM        ; name pointers.
       add hl,de           ; point to name.
       ld e,(hl)           ; low byte.
       inc hl              ; point to high byte.
       ld d,(hl)           ; high byte.
       ex de,hl            ; want the address in hl.
dsys0  ld a,(hl)           ; letter.
       and a               ; end of string?
       ret z               ; yes.
       rst 16              ; display char.
       inc hl              ; next one.
       jr dsys0

; Display planet name.

dpln   ld de,systx4        ; AT code.
       ld bc,3             ; 3 chars.
       call 8252           ; set coords.
       ld a,(sysno)        ; system.
       call sysad          ; get system address.
       ld a,(planet)       ; planet number.
       and a               ; exit?
       ret z               ; yes, nothing to display.
       dec a               ; one less for actual planet.
       ld d,0              ; no high byte.
       ld e,a              ; displacement.
       add hl,de           ; point to planet.
       call ram1           ; page in the data.
       ld a,(hl)           ; planet number.
       ld hl,(49152)       ; planet names.
       call getwrd         ; find name in null-separated list.
dpln0  ld a,(hl)           ; letter.
       and a               ; null terminator?
       jp z,ram0           ; yes, job done.
       inc hl              ; point to next one.
       rst 16              ; display letter.
       jr dpln0


; On entry: hl points to word list
;           a contains word number.

getwrd and a               ; first word in list?
       ret z               ; yep, don't search.
       ld b,a              ; words to skip.
getwd0 ld a,(hl)           ; get character.
       inc hl              ; next letter.
       and a               ; found end?
       jr nz,getwd0        ; no, carry on.
       djnz getwd0         ; until we have right number.
       ret



sysad  rlca                ; multiple of 2.
       ld e,a              ; low byte.
       ld d,0              ; zero displacement high byte.
       ld hl,sysptr        ; system pointer.
       add hl,de           ; point to system package.
       ld e,(hl)           ; low byte of address.
       inc hl              ; point to high byte.
       ld d,(hl)           ; fetch high byte.
       ex de,hl            ; pointer in hl please.
       ret



systx0 defb 22,20,10,16,7
       defb 'SYSTEM:'
systx1 defb 22,21,10
       defb 'PLANETS:'
systx2 defb 22,2,10,16,3,127,16,7
systx3 defb ' SYSTEM'
systx4 defb 22,21,10

dcur   ld hl,(curxy)       ; coords.
       ld de,1798          ; x=7, y=7.
       and a               ; clear carry flag.
       sbc hl,de           ; subtract pixels from x and y.
       ld (dispx),hl       ; coordinates.
       ld hl,crosh         ; cursor graphics.
       jr shift            ; sprite.



; Unshifted sprite routine.
; On entry HL must point to the unshifted sprite data.

shift7 xor 7               ; complement last 3 bits.
       inc a               ; add one for luck!
shift3 rl d                ; rotate left...
       rl c                ; ...into middle byte...
       rl e                ; ...and finally into left character cell.
       dec a               ; count shifts we've done.
       jr nz,shift3        ; return until all shifts complete.

; Line of sprite image is now in e + c + d, we need it in form c + d + e.

       ld a,e              ; left edge of image is currently in e.
       ld e,d              ; put right edge there instead.
       ld d,c              ; middle bit goes in d.
       ld c,a              ; and the left edge back into c.
       jr shift0           ; we've done the switch so transfer to screen.

shift  ex de,hl            ; put sprite address into de.
       call scadd          ; calculate screen address.
       ex de,hl            ; screen in de, sprite in hl.
       ld a,16             ; height of sprite in pixels.
shift1 ex af,af'           ; store loop counter.
       push de             ; store screen address.
       ld c,(hl)           ; first sprite graphic.
       inc hl              ; increment poiinter to sprite data.
       ld d,(hl)           ; next bit of sprite image.
       inc hl              ; point to next row of sprite data.
       ld (tmp0),hl        ; store in tmp0 for later.
       ld e,0              ; blank right byte for now.
       ld a,(dispy)        ; y position.
       and 7               ; how are we straddling character cells?
       jr z,shift0         ; we're not straddling them, don't bother shifting.
       cp 5                ; 5 or more right shifts needed?
       jr nc,shift7        ; yes, shift from left as it's quicker.
       and a               ; oops, carry flag is set so clear it.
shift2 rr c                ; rotate left byte right...
       rr d                ; ...through middle byte...
       rr e                ; ...into right byte.
       dec a               ; one less shift to do.
       jr nz,shift2        ; return until all shifts complete.
shift0 pop hl              ; pop screen address from stack.
       ld a,(hl)           ; what's there already.
       xor c               ; merge in image data.
       ld (hl),a           ; place onto screen.
       inc l               ; next character cell to right please.
       ld a,(hl)           ; what's there already.
       xor d               ; merge with middle bit of image.
       ld (hl),a           ; put back onto screen.
       inc hl              ; next bit of screen area.
       ld a,(hl)           ; what's already there.
       xor e               ; right edge of sprite image data.
       ld (hl),a           ; plonk it on screen.
       ld a,(dispx)        ; vertical coordinate.
       inc a               ; next line down.
       ld (dispx),a        ; store new position.
       and 63              ; are we moving to next third of screen?
       jr z,shift4         ; yes so find next segment.
       and 7               ; moving into character cell below?
       jr z,shift5         ; yes, find next row.
       dec hl              ; left 2 bytes.
       dec l               ; not straddling 256-byte boundary here.
       inc h               ; next row of this character cell.
shift6 ex de,hl            ; screen address in de.
       ld hl,(tmp0)        ; restore graphic address.
       ex af,af'           ; restore loop counter.
       dec a               ; decrement it.
       jp nz,shift1        ; not reached bottom of sprite yet to repeat.
       ret                 ; job done.
shift4 ld de,30            ; next segment is 30 bytes on.
       add hl,de           ; add to screen address.
       jp shift6           ; repeat.
shift5 ld de,63774         ; minus 1762.
       add hl,de           ; subtract 1762 from physical screen address.
       jp shift6           ; rejoin loop.

crosh  defb 32,4,96,6,240,15,48,12,8,16,0,0,0,0,0,0
       defb 0,0,0,0,0,0,8,16,48,12,240,15,96,6,32,4
sun    defb 7,224,31,248,63,252,127,254,127,254,255,255,255,255,255,255
       defb 255,255,255,255,255,255,127,254,127,254,63,252,31,248,7,224
plgfx  defb 0,0,0,0,0,0,0,0,1,128,7,224,7,224,15,240
       defb 15,240,7,224,7,224,1,128,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,1,128,6,96,4,32,8,16
       defb 8,16,4,32,6,96,1,128,0,0,0,0,0,0,0,0



framec defb 0              ; general purpose frame counter.
tmp0   defw 0              ; general purpose.
firefl defb 0              ; fire debounce flag.
curxy  equ 23728           ; cursor coords.
curxf  defb 0              ; cursor x/y fractions.
curyf  defb 0
distx  defw 0              ; x distance.
disty  defw 0              ; y distance.
amult  equ disty           ; angle multiplier - used to generate orbits.
planet defb 0              ; current planet.



; Get planet display coords.

gpxy   ld hl,solxy         ; system coords.
       jr gdxy

; Get system display coords.

gsxy   ld hl,sysxy         ; system coords.

; Get display coords.

gdxy   rlca                ; multiple of 2.
       ld e,a              ; low byte in e.
       ld d,0              ; no high byte.
       add hl,de           ; point to coords.
       ld e,(hl)           ; x coord.
       inc hl              ; point to y.
       ld d,(hl)           ; y coord.
       ld (dispx),de       ; set display coords.
       ret


; Window attribute colours.

wcol   ld hl,22569         ; address of window attributes.
       ld b,22             ; number of attribute cell lines.
wcol0  push bc             ; store main loop counter.
       ld b,22             ; number of columns.
wcol1  ld (hl),71          ; set attribute.
       inc hl              ; next attribute position.
       djnz wcol1          ; repeat for rest of line.
       ld de,10            ; bytes to end of row.
       add hl,de           ; start at beginning of next row.
       pop bc              ; row count.
       djnz wcol0          ; repeat for all lines.
       ret


; Point to level data.

getlev ld a,(sysno)        ; system number.
       rlca                ; multiple of 2.
       ld e,a              ; low byte.
       ld d,0              ; zero displacement high byte.
       ld hl,sysptr        ; system pointer.
       add hl,de           ; point to system package.
       ld e,(hl)           ; low byte of address.
       inc hl              ; point to high byte.
       ld d,(hl)           ; fetch high byte.
       ld a,(planet)       ; planet within system.
       ld l,a              ; low byte of displacement.
       ld h,0              ; zero high byte.
       add hl,de           ; point to level number.
       ld a,(hl)           ; level number in accumulator.
       ret

; Return number of planets in b.

planum ld a,(sysno)        ; system number.
       rlca                ; multiple of 2.
       ld e,a              ; low byte.
       ld d,0              ; zero displacement high byte.
       ld hl,sysptr        ; system pointer.
       add hl,de           ; point to system package.
       ld e,(hl)           ; low byte of address.
       inc hl              ; point to high byte.
       ld d,(hl)           ; fetch high byte.
       ex de,hl            ; pointer in hl please.
       ld b,0              ; start with no planets.
planm0 ld a,(hl)           ; planet here?
       cp 255              ; 255 means end of list.
       ret z
       inc hl              ; next one in list.
       inc b               ; increment counter.
       jr planm0


; Get address of planet visited flag.

getvis ld hl,plavis        ; planets visited.
       ld e,a              ; displacement to flag.
       ld d,0              ; no high byte.
       add hl,de           ; point to flag.
       ret


       ; ----- System packages -----

sysptr defw syst0,syst1,syst2,syst3,syst4,syst5
       defw syst6,syst7,syst8
sysxy  defb 22,182
       defb 64,228
       defb 144,172
       defb 128,121
       defb 112,102
       defb 92,154
       defb 68,120
       defb 44,88
       defb 19,91

syst0  defb 3,1,24,16,255
syst1  defb 2,5,6,30,15,255
syst2  defb 4,8,9,31,255
syst3  defb 7,10,11,255
syst4  defb 12,13,14,17,255
syst5  defb 18,19,20,255
syst6  defb 21,22,23,0,255
syst7  defb 25,26,27,28,29,255
syst8  defb 33,255

solxy  defb 18,83,0,0,0,0,0,0,0,0,0,0

; Planets visited.

plavis defw 0,0,0,0,0,0,0,0
       defw 0,0,0,0,0,0,0,0
       defw 0
endvis equ $

       ; ----- End of packages -----



shop   call cwin           ; clear window.
       call shopm          ; do the shop stuff.
       call cwin           ; clear window.
       call trans          ; restore screen.
       jp pause1           ; rejoin pause routine.

shopm  ld de,shptxt        ; text.
       ld bc,shpend-shptxt ; length.
       call htxt           ; show text.
       ld a,4              ; last option - exit.
       ld (shopop),a       ; set default option.
shop2  call dbar           ; show bar.
       call debfir         ; debounce.
shop0  call joykey         ; control routines.
       and a               ; anything pressed?
       jr z,shop0          ; no.
       call dbar           ; show bar.
       ld a,(joyval)       ; value returned.
       and 16              ; fire?
       jr nz,shop1         ; okay, see what player wants.
       ld a,(joyval)       ; reading.
       rra                 ; right?
       jr c,shopr          ; move down.
       rra                 ; left?
       jr c,shopl          ; move up.
       jr shop2

shop1  call debfir         ; debounce fire.
       ld a,(shopop)       ; option selected.
       cp 4                ; exit?
       ret z               ; yes - back to pause routine.
       and a               ; ammo?
       jr z,shopam         ; add ammo.
       cp 1                ; fuel?
       jp z,shopfu         ; refuel.
       cp 2                ; ship?
       jr z,shoplf         ; add ship.
       cp 3                ; booster rockets?
       jr z,shopbs         ; add boosters.
       jp shop2            ; rejoin.

shopl  ld a,(shopop)       ; option.
       and a               ; zero already?
       jr z,shop2          ; can't go up so rejoin routine.
       dec a               ; go up.
       ld (shopop),a       ; new setting.
       jr shop2

shopr  ld a,(shopop)       ; option.
       cp 4                ; at bottom already?
       jr z,shop2          ; can't go down so rejoin routine.
       inc a               ; go down.
       ld (shopop),a       ; new setting.
       jr shop2

shopam ld hl,score+3       ; money.
       ld b,1              ; amount to reduce.
       call cscor          ; check there's enough cash.
       jp c,shop2          ; can't afford it.
       ld hl,score+3       ; money.
       call rscor          ; subtract cash.
       ld hl,ammo+3        ; ammunition.
       ld b,5              ; increment.
       call uscor          ; up the supply.
       call tmoney         ; transfer money.
       call dammo          ; show ammo.
       call dscore         ; show money.
       jr shop2

shoplf ld hl,score+2       ; money.
       ld b,1              ; amount to reduce.
       call cscor          ; check there's enough cash.
       jp c,shop2          ; can't afford it.
       ld hl,score+2       ; money.
       call rscor          ; subtract cash.
       ld hl,lives         ; lives.
       inc (hl)            ; one more.
shoprj call tmoney         ; transfer money.
       ld de,pantxt        ; panel text.
       ld bc,dfuel-pantxt  ; size of text.
       call htxt           ; show text.
       call dcraft         ; show lives remaining.
       jp shop2

shopbs ld a,(consum+1)     ; fuel consumption.
       cp 3                ; reached maximum?
       jp nc,shop2         ; yes, can't extend.
       ld hl,score+2       ; money.
       ld b,1              ; amount to reduce.
       call cscor          ; check there's enough cash.
       jp c,shop2          ; can't afford it.
       ld hl,score+2       ; money.
       call rscor          ; subtract cash.
       ld hl,consum+1      ; fuel consumption.
       ld a,(hl)           ; current level.
       inc (hl)            ; increase fuel consumption.
       ld hl,power0+2      ; vertical power.
       dec (hl)            ; increase it.
       ld hl,power1+2      ; horizontal power.
       dec (hl)            ; increase it.
       ld e,a              ; consumption level.
       ld d,0              ; zero in high byte of de.
       ld hl,boostl-1      ; booster indicator.
       add hl,de           ; point to text indicator.
       ld (hl),104         ; set a plus sign.
       ld de,bsttxt        ; text.
       ld bc,shpend-bsttxt ; length.
       call htxt           ; show text.
       jr shoprj

shopfu ld hl,score+3       ; money.
       ld b,2              ; amount to reduce.
       call cscor          ; check there's enough cash.
       jp c,shop2          ; can't afford it.
       ld hl,score+3       ; money.
       call rscor          ; subtract cash.
       ld hl,fuel+1        ; ammunition.
       ld b,1              ; increment.
       call uscor          ; up the supply.
       call tmoney         ; transfer money.
       call dfuel          ; show fuel.
       call tfuel          ; test fuel not below limit.
       call dscore         ; show money.
       jp shop2


; Transfer money from bank to visible amount.

tmoney ld hl,score         ; bounty remaining.
       ld de,points        ; amount shown.
       ld bc,6             ; digits to transfer.
       ldir                ; copy across.

debfir call joykey         ; get keyboard/joystick status.
       and a               ; check reading.
       jr nz,debfir        ; something moved, wait for release.
       ret


shptxt defb 22,2,18
       defb 'SHOP'
       defb 22,6,13
       defb 'LASERS@@@@@\[['
       defb 22,8,13
       defb 'FUEL@@@@@@@][['
       defb 22,10,13
       defb 'SHIP@@@@@@\[[['
bsttxt defb 22,12,13
       defb 'BOOSTER'
boostl defb '@@@\[[['
       defb 22,14,18
       defb 'DONE'
shpend equ $


; Display bar.
; Won't work for x coordinates where text straddles segments.

dbar   ld a,(shopop)       ; selected option.
       rlca                ; multiply by 2.
       add a,6             ; add 6.
       ld (cwinx),a        ; vertical position.
       ld a,12             ; horizontal.
       ld (cwiny),a        ; set position.
       call chadd          ; find character address.
       ex de,hl            ; result in hl please.
       ld b,16             ; width.
       ld de,32            ; distance to second half of char.
dbar1  push bc             ; push counter.
       push hl             ; store screen address.
       ld b,8              ; vertical lines in a char.
dbar0  ld a,(hl)           ; get screen image.
       cpl                 ; reverse all bits.
       ld (hl),a           ; new screen image.
       add hl,de           ; down to second half.
       ld a,(hl)           ; fetch image.
       cpl                 ; reverse all bits.
       ld (hl),a           ; write new image.
       sbc hl,de           ; back to top position again.
       inc h               ; next line down.
       djnz dbar0          ; repeat for 8 lines.
       pop hl              ; restore screen address.
       inc hl              ; next one along.
       pop bc              ; width counter.
       djnz dbar1          ; repeat.
       ret





; Clear window animation.

cwin   ld b,8              ; times to scroll.
cwin3  push bc             ; line counter.
       defb 33,8,72        ; pixel coords of window.
       ld (cwinx),hl       ; set up coords for display.
       ld b,22             ; lines to do.
cwin2  push bc             ; line counter.
       call scadd2         ; calculate address.
       ld b,8              ; pixel lines.
cwin1  push bc             ; store pixel count.
       push hl             ; store screen address.
       ld b,22             ; width of window.
cwin0  and a               ; clear carry.
       rr (hl)             ; rotate pixels.
       inc l               ; next cell.
       djnz cwin0          ; repeat for rest of pixel line.
       pop hl              ; restore address of line.
       inc h               ; one pixel line down.
       pop bc              ; restore pixel count.
       djnz cwin1          ; do rest of pixels within char.
       pop bc              ; height counter.
       ld a,(cwinx)        ; x coord.
       add a,8             ; look down.
       ld (cwinx),a        ; next value.
       djnz cwin2          ; do rest of lines.
       halt                ; short delay.
       pop bc              ; iterations.
       djnz cwin3          ; repeat animation.
       ret



sammo  defb '[[\[['        ; starting ammo.
sfuel  defb '[\[[['        ; starting fuel.

pandel defb 22,21,0        ; scanner clearing text.
       defb '@@@@@@@'

pantxt defb 22,1,1
       defb 'CREDIT'
       defb 22,3,1
points defb '[[[[[['
       defb 22,6,3
       defb 'FUEL'
       defb 22,11,1
       defb 'LASERS'
       defb 22,16,2
       defb 'SHIPS'
       defb 22,18,5
ships  defb '[['
       defb 22,8,2
fuel   defb '[\[[['
       defb 22,13,2
ammo   defb '[[\[['


; Fuel display routine.

dfuel  ld de,fuel-3        ; point to fuel position control codes.
       ld bc,8             ; digits to display.
       jr htxt             ; show digits.

; Ammo display routine.

dammo  ld de,ammo-3        ; point to fuel position control codes.
       ld bc,8             ; digits to display.
       jr htxt             ; show digits.

; Craft remaining display routine.

dcraft ld hl,ships         ; ships tens column.
       ld a,(lives)        ; lives.
       cp 10               ; 10 or more?
       jr c,dcrft0         ; no.
       ld (hl),'\'         ; code for '1'.
       sub 10              ; subtract lives.
dcrft0 inc hl              ; point to units.
       add a,'['           ; code for digit zero.
       ld (hl),a           ; set digit.
       ld de,ships-3       ; point to fuel position control codes.
       ld bc,5             ; length.
       jr htxt             ; show digits.

; Score display routine.

dscore ld de,points-3      ; point to score.
       ld bc,9             ; digits to display.

; Now drop through into htxt routine.

; This routine displays double-height text straddling 2 rows.
; The top half of each character is displayed on one row, the bottom
; half on the next.  This means that each half can be a different colour.

htxt   push de
       push bc
       ld a,(htxtf)        ; are we in process of fixing coords?
       cp 0
       jr nz,htxt1         ; yes - this byte is a coord, not a char.
       ld a,(de)           ; get next byte to display.
       cp 22               ; is this the @ byte?
       jr z,htxt0          ; yes - set flag.
       cp 8                ; backspace?
       jr z,htxt5          ; yes - set coords.
       call hchr           ; display it.
htxt4  pop bc
       pop de
       inc de              ; next character in string.
       dec bc
       ld a,b
       or c
       jr nz,htxt          ; more to display.
       ret

htxt0  ld a,2              ; next 2 bytes are coordinates.
       ld (htxtf),a
       jr htxt4

htxt1  cp 2                ; x coord?
       jr z,htxt3
       ld a,(de)
       ld (cwiny),a        ; set y coord.
htxt2  ld a,(htxtf)        ; decrement flag.
       dec a
       ld (htxtf),a
       jr htxt4
htxt3  ld a,(de)
       ld (cwinx),a        ; set x coord.
       jr htxt2

htxt5  ld a,(cwiny)        ; current y coord.
       cp 0                ; at left edge already?
       jr z,htxt4          ; yes - can't go back further.
       dec a               ; back one char.
       ld (cwiny),a
       jr htxt4

hchr   ld hl,font-1024     ; font, minus displacement for first character.
       rlca                ; multiply char code by 16.
       rlca
       rlca
       rlca
       ld e,a              ; put in e for now.
       and 7               ; just want the high bits.
       ld d,a              ; got high byte of character displacement.
       ld a,e              ; restore all bits again.
       and 248             ; just want low bits this time.
       ld e,a              ; result in de.
       add hl,de           ; add displacement for font.
       call chadd          ; screen address in de.
       ld b,8              ; 8 lines to display.
hchr0  ld a,(hl)           ; fetch source byte.
       ld (de),a           ; dump to screen.
       inc hl
       inc d               ; move down one pixel.
       djnz hchr0          ; repeat for top half of character.
       ld a,(cwinx)        ; vertical print position.
       inc a               ; one character down.
       ld (cwinx),a        ; store new coordinate.
       call chadd          ; screen address for bottom half in de.
       ld b,8              ; 8 bytes to display.
hchr1  ld a,(hl)           ; get font image.
       ld (de),a           ; apply to screen.
       inc d               ; next pixel line.
       inc hl              ; next source byte.
       djnz hchr1          ; repeat for bottom half.
       ld hl,cwinx         ; restore vertical coordinate.
       dec (hl)            ; move it up.
       inc hl              ; horizontal position of cursor.
       inc (hl)            ; one char to right.
       ret

htxtf  defb 0

; Calculate screen address from x and y coordinates.

chadd  ld a,(cwinx)        ; x coordinate.
       ld e,a              ; store away in e register.
       and 24              ; mask away all but the segment bits.
       add a,64            ; add to screen start address.
       ld d,a              ; put into high byte of address.
       ld a,e              ; get x coord again.
       rrca                ; multiply by 32.
       rrca                ; 3 rrcas faster than 5 rlcas.
       rrca
       and 224             ; make it a multiple of 32.
       ld e,a              ; put result in low byte.
       ld a,(cwiny)        ; fetch y coordinate.
       add a,e             ; add to low byte already have.
       ld e,a              ; address now in de.
       ret


font   defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

       defb 124,254,254,238,238,238,238,238
       defb 238,254,254,254,238,238,238,0
       defb 252,254,254,238,238,238,254,252
       defb 254,238,238,238,254,254,252,0
       defb 56,124,254,238,224,224,224,224
       defb 224,224,224,238,254,124,56,0
       defb 240,248,252,252,238,238,238,238
       defb 238,238,238,238,254,254,252,0
       defb 126,254,254,224,224,224,252,252
       defb 252,224,224,224,254,254,126,0
       defb 124,254,254,238,224,224,252,252
       defb 252,224,224,224,224,224,224,0
       defb 56,124,254,238,224,224,224,238
       defb 238,238,238,238,254,126,62,0
       defb 238,238,238,238,238,238,254,254
       defb 254,238,238,238,238,238,238,0
       defb 124,124,124,56,56,56,56,56
       defb 56,56,56,56,124,124,124,0

       defb 14,14,14,14,14,14,14,14
       defb 14,14,14,30,254,252,248,0
       defb 238,238,238,238,254,252,248,240
       defb 248,252,254,238,238,238,238,0
       defb 224,224,224,224,224,224,224,224
       defb 224,224,224,224,254,254,254,0
       defb 238,254,254,254,254,254,254,254
       defb 254,238,238,238,238,238,238,0
       defb 252,254,254,238,238,238,238,238
       defb 238,238,238,238,238,238,238,0
       defb 56,124,254,254,238,238,238,238
       defb 238,238,238,254,254,124,56,0
       defb 248,252,254,238,238,238,238,238
       defb 254,252,248,224,224,224,224,0
       defb 56,124,254,238,238,238,238,238
       defb 238,238,238,240,254,126,62,0
       defb 248,252,254,238,238,238,238,238
       defb 254,252,248,252,254,238,238,0

       defb 124,254,254,238,224,240,248,124
       defb 62,30,14,238,254,254,124,0
       defb 254,254,254,56,56,56,56,56
       defb 56,56,56,56,56,56,56,0
       defb 238,238,238,238,238,238,238,238
       defb 238,238,238,238,254,254,124,0
       defb 238,238,238,238,238,238,238,238
       defb 254,124,124,56,56,16,16,0
       defb 238,238,238,238,226,234,234,234
       defb 234,234,238,254,254,254,124,0
       defb 238,238,238,254,254,254,124,56
       defb 124,254,254,254,238,238,238,0
       defb 238,238,238,238,238,238,126,124
       defb 60,56,120,112,240,224,224,0
       defb 254,254,254,30,28,60,60,56
       defb 120,120,112,240,254,254,254,0
       defb 56,124,254,238,238,238,238,238
       defb 238,238,238,238,254,124,56,0

       defb 56,56,120,120,120,56,56,56
       defb 56,56,56,56,124,124,124,0
       defb 56,124,254,238,238,14,30,60
       defb 120,240,224,238,254,254,254,0
       defb 56,124,254,238,14,30,60,56
       defb 60,30,14,238,254,124,56,0
       defb 28,28,56,56,112,110,238,254
       defb 254,254,14,14,14,14,14,0
       defb 254,254,254,224,224,252,254,254
       defb 14,14,14,238,254,124,56,0
       defb 60,124,124,240,224,248,252,252
       defb 238,238,238,238,124,124,56,0
       defb 254,254,254,14,14,14,30,28
       defb 28,60,56,56,56,56,56,0
       defb 56,124,254,238,238,254,254,124
       defb 254,238,238,254,254,124,56,0
       defb 56,124,124,238,238,238,238,126
       defb 126,62,14,30,124,124,120,0

       defb 56,56,120,112,112,224,224,224,224,224,112,112,120,56,56,0
       defb 56,56,60,28,28,14,14,14,14,14,28,28,60,56,56,0
       defb 0,56,56,56,0,0,0,0
       defb 0,0,0,0,0,0,0,0

       defb 0,0,0,56,56,56,254,254,254,56,56,56,0,0,0,0


; Test for pause key.
; Pause mode.

pause  ld a,(keys+4)       ; pause key.
       call ktest          ; has it been pressed?
       ret c               ; no.
       ld hl,(23672)       ; get clock.
       push hl             ; store clock value.
       ld a,1              ; blue.
       out (254),a         ; set border colour.
pause0 ld a,(keys+4)       ; pause key.
       call ktest          ; has it been pressed?
       jr nc,pause0        ; wait until pause key is released.
pause1 call joykey         ; control.
       and 16              ; fire button.
       jp nz,shop          ; let's go shopping.
       ld a,(keys+4)       ; pause button.
       call ktest          ; pressed it yet?
       jr c,pause1         ; pause game until pause key pressed.
pause2 ld a,(keys+4)
       call ktest
       jr nc,pause2        ; wait until pause key is released.
       xor a               ; zero = black.
       out (254),a         ; set border colour.
       pop hl              ; restore clock value.
       ld (23672),hl       ; restore clock.
       ret

; Key test routine.

ktest  ld c,a              ; key to test in c.
       and 7               ; mask bits d0-d2 for row.
       inc a               ; in range 1-8.
       ld b,a              ; place in b.
       srl c               ; divide c by 8
       srl c               ; to find position within row.
       srl c
       ld a,5              ; only 5 keys per row.
       sub c               ; subtract position.
       ld c,a              ; put in c.
       ld a,254            ; high byte of port to read.
ktest0 rrca                ; rotate into position.
       djnz ktest0         ; repeat until we've found relevant row.
       in a,(254)          ; read port (a=high, 254=low).
ktest1 rra                 ; rotate bit out of result.
       dec c               ; loop counter.
       jp nz,ktest1        ; repeat until bit for position in carry.
       ret

; User defined keys.

keys   defb 28,27,35,16,1


; Joystick and keyboard reading routines.

joykey ld a,(contrl)       ; control flag.
       and a               ; is it the keyboard?
       jr nz,joyjoy        ; no, it's joystick.

; Keyboard controls.

       ld e,0              ; control.
       ld a,(keys+3)       ; fire key.
       call ktest          ; being pressed?
       ccf                 ; complement the carry.
       rl e                ; rotate into e register.
       ld a,(keys)         ; up key.
       call ktest          ; being pressed?
       ccf                 ; complement the carry.
       rl e                ; rotate into e register.
       rl e                ; rotate into e register.
       ld a,(keys+1)       ; left key.
       call ktest          ; being pressed?
       ccf                 ; complement the carry.
       rl e                ; rotate into bit d0 of e register.
       ld a,(keys+2)       ; left key.
       call ktest          ; being pressed?
       ccf                 ; complement the carry.
       rl e                ; destined for bit d1 of e register.
       ld a,e              ; place result in accumulator.
       ld (joyval),a       ; put that into joyval.
       ret

joyjoy dec a               ; is it Kempston?
       jr z,joykem         ; yes.

; Sinclair joystick controls.

joysin ld bc,61438         ; port for Sinclair 2.
       in a,(c)            ; read joystick.
       ld d,a              ; clear values.
       xor a               ; clear accumulator.
       ld e,16             ; Kempston fire bit value.
       bit 0,d             ; fire bit pressed?
       call z,joysi0       ; add bit.
       ld e,1              ; Kempston bit value.
       bit 3,d             ; fire bit pressed?
       call z,joysi0       ; add bit.
       ld e,2              ; Kempston bit value.
       bit 4,d             ; fire bit pressed?
       call z,joysi0       ; add bit.
       ld e,8              ; Kempston bit value.
       bit 1,d             ; fire bit pressed?
       call z,joysi0       ; add bit.
       ld e,4              ; Kempston bit value.
       bit 2,d             ; fire bit pressed?
       call z,joysi0       ; add bit.
       ld (joyval),a       ; remember value.
       ret

joysi0 add a,e             ; add bit value.
       ret


; Kempston joystick controls.

joykem ld bc,31            ; port for Kempston interface.
       in a,(c)            ; read it.
       ld (joyval),a       ; remember value.
       ret

contrl defb 0              ; control method.
joyval defb 0              ; value returned.


negtst ld a,(nshpxf)       ; new ship sign.
       rra                 ; test sign.
       jp nc,negt0         ; it's positive, nothing to fix.
       xor a               ; clear accumulator.
       ld (nshpxf),a       ; clear sign.
       ld (nshipx),a       ; clear integer.
       ld (inxf),a         ; fix inertia sign.
       ld (inxi),a         ; fix inertia integer.
       ret
negt0  ld a,(inyi)         ; inertia integer.
       cp 4                ; below maximum speed?
       ret c               ; yes.
       ld a,4              ; maximum speed.
       ld (inyi),a         ; new speed.
       ret


getobj ld a,(nshipx)       ; player x coord.
       ld (dispx),a        ; x coordinate to test.
       ld a,(nshipy)       ; ship y.
       ld (dispy),a        ; x coordinate.
       call blkad          ; block address there.
       ld a,(hl)           ; item there.
       cp PRIZE            ; valuable?
       jp z,getdmd         ; yes, get it.
       cp TELEP            ; teleport?
       jp z,telep          ; yes, finish level.

;       ld a,(23560)        ; temp JAC.
;       cp 32
;       jp z,telep

       inc hl              ; look down.
       ld a,(hl)           ; item there.
       cp PRIZE            ; valuable?
       jp z,getdmd         ; yes, get it.
       cp TELEP            ; teleport?
       jp z,telep          ; yes, finish level.

       ld de,15            ; distance to top of next column.
       add hl,de           ; look across.
       ld a,(hl)           ; item there.
       cp PRIZE            ; valuable?
       jp z,getdmd         ; yes, get it.
       cp TELEP            ; teleport?
       jp z,telep          ; yes, finish level.
       inc hl              ; look down.
       ld a,(hl)           ; item there.
       cp PRIZE            ; valuable?
       jp z,getdmd         ; yes, get it.
       cp TELEP            ; teleport?
       jp z,telep          ; yes, finish level.
       ret

telep  ld b,32             ; frames to turn.
telep0 push bc
       call psprit         ; draw ship.
       call txfer          ; show screen.
       call psprit         ; delete ship.
       ld a,(angle)        ; ship angle.
       add a,16            ; increment.
       ld (angle),a        ; new angle.
       halt                ; wait.
       halt
       pop bc              ; one less loop.
       djnz telep0
       pop de              ; remove return address from stack.
       jp nexlev           ; next level.




; Clear screen routine.

clrsc  xor a               ; top line.
       ld (clrx0),a        ; set up position.
       ld a,23             ; bottom line.
       ld (clrx1),a        ; set up position.
       ld b,24             ; 24 character lines on screen.
clrsc0 push bc             ; store counter.
       ld a,(clrx0)        ; top down pointer.
       ld c,64             ; top 4 lines.
       call clrlin         ; clear this line.
       ld a,(clrx1)        ; bottom up pointer.
       ld c,65             ; bottom 4 lines.
       call clrlin         ; clear this line.
       ld hl,clrx0         ; top down pointer.
       inc (hl)            ; next row down.
       inc hl              ; cottum-up position.
       dec (hl)            ; move up one line.
       halt                ; pause.
       pop bc              ; restore loop count.
       djnz clrsc0         ; repeat.
       ret
clrlin ld b,4              ; 4 lines to clear.
       ld l,a              ; store x coordinate away in l register.
       and 24              ; mask away all but the segment bits.
       add a,c             ; add to screen start address.
       ld h,a              ; put into high byte of address.
       ld a,l              ; get x coord again.
       rrca                ; multiply by 32.
       rrca                ; 3 rrcas faster than 5 rlcas.
       rrca
       and 224             ; make it a multiple of 32.
       ld l,a              ; put result in low byte.
clrln0 push bc             ; remember the count.
       ld d,h              ; copy h to d.
       ld e,l              ; copy l to e, so de=hl.
       inc de              ; point to next byte.
       ld bc,31            ; line length minus one.
       ld (hl),b           ; blank firt byte of line.
       ldir                ; copy byte to remainder of line.
       ld de,481           ; 2 pixel lines down.
       add hl,de           ; next line down.
       pop bc              ; restore loop counter.
       djnz clrln0         ; repeat 4 times.
       ret
clrx0  defb 0              ; first position.
clrx1  defb 0              ; second position.


; Window attribute fade routine.

fade   ld b,7              ; brightest colour = 7 (white).
fade4  push bc             ; store main loop counter.
       ld hl,22569         ; address of window attributes.
       ld b,22             ; number of attribute cell lines.
fade3  push bc             ; store main loop counter.
       ld b,22             ; number of columns.
fade2  ld a,(hl)           ; get attribute.
       and 7               ; get ink colour.
       jr z,fade0          ; already zero so don't fade it.
       dec a
fade0  ld e,a              ; ink in e register.
       ld a,(hl)           ; get attribute.
       and 56              ; get paper colour.
       jr z,fade1          ; already black so can't fade it.
       sub 8               ; paper colour - 1.
fade1  or e                ; combine paper with ink.
       ld (hl),a           ; write new attribute.
       inc hl              ; next attribute position.
       djnz fade2          ; repeat for rest of line.
       ld de,10            ; bytes to end of row.
       add hl,de           ; start at beginning of next row.
       pop bc              ; row count.
       djnz fade3          ; repeat for all lines.
       halt                ; wait for an interrupt.
       halt                ; do it again.
       halt                ; third pause = 17 frames/second.
       pop bc              ; restore main loop counter.
       djnz fade4          ; repeat until screen is black.
       ret



; Delay routine.

delay  halt                ; wait for interrupt.
       djnz delay          ; repeat.
       ret


gmtxt1 defb 22,0,8
       defb 'BLIZZARDgS@RIFT'
       defb 22,6,7
       defb '\@KEYBOARD'
       defb 22,8,7
       defb ']@KEMPSTON'
       defb 22,10,7
       defb '^@SINCLAIR'
       defb 22,12,7
       defb '_@REDEFINE@KEYS'
       defb 22,14,7
       defb '`@BACKGROUNDS'
       defb 22,22,2
       defb 'eCf@][[b@JONATHAN@CAULDWELL'
gmtxt2 defb 22,14,22
       defb 'ON@'
gmtxt3 defb 22,14,22
       defb 'OFF'
gmtxt4 equ $

; High score table.

hstab  defb 'TRITON@@[[[`[['
       defb 'PASIPHAE[[[_[['
       defb 'ANANKE@@[[[^[['
       defb 'CARME@@@[[[][['
       defb 'SINOPE@@[[[\[['
       defb 'PHOEBE@@[[[[[['

namec  defb 'DIGBY@@@'     ; cheating bastness.
namep  defb 'BLIZZARD'     ; used when no name entered.
name   defb 'RUDENESS'     ; used when rude word entered.
hstxt0 defb 22,2,10
       defb 'BEST@CREDITS'
hstxt1 equ $
hstxt2 defb 22,6,10
       defb 'END@OF@FILE'
       defb 22,9,8
       defb 'IDENTIFY@PLEASE'
hstxt3 equ $


; Redefine keys routine.

redkey call clrsc          ; fancy routine to clear screen.
       ld hl,22528         ; attributes start here.
       ld de,22529         ; next cell address.
       ld bc,767           ; size of attributes file.
       ld (hl),70          ; bright yellow on black.
       ldir                ; set all attributes.
       call 028eh          ; D=shift, E=key.
       ld a,e              ; get value.
       inc a               ; is it 255?
       jr nz,redkey        ; yes - loop until key is released.
       ld hl,keys          ; redefined keys.
       ld de,keys+1
       ld bc,4
       ld (hl),255
       ldir                ; clear keys.
       ld de,ktxt0         ; prompt to display.
       ld bc,ktxt1-ktxt0   ; length.
       call htxt           ; display prompt for next key.
       call redky0         ; wait for keypress.
       ld a,e
       ld (keys+1),a       ; set this as left key.
       ld de,ktxt1         ; prompt to display.
       ld bc,ktxt2-ktxt1   ; length.
       call htxt           ; display prompt for next key.
       call redky0         ; wait for keypress.
       ld a,e
       ld (keys+2),a       ; set this as right key.
       ld de,ktxt2         ; prompt to display.
       ld bc,ktxt3-ktxt2   ; length.
       call htxt           ; display prompt for next key.
       call redky0         ; wait for keypress.
       ld a,e
       ld (keys),a         ; set this as up key.
       ld de,ktxt3         ; prompt to display.
       ld bc,ktxt4-ktxt3   ; length.
       call htxt           ; display prompt for next key.
       call redky0         ; wait for keypress.
       ld a,e
       ld (keys+3),a       ; set this as fire key.
       ld de,ktxt4         ; prompt to display.
       ld bc,ktxt5-ktxt4   ; length.
       call htxt           ; display prompt for next key.
       call redky0         ; wait for keypress.
       ld a,e
       ld (keys+4),a       ; set this as pause key.
       jp run

ktxt0  defb 22,5,8
       defb 'ANTICLOCKWISE',22,5,23
ktxt1  defb 22,7,8
       defb 'CLOCKWISE',22,7,23
ktxt2  defb 22,9,8
       defb 'THRUST',22,9,23
ktxt3  defb 22,11,8
       defb 'FIRE',22,11,23
ktxt4  defb 22,15,8
       defb 'PAUSE',22,15,23
ktxt5  defb 'BHYa`TGV'
       defb 'NJUb_RFC'
       defb 'MKIc^EDX'
       defb 'fLOd]WSZ'
       defb 'e@P[\QA^'

redky0 call 028eh          ; D=shift, E=key.
       ld a,e              ; get value.
       inc a               ; is it 255?
       jr z,redky0         ; yes - loop until something pressed.
       ld a,(keys)         ; first key.
       cp e                ; is this the same?
       jr z,redky0         ; yes - try again.
       ld a,(keys+1)       ; down key.
       cp e                ; is this the same?
       jr z,redky0         ; yes - try again.
       ld a,(keys+2)       ; left key.
       cp e                ; is this the same?
       jr z,redky0         ; yes - try again.
       ld a,(keys+3)       ; right key.
       cp e                ; is this the same?
       jr z,redky0         ; yes - try again.
       ld a,(keys+4)       ; fire key.
       cp e                ; is this the same?
       jr z,redky0         ; yes - try again.
       push de
       ld hl,ktxt5         ; table of key names.
       ld d,0              ; zero high byte.
       add hl,de           ; name of key in look-up table.
       ex de,hl            ; want result in DE.
       ld bc,1             ; length = 4.
       call htxt           ; ROM routine to display string.
       pop de
       ret


; Display high-score table.

dishs  call colhs          ; colour high score table.
       ld de,hstxt0
       ld bc,hstxt1-hstxt0
       call htxt
       ld b,6              ; number of entries to display.
       ld de,hstab         ; address of first name.
dishs0 push bc             ; stack name counter.
       push de
       ld a,9              ; top of table.
       sub b               ; subtract counter.
       rlca                ; multiply by 2.
       inc a               ; add 1 for luck.
       ld (cwinx),a        ; that's our vertical position.
       ld bc,8             ; length of name.
       ld a,c              ; horizontal position.
       ld (cwiny),a        ; set the column.
       call htxt           ; display name.
       ld hl,cwiny         ; column.
       inc (hl)            ; skip one.
       ld bc,6             ; digits in score.
       call htxt           ; show digits.
       pop hl              ; restore address.
       pop bc              ; retrieve counter from stack.
       ld de,14            ; distance to next entry.
       add hl,de           ; point there.
       ex de,hl            ; want result in de please.
       djnz dishs0         ; repeat for all entries.
       ret


; Set up high score table colours.

colhs  ld hl,22528
       ld de,22529         ; next cell.
       ld bc,128           ; 4 lines.
       ld (hl),70          ; set all to this colour.
       ldir                ; colour 'em all.
       ret


hsrol  ld a,(23672)        ; clock low.
       and 30              ; every 31 frames.
       ret nz              ; not time yet.
       ld hl,22752         ; top left of high score table attributes.
       ld de,22753         ; next cell.
       ld bc,384           ; cells to colour.
       ld a,(hl)           ; fetch colour.
       xor 6               ; toggle red/green.
       ld (hl),a           ; new colour.
       ldir                ; copy to all cells.
       ret




; Find address of character attribute at (dispx, dispy).
; Only used in high score name entry routine.

atadd  ld a,(cwinx)        ; vertical position.
       rrca                ; divide by 8.
       rrca
       rrca
       ld e,a              ; store in e for now.
       and 3               ; mask bits to find screen segment.
       add a,88            ; attributes start at 88*256=22528.
       ld d,a              ; that gives us our high byte.
       ld a,e              ; vertical divided by 8/multiplied by 32.
       and 224             ; mask bits to find a multiple of 32.
       ld e,a              ; put that in low byte.
       ld a,(cwiny)        ; get horizontal position.
       add a,e             ; add to low byte.
       ld e,a              ; final low byte.
       ret
       

; Calculating a screen address from a pixel coordinate can be tricky!
; The Spectrum screen display is organized into 3 segments of 2048 bytes,
; all containing 8 rows of 32 character squares, each with 8 lines.
; Hence 8 * 32 * 8 * 3 = 6144 bytes.
; Low resolution colour filter = 32 * 8 character squares = 768 bytes.
; Total = 6144 + 768 = 6912 bytes, 16384 to 23295 inclusive.

scadd  ld a,(dispx)        ; Returns screen address of coordinates
       ld l,a              ; (dispx, dispy) in hl.
       and 7               ; Line 0-7 within character square.
       add a,64            ; 64 * 256 = 16384 (Start of screen display)
       ld h,a              ; Line * 256.
       ld a,l
       rrca
       rrca
       rrca
       and 24              ; Segment 0-2 multiplied by 8
       add a,h             ; Add to h (so multiply by 8 * 256 = 2048)
       ld h,a
       ld a,l              ; 8 character squares per segment.
       rlca                ; Divide x by 8 and multiply by 32,
       rlca                ; net calculation: multiply by 4.
       and 224             ; Mask off bits we don't want.
       ld l,a              ; Vertical coordinate calculation done.
       ld a,(dispy)        ; y coordinate.
       rrca                ; Only need to divide by 8.
       rrca
       rrca
       and 31              ; Squares 0 - 31 across screen.
       add a,l             ; Add to total so far.
       ld l,a              ; hl = address of screen.
       ret

scadd2 ld a,(cwinx)        ; Returns screen address of coordinates
       ld l,a              ; (dispx, dispy) in hl.
       and 7               ; Line 0-7 within character square.
       add a,64            ; 64 * 256 = 16384 (Start of screen display)
       ld h,a              ; Line * 256.
       ld a,l
       rrca
       rrca
       rrca
       and 24              ; Segment 0-2 multiplied by 8
       add a,h             ; Add to h (so multiply by 8 * 256 = 2048)
       ld h,a
       ld a,l              ; 8 character squares per segment.
       rlca                ; Divide x by 8 and multiply by 32,
       rlca                ; net calculation: multiply by 4.
       and 224             ; Mask off bits we don't want.
       ld l,a              ; Vertical coordinate calculation done.
       ld a,(cwiny)        ; y coordinate.
       rrca                ; Only need to divide by 8.
       rrca
       rrca
       and 31              ; Squares 0 - 31 across screen.
       add a,l             ; Add to total so far.
       ld l,a              ; hl = address of screen.
       ret



nofire xor a               ; clear flags/accumulator.
       ld (firefl),a       ; set fire flag.
       ret

fire   ld hl,firefl        ; Must release key between bullets.
       ld a,(hl)           ; fire already pressed flag.
       and a               ; pressed last time?
       ret nz              ; yes, release before firing again.
       inc (hl)            ; set pressed flag.
       ld hl,bultab        ; bullet table.
       ld b,6              ; number of bullets.
       ld de,6             ; size of bullet table entry.
fire1  ld a,(hl)
       rla                 ; check leftmost bit.
       jr c,fire0          ; it's set, bullet is disabled.
       add hl,de           ; try next in table.
       djnz fire1          ; repeat until we find empty spot.
       ret
fire0  push hl             ; store address.
       call ftest          ; do fire test.
       pop hl
       ret c               ; went negative, so no ammo left to fire.
       xor a               ; zero.
       ld c,a              ; zero c register as well.
       ld (hl),a           ; enable bullet.
       inc hl              ; point to angle.
       ld a,(nangle)       ; angle of ship.
       ld (hl),a           ; fire in direction we're pointing.
       inc hl              ; point to x integer.
       push hl             ; store pointer.
       ld a,(nangle)       ; angle of ship.
       call sin            ; sine of angle.
       ld h,d              ; copy to hl.
       ld l,e
       call octuhl         ; octuple it.
       call add            ; add again, so sin*10.
       ld a,(nshipx)       ; ship x.
       add a,7             ; middle of sprite.
       ld d,a              ; put in integer.
       ld e,0              ; blank fraction/sign.
       call add            ; combine them.
       ex de,hl            ; put into de pair.
       pop hl              ; restore pointer.
       ld a,d
       ld (hl),e           ; set up fraction/sign.
       ld (dispx),a        ; coords set up dispx.
       inc hl              ; point to x fraction.
       ld (hl),a           ; set coordinate.
       inc hl              ; point to y fraction.
       push hl             ; store pointer.
       ld a,(nangle)       ; angle of ship.
       call cos            ; cosine of angle.
       ld h,d              ; copy to hl.
       ld l,e
       call octuhl         ; octuple it.
       call add            ; add again, so cos*9.
       ld a,(nshipy)       ; ship x.
       add a,7             ; middle of sprite.
       ld d,a              ; put in integer.
       ld e,0              ; blank fraction/sign.
       call add            ; combine them.
       ex de,hl            ; put into de pair.
       pop hl              ; restore pointer.
       ld a,d
       ld (dispy),a        ; coords set up dispx.
       ld (hl),e           ; set fraction.
       inc hl              ; point to y integer.
       ld (hl),a           ; set coordinate.
       ret

ftest  call click          ; brief sound effect.
       ld hl,ammo+4        ; ammo digits.
       ld b,1              ; total to subtract.
       call cscor          ; decrease ammo.
       ret c               ; nothing doing - no ammo left.
       ld hl,ammo+4        ; ammo digits.
       ld b,1              ; total to subtract.
       call rscor          ; decrease ammo.
       jp dammo            ; display ammunition remaining.



sprptr defw 0              ; pointer to sprite we wish to remove.


; Destroyed a gun turret.
; Look for entry in gun table and disable it.

hitgun push hl             ; store address.
       ld de,turrsp        ; pointer to sprite.
       call remob          ; remove object.
       pop de              ; restore map address.
       ld hl,guntab+2      ; table of guns.
       ld a,MAXGUN         ; maximum allowed per level.
       ld bc,4             ; size of gun entry.
hitg1  ex af,af'           ; store loop counter.
       ld a,(hl)           ; gun address low byte.
       cp e                ; found a match?
       jr z,hitg0          ; they match.
hitg2  add hl,bc           ; point to next gun table entry.
       ex af,af'           ; restore loop counter.
       dec a               ; one less iteration.
       jr nz,hitg1         ; go round again.
       ret

hitg0  inc hl              ; next byte of pointer.
       ld a,(hl)           ; fetch byte.
       dec hl              ; restore address.
       cp d                ; test high byte.
       jr nz,hitg2         ; high bytes don't match.
       dec hl              ; angle.
       dec hl              ; on/off switch.
       ld (hl),0           ; switch off this turret.
       ret


; Get a diamond.

getdmd ld de,dmdspr        ; pointer to sprite.
       call remob          ; remove object.
       call bong1          ; play a sound.

; Increment the score by 100.

       ld hl,score+3       ; tens column.
       ld b,1              ; single increment.
       jp uscor            ; up the score.

hitshp ld hl,score+4       ; player's score.
       ld b,5              ; increment.
       jp uscor            ; up the score.

remob  ld (sprptr),de      ; store sprite pointer.
       ld (hl),0           ; remove block from level array.
       push hl             ; store pointer to map position.
       call bplot          ; unplot item.
       pop hl              ; restore pointer to map.

; Remove the item from the display window.

       call getxy          ; get x and y coords of block.
       ld hl,(sprptr)      ; pointer to sprite.
       jp sprite           ; display sprite.



getxy  ld de,(levptr)      ; pointer to start of screen area.
       and a               ; reset carry flag.
       sbc hl,de           ; get displacement.
       ld a,l              ; low byte gives y + 16.
       and 240             ; make it a multiple of 16.
       ld e,a              ; copy into e.
       ld a,(scrolc)       ; scroll counter gives window displacement.
       neg                 ; curses, it's reversed!
       and 15              ; want it in range 0-15.
       jr nz,getxik        ; not zero.
       ld a,16             ; zero is 16.
getxik add a,e             ; add to y coordinate.
       ld (dispy),a        ; that's our y position.
       ld a,l              ; find difference again.
       and 15              ; establish which row block is on.
       rlca                ; multiply by 16.
       rlca
       rlca
       rlca
       ld (dispx),a        ; that's the x coordinate.
       ret


blkad  ld a,(dispy)        ; y displacement.
       ld e,a              ; copy into e.
       ld a,(scrolc)       ; scroll counter gives window displacement.
       and 15              ; want it in range 0-15.
       add a,e             ; add to x coordinate.
       sub 16              ; levptr always 16 bytes to the left.
       and 240             ; make it a multiple of 16.
       ld e,a              ; store low byte.
       ld a,(dispx)        ; x coordinate.
       rrca                ; divide by 16.
       rrca
       rrca
       rrca
       and 15              ; block displacement is 0-15.
       add a,e             ; add to column displacement.
       ld e,a              ; that's the low byte.
       ld d,0              ; maximum displacement from left edge is 255.
       ld hl,(levptr)      ; pointer to start of screen.
       add hl,de           ; add displacement.
       ret



; Move gun.

movgun ld ix,guntab        ; gun table.
       ld b,MAXGUN         ; maximum number of guns.
movgn0 ld a,(ix)           ; on/off switch.
       push bc             ; counter.
       push ix             ; pointer to gun.
       and a               ; test for on.
       call nz,mgun        ; it's switched on, process gun.
       pop ix
       pop bc
       ld de,4             ; size of gun entry.
       add ix,de           ; look for next one.
       djnz movgn0         ; repeat for remaining patrols.
       ret

mgun   ld hl,(levptr)      ; find address of screen.
       ex de,hl            ; put screen address into de pair.
       ld l,(ix+2)         ; gun address low.
       ld h,(ix+3)         ; gun address high.
       and a               ; reset carry.
       sbc hl,de           ; subtract screen from gun's address.
       ret c               ; gun is to the left of the screen.

       ld a,h              ; high byte of result.
       and a               ; must be zero.
       ret nz              ; no, more than 16 columns imbetween.
       ld a,l              ; displacement low byte.
       cp 208              ; past right edge?
       ret nc              ; yes, off screen.
       cp 16               ; past left edge?
       ret c               ; yes, off screen.
       and 15              ; want number 0-15.
       rlca                ; multiply by 16.
       rlca
       rlca
       rlca
       ld (gunx),a         ; that's the x coord then.
       ld a,l              ; fetch displacement again.
       and 240             ; multiple of 16 gives column.
       ld l,a
       ld a,(scrolc)       ; check scroll counter.
       neg                 ; curses, it's reversed!
       and 15              ; want it in range 0-15.
       jr nz,mgun1         ; not zero.
       ld a,16             ; zero is 16.
mgun1  ld (sfac),a         ; put it away for later.
       add a,l
       ld (guny),a         ; that's the y coordinate.

       ld a,(framec)       ; frame counter.
       ld hl,gunx          ; gun x coord.
       xor (hl)            ; combine them.
       and 31              ; move on every 32nd frame.
       jp z,fgun           ; wait until hit right frame before firing.
       ld hl,nshipx        ; ship x coord.
       ld a,(gunx)         ; gun x coord.
       cp (hl)             ; compare the two.
       jp c,mgund          ; ship is lower than gun, simple left/right check.

; Ship is above the gun so we can employ some basic trigonometry to aim it.
; We need to find the angle and to do this we divide the adjacent by
; the hypotenuse and find the arccosine.
; First of all we put the length of the opposite on the stack:

mgunx  ld a,(nshipy)       ; ship y coordinate.
       ld hl,guny          ; gun y coord.
       sub (hl)            ; find difference.
       jr nc,mgun0         ; result was positive.
       neg                 ; negative, make it positive.
mgun0  cp 5                ; y difference less than 5?
       jr c,mgunu          ; yes, point straight up.
       push af             ; place length of opposite on stack.

; Next we require the length of the hypotenuse and we can use good
; old Pythagoras' theorem for this.

       ld h,a              ; copy a to h.
       ld d,h              ; copy h to d.
       call imul           ; multiply integer parts to get 16-bit result.
       push hl             ; remember squared value.

       ld hl,nshipx        ; gun x coordinate.
       ld a,(gunx)         ; ship x coordinate.
       sub (hl)            ; find difference, will always be positive.
       ld h,a              ; put x difference in h.
       ld d,h              ; copy h to d.
       call imul           ; multiply h by d to get square.

       pop de              ; get last squared result.
       add hl,de           ; want the sum of the two.
       call isqr           ; find the square root, hypotenuse in a.
       pop de              ; opposite line now in d register.

       ld h,a              ; length of hypotenuse.
       ld l,0              ; no fraction or sign.
       ex de,hl            ; switch 'em.

; Opposite and hypotenuse are now in de and hl.
; We now divide the first by the second and find the arcsine.
; Remember - sine = opposite over hypotenuse.

       call div            ; division will give us the sine.
       ex de,hl            ; want result in de.
       call asn            ; get arcsine to find the angle.
       push af

; Okay, we have the angle but it's only 0 to half-pi radians (64 angles)
; so we need to make an adjustment based upon the quarter of the circle.
; We can establish which quarter of the circle our angle lies in by
; examining the differences between the ship and gun coordinates.

       ld a,(guny)         ; gun y position.
       ld hl,shipy         ; ship y.
       cp (hl)             ; is ship to the right?
       jr nc,mgun2         ; player to the left, angle in second quarter.

; Angle to play is in first quarter, so it needs subtracting from 64.

       ld a,64             ; pi/2 radians = 64 angles.
       pop bc              ; angle in b.
       sub b               ; do the subtraction.
       ld (ix+1),a         ; new angle.
       ret                 ; we have our angle.

; Second quarter - add literal 64 to our angle.

mgun2  pop af              ; original angle.
       add a,192           ; add pi/2 radians.
       ld (ix+1),a         ; new angle.
       ret                 ; job's a good 'un!

; Ship is below the gun.  move the gun barrel to the left or right.

mgund  ld hl,shipy         ; player y coord.
       ld a,(guny)         ; gun y position.
       cp (hl)             ; compare them.
       jr c,mgunr          ; player is to the right.
       ld a,192            ; due west.
       ld (ix+1),a         ; point there.
       ret
mgunr  ld a,64             ; due east.
       ld (ix+1),a         ; point east.
       ret
mgunu  xor a               ; due north.
       ld (ix+1),a         ; point up.
       ret


gunx   defb 0              ; gun turret coordinates.
guny   defb 0


; Fire gun turret.

fgun   ld b,(ix+1)         ; turret angle.
       ld ix,ebtab         ; first bullet entry.
       ld a,(ix)           ; on/off flag.
       rla                 ; is it enabled?
       jr c,fgun0          ; no - fire this one.
       ld ix,ebtab+6       ; second bullet entry.
       ld a,(ix)           ; on/off flag.
       rla                 ; is it enabled?
       jr c,fgun0          ; no - fire this one.
       ret
fgun0  ld (ix+1),b         ; set bullet direction to turret angle.
       xor a               ; zero.
       ld (ix),a           ; enable bullet.
       ld (ix+2),a         ; reset sign/integer of x.
       ld (ix+4),a         ; do the same for y.
       ld a,(gunx)         ; turret x coord.
       add a,4             ; mid-point.

       ld (ix+3),a         ; x coord.
       ld (dispx),a        ; display coordinate.
       ld a,(guny)         ; turret x coord.
       add a,7             ; mid-point.
       ld (ix+5),a         ; y coord.
       ld (dispy),a        ; display coordinate.

; Now do initial move away from turret.

       ld a,(ix+1)         ; what is the angle?

       call sin            ; get sine of this angle.
       call octuhl         ; quadruple it.
       ld e,(ix+2)         ; fraction of x.
       ld d,(ix+3)         ; integer of x.
       call add            ; add the sine.
       ld (ix+2),l         ; new fraction.
       ld (ix+3),h         ; new integer.
       rr l                ; x gone negative?
       call c,3582
       jp c,kileb          ; yes, bullet off screen.
       ld a,(ix+1)         ; what is the angle?
       call cos            ; get cosine of this angle.
       call octuhl         ; quadruple it.
       ld e,(ix+4)         ; fraction of y.
       ld d,(ix+5)         ; integer of y.
       call add            ; add the sine.
       ld (ix+4),l         ; new fraction.
       ld (ix+5),h         ; new integer.
       rr l                ; get sign.
       jp c,kileb          ; it's gone negative, remove bullet.
       ld a,h              ; get integer bit in accumulator.
       cp 192              ; right side of screen check.
       jp nc,kileb         ; going past right edge, remove it.
       cp 16               ; left side of screen check.
       jp c,kileb          ; going past left edge, remove it.
       ret


; Move enemy bullet.

moveb0 ld a,(ix+1)         ; what is the angle?
       call sin            ; get sine of this angle.
       call quadhl         ; quadruple it.
       ld e,(ix+2)         ; fraction of x.
       ld d,(ix+3)         ; integer of x.
       call add            ; add the sine.
       ld (ix+2),l         ; new fraction.
       ld (ix+3),h         ; new integer.
       rr l                ; x gone negative?
       jp c,kileb          ; yes, bullet off screen.
       ld a,(ix+1)         ; what is the angle?
       call cos            ; get cosine of this angle.
       call quadhl         ; quadruple it.
       ld e,(ix+4)         ; fraction of y.
       ld d,(ix+5)         ; integer of y.
       call add            ; add the sine.
       ld (ix+4),l         ; new fraction.
       ld (ix+5),h         ; new integer.
       rr l                ; get sign.
       jp c,kileb          ; it's gone negative, remove bullet.
       ld a,h              ; get integer bit in accumulator.
       cp 192              ; right side of screen check.
       jp nc,kileb         ; going past right edge, remove it.
       cp 32               ; left side of screen check.
       jp c,kileb          ; going past left edge, remove it.
       ld l,(ix+3)         ; x integer.
       ld h,(ix+5)         ; y integer.
       ld (dispx),hl       ; workspace coordinates.

; Now check back screen for collision with walls.

       call wpoint         ; back screen address.
       jp nz,kileb         ; hit something, check if it's a gun.
       ret



drchk  ld hl,dronet        ; table of drones.
       ld b,4              ; maximum number allowed.
drchk0 ld a,(hl)           ; on/off flag.
       and a               ; test for on.
       jr nz,drchk1        ; it's switched on, test for collision.
       ld de,8             ; size of drone table.
       add hl,de           ; look for next one.
drchk2 djnz drchk0         ; repeat for remaining patrols.
       ret

drchk1 ld a,(dispx)        ; x coord of bullet.
       ld de,6             ; distance to display x.
       add hl,de           ; window coord.
       sub (hl)            ; find distance.
       inc a               ; height of bullet.
       cp 17               ; within range?
       jr nc,drchk3        ; no, missed this drone.
       inc hl              ; point to window y coord.
       ld a,(dispy)        ; bullet y.
       sub (hl)            ; distance between coordinates.
       inc hl              ; point to next drone.
       inc a               ; bullet height.
       cp 17               ; within range?
       jr nc,drchk2        ; no, missed this drone.
       ld de,65528         ; distance to destroyed drone.
       add hl,de
       push ix             ; remember bullet pointer.
       push hl             ; stack drone pointer.
       call explod         ; explosion.
       pop ix              ; unstack into ix.
       call shodr1         ; delete the drone.
       ld (ix),0           ; switch drone off.
       ld l,(ix+2)         ; drone address low.
       ld h,(ix+3)         ; drone address high.
       call bplot          ; remove drone from scanner.
       pop ix              ; restore bullet pointer.
       ret
drchk3 inc hl              ; last byte.
       inc hl              ; next drone.
       jr drchk2           ; check that for collision.



; Move or display shrapnel from explosion.

proshr ld a,(explc)        ; explosion counter.
       and a               ; switched on?
       ret z               ; no, nothing to do.

       ld ix,shrtab        ; table.
       ld b,10             ; shrapnel pieces to process.
prosh0 push bc             ; store counter.
       ld a,(ix)           ; on/off marker.
       rla                 ; check its status.
proshx call nc,mshr0       ; on, so process it.
       pop bc              ; restore counter.
       ld de,6             ; distance to next.
       add ix,de           ; point there.
       djnz prosh0         ; round again.
       ret

explc  defb 0              ; explosion counter.

; Display shrapnel.

dshr0  ld l,(ix+3)         ; x integer.
       ld h,(ix+5)         ; y integer.
       ld (dispx),hl       ; workspace coordinates.
       jp wplot            ; plot/unplot present position.

; Move shrapnel.

mshr0  ld a,(ix+1)         ; what is the angle?
       call sin            ; get sine of this angle.
       call quadhl         ; quadruple it.
       ld e,(ix+2)         ; fraction of x.
       ld d,(ix+3)         ; integer of x.
       call add            ; add the sine.
       ld (ix+2),l         ; new fraction.
       ld (ix+3),h         ; new integer.
       rr l                ; x gone negative?
       jp c,mshr1          ; yes, bullet off screen.
       ld a,(ix+1)         ; what is the angle?
       call cos            ; get cosine of this angle.
       call quadhl         ; quadruple it.
       ld e,(ix+4)         ; fraction of y.
       ld d,(ix+5)         ; integer of y.
       call add            ; add the sine.
       ld (ix+4),l         ; new fraction.
       ld (ix+5),h         ; new integer.
       rr l                ; get sign.
       jp c,mshr1          ; it's gone negative, remove bullet.
       ld a,h              ; get integer bit in accumulator.
       cp 208              ; right side of screen check.
       jp nc,mshr1         ; going past right edge, remove it.
       cp 32               ; left side of screen check.
       jp c,mshr1          ; going past left edge, remove it.
       ld l,(ix+3)         ; x integer.
       ld h,(ix+5)         ; y integer.
       ld (dispx),hl       ; workspace coordinates.

; Now check back screen for collision with walls.

       call wpoint         ; back screen address.
       jp nz,mshr1         ; hit something, check if it's a gun.
       ret

mshr1  ld (ix),128         ; switch off shrapnel.
       ret

; Kill enemy bullet.

kileb  equ mshr1           ; same code to kill enemy bullet.

; Cause an explosion at (dispx),dispy).

explod call crash          ; make noise.
       ld a,(explc)        ; set counter.
       and a               ; already in motion?
       ret nz              ; yes, nothing to do.
       ld a,10             ; explosion counter.
       ld (explc),a        ; set counter.
       xor a               ; first angle.
       ld ix,shrtab        ; shrapnel table.
       ld hl,(dispx)       ; coordinates of eplosion.
       ld de,6             ; size of shrapnel element.
expld0 ld (ix+3),l         ; x coord.
       ld (ix+5),h         ; y coord.
       ld (ix+1),a         ; angle.
       ld (ix),d           ; switch it on.
       ld (ix+2),d         ; zero sign.
       ld (ix+4),d         ; zero sign.
       add ix,de           ; point to more shrapnel.
       add a,26            ; distance to next bit of shrapnel.
       jp nc,expld0
       ret

; Movement routine.

mshrp  ld a,(explc)        ; explosion counter.
       and a               ; already zero?
       ret z               ; yes, no shrapnel.
       dec a               ; one less frame.
       ld (explc),a        ; set new counter.
       ld hl,mshr0         ; movement routine.
       ld (proshx+1),hl    ; modify routine.
       jp proshr           ; process shrapnel.

; Display shrapnel.

dshrp  ld hl,dshr0         ; display routine.
       ld (proshx+1),hl    ; modify routine.
       jp proshr           ; process shrapnel.




lives  defb 0              ; player lives.


; Plot block on scanner.

bplot  ld de,levbuf        ; level buffer address.
       and a               ; reset carry,
       sbc hl,de           ; find displacement to this block.
       ld a,l              ; get low byte.
       and 15              ; find remainder of division by 16.
       add a,168           ; start near bottom of screen.
       ld (dispx),a        ; that's the x coordinate.
       rr h                ; divide block position by 4.
       rr l                ; don't forget to divide low byte.
       rr h                ; second division.
       rr l                ; don't forget to divide low byte.
       ld a,l              ; block position divided by 4.
       rra                 ; divide by another 2.
       rra                 ; and again, so now block/16.
       and 63              ; should give us horizontal position.
       add a,8             ; add horizontal panel displacement.
       cp 64               ; outside range?
       ret nc              ; yes, don't plot it.
       ld (dispy),a        ; got horizontal position.

;   splot   : plots point dispx,dispy.

splot  ld a,(dispy)        ; y coordinate.
       and 7               ; want in range 0-7.
       ld d,0              ; zero high byte.
       ld e,a              ; de=displacement for pixel.
       ld hl,pixels        ; pre-shifted pixel table.
       add hl,de           ; get address of pixel.
       ld a,(hl)           ; a = pixel.
       ex af,af'           ; store it.
       call scadd          ; get screen address in hl.
       ex af,af'           ; restore pixel.
       xor (hl)            ; merge with what's there.
       ld (hl),a           ; write new screen address.
       ret
pixels defb 128,64,32
       defb 16,8,4,2,1


; Scoring routines

shopop defb 0              ; shop option selected.
score  defb '[[[[[['

; Up the score.

uscor  ld a,(hl)           ; current value of digit.
       add a,b             ; add points to this digit.
       ld (hl),a           ; place new digit back in string.
       cp 101              ; more than ASCII value '9'?
       ret c               ; no - relax.
       sub 10              ; subtract 10.
       ld (hl),a           ; put new character back in string.
uscor0 dec hl              ; previous character in string.
       inc (hl)            ; up this by one.
       ld a,(hl)           ; what's the new value?
       cp 101              ; gone past ASCII nine?
       ret c               ; no, scoring done.
       sub 10              ; down by ten.
       ld (hl),a           ; put it back.
       jp uscor0           ; go round again.

; Reduce the score.

rscor  ld a,(hl)           ; current value of digit.
       sub b               ; subtract value from digit.
       ld (hl),a           ; place new digit back in string.
       cp 91               ; less than ASCII value '0'?
       ret nc              ; no, score is okay.
       add a,10            ; add 10.
       ld (hl),a           ; put new character back in string.
rscor0 dec hl              ; previous character in string.
       ld a,(hl)           ; get character already there.
       cp 91               ; is this part of ASCII score?
       jr c,rscor1         ; no, we've gone past last character.
       dec (hl)            ; decrement this by one.
       ld a,(hl)           ; what's the new value?
       cp 91               ; gone below ASCII zero?
       ret nc              ; no, scoring done.
       add a,10            ; back up by ten.
       ld (hl),a           ; put it back.
       jp rscor0           ; go round again.
rscor1 inc hl              ; move back to first character of score.
       ld d,h              ; copy hl to de.
       ld e,l
       ld (hl),91          ; make first digit a zero.
       inc de              ; point to next digit.
       ld bc,4             ; five minus one digits to copy.
       ldir                ; zeroise remaining digits.
       scf                 ; set carry to indicate we went negative.
       ret

; Check score can be reduced by value in b register.

cscor  ld a,(hl)           ; current value of digit.
       sub b               ; subtract value from digit.
       cp 91               ; less than ASCII value '0'?
       ret nc              ; no, score is okay.
cscor0 dec hl              ; previous character in string.
       ld a,(hl)           ; get character already there.
       cp 91               ; is this part of ASCII score?
       ret c               ; no, we've gone past last character.
       cp 92               ; would it go below ASCII zero?
       ret nc              ; no, scoring done.
       jp cscor0           ; go round again.

; Decompress level data into workspace RAM.

decom  ex de,hl            ; store address of data.
       ld a,(levnum)       ; current level.
       ld hl,lastdc        ; last one decompressed.
       cp (hl)             ; do they match?
       jr z,decom3         ; yes, nothing to do.
       ld (hl),a           ; set last level decompressed.
       ex de,hl            ; restore data address.
       ld bc,768           ; size of target area.
       ld de,levbuf        ; address of data buffer.
decom2 ld a,(hl)           ; source byte.
       cp 255              ; is it a control code code?
       jr z,decom0         ; it is, process it.
       ld (de),a           ; write target byte.
       inc de              ; next target address.
       inc hl              ; next source address.
       dec bc              ; decrement counter.
       ld a,b              ; loop counter high byte.
       or c                ; combine with low byte for zero check.
       jr nz,decom2        ; not done, go round again.
       jr decom4           ; done, check visited flag.
decom0 inc hl              ; next source byte.
       ld a,(hl)           ; fill byte we're expanding.
       ld (dbyte),a        ; store it here.
       inc hl
       ld a,(hl)           ; loop counter.
       inc hl
decom1 ex af,af'           ; store counter.
       ld a,(dbyte)
       ld (de),a           ; fill byte in.
       inc de              ; next byte of screen.
       dec bc              ; decrement overall counter.
       ld a,b              ; loop counter high.
       or c                ; hit zero?
       jr z,decom4         ; yes, decompression finished.
       ex af,af'           ; restore mini loop counter.
       dec a               ; decrement it.
       jr nz,decom1        ; not finished expanding yet.
       jr decom2
decom3 ld hl,(xptr)        ; start position marker address.
       ld (hl),X           ; make a mark.
       ret
decom4 ld a,(levnum)       ; planet number.
       call getvis         ; address of visited flag.
       ld a,(hl)           ; visited before?
       ld (hl),h           ; set visited flag.
       and a               ; zero means we haven't.
       ret z               ; it's okay, it's the first time.

; We've visited before.
; scavengers have been along since so delete drones turrets and collectables.

       ld hl,levbuf        ; level buffer.
       ld bc,768           ; bytes to check.
vis0   ld a,(hl)           ; block value.
       cp P                ; drone?
       call z,vis1         ; delete it.
       cp T                ; turret?
       call z,vis1         ; delete it.
       cp 4                ; diamond?
       call z,vis1         ; delete it.
       inc hl              ; next block.
       dec bc              ; decrement counter.
       ld a,b              ; counter high.
       or c                ; counter low.
       jr nz,vis0          ; not done yet so keep going.
       ret
vis1   ld (hl),0           ; delete item.
       ret

; Flip the level - ie, mirror it horizontally.

flip   ld a,(levnum)       ; level number.
       cp 28               ; beyond defined levels?
       ret c               ; no, so no flipping required.
       ld de,levbuf        ; start of level.
       ld hl,levbuf+47*16  ; last bit of buffer.
       ld b,24             ; half width of level.
flip1  push bc             ; store column.
       ld b,16             ; height.
flip0  push bc             ; store counter.
       ld a,(de)           ; fetch byte from de.
       call flipc          ; convert as we go along.
       ld b,a              ; store in b.
       ld a,(hl)           ; fetch byte in hl.
       call flipc          ; convert as we go along.
       ld (hl),b           ; byte from de to hl.
       ld (de),a           ; copy hl to de.
       inc hl              ; next hl.
       inc de              ; next de.
       pop bc              ; height counter.
       djnz flip0          ; repeat.
       ld bc,65504         ; two columns back.
       add hl,bc           ; new hl pointer.
       pop bc              ; column counter.
       djnz flip1          ; repeat.
       ret
flipc  cp W                ; is it the wall?
       ret nz              ; no, it's okay.
       ld a,2              ; convert to this symbol.
       ret


dbyte  equ 23756           ; decompression byte.
lastdc defb 255            ; last level decompressed.


; Show drones on scanner.

scdro  ld ix,dronet        ; table of drones.
       ld b,4              ; number allowed.
scdro0 ld a,(ix)           ; enabled/disabled flag.
       and a               ; test for on.
       call nz,scdro1      ; it's switched on, process sprite.
       ld de,8             ; size of drone table.
       add ix,de           ; look for next one.
       djnz scdro0         ; repeat for remaining patrols.
       ret
scdro1 ld l,(ix+2)         ; drone's low address.
       ld h,(ix+3)         ; drone's high address.
       jp bplot            ; show drone on scanner.


; AY sound effect routines.

woosh  ld a,(explc)        ; explosion counter.
       cp 3                ; still going?
       ret nc              ; yes, no noise please.
       inc a               ; make sure accumulator isn't zero.
       ld (nflag),a        ; set thrust noise flag.
       ld hl,0             ; period.
       ld (snddat+11),hl   ; place in buffer.
       defb 33,20,7        ; noise generator/mixer.
       ld (snddat+6),hl    ; place in buffer.
       ld a,12             ; envelope control.
       ld (snddat+13),a    ; put that in buffer.
       jp w8912            ; play the sound.

crash  ld hl,4500          ; period.
       ld (snddat+11),hl   ; place in buffer.
       defb 33,31,7        ; noise generator/mixer.
       jr click0

silenc xor a               ; zeroise accumulator.
       ld (snddat+8),a     ; set volume.
       ld (snddat+9),a     ; set volume.
       ld (snddat+10),a    ; set volume.
       call w8912          ; play the sound.
       ld a,16             ; envelope generator.
       ld (snddat+8),a     ; set volume.
       ld (snddat+9),a     ; set volume.
       ld (snddat+10),a    ; set volume.
       ret

click  call cnoise         ; don't let nthrst silence noise.
       ld a,(explc)        ; explosion counter.
       cp 3                ; still going?
       ret nc              ; yes, no noise please.
       ld hl,150           ; period.
       ld (snddat+11),hl   ; place in buffer.
       defb 33,1,7         ; noise generator/mixer.
click0 ld (snddat+6),hl    ; place in buffer.
       ld a,3              ; envelope control.
       ld (snddat+13),a    ; put that in buffer.
       jr w8912            ; play the sound.

bong1  call cnoise         ; don't let nthrst silence noise.
       ld hl,3500          ; period.
       ld (snddat+11),hl   ; place in buffer.
       ld hl,300           ; pitch.
       ld (snddat),hl      ; set up registers.
       inc h               ; decrease it.
       ld (snddat+2),hl    ; set up registers.
       inc h               ; decrease it.
       ld (snddat+4),hl    ; set up registers.
bong1a defb 33,15,56       ; noise generator/mixer.
       ld (snddat+6),hl    ; place in buffer.
       ld a,3              ; envelope control.
       ld (snddat+13),a    ; put that in buffer.


; Write the contents of our AY buffer to the AY registers.

w8912  ld hl,snddat        ; start of AY-3-8912 register data.
       ld e,0              ; register to start with.
       ld d,14             ; number of registers to write.
w8912a ld a,e
       ld bc,65533         ; port 65533=select soundchip register.
       out (c),a           ; tell chip which register we're writing.
       ld a,(hl)           ; value to write.
       ld bc,49149         ; port 49149=write value to register.
       out (c),a           ; this is what we're putting there.
       inc e               ; next sound chip register.
       inc hl              ; next byte to write.
       dec d               ; decrement loop counter.
       jp nz,w8912a        ; repeat until done.
       ret

snddat defw 0              ; tone registers, channel A.
       defw 0              ; channel B tone registers.
       defw 0              ; as above, channel C.
       defb 0              ; white noise period.
       defb 60             ; tone/noise mixer control.
       defb 16             ; channel A amplitude/envelope generator.
       defb 16             ; channel B amplitude/envelope.
       defb 16             ; channel C amplitude/envelope.
       defw 6000           ; duration of each note.
       defb 0

stptr  defw 0              ; stack pointer.
blip   ld hl,100           ; pitch.
       ld de,0             ; duration.
       jp 949              ; VERY short sound.
nflag  defb 0              ; thrust noise flag.

swap   ld a,(hl)           ; fetch byte from hl.
       ex af,af'           ; store it.
       ld a,(de)           ; fetch byte from de.
       ld (hl),a           ; switch into hl.
       ex af,af'           ; restore hl value.
       ld (de),a           ; switch into de.
       inc hl              ; next hl.
       inc de              ; next de.
       dec bc              ; next bc.
       ld a,b              ; high byte of counter.
       or c                ; combine with low byte.
       jr nz,swap          ; repeat.
       ret
levnum defb 0              ; level number.


; Display box around window.

box    defb 33,6,70        ; coordinates.
       ld (dispx),hl       ; set coords.
       ld b,179            ; length of line.
box0   call splot          ; plot point on screen.
       ld hl,dispx         ; coordinate.
       inc (hl)            ; move it along.
       djnz box0           ; repeat.
       ld b,179            ; length of line.
box1   call splot          ; plot point on screen.
       ld hl,dispy         ; coordinate.
       inc (hl)            ; move it along.
       djnz box1           ; repeat.
       ld b,179            ; length of line.
box2   call splot          ; plot point on screen.
       ld hl,dispx         ; coordinate.
       dec (hl)            ; move it along.
       djnz box2           ; repeat.
       ld b,179            ; length of line.
box3   call splot          ; plot point on screen.
       ld hl,dispy         ; coordinate.
       dec (hl)            ; move it along.
       djnz box3           ; repeat.
       ret

add10  ld hl,score+4       ; ten points.
       ld b,1              ; total to subtract.
       call uscor          ; increase score.
       ld hl,score         ; actual score.
       ld de,points        ; displayed score.
       ld bc,6             ; digits to transfer.
       ldir                ; copy them across.
       halt                ; pause.
       call dscore         ; show score.
       ld de,6             ; duration.
       ld hl,300           ; pitch.
       jp 949              ; short blip.

; Deduct stake.

dstak  ld hl,score+4       ; ten points.
       ld b,1              ; total to subtract.
       call rscor          ; reduce score.
       ld hl,score         ; actual score.
       ld de,points        ; displayed score.
       ld bc,6             ; digits to transfer.
       ldir                ; copy them across.
       halt                ; pause.
       call dscore         ; show score.
       ld de,15            ; duration.
       ld hl,500           ; pitch.
       jp 949              ; short blip.

enuff  ld hl,score+4       ; tens column.
       ld b,1              ; number to subtract.
       call cscor          ; check score can be reduced.
       ret

casino call cwin           ; clear window.
       call ram6           ; page in the sub-game.
       ld hl,23697         ; over control.
       ld (hl),0           ; set temporary and permanent overwrite mode.
       call 49152          ; play the game.
       ld hl,23697         ; over control.
       ld (hl),3           ; set temporary and permanent XOR mode.
       dec hl              ; change hl to 23695.
       dec hl
       ld (hl),68          ; set temporary attributes.
       call ram0           ; restore original bank.
       jp newlev           ; back to galaxy selection.


; Character set.

chrset defb 0,0,0,0,0,0,0,0

       defb 16,16,16,16,16,0,16,0              ; symbols.
       defb 40,40,0,0,0,0,0,0
       defb 40,40,254,40,254,40,40,0
       defb 28,34,64,248,64,34,28,0
       defb 66,164,72,16,36,74,132,0
       defb 48,72,40,80,138,132,122,0
       defb 16,16,0,0,0,0,0,0
       defb 16,32,32,32,32,32,16,0
       defb 16,8,8,8,8,8,16,0
       defb 16,84,56,254,56,84,16,0
       defb 0,16,16,124,16,16,0,0
       defb 0,0,0,0,0,0,8,16
       defb 0,0,0,124,0,0,0,0
       defb 0,0,0,0,0,0,16,0
       defb 2,4,8,16,32,64,128,0

       defb 124,130,130,130,130,130,124,0      ; numbers.
       defb 16,48,16,16,16,16,56,0
       defb 124,130,2,28,96,128,254,0
       defb 126,132,8,30,2,132,120,0
       defb 8,24,40,72,254,8,8,0
       defb 254,128,252,2,2,130,124,0
       defb 56,64,156,162,194,68,56,0
       defb 254,2,4,8,16,16,16,0
       defb 56,68,130,124,130,68,56,0
       defb 56,68,134,138,114,4,56,0


       defb 0,16,0,0,0,16,0,0                  ; 58 - 64.
       defb 0,8,0,0,0,0,8,16
       defb 0,12,48,192,48,12,0,0
       defb 0,0,124,0,124,0,0,0
       defb 0,96,24,6,24,96,0,0
       defb 120,132,4,24,32,0,32,0
       defb 60,66,154,170,156,64,62,0


       defb 16,16,40,40,68,124,130,0           ; letters.
       defb 248,132,136,176,136,132,248,0
       defb 60,66,128,128,128,66,60,0
       defb 224,144,136,132,130,132,248,0
       defb 60,66,128,248,128,66,60,0
       defb 60,66,128,240,128,128,128,0
       defb 60,66,128,142,130,66,62,0
       defb 130,130,130,254,130,130,130,0
       defb 56,16,16,16,16,16,56,0
       defb 6,2,2,2,2,132,120,0
       defb 128,144,160,208,136,132,130,0
       defb 192,128,128,128,128,128,254,0
       defb 130,198,170,146,130,130,130,0
       defb 130,194,162,146,138,134,130,0
       defb 56,68,130,130,130,68,56,0
       defb 248,132,130,130,252,128,128,0
       defb 56,68,130,130,138,70,62,0
       defb 252,130,132,136,240,136,134,0
       defb 60,66,128,124,2,132,120,0
       defb 254,16,16,16,16,16,16,0
       defb 130,130,130,130,130,68,56,0
       defb 130,68,68,40,40,16,16,0
       defb 130,130,130,146,170,198,130,0
       defb 130,68,40,16,40,68,130,0
       defb 130,130,68,40,16,16,16,0
       defb 254,2,12,48,64,128,254,0

       defb 56,32,32,32,32,32,56,0             ; symbols.
       defb 128,64,32,16,8,4,2,0
       defb 56,8,8,8,8,8,56,0
       defb 16,40,68,0,0,0,0,0
       defb 0,0,0,0,0,0,0,254
       defb 56,68,128,240,128,128,252,0

       defb 16,16,40,40,68,124,130,0           ; letters.
       defb 248,132,136,176,136,132,248,0
       defb 60,66,128,128,128,66,60,0
       defb 224,144,136,132,130,132,248,0
       defb 60,66,128,248,128,66,60,0
       defb 60,66,128,240,128,128,128,0
       defb 60,66,128,142,130,66,62,0
       defb 130,130,130,254,130,130,130,0
       defb 56,16,16,16,16,16,56,0
       defb 6,2,2,2,2,132,120,0
       defb 128,144,160,208,136,132,130,0
       defb 192,128,128,128,128,128,254,0
       defb 130,198,170,146,130,130,130,0
       defb 130,194,162,146,138,134,130,0
       defb 56,68,130,130,130,68,56,0
       defb 248,132,130,130,252,128,128,0
       defb 56,68,130,130,138,70,62,0
       defb 252,130,132,136,240,136,134,0
       defb 60,66,128,124,2,132,120,0
       defb 254,16,16,16,16,16,16,0
       defb 130,130,130,130,130,68,56,0
       defb 130,68,68,40,40,16,16,0
       defb 130,130,130,146,170,198,130,0
       defb 130,68,40,16,40,68,130,0
       defb 130,130,68,40,16,16,16,0
       defb 254,2,12,48,64,128,254,0

       defb 56,32,32,64,32,32,56,0             ; final symbols.
       defb 16,16,16,16,16,16,16,0
       defb 56,8,8,4,8,8,56,0
       defb 34,84,136,0,0,0,0,0
       defb 24,126,126,255,255,126,126,24


adtxt0 defb 22,1,8
       defb 'OTHER GAMES FROM'
       defb 22,3,4
       defb 'THE SAME AUTHOR INCLUDE:'
       defb 22,19,6
       defb 'WWW.CRONOSOFT.CO.UK'
       defb 22,21,6
       defb 'WWW.RETRO-SOFT.CO.UK'
adtxt1 defb 22,6,7
       defb 'HIGGLEDY@PIGGLEDY'
       defb 22,8,12
       defb 'FUN@PARK'
       defb 22,10,9
       defb 'ROUGH@JUSTICE'
       defb 22,12,7
       defb 'EGGHEAD@ENTERTAINS'
       defb 22,14,11
       defb 'IZZY@WIZZY'
adtxt2 equ $


; Colour screen twinkle.

ctwkp  defw 0              ; colour screen pointer.
ctwk   ld de,22528         ; attribute cells.
       ld bc,768           ; cells to colour.
       ld hl,(ctwkp)       ; pointer.
ctwk0  ld a,(hl)           ; get colour from ROM.
       inc hl              ; move pointer along.
       res 5,h             ; stay in ROM 0 - 8191.
       and 7               ; mask away unused bits.
       cp 5                ; in range 0-4?
       jr nc,ctwk0         ; no, try another.
       add a,66            ; red through yellow, bright.
       ld (de),a           ; write attributes.
       inc de              ; next cell.
       dec bc              ; one less cell to colour.
       ld a,b              ; high byte of cells remaining.
       or c                ; merge with low byte.
       jp nz,ctwk0         ; still cells to go.
       ld (ctwkp),hl       ; set new pointer value.
       ret



; Debug routine - not used in the game.

debug  ret                 ; toggle NOP/RET for debug on/off.
       ld hl,22528
       ld de,ebtab         ; enemy bullets table.
       ld b,24             ; bytes to check.
debug3 push bc
       ld a,(de)
       ld b,8
debug0 rla
       jr c,debug1
       ld (hl),8
       jr debug2
debug1 ld (hl),40
debug2 inc hl
       djnz debug0
       push de
       ld de,24
       add hl,de
       pop de
       inc de
       pop bc
       djnz debug3
       ret


; Move gun turrets' bullets.

moveb  ld ix,ebtab         ; enemy bullet table address.
       ld a,(ix)           ; bullet enabled flag.
       rla                 ; check leftmost bit.
       call nc,moveb0      ; not set, so bullet is enabled.
       ld ix,ebtab+6       ; second bullet address.
       ld a,(ix)           ; bullet enabled flag.
       rla                 ; check leftmost bit.
       jp nc,moveb0        ; not set, so bullet is enabled.
       ret




       defb "Blizzard's Rift "
       defb 'Version 1.0.    '
       defb 'Copyright 2007 Jonathan Cauldwell, all rights reserved.  '
       defb '                    '
       defb 'Congratulations, you have discovered the hidden message. '
       defb ' Notts County FC rule ok!  '
       defb 'Hello to Izzy, Deano and Ste.  '
       defb 'Easwig Addlethorpe will be returning to a Spectrum '
       defb 'near you soon...  '
       defb 'Time for tea methinks.  '
       defb 'Have you found the cheat mode yet?  '


       org 32741


enough jp enuff            ; enough credit?
win    jp add10            ; add 10 to credit.
stake  jp dstak            ; deduct stake.
hold   jp pause            ; pause routine.
trans  jp txfer            ; screen transfer routine.
       jp pscor            ; update score.
       jp hitshp           ; hit a ship so do the score.
       jp ftest            ; fire test routine.
       jp joykey           ; joystick and keyboard routines.

       org 32768

mloop  call moveb          ; move enemy's bullets.
       call shodro         ; show drones.
       call mvbul          ; move player's bullets.
       call debul          ; display enemy bullets.
       call haltr

       ld a,(pdead)        ; player dead flag.
       and a               ; is he dead?
       jr nz,skipc         ; yes, skip controls.

       call joykey         ; joystick or keyboard controls.

       and 2               ; rotate anticlockwise.
       call nz,rotl        ; rotate left.
       ld a,(joyval)       ; read input.
       and 1               ; rotate anticlockwise.
       call nz,rotr        ; rotate right.
       ld a,(joyval)       ; read input.
       and 8               ; forward.
       call z,nthrst       ; no thrust.
       call nz,thrust      ; thrust.
       ld a,(joyval)       ; read input.
       and 16              ; fire.
       call z,nofire       ; not pressed.
       call nz,fire        ; fire pressed.

       call gravty         ; gravity.
       call playmo         ; player movement.
       call getobj         ; get items.

skipc  call negtst         ; negative coordinate check.
       ld a,(nangle)       ; new angle.
       ld (angle),a        ; ship points here now.
       ld hl,(nshipx)      ; new ship coords.
       ld (shipx),hl       ; new ship position.

       call coldet         ; check for collision.

       call dbul           ; display player bullets.
       call psprit         ; display player sprite.
       call dshrp          ; draw shrapnel.
       call pause          ; pause routine.
       call txfer          ; transfer window to screen.
       call debul          ; delete enemy bullets.
       call dshrp          ; delete shrapnel.
       call mshrp          ; move shrapnel.
       call shodro         ; delete all drones.
       call movdrn         ; move our drones.
       call movgun         ; move the gun.
       call psprit         ; delete player sprite.
       call dbul           ; delete player bullets.
       call debug          ; debug screen.

mloop1 call schk           ; horizontal scroll check.
       call vscrol         ; vertical scroll.
       ld hl,framec        ; frame counter.
       inc (hl)            ; next frame.
       call pscor          ; check shown score is same.

       ld a,(dcount)       ; dead counter.
       and a               ; has it started yet?
       jp z,mloop          ; yes, don't restart it.
       inc a               ; start it off then.
       ld (dcount),a       ; set counter.
       jp nz,mloop         ; wait for a while.
       call cwin           ; clear the screen.
       ld hl,lives         ; number of lives.
       dec (hl)            ; one less.
       ret z               ; done.
       ld hl,(xptr)        ; start position marker address.
       ld (hl),X           ; make a mark.
       jp samlev           ; continue.



rotl   ld a,(nangle)       ; new angle.
       sub 8               ; rotate left.
       ld (nangle),a       ; next angle.
       ret
rotr   ld a,(nangle)       ; new angle.
       add a,8             ; clockwise rotation.
       ld (nangle),a       ; point here instead.
       ret


; Move ship vertically.

playmo ld a,(nshipx)       ; ship x integer.
       ld d,a              ; make this high byte.
       ld a,(nshpxf)       ; ship x fraction.
       ld e,a              ; make this high byte.
       ld hl,(inxf)        ; inertia.
       call add            ; combine the two.
       ld a,l              ; fraction/sign.
       ld (nshpxf),a       ; new fraction.
       ld a,h              ; integer.
       ld (nshipx),a       ; ship x integer.

; Move ship horizontally.

       ld a,(nshipy)       ; ship x integer.
       ld d,a              ; make this high byte.
       ld a,(nshpyf)       ; ship x fraction.
       ld e,a              ; make this high byte.
       ld hl,(inyf)        ; inertia.
       call add            ; combine the two.
       ld a,l              ; fraction/sign.
       ld (nshpyf),a       ; new fraction.
       ld a,h              ; integer.
       ld (nshipy),a       ; ship x integer.
       ret




; Horizontal scroll check.

schk   ld hl,hsleft        ; amount left to do.
       ld a,(hl)           ; see how many remaining.
       and a               ; anything left?
       jr z,stest          ; no - test coordinates again.
       dec (hl)            ; one less to do.
schkx  ld hl,nshipy        ; ship coordinate.
       ld a,(hstyp)        ; type of scrolling required.
       cp 252              ; hard left?
       jp z,scrr4          ; scroll screen right.
       cp 254              ; medium left?
       jp z,scrr2          ; scroll screen right.
       cp 255              ; soft left?
       jp z,scrr1          ; gently scroll screen right.
       cp 1                ; soft right?
       jp z,scrl1          ; yes, scroll screen left.
       cp 2                ; medium right?
       jp z,scrl2          ; yes, scroll screen left.
       cp 4                ; hard right?
       jp z,scrl4          ; yes, scroll screen left.
       ret

stest  ld hl,nshipy        ; horizontal coordinate.
       ld a,(hl)           ; where are we now?
       cp 88               ; leftmost 11 chars?
       jp nc,stest0        ; no, carry on.
       ld a,252            ; left 4.
       ld (hstyp),a        ; direction.
       jp stestx           ; set counter.
stest0 cp 96               ; leftmost 12 chars?
       jp nc,stest1        ; no, carry on.
       ld a,254            ; left 2.
       ld (hstyp),a        ; direction.
       jp stestx           ; set counter.
stest1 cp 104              ; leftmost 13 chars?
       jp nc,stest2        ; no, carry on.
       ld a,255            ; left 1.
       ld (hstyp),a        ; direction.
       jp stestx           ; set counter.
stest2 cp 136              ; rightmost 11 chars?
       jr nc,stest3        ; yes, scroll screen left.
       cp 128              ; rightmost 12 chars?
       jr nc,stest4        ; yes, gently scroll screen left.
       cp 120              ; rightmost 13 chars?
       jr nc,stest5        ; yes, gently scroll screen left.
       ret
stest3 ld a,4              ; right 4.
       ld (hstyp),a        ; direction.
       jp stestx           ; set counter.
stest4 ld a,2              ; right 2.
       ld (hstyp),a        ; direction.
       jp stestx           ; set counter.
stest5 ld a,1              ; right 1.
       ld (hstyp),a        ; direction.
stestx ld a,7              ; times to scroll.
       ld (hsleft),a       ; set counter.
       jp schkx

hstyp  defb 0              ; type of scrolling.
hsleft defb 0              ; Horizontal scrolling left to do.

nthrst ld a,(nflag)        ; thrust noise flag.
       and a               ; is it set?
       ret z               ; yes, nothing to do.
       call silenc         ; silence please.
cnoise xor a               ; clear accumulator.
       ld (nflag),a        ; set thrust noise flag.
       ret

; Move ship vertically.

thrust ld hl,fuel+4        ; fuel digits.
       ld b,1              ; total to subtract.
       call cscor          ; check fuel can decrease.
       jp c,blip           ; no fuel in tank.
       call woosh          ; sound effect.
       ld hl,fuel+4        ; fuel digits.
consum ld b,1              ; number to subtract.
       call rscor          ; decrease fuel.
       call dfuel          ; display fuel remaining.
       ld a,(nangle)       ; angle.
       and 248             ; only want bits d3-d7.
       call sin            ; get sine of this angle.
       ex de,hl
power0 ld de,1024          ; divide by this.
       call div
       ex de,hl
       ld a,(inxi)         ; ship x integer.
       ld h,a              ; make this high byte.
       ld a,(inxf)         ; ship x fraction.
       ld l,a              ; make this the low byte.
       call add            ; combine the two.
       ld a,l              ; fraction/sign.
       ld (inxf),a         ; new fraction.
       ld a,h              ; integer.
       ld (inxi),a         ; ship x integer.

; Now for the horizontal element.

       ld a,(nangle)       ; new angle.
       call cos            ; get sine of this angle.
       ex de,hl
power1 ld de,1024          ; divide by this.
       call div
       ex de,hl
       ld a,(inyi)         ; ship x integer.
       ld h,a              ; make this high byte.
       ld a,(inyf)         ; ship x fraction.
       ld l,a              ; make this the low byte.
       call add            ; add the two.
       ld a,l              ; fraction/sign.
       ld (inyf),a         ; new fraction.
       ld a,h              ; integer.
       ld (inyi),a         ; ship y integer.
       ret


; Gravity.

gravty ld de,12            ; gravity constant.
       ld a,(inxi)         ; ship x integer.
       ld h,a              ; make this high byte.
       ld a,(inxf)         ; ship x fraction.
       ld l,a              ; make this the low byte.
       call add            ; combine the two.
       ld a,l              ; fraction/sign.
       ld (inxf),a         ; new fraction.
       ld a,h              ; integer.
       ld (inxi),a         ; ship x integer.
       ret



; Display gun turrets' bullets.

debul  ld ix,ebtab         ; bullet table, first entry.
       ld a,(ix)           ; bullet enabled flag.
       rla                 ; check leftmost bit.
       call nc,debul0      ; not set, so bullet is enabled.
       ld ix,ebtab+6       ; second bullet address.
       ld a,(ix)           ; bullet enabled flag.
       rla                 ; check leftmost bit.
       ret c               ; set, bullet is disabled.
debul0 ld l,(ix+3)         ; x integer.
       ld h,(ix+5)         ; y integer.
       ld (dispx),hl       ; workspace coordinates.
       jp wplot            ; plot first position.


; Display player's bullets.

dbul   ld b,6              ; bullets to move.
       ld ix,bultab        ; bullet table address.
       ld de,6             ; six bytes required per bullet.
dbul1  ld a,(ix)
       rla                 ; check leftmost bit.
       call nc,dbul0       ; not set, so bullet is enabled.
       add ix,de           ; point ix at next one.
       djnz dbul1          ; repeat for all bullets.
       ret
dbul0  exx                 ; flip loop register into alternate set.
       ld l,(ix+3)         ; x integer.
       ld h,(ix+5)         ; y integer.
       ld (dispx),hl       ; workspace coordinates.
       call wplot          ; plot or unplot present position.
       exx                 ; restore b register.
       ret

; Move player's bullets.

mvbul  ld b,6              ; bullets to move.
       ld ix,bultab        ; bullet table address.
mvbul1 ld a,(ix)
       rla                 ; check leftmost bit.
       call nc,mvbul0      ; not set, so bullet is enabled.
       ld de,6             ; six bytes required per bullet.
       add ix,de           ; point ix at next one.
       djnz mvbul1         ; repeat for all bullets.
       ret
mvbul0 push bc             ; store counter.
       ld a,(ix+1)         ; what is the angle?
       call sin            ; get sine of this angle.
       call octuhl         ; octuple it.
       ld e,(ix+2)         ; fraction of x.
       ld d,(ix+3)         ; integer of x.
       call add            ; add the sine.
       ld (ix+2),l         ; new fraction.
       ld (ix+3),h         ; new integer.
       rr l                ; x gone negative?
       jp c,kilbul         ; yes, bullet off screen.
       ld a,(ix+1)         ; what is the angle?
       call cos            ; get cosine of this angle.
       call octuhl         ; octuple it.
       ld e,(ix+4)         ; fraction of y.
       ld d,(ix+5)         ; integer of y.
       call add            ; add the sine.
       ld (ix+4),l         ; new fraction.
       ld (ix+5),h         ; new integer.
       rr l                ; get sign.
       jr c,kilbul         ; it's gone negative, remove bullet.
       ld a,h              ; get integer bit in accumulator.
       cp 208              ; right side of screen check.
       jr nc,kilbul        ; going past right edge, remove it.
;       cp 32               ; left side of screen check.
       cp 16               ; left side of screen check.
       jr c,kilbul         ; going past left edge, remove it.
       ld l,(ix+3)         ; x integer.
       ld h,(ix+5)         ; y integer.
       ld (dispx),hl       ; workspace coordinates.

; Now check back screen for collision with walls.

       call wpoint         ; back screen address.
       jr nz,gunch         ; hit something, check if it's a gun.

; Bullet came through unscathed so plot it at its new position.

mvbul2 pop bc              ; restore loop counter.
       ret

gunch  call blkad          ; find address of block at this point.
       ld a,(hl)           ; fetch type.
       cp TURRET           ; is it a turret?
       jr z,kturr          ; yes, kill it off.
       call drchk          ; check for drones at this point.


; Kill bullet.

kilbul ld (ix),128         ; set flag to switch it off.
       jr mvbul2           ; rejoin loop.

kturr  call hitgun         ; remove the gun.
       push ix             ; store pointer.
       call explod         ; explosion.
       pop ix              ; restore pointer.
       jr kilbul           ; and the bullet too.


inxf   defb 0              ; inertia x fraction.
inxi   defb 0              ; inertia x integer.
inyf   defb 0              ; inertia y fraction.
inyi   defb 0              ; inertia y integer.

sqbuf0 defw 0
sqbuf1 defw 0
sqbuf2 defw 0
mtbuff defw 0              ; maths buffer.
angle  defb 0              ; direction facing.
nangle defb 0              ; new angle.
shipx  defb 0              ; ship x coord.
shipy  defb 0              ; ship y coord.
nshipx defb 0              ; new ship x coord.
nshipy defb 0              ; new ship y coord.
nshpxf defb 0              ; new ship x coord.
nshpyf defb 0              ; new ship y coord.


; Shift bullets according to scrolling.

sbul   ld de,5             ; distance to y position.
       ld hl,bultab        ; table of bullets.
       call sbul0          ; test.
       ld hl,bultab+6      ; table of bullets.
       call sbul0          ; test.
       ld hl,bultab+12     ; table of bullets.
       call sbul0          ; test.
       ld hl,bultab+18     ; table of bullets.
       call sbul0          ; test.
       ld hl,bultab+24     ; table of bullets.
       call sbul0          ; test.
       ld hl,bultab+30     ; table of bullets.
       call sbul0          ; test.
       ld hl,bultab+36     ; table of bullets.
       call sbul0          ; test.
       ld hl,bultab+42     ; table of bullets.

sbul0  ld a,(hl)           ; on/off flag.
       rla                 ; check it's enabled.
       ret c               ; it isn't, ignore entry.
       add hl,de           ; point to y position.
       ld a,(hl)           ; fetch y coordinate.
       add a,c             ; add displacement.
       ld (hl),a           ; new value.
       cp 208              ; off right edge?
       jr nc,sbul1         ; yes - kill it.
       cp 16               ; off left edge?
       ret nc              ; no, it's fine.
       and a               ; clear carry dlag.
sbul1  sbc hl,de           ; back to on/off flag.
       ld (hl),128         ; switch it off.
       ret





; Search sine table for arcsine of de and return angle in a.
; Passing a negative sine may slightly reduce accuracy.

asn    ld hl,arcsin-1      ; sine table.
       ld (mtbuff),hl      ; current sine.
       xor a               ; default angle = 0.
asn1   ex af,af'           ; store in alternate accumulator.
       ld hl,(mtbuff)      ; current sine.
       ld b,(hl)           ; positive sine value now in bc.
       dec hl              ; move pointer along.
       ld c,(hl)           ; high byte byte.
       dec hl              ; move pointer along.
       ld (mtbuff),hl      ; store sine pointer.
       ex de,hl            ; put original sine in hl.
       push hl             ; store original sine.
       sbc hl,bc           ; compare two values.
       pop de              ; original sine back in de.
       jr c,asn0           ; table is higher, found our match.
       jr z,asn0           ; values identical, found our match.
       ex af,af'           ; angle.
       inc a               ; next angle.
       jp asn1             ; keep looking.
asn0   ex af,af'           ; restore angle.
       neg                 ; negate result.
       add a,64            ; effectively subtract from 64.
       ret

; Divide hl by d and return in hl.

idiv   xor a               ; HL = HL / D
       ld c,a              ; zeroise c.
       ld e,a              ; zeroise e.
       call idiv4
       push af
       xor a
       ld c,a
       ld d,a
       call idiv4
       pop hl
       ld l,h
       ld h,a
       ret
idiv4  ld b,8
idiv1  rr d
       rr e
       rr c
       ex af,af'           ; store flag.
       xor a               ; zeroise accumulator.
       cp c                ; is c zero?
       jr z,idiv2          ; yes.
       ex af,af'           ; restore flags.
idiv3  rla                 ; rotate into right of accumulator.
       and a               ; reset carry.
       djnz idiv1          ; repeat 8 times.
       ret
idiv2  ex af,af'
       ld (mtbuff),hl
       sbc hl,de
       ccf
       jr c,idiv3
       ld hl,(mtbuff)
       jp idiv3

; Return square root of hl in accumulator.

isqr   ld (sqbuf0),hl      ; number for which we want to find square root.
       xor a               ; zeroise accumulator.
       ld (sqbuf2),a       ; result buffer.
       ld a,128            ; start division with highest bit.
       ld (sqbuf1),a       ; next divisor.
       ld b,8              ; 8 bits to divide.
isqr1  push bc             ; store loop counter.
       ld a,(sqbuf2)       ; current result.
       ld d,a
       ld a,(sqbuf1)       ; next bit to check.
       or d                ; combine with divisor.
       ld d,a              ; store low byte.
       xor a               ; HL = HL / D
       ld c,a              ; zeroise c.
       ld e,a              ; zeroise e.
       push de             ; remember divisor.
       ld hl,(sqbuf0)      ; original number.
       call idiv4          ; divide number by d.
       pop de              ; restore divisor.
       cp d                ; is divisor greater than result?
       jr c,isqr0          ; yes, don't store this bit then.
       ld a,d
       ld (sqbuf2),a       ; store new divisor.
isqr0  ld hl,sqbuf1        ; bit we tested.
       and a               ; clear carry flag.
       rr (hl)             ; next bit to right.
       pop bc              ; restore loop counter.
       djnz isqr1          ; repeat
       ld a,(sqbuf2)       ; return result in hl.
       ret

; Get cosine of angle passed in the accumulator, and return in de pair.

cos    add a,64            ; DE = cosine A.

; Find sine of angle in accumulator, return in de registers.

sin    ld hl,sine          ; DE = sine A.
       ld d,0              ; zeroise high byte.
       and a               ; clear carry flag.
       rla                 ; multiply accumulator by 2.
       rl d                ; shift top bit into high byte.
       ld e,a              ; put remainder in low byte.
       add hl,de           ; add displacement to start of table.
       ld e,(hl)           ; get low value of sine value.
       inc hl              ; njext byte along.
       ld d,(hl)           ; fetch high byte.
       ret

; Search sine table for arcsine of de and return angle in a.
; Passing a negative sine may slightly reduce accuracy.

; 16-bit mathematics routines.
; 8 bits=integer
; 7 bits=decimal places
; 1 bit sign.

sub    ld a,1              ; HL = HL - DE
       xor e
       ld e,a
add    ld a,l              ; HL = HL + DE
       and 1
       ld c,a
       ld a,e
       and 1
       xor c
       jr nz,add1
       res 0,l
       res 0,e
       add hl,de
       ld a,l
       or c
       ld l,a
       ret
add1   bit 0,c
       jr z,add3
       ex de,hl
add3   res 0,l
       res 0,e
       sbc hl,de
       jr c,add2
       ret
add2   ex de,hl
       ld hl,2
       sbc hl,de
       ret
div    ld a,l              ; HL = HL / DE
       xor e
       and 1
       push af
       xor a
       ld c,d
       ld d,e
       ld e,a
       call div4
       push af
       call div4
       and 254
       ld l,a
       pop de
       pop af
       or l
       ld l,a
       ld h,d
       ret
div4   ld b,8
div1   rr c
       rr d
       rr e
       ex af,af'
       xor a
       cp c
       jr z,div2
       ex af,af'
div3   rla
       and a
       djnz div1
       ret
div2   ex af,af'
       ld (mtbuff),hl
       sbc hl,de
       ccf
       jr c,div3
       ld hl,(mtbuff)
       jp div3

; Multiply hl by de and return in hl.

mul    ld a,l              ; sign of hl.
       xor e               ; merge with sign of de.
       and 1               ; now in accumulator.
       push af             ; store sign
       res 0,l             ; clear sign of hl.
       ld a,e              ; de low to accumulator.
       and 254             ; remove sign.
       ld e,d              ; high byte of de to e.
       ld b,h
       ld c,l
       ld hl,0
       ld d,h
       ex af,af'
       ld a,16
mul1   ex af,af'           ; store counter in alternate set.
       rr b
       rr c
       jr nc,mul2          ; bit not set, no addition this time.
       add hl,de           ; add to total.
       and a               ; clear carry.
mul2   rla
       rl e
       rl d
       ex af,af'           ; restore counter.
       dec a               ; one less iteration.
       jp nz,mul1          ; keep going.
       ld a,l              ; result fraction/sign.
       and 254             ; mask off sign.
       pop bc              ; restore sign in b.
       or b                ; combine with accumulator.
       ld l,a              ; add sign to hl.
       ret

; Multiply h by d and return in hl.

imul   ld e,d              ; HL = H * D
       ld c,h              ; make c first multiplier.
       ld hl,0             ; zeroise total.
       ld d,h              ; zeroise high byte so de=multiplier.
       ld b,8              ; repeat 8 times.
imul1  rr c                ; rotate rightmost bit into carry.
       jr nc,imul2         ; wasn't set.
       add hl,de           ; bit was set, so add de.
       and a               ; reset carry.
imul2  rl e                ; shift de 1 bit left.
       rl d
       djnz imul1          ; repeat 8 times.
       ret

quadhl ex de,hl
       ld a,l              ; store sign in accumulator.
       res 0,l             ; clear sign.
       add hl,hl           ; double it.
       rra                 ; rotate sign into carry.
       adc hl,hl           ; quadruple hl.
       ret



octuhl ex de,hl
       ld a,l              ; store sign in accumulator.
       res 0,l             ; clear sign.
       add hl,hl           ; double hl.
       add hl,hl           ; quadruple hl.
       rra                 ; rotate sign into carry.
       adc hl,hl           ; octuple it.
       ret


; Sine table.

sine   defb 1,1,1,1,1,1,1,1,255,0,255,0,255,0,253,0
       defb 253,0,251,0,249,0,247,0,245,0,245,0,243,0,239,0
       defb 237,0,235,0,233,0,229,0,227,0,223,0,221,0,217,0
       defb 213,0,211,0,207,0,203,0,199,0,195,0,191,0,187,0
       defb 183,0,177,0,173,0,169,0,163,0,159,0,153,0,149,0
       defb 143,0,137,0,133,0,127,0,121,0,117,0,111,0,105,0
       defb 99,0,93,0,87,0,81,0,75,0,69,0,63,0,57,0
       defb 51,0,45,0,39,0,33,0,27,0,19,0,13,0,7,0

       defb 0,0,6,0,12,0,18,0,24,0,32,0,38,0,44,0
       defb 50,0,56,0,62,0,68,0,74,0,80,0,86,0,92,0
       defb 98,0,102,0,108,0,114,0,120,0,126,0,130,0,136,0
       defb 142,0,146,0,152,0,156,0,162,0,166,0,170,0,176,0
       defb 180,0,184,0,188,0,192,0,196,0,200,0,204,0,208,0
       defb 212,0,216,0,218,0,222,0,224,0,228,0,230,0,234,0
       defb 236,0,238,0,240,0,242,0,244,0,246,0,248,0,248,0
       defb 250,0,252,0,252,0,254,0,254,0,254,0,254,0,254,0

       defb 0,1,254,0,254,0,254,0,254,0,254,0,252,0,252,0
       defb 250,0,248,0,248,0,246,0,244,0,242,0,240,0,238,0
       defb 236,0,234,0,230,0,228,0,224,0,222,0,218,0,216,0
       defb 212,0,208,0,204,0,200,0,196,0,192,0,188,0,184,0
       defb 180,0,176,0,170,0,166,0,162,0,156,0,152,0,146,0
       defb 142,0,136,0,130,0,126,0,120,0,114,0,108,0,102,0
       defb 96,0,92,0,86,0,80,0,74,0,68,0,62,0,56,0
       defb 48,0,42,0,36,0,30,0,24,0,18,0,12,0,6,0

arcsin defb 0,0,7,0,13,0,19,0,27,0,33,0,39,0,45,0
       defb 51,0,57,0,63,0,69,0,75,0,81,0,87,0,93,0
       defb 99,0,105,0,111,0,117,0,121,0,127,0,133,0,137,0
       defb 143,0,149,0,153,0,159,0,163,0,169,0,173,0,177,0
       defb 183,0,187,0,191,0,195,0,199,0,203,0,207,0,211,0
       defb 213,0,217,0,221,0,223,0,227,0,229,0,233,0,235,0
       defb 237,0,239,0,243,0,245,0,245,0,247,0,249,0,251,0
       defb 253,0,253,0,255,0,255,0,255,0,1,1,1,1,1,1


coldet ld a,(pdead)        ; is player alive?
       and a               ; zero means we're okay.
       ret nz              ; no, so collisions are off.
       ld (stptr),sp       ; store stack pointer.
       ld b,16             ; height of sprite.
       exx                 ; flip into alternate register set.
       di                  ; interrupts off.

       ld hl,(shipx)       ; player's coordinates.
       ld (dispx),hl       ; copy them into general purpose coords.
       ld hl,spdat         ; player sprite data.
       ld a,(dispy)        ; y coordinate.
       and 7               ; 8 pre-shifted positions.
       rlca                ; multiply by 1024.
       rlca
       ld d,a              ; high byte of displacement.
       ld e,0              ; no low byte.
       add hl,de           ; add y coordinate shift displacement.
       ld a,(angle)        ; angle we're facing.
       rlca                ; multiply by 32 and divide by 4.
       rlca
       ld e,a              ; store result.
       and 3               ; high mask.
       ld d,a              ; high byte.
       ld a,e              ; restore result.
       and 224             ; low mask.
       ld e,a              ; sprite displacement now in de.
       add hl,de           ; add disp for this sprite.

       push hl             ; remember sprite image.
       call wadd           ; get window address.
       push hl             ; remember address.

       ld a,(dispy)        ; sprites are pre-shifted so find y coord.
       and 7               ; position within byte boundary.
       rlca                ; multiple of 2.
       ld hl,spmask        ; pointer to mask table.
       ld e,a              ; low byte.
       ld d,0              ; only want small displacement.
       add hl,de           ; add displacement to pointer.
       ld e,(hl)           ; left mask.
       inc hl              ; next byte of mask table.
       ld d,(hl)           ; right edge mask.
       pop hl              ; retrieve address of window.
       pop bc              ; sprite image in bc.
       ld sp,22            ; width of window.

       exx                 ; flip counter back from alternate set.
cold0  exx                 ; store counter in alternate set.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       and (hl)            ; merge with window image.
       jr nz,kilp          ; player hit something.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       and (hl)            ; merge with window pixels.
       jr nz,kilp          ; player hit something.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       and (hl)            ; combine with existing window.
       jr nz,kilp          ; player hit something.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line.
       exx                 ; flip counter back from alternate set.
       djnz cold0          ; repeat.
       ld sp,(stptr)       ; restore stack pointer.
       ei                  ; interrupts back on.
       ret
kilp   ld sp,(stptr)       ; restore stack pointer.
       ei                  ; interrupts back on.
       ld a,192            ; death counter.
       ld (dcount),a       ; start it off.
       ld (pdead),a        ; kill player.
       ld a,(nshipx)       ; ship x.
       add a,7             ; half-way down.
       ld (dispx),a        ; set explosion x.
       ld a,(nshipy)       ; ship y.
       add a,7             ; half-way across.
       ld (dispy),a        ; set explosion y.
       jp explod           ; start an explosion.






; Sprites are held in 8 pre-shifted forms, in efficient wrap-around format.
; To display a sprite, point hl at the graphic image and perform this:

; Drone sprites.

sprite ld a,(dispy)        ; y coordinate.
       and 7               ; 8 pre-shifted positions.
       rrca
       rrca
       rrca                ; multiply by 32.
       ld e,a              ; low byte of displacement.
       ld d,0              ; no high byte, maximum is 7 * 32 = 224.
       add hl,de           ; add y coordinate shift displacement.


; Draw/delete sprite.


xfer   di                  ; disable interrupts.
       push hl             ; remember sprite image.
       call wadd           ; get window address.
       push hl             ; remember address.
       ld a,(dispy)        ; sprites are pre-shifted so find y coord.
       and 7               ; position within byte boundary.
       rlca                ; multiple of 2.
       ld hl,spmask        ; pointer to mask table.
       ld e,a              ; low byte.
       ld d,0              ; only want small displacement.
       add hl,de           ; add displacement to pointer.
       ld e,(hl)           ; left mask.
       inc hl              ; next byte of mask table.
       ld d,(hl)           ; right edge mask.
       pop hl              ; retrieve address of window.
       pop bc              ; sprite image in bc.

       ld (stptr),sp       ; store stack pointer.

       ld sp,22            ; width of window.

; Now transfer to window.

       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.
       inc bc              ; second source byte.
       inc bc              ; next line of source.
       add hl,sp           ; next line down.
       ld a,(bc)           ; first source byte.
       and e               ; left bitmask.
       xor (hl)            ; merge with window image.
       ld (hl),a           ; new window image.
       inc bc              ; second byte.
       inc hl              ; next window position.
       ld a,(bc)           ; source graphic.
       xor (hl)            ; merge with window pixels.
       ld (hl),a           ; new bitmap.
       dec bc              ; first source byte.
       inc hl              ; next window byte.
       ld a,(bc)           ; fetch source.
       and d               ; right bitmask.
       xor (hl)            ; combine with existing window.
       ld (hl),a           ; new graphic image.

jac    ld sp,(stptr)       ; restore stack pointer.
       ei                  ; enable interrupts again.
       ret


; Window plotting.

wpoint call wpixad         ; window point.
       ld a,(hl)           ; data there.
       and c               ; test pixel.
       ret nz              ; hit!
       inc hl              ; next pixel.
       ld a,(hl)           ; find image there.
       and b               ; test pixel.
       ret nz              ; hit!
       ld de,23            ; distance to next line.
       add hl,de           ; point to next one.
       ld a,(hl)           ; data there.
       and c               ; test pixel.
       ret nz              ; hit!
       inc hl              ; next pixel.
       ld a,(hl)           ; find image there.
       and b               ; test pixel.
       ret

wplot  call wpixad         ; window point.
       ld a,(hl)           ; first graphic address.
       xor c               ; combine with pixel.
       ld (hl),a           ; new value.
       inc hl              ; next pixel.
       ld a,(hl)           ; second graphic address.
       xor b               ; combine with pixel.
       ld (hl),a           ; new value.
       ld de,23            ; width.
       add hl,de           ; point to next line.
       ld a,(hl)           ; first graphic address.
       xor c               ; combine with pixel.
       ld (hl),a           ; new value.
       inc hl              ; next pixel.
       ld a,(hl)           ; second graphic address.
       xor b               ; combine with pixel.
       ld (hl),a           ; new value.
       ret

wpixad ld a,(dispy)        ; horizontal position.
       and 7               ; position straddling character cells.
       rlca                ; multiply by 2.
       ld d,0              ; zero high byte of de.
       ld e,a              ; displacement in de.
       ld hl,wpixel        ; pixels.
       add hl,de           ; point to pixels.
       ld c,(hl)           ; first pixel.
       inc hl              ; next pixel.
       ld b,(hl)           ; second pixel.
       jp wadd             ; find window address.

wpixel defb 192,0,96,0,48,0,24,0,12,0,6,0,3,0,1,128


; Calculate window address.
; x coordinates need multiplying by 24, so that's 16 + 8.

wadd   ld a,(dispx)        ; x coord.
       ld h,0              ; no high byte yet.
       ld l,a              ; low byte in l.
       add hl,hl           ; multiply by 2.
       add hl,hl           ; multiple of 4.
       add hl,hl           ; multiple of 8.
       ld d,h              ; copy total to de.
       ld e,l
       add hl,hl           ; multiple of 16.
       add hl,de           ; add multiple of 8.
       ld a,(dispy)        ; y coordinate.
       rra                 ; divide by 8.
       rra
       rra
       and 31              ; remove bits shifted in from left.
       ld e,a              ; low byte.
       ld d,0              ; zero high byte.
       add hl,de           ; add y displacement.
       ld de,window-2      ; address of window.
       add hl,de           ; add to displacement.
       ret                 ; address of window in hl.



; Gun table.
; 0 = on/off.
; 1 = angle.
; 2 = table address low byte.
; 3 = table address high byte.

guntab call ram0           ; ram 0.
       ld hl,65534         ; penultimate of bank.
       ld (hl),l           ; set to 254.
       call ram1           ; ram 1.
       ld (hl),h           ; set to 255.
       call ram0           ; ram 0.
       ld a,(hl)           ; fetch contents.
       cp l                ; set to original 254?
       jr nz,set48         ; no, so we're in 48K mode.
       ret



; Set up 48K routines.

set48  ld de,set48t        ; text message.
       ld bc,set48e-set48t ; length.
       call 8252           ; display message.
set48a jr set48a
set48t defb 22,0,0
       defb 'LOAD IN 48K MODE'
set48e equ $



dronet equ guntab + 32
       org guntab + 68


; Drone table.
; 0 = on/off.
; 1 = direction moving.
; 2 = table address low byte.
; 3 = table address high byte.
; 4 = tile position, 0-15.




; RAM bank paging routines.

ram6   ld a,22             ; RAM 6 = casino.
       jr ram1a
ram4   ld a,23             ; RAM 4 = starfield.
       jr ram1a
ram0   ld a,16             ; zero.
       jr ram1a
ram1   ld a,17             ; want 1 in accumulator.
ram1a  di                  ; disable interrupts.
       ld bc,32765         ; memory paging port.
       out (c),a           ; page in RAM 1.
       ei                  ; re-enable interrupts.
       ret                 ; done.



; Transfer window to screen.

txfer  ld a,(viewx)        ; window view x coord.
       ld h,0              ; no high byte yet.
       ld l,a              ; low byte in l.
       add hl,hl           ; multiply by 2.
       add hl,hl           ; multiple of 4.
       add hl,hl           ; multiple of 8.
       ld d,h              ; copy total to de.
       ld e,l
       add hl,hl           ; multiple of 16.
       add hl,de           ; add multiple of 8.
       ld de,window+2      ; buffer to move.
       add hl,de           ; add displacement for window view.
       ld de,CH001         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH001+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH001+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH001+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH001+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH001+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH001+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH001+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH002         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH002+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH002+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH002+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH002+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH002+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH002+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH002+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH003         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH003+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH003+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH003+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH003+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH003+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH003+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH003+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH004         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH004+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH004+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH004+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH004+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH004+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH004+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH004+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH005         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH005+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH005+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH005+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH005+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH005+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH005+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH005+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH006         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH006+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH006+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH006+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH006+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH006+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH006+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH006+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH007         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH007+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH007+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH007+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH007+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH007+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH007+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH007+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH008         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH008+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH008+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH008+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH008+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH008+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH008+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH008+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH009         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH009+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH009+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH009+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH009+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH009+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH009+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH009+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH010         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH010+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH010+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH010+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH010+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH010+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH010+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH010+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH011         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH011+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH011+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH011+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH011+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH011+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH011+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH011+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH012         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH012+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH012+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH012+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH012+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH012+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH012+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH012+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH013
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH013+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH013+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH013+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH013+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH013+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH013+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH013+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH014         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH014+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH014+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH014+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH014+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH014+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH014+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH014+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH015         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH015+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH015+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH015+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH015+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH015+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH015+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH015+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH016         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH016+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH016+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH016+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH016+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH016+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH016+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH016+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH017         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH017+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH017+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH017+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH017+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH017+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH017+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH017+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH018         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH018+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH018+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH018+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH018+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH018+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH018+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH018+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH019         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH019+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH019+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH019+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH019+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH019+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH019+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH019+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH020         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH020+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH020+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH020+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH020+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH020+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH020+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH020+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH021         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH021+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH021+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH021+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH021+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH021+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH021+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH021+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH022         ; the very first pixel line of the window.
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH022+256
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH022+512
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH022+768
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH022+1024
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH022+1280
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH022+1536
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       inc l
       inc l
       ld de,CH022+1792
       ldi                 ; transfer byte 1.
       ldi                 ; transfer byte 2.
       ldi                 ; transfer byte 3.
       ldi                 ; transfer byte 4.
       ldi                 ; transfer byte 5.
       ldi                 ; transfer byte 6.
       ldi                 ; transfer byte 7.
       ldi                 ; transfer byte 8.
       ldi                 ; transfer byte 9.
       ldi                 ; transfer byte 10.
       ldi                 ; transfer byte 11.
       ldi                 ; transfer byte 12.
       ldi                 ; transfer byte 13.
       ldi                 ; transfer byte 14.
       ldi                 ; transfer byte 15.
       ldi                 ; transfer byte 16.
       ldi                 ; transfer byte 17.
       ldi                 ; transfer byte 18.
       ldi                 ; transfer byte 19.
       ldi                 ; transfer byte 20.
       ldi                 ; transfer byte 21.
       ldi                 ; transfer byte 22.
       ret


       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

levbuf defb 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
       defb 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2
       defb 0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,2
       defb 0,0,0,1,1,1,1,1,1,0,0,0,1,1,1,2
       defb 0,0,0,1,0,0,0,0,1,0,0,0,1,1,1,2
       defb 0,0,0,1,0,0,0,0,1,0,0,0,1,1,1,2
       defb 0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,2
       defb 0,0,0,1,0,0,0,0,1,0,0,0,P,0,0,2
       defb 0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,2
       defb 0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,2
       defb 0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,2
       defb 0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,2
       defb 0,0,0,1,0,0,0,3,1,0,0,0,X,1,1,2
       defb 0,0,0,1,0,0,0,0,1,0,0,0,0,1,1,2
       defb 1,1,1,1,0,0,0,3,1,0,0,0,0,1,1,2
       defb 0,0,0,0,0,0,0,0,1,0,0,1,1,1,1,2
       defb 0,0,T,0,0,0,0,3,1,0,0,1,1,1,1,2
       defb 0,0,0,0,0,0,0,0,1,0,0,1,1,1,1,2
       defb 0,0,0,0,0,0,0,3,1,0,0,1,1,1,1,2
       defb 0,0,0,P,0,0,0,0,1,0,0,1,1,1,1,2
       defb 0,0,0,0,0,0,0,0,1,0,0,1,1,1,1,2
       defb 0,0,0,0,0,0,0,0,1,0,0,1,1,1,1,2
       defb 0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,2
       defb 0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,2
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
       defb 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,P,0,0,0,0,0,0,0,0,0,2
       defb 0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,2
       defb 0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,2
       defb 0,0,0,0,2,0,0,0,0,0,0,0,1,1,1,2
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2
       defb 0,0,0,0,0,1,0,0,0,2,0,0,0,0,1,2
       defb 0,0,0,0,0,1,0,0,0,0,0,0,0,0,1,2
       defb 0,0,0,0,0,1,0,0,2,0,0,0,0,0,1,2
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2
       defb 0,0,0,0,0,0,0,2,0,1,1,1,1,1,1,2
       defb 0,0,0,0,0,0,2,2,0,1,1,1,1,1,1,2
       defb 1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,2
       defb 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2

       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
tiles  defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0



; tiles  defw 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0



       defb 0,1,85,85,42,171,64,5,42,171,69,93,42,171,69,93
       defb 42,171,69,93,42,171,69,93,47,251,85,85,42,171,255,255

;       defb 170,170,1,127,170,232,23,85,170,232,23,85,190,128,85,85
;       defb 170,170,127,3,232,170,85,23,232,170,85,23,192,254,85,85

       defb 0,0,255,254,191,250,255,254,255,254,255,254,255,254,255,254
       defb 255,254,255,254,255,254,255,254,255,254,255,254,191,250,255,254

;       defb 239,239,175,234,239,239,160,224,254,254,170,254,254,254,10,14
;       defb 239,239,234,175,239,239,224,160,254,254,254,170,254,254,14,10


; Teleporter tile.

telsp  defb 255,255,128,1,191,253,191,253,191,253,179,205,131,193,131,193
       defb 131,193,131,193,131,193,131,193,135,225,135,225,128,1,255,255


; Diamond.

       defb 1,128,7,224,27,56,103,142,159,195,224,63,159,193,159,193
       defb 207,195,103,134,51,140,27,24,13,48,6,96,3,192,1,128


; Turret tile.


       defb 0,0,0,0,3,192,14,240,24,248,51,252,35,252,33,124
       defb 143,255,143,255,0,0,79,254,0,0,39,252,0,0,39,252

; Chain and girder.

       defb 12,48,12,48,12,48,13,176,5,160,1,128,1,128,1,128
       defb 1,128,1,128,1,128,5,160,13,176,12,48,12,48,12,48
       defb 12,48,12,48,12,48,14,48,7,112,2,32,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 0,0,255,255,255,255,112,14,56,28,28,56,14,112,255,255
       defb 255,255,14,112,28,56,56,28,112,14,255,255,255,255,0,0


; Platforms.

       defb 127,254,255,255,255,255,239,239,3,199,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
       defb 247,134,255,223,255,255,255,255,28,252,0,0,0,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


; Trees.

       defb 0,0,0,0,3,176,15,252,15,252,29,238,27,230,18,210
       defb 16,210,0,192,0,192,1,192,1,192,1,128,3,128,3,128
       defb 3,0,7,240,31,248,63,216,107,236,105,172,201,164,201,132
       defb 67,132,67,128,3,128,3,0,7,0,7,0,15,128,15,192
       defb 61,224,111,184,159,152,63,200,119,236,102,228,102,96,103,64
       defb 39,64,35,0,3,128,3,128,3,128,1,192,1,224,1,240

; Bricks.

       defb 128,0,213,84,170,170,213,84,170,170,213,84,170,170,255,255
       defb 0,128,84,213,170,170,84,213,170,170,84,213,170,170,255,255

; Squares with holes.

       defb 255,255,255,255,252,63,240,15,224,7,224,7,192,3,192,3
       defb 192,3,192,3,224,7,224,7,240,15,252,63,255,255,255,255


; Hard left scroll routine.

scrl4  ld a,(scrolc)       ; scroll count.
       and 3               ; pixel remainder.
       jr z,scrl4a         ; it's fine to scroll 4 pixels.
       cp 3                ; remainder 1?
       jr z,scrl1          ; yes, scroll one pixel.
       jr scrl2            ; scroll two pixels.
scrl4a ld a,(hl)           ; pixels.
       sub 4               ; 4 pixels left.
       ld (hl),a           ; new position.
       ld c,252            ; pixels to scroll.
       call sbul           ; shift bullets accordingly.
       call sleft4         ; scroll left 4 pixels.
       ld hl,scrolc        ; scroll count.
       ld a,(hl)           ; current value.
       add a,4             ; increment it.
       ld (hl),a           ; new value.
       and 15              ; reached 16th pixel?
       jp z,tilel          ; drop in new tiles.
       ret


; Left scroll routine.

scrl1  dec (hl)            ; move 1 pixel left.
       call sleft1         ; scroll left 1 pixel please.
       ld c,255            ; pixels scrolled.
       call sbul           ; shift bullets accordingly.
       ld hl,scrolc        ; scroll count.
       inc (hl)            ; pre-increment it.
       ld a,(hl)           ; get count.
       and 15              ; reached 16th pixel?
       jp z,tilel          ; drop in new tiles.
       ret

; Left scroll routine.

scrl2  dec (hl)            ; move 2 pixels left.
       dec (hl)
       ld c,254            ; pixels to scroll.
       call sbul           ; shift bullets accordingly.
       call sleft1         ; scroll left 1 pixel please.
       ld hl,scrolc        ; scroll count.
       inc (hl)            ; pre-increment it.
       ld a,(hl)           ; get count.
       and 15              ; reached 16th pixel?
       jp nz,scrl2a        ; no, don't drop new tiles in.
       call tilel          ; drop in some new tiles.
scrl2a call sleft1         ; scroll left 1 pixel.
       ld hl,scrolc        ; scroll count.
       inc (hl)            ; pre-increment it.
       ld a,(hl)           ; get count.
       and 15              ; reached 16th pixel?
       ret nz              ; no, don't drop new tiles in.

; Window scrolling left, so display tile at right.

tilel  ld hl,(levptr)      ; level data.
       ld de,208           ; blocks between left/right sides.
       add hl,de           ; add displacement for right side of screen.
       ld de,window+24     ; just off right edge of window.
       call tilec          ; tile column routine.
       ld hl,(levptr)      ; level data.
       ld de,16            ; displacement.
       add hl,de           ; move 1 column to the right.
       ld (levptr),hl      ; new position.
       ret

tilec  ld b,16             ; number of tiles.
tilec0 ld a,(hl)           ; tile number.
       push bc
       push hl
       call tile           ; display tile.
       pop hl
       pop bc
       inc hl              ; point to next tile.
       djnz tilec0
       ret

; Scrolling right, so display tile at left.

tiler  ld de,window        ; top left edge of window.
       ld hl,(levptr)      ; level pointer.
       call tilec          ; diplay column of tiles here.
       ld de,65504         ; displacement.
       add hl,de           ; move 1 column to the left.
       ld (levptr),hl      ; new position.
       ret

; Right scroll routines.

scrr4  ld a,(scrolc)       ; scroll count.
;       dec a               ; take post-decrement into account.
       and 3               ; 4-pixel position remainder.
       jr z,scrr4a         ; we can do 4-pixel scroll.
       cp 1                ; is it 1?
       jr z,scrr1          ; scroll 1 pixel.
       jp scrr2            ; scroll 2 pixels.

scrr4a ld a,(hl)           ; present pixel coordinate of ship.
       add a,4             ; move 4 pixels right.
       ld (hl),a           ; new position.
       ld c,4              ; pixels to scroll.
       call sbul           ; shift bullets accordingly.
       ld hl,scrolc        ; scroll count.
       ld a,(hl)           ; get count.
       ld b,a              ; store count.
       sub 4               ; post-decrement.
       ld (hl),a           ; new value.
       ld a,b              ; previous value.
       and 15              ; reached 16th pixel?
       call z,tiler        ; yes, drop new tiles in.
       jp srigt4           ; scroll window right 4 pixels.

scrr1  inc (hl)            ; move 1 pixel right.
       ld c,1              ; pixels to scroll.
       call sbul           ; shift bullets accordingly.
       ld hl,scrolc        ; scroll count.
       ld a,(hl)           ; get count.
       dec (hl)            ; post-decrement it.
       and 15              ; reached 16th pixel?
       call z,tiler        ; yes, drop new tiles in.
       jp srigt1           ; scroll window right 1 pixel.

scrr2  inc (hl)            ; move 2 pixels right.
       inc (hl)
       ld c,2              ; pixels to scroll.
       call sbul           ; shift bullets accordingly.
       ld hl,scrolc        ; scroll count.
       ld a,(hl)           ; get count.
       dec (hl)            ; post-decrement it.
       and 15              ; reached 16th pixel?
       call z,tiler        ; yes, drop new tiles in.
srigt2 call srigt1         ; scroll window right 1 pixel.
       ld hl,scrolc        ; scroll count.
       ld a,(hl)           ; get count.
       dec (hl)            ; post-decrement it.
       and 15              ; reached 16th pixel?
       call z,tiler        ; yes, drop new tiles in.
srigt1 ld hl,srigtr
       push hl
       ld hl,shifr1        ; address to call.
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       ld hl,window        ; first position to scroll.
       jp shifr1
srigtr rr (hl)
       inc l
       rr (hl)
       ret


; Scroll left.

shifr1 rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc hl
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       rr (hl)
       inc l
       ret

srigt4 ld hl,srig4r        ; rejoin point.
       push hl             ; push address onto return stack.
       ld hl,shifr4        ; 256 byte shift routine.
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       ld hl,window        ; first position to scroll.
       jp shifr4
srig4r rrd                 ; point at which we return.
       inc l
       rrd
       ret


; Scroll left.

shifr4 rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc hl
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       rrd
       inc l
       ret


; Scroll left.

sleft2 call sleft1

sleft1 ld hl,sleftr        ; position to rejoin.
       push hl             ; stack return address.
       ld hl,shifl1        ; address to call.
       push hl             ; stack return address.
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       ld hl,winend        ; last position to scroll.
       jp shifl1
sleftr rl (hl)
       dec l
       rl (hl)
       ret

shifl1 rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec l
       rl (hl)
       dec hl
       rl (hl)
       dec l
       rl (hl)
       dec l
       ret


sleft4 ld hl,slef4r        ; point at which to rejoin.
       push hl             ; place on return stack.
       ld hl,shifl4        ; address to call.
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       push hl
       ld hl,winend        ; last position to scroll.
       jp shifl4
slef4r rld
       dec l
       rld
       ret

shifl4 rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec l
       rld
       dec hl
       rld
       dec l
       rld
       dec l
       ret




; Tiles are just blocks which are written to the screen.
; No shifting is involved, it's pretty basic stuff.

tile   ld hl,tiles         ; graphics.
       rrca                ; multiply tile by 32.
       rrca
       rrca
       ld b,a              ; store result in b.
       and 224             ; low byte mask.
       ld c,a              ; low byte.
       ld a,b              ; result.
       and 31              ; high byte mask.
       ld b,a              ; displacement high byte.
       add hl,bc           ; tile address.
tilea0 ld a,22             ; low byte to add each time.
       ld bc,99            ; no high byte.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ldi                 ; transfer to window.
       ldi                 ; transfer second byte.
       ex de,hl
       ld c,a              ; restore bc.
       add hl,bc           ; next line of window.
       ex de,hl            ; switch them around.
       ret


; Sprite data.

spdat  defb 0,128,0,128,1,192,1,192,3,224,3,224,7,240,7,240
       defb 7,240,15,248,15,248,31,252,31,60,60,14,48,2,0,0
       defb 0,32,0,96,0,96,0,240,1,240,1,240,3,240,7,248
       defb 7,248,15,248,31,248,30,120,48,60,0,12,0,4,0,0
       defb 0,0,0,16,0,48,0,112,0,240,1,240,3,240,7,240
       defb 15,240,31,240,63,240,127,240,0,240,0,112,0,112,0,48
       defb 0,0,0,8,0,56,0,120,1,240,3,240,15,240,31,240
       defb 127,224,255,224,15,224,1,224,1,224,0,192,0,192,0,64
       defb 0,0,0,0,0,6,0,30,0,124,3,252,15,248,63,248
       defb 255,240,63,240,7,240,3,224,1,224,1,192,1,192,0,128
       defb 0,0,0,0,0,0,0,7,0,254,15,254,127,252,63,248
       defb 15,248,3,240,3,224,3,224,3,192,1,128,1,128,1,0
       defb 0,0,0,0,0,0,0,0,0,0,255,255,127,254,63,252
       defb 15,248,7,240,7,224,7,192,7,128,7,0,6,0,4,0
       defb 0,0,0,0,0,0,56,0,31,128,15,252,15,255,7,255
       defb 3,252,3,248,7,224,7,192,7,0,14,0,8,0,0,0
       defb 0,0,0,0,48,0,60,0,31,0,31,224,15,248,15,254
       defb 7,255,7,254,15,248,15,224,31,0,28,0,48,0,0,0
       defb 0,0,8,0,14,0,7,0,7,192,7,224,3,248,3,252
       defb 7,255,15,255,15,252,31,192,56,0,0,0,0,0,0,0
       defb 0,0,4,0,6,0,7,0,7,128,7,192,7,224,7,240
       defb 15,248,63,252,127,254,255,255,0,0,0,0,0,0,0,0
       defb 1,0,1,128,1,128,1,192,3,224,3,224,3,240,15,248
       defb 63,248,127,252,15,254,0,126,0,7,0,0,0,0,0,0
       defb 0,128,0,128,1,192,1,192,1,224,3,224,7,240,63,240
       defb 255,240,63,248,15,248,3,252,0,124,0,30,0,6,0,0
       defb 0,0,0,64,0,192,0,192,1,224,1,224,31,224,255,224
       defb 127,240,31,240,15,240,3,240,1,240,0,120,0,56,0,8
       defb 0,16,0,48,0,112,0,112,0,240,127,240,63,240,31,240
       defb 15,240,7,240,3,240,1,240,0,240,0,112,0,48,0,16
       defb 0,0,0,0,0,4,0,12,48,60,30,120,31,248,15,248
       defb 7,248,7,240,3,240,1,240,1,240,0,240,0,96,0,96
       defb 0,0,0,0,32,6,56,30,30,124,31,252,15,248,15,248
       defb 7,240,7,240,7,240,3,224,3,224,1,192,1,192,0,128
       defb 0,0,0,0,16,0,24,0,30,6,15,60,15,252,15,248
       defb 15,240,15,240,7,224,7,192,7,192,7,128,3,0,3,0
       defb 4,0,6,0,7,0,7,0,7,128,7,255,7,254,7,252
       defb 7,248,7,240,7,224,7,192,7,128,7,0,6,0,4,0
       defb 0,0,1,0,1,128,1,128,3,192,3,192,3,248,3,255
       defb 3,255,7,252,7,248,7,224,7,192,15,0,14,0,8,0
       defb 0,128,0,128,1,192,1,192,3,192,3,224,7,240,7,254
       defb 7,255,15,254,15,248,31,224,31,0,60,0,48,0,0,0
       defb 0,64,0,192,0,192,1,224,3,224,3,224,7,224,15,248
       defb 15,254,31,255,63,248,63,128,112,0,0,0,0,0,0,0
       defb 0,0,0,16,0,48,0,112,0,240,1,240,3,240,7,240
       defb 15,248,31,252,63,255,127,255,0,0,0,0,0,0,0,0
       defb 0,0,0,8,0,56,0,112,1,240,3,240,15,224,31,224
       defb 127,240,255,248,31,248,0,252,0,14,0,0,0,0,0,0
       defb 0,0,0,0,0,6,0,28,0,124,3,248,15,248,63,240
       defb 255,240,63,248,15,248,3,252,0,124,0,30,0,6,0,0
       defb 0,0,0,0,0,0,0,14,1,252,31,248,255,248,127,240
       defb 31,224,15,224,3,240,1,240,0,112,0,56,0,8,0,0
       defb 0,0,0,0,0,0,0,0,0,0,127,255,63,255,31,254
       defb 15,248,7,240,3,240,1,240,0,240,0,112,0,48,0,16
       defb 0,0,0,0,0,0,112,0,63,0,63,248,31,255,15,254
       defb 15,248,7,224,3,224,3,224,1,192,0,192,0,192,0,64
       defb 0,0,0,0,48,0,60,0,31,0,31,224,15,248,15,254
       defb 7,255,7,254,7,240,3,224,3,192,1,192,1,192,0,128
       defb 0,0,8,0,14,0,15,0,7,192,7,224,7,248,7,252
       defb 7,255,3,255,3,252,3,192,3,192,1,128,1,128,1,0
       defb 0,0,4,0,6,0,7,0,7,128,7,192,7,224,7,240
       defb 7,248,7,252,7,254,7,255,7,128,7,0,7,0,6,0
       defb 2,0,3,0,3,0,7,128,7,192,7,192,7,224,7,240
       defb 15,240,15,248,15,252,15,60,30,6,24,0,16,0,0,0

       defb 0,64,0,64,0,224,0,224,1,240,1,240,3,248,3,248
       defb 3,248,7,252,7,252,15,254,15,158,30,7,24,1,0,0
       defb 0,16,0,48,0,48,0,120,0,248,0,248,1,248,3,252
       defb 3,252,7,252,15,252,15,60,24,30,0,6,0,2,0,0
       defb 0,0,0,8,0,24,0,56,0,120,0,248,1,248,3,248
       defb 7,248,15,248,31,248,63,248,0,120,0,56,0,56,0,24
       defb 0,0,0,4,0,28,0,60,0,248,1,248,7,248,15,248
       defb 63,240,127,240,7,240,0,240,0,240,0,96,0,96,0,32
       defb 0,0,0,0,0,3,0,15,0,62,1,254,7,252,31,252
       defb 127,248,31,248,3,248,1,240,0,240,0,224,0,224,0,64
       defb 0,0,0,0,0,0,128,3,0,127,7,255,63,254,31,252
       defb 7,252,1,248,1,240,1,240,1,224,0,192,0,192,0,128
       defb 0,0,0,0,0,0,0,0,0,0,255,255,63,255,31,254
       defb 7,252,3,248,3,240,3,224,3,192,3,128,3,0,2,0
       defb 0,0,0,0,0,0,28,0,15,192,7,254,135,255,131,255
       defb 1,254,1,252,3,240,3,224,3,128,7,0,4,0,0,0
       defb 0,0,0,0,24,0,30,0,15,128,15,240,7,252,7,255
       defb 131,255,3,255,7,252,7,240,15,128,14,0,24,0,0,0
       defb 0,0,4,0,7,0,3,128,3,224,3,240,1,252,1,254
       defb 131,255,135,255,7,254,15,224,28,0,0,0,0,0,0,0
       defb 0,0,2,0,3,0,3,128,3,192,3,224,3,240,3,248
       defb 7,252,31,254,63,255,255,255,0,0,0,0,0,0,0,0
       defb 0,128,0,192,0,192,0,224,1,240,1,240,1,248,7,252
       defb 31,252,63,254,7,255,0,63,128,3,0,0,0,0,0,0
       defb 0,64,0,64,0,224,0,224,0,240,1,240,3,248,31,248
       defb 127,248,31,252,7,252,1,254,0,62,0,15,0,3,0,0
       defb 0,0,0,32,0,96,0,96,0,240,0,240,15,240,127,240
       defb 63,248,15,248,7,248,1,248,0,248,0,60,0,28,0,4
       defb 0,8,0,24,0,56,0,56,0,120,63,248,31,248,15,248
       defb 7,248,3,248,1,248,0,248,0,120,0,56,0,24,0,8
       defb 0,0,0,0,0,2,0,6,24,30,15,60,15,252,7,252
       defb 3,252,3,248,1,248,0,248,0,248,0,120,0,48,0,48
       defb 0,0,0,0,16,3,28,15,15,62,15,254,7,252,7,252
       defb 3,248,3,248,3,248,1,240,1,240,0,224,0,224,0,64
       defb 0,0,0,0,8,0,12,0,15,3,7,158,7,254,7,252
       defb 7,248,7,248,3,240,3,224,3,224,3,192,1,128,1,128
       defb 2,0,3,0,3,128,3,128,3,192,131,255,3,255,3,254
       defb 3,252,3,248,3,240,3,224,3,192,3,128,3,0,2,0
       defb 0,0,0,128,0,192,0,192,1,224,1,224,1,252,129,255
       defb 129,255,3,254,3,252,3,240,3,224,7,128,7,0,4,0
       defb 0,64,0,64,0,224,0,224,1,224,1,240,3,248,3,255
       defb 131,255,7,255,7,252,15,240,15,128,30,0,24,0,0,0
       defb 0,32,0,96,0,96,0,240,1,240,1,240,3,240,7,252
       defb 7,255,143,255,31,252,31,192,56,0,0,0,0,0,0,0
       defb 0,0,0,8,0,24,0,56,0,120,0,248,1,248,3,248
       defb 7,252,15,254,159,255,191,255,0,0,0,0,0,0,0,0
       defb 0,0,0,4,0,28,0,56,0,248,1,248,7,240,15,240
       defb 63,248,127,252,15,252,0,126,0,7,0,0,0,0,0,0
       defb 0,0,0,0,0,3,0,14,0,62,1,252,7,252,31,248
       defb 127,248,31,252,7,252,1,254,0,62,0,15,0,3,0,0
       defb 0,0,0,0,0,0,0,7,0,254,15,252,127,252,63,248
       defb 15,240,7,240,1,248,0,248,0,56,0,28,0,4,0,0
       defb 0,0,0,0,0,0,0,0,0,0,191,255,159,255,15,255
       defb 7,252,3,248,1,248,0,248,0,120,0,56,0,24,0,8
       defb 0,0,0,0,0,0,56,0,31,128,31,252,143,255,7,255
       defb 7,252,3,240,1,240,1,240,0,224,0,96,0,96,0,32
       defb 0,0,0,0,24,0,30,0,15,128,15,240,7,252,7,255
       defb 131,255,3,255,3,248,1,240,1,224,0,224,0,224,0,64
       defb 0,0,4,0,7,0,7,128,3,224,3,240,3,252,3,254
       defb 131,255,129,255,1,254,1,224,1,224,0,192,0,192,0,128
       defb 0,0,2,0,3,0,3,128,3,192,3,224,3,240,3,248
       defb 3,252,3,254,3,255,131,255,3,192,3,128,3,128,3,0
       defb 1,0,1,128,1,128,3,192,3,224,3,224,3,240,3,248
       defb 7,248,7,252,7,254,7,158,15,3,12,0,8,0,0,0

       defb 0,32,0,32,0,112,0,112,0,248,0,248,1,252,1,252
       defb 1,252,3,254,3,254,7,255,7,207,143,3,140,0,0,0
       defb 0,8,0,24,0,24,0,60,0,124,0,124,0,252,1,254
       defb 1,254,3,254,7,254,7,158,12,15,0,3,0,1,0,0
       defb 0,0,0,4,0,12,0,28,0,60,0,124,0,252,1,252
       defb 3,252,7,252,15,252,31,252,0,60,0,28,0,28,0,12
       defb 0,0,0,2,0,14,0,30,0,124,0,252,3,252,7,252
       defb 31,248,63,248,3,248,0,120,0,120,0,48,0,48,0,16
       defb 0,0,0,0,128,1,128,7,0,31,0,255,3,254,15,254
       defb 63,252,15,252,1,252,0,248,0,120,0,112,0,112,0,32
       defb 0,0,0,0,0,0,192,1,128,63,131,255,31,255,15,254
       defb 3,254,0,252,0,248,0,248,0,240,0,96,0,96,0,64
       defb 0,0,0,0,0,0,0,0,0,0,255,255,159,255,15,255
       defb 3,254,1,252,1,248,1,240,1,224,1,192,1,128,1,0
       defb 0,0,0,0,0,0,14,0,7,224,3,255,195,255,193,255
       defb 0,255,0,254,1,248,1,240,1,192,3,128,2,0,0,0
       defb 0,0,0,0,12,0,15,0,7,192,7,248,3,254,131,255
       defb 193,255,129,255,3,254,3,248,7,192,7,0,12,0,0,0
       defb 0,0,2,0,3,128,1,192,1,240,1,248,0,254,0,255
       defb 193,255,195,255,3,255,7,240,14,0,0,0,0,0,0,0
       defb 0,0,1,0,1,128,1,192,1,224,1,240,1,248,1,252
       defb 3,254,15,255,159,255,255,255,0,0,0,0,0,0,0,0
       defb 0,64,0,96,0,96,0,112,0,248,0,248,0,252,3,254
       defb 15,254,31,255,131,255,128,31,192,1,0,0,0,0,0,0
       defb 0,32,0,32,0,112,0,112,0,120,0,248,1,252,15,252
       defb 63,252,15,254,3,254,0,255,0,31,128,7,128,1,0,0
       defb 0,0,0,16,0,48,0,48,0,120,0,120,7,248,63,248
       defb 31,252,7,252,3,252,0,252,0,124,0,30,0,14,0,2
       defb 0,4,0,12,0,28,0,28,0,60,31,252,15,252,7,252
       defb 3,252,1,252,0,252,0,124,0,60,0,28,0,12,0,4
       defb 0,0,0,0,0,1,0,3,12,15,7,158,7,254,3,254
       defb 1,254,1,252,0,252,0,124,0,124,0,60,0,24,0,24
       defb 0,0,0,0,136,1,142,7,7,159,7,255,3,254,3,254
       defb 1,252,1,252,1,252,0,248,0,248,0,112,0,112,0,32
       defb 0,0,0,0,4,0,6,0,135,129,3,207,3,255,3,254
       defb 3,252,3,252,1,248,1,240,1,240,1,224,0,192,0,192
       defb 1,0,1,128,1,192,1,192,1,224,193,255,129,255,1,255
       defb 1,254,1,252,1,248,1,240,1,224,1,192,1,128,1,0
       defb 0,0,0,64,0,96,0,96,0,240,0,240,0,254,192,255
       defb 192,255,1,255,1,254,1,248,1,240,3,192,3,128,2,0
       defb 0,32,0,32,0,112,0,112,0,240,0,248,1,252,129,255
       defb 193,255,131,255,3,254,7,248,7,192,15,0,12,0,0,0
       defb 0,16,0,48,0,48,0,120,0,248,0,248,1,248,3,254
       defb 131,255,199,255,15,254,15,224,28,0,0,0,0,0,0,0
       defb 0,0,0,4,0,12,0,28,0,60,0,124,0,252,1,252
       defb 3,254,7,255,207,255,223,255,0,0,0,0,0,0,0,0
       defb 0,0,0,2,0,14,0,28,0,124,0,252,3,248,7,248
       defb 31,252,63,254,7,254,0,63,128,3,0,0,0,0,0,0
       defb 0,0,0,0,128,1,0,7,0,31,0,254,3,254,15,252
       defb 63,252,15,254,3,254,0,255,0,31,128,7,128,1,0,0
       defb 0,0,0,0,0,0,128,3,0,127,7,254,63,254,31,252
       defb 7,248,3,248,0,252,0,124,0,28,0,14,0,2,0,0
       defb 0,0,0,0,0,0,0,0,0,0,223,255,207,255,135,255
       defb 3,254,1,252,0,252,0,124,0,60,0,28,0,12,0,4
       defb 0,0,0,0,0,0,28,0,15,192,15,254,199,255,131,255
       defb 3,254,1,248,0,248,0,248,0,112,0,48,0,48,0,16
       defb 0,0,0,0,12,0,15,0,7,192,7,248,3,254,131,255
       defb 193,255,129,255,1,252,0,248,0,240,0,112,0,112,0,32
       defb 0,0,2,0,3,128,3,192,1,240,1,248,1,254,1,255
       defb 193,255,192,255,0,255,0,240,0,240,0,96,0,96,0,64
       defb 0,0,1,0,1,128,1,192,1,224,1,240,1,248,1,252
       defb 1,254,1,255,129,255,193,255,1,224,1,192,1,192,1,128
       defb 0,128,0,192,0,192,1,224,1,240,1,240,1,248,1,252
       defb 3,252,3,254,3,255,3,207,135,129,6,0,4,0,0,0

       defb 0,16,0,16,0,56,0,56,0,124,0,124,0,254,0,254
       defb 0,254,1,255,1,255,131,255,131,231,199,129,70,0,0,0
       defb 0,4,0,12,0,12,0,30,0,62,0,62,0,126,0,255
       defb 0,255,1,255,3,255,3,207,134,7,128,1,128,0,0,0
       defb 0,0,0,2,0,6,0,14,0,30,0,62,0,126,0,254
       defb 1,254,3,254,7,254,15,254,0,30,0,14,0,14,0,6
       defb 0,0,0,1,0,7,0,15,0,62,0,126,1,254,3,254
       defb 15,252,31,252,1,252,0,60,0,60,0,24,0,24,0,8
       defb 0,0,0,0,192,0,192,3,128,15,128,127,1,255,7,255
       defb 31,254,7,254,0,254,0,124,0,60,0,56,0,56,0,16
       defb 0,0,0,0,0,0,224,0,192,31,193,255,143,255,7,255
       defb 1,255,0,126,0,124,0,124,0,120,0,48,0,48,0,32
       defb 0,0,0,0,0,0,0,0,0,0,255,255,207,255,135,255
       defb 1,255,0,254,0,252,0,248,0,240,0,224,0,192,0,128
       defb 0,0,0,0,0,0,7,0,3,240,129,255,225,255,224,255
       defb 128,127,0,127,0,252,0,248,0,224,1,192,1,0,0,0
       defb 0,0,0,0,6,0,7,128,3,224,3,252,1,255,193,255
       defb 224,255,192,255,1,255,1,252,3,224,3,128,6,0,0,0
       defb 0,0,1,0,1,192,0,224,0,248,0,252,0,127,128,127
       defb 224,255,225,255,129,255,3,248,7,0,0,0,0,0,0,0
       defb 0,0,0,128,0,192,0,224,0,240,0,248,0,252,0,254
       defb 1,255,135,255,207,255,255,255,0,0,0,0,0,0,0,0
       defb 0,32,0,48,0,48,0,56,0,124,0,124,0,126,1,255
       defb 7,255,143,255,193,255,192,15,224,0,0,0,0,0,0,0
       defb 0,16,0,16,0,56,0,56,0,60,0,124,0,254,7,254
       defb 31,254,7,255,1,255,128,127,128,15,192,3,192,0,0,0
       defb 0,0,0,8,0,24,0,24,0,60,0,60,3,252,31,252
       defb 15,254,3,254,1,254,0,126,0,62,0,15,0,7,0,1
       defb 0,2,0,6,0,14,0,14,0,30,15,254,7,254,3,254
       defb 1,254,0,254,0,126,0,62,0,30,0,14,0,6,0,2
       defb 0,0,0,0,128,0,128,1,134,7,3,207,3,255,1,255
       defb 0,255,0,254,0,126,0,62,0,62,0,30,0,12,0,12
       defb 0,0,0,0,196,0,199,3,131,207,131,255,1,255,1,255
       defb 0,254,0,254,0,254,0,124,0,124,0,56,0,56,0,16
       defb 0,0,0,0,2,0,3,0,195,192,129,231,129,255,1,255
       defb 1,254,1,254,0,252,0,248,0,248,0,240,0,96,0,96
       defb 0,128,0,192,0,224,0,224,0,240,224,255,192,255,128,255
       defb 0,255,0,254,0,252,0,248,0,240,0,224,0,192,0,128
       defb 0,0,0,32,0,48,0,48,0,120,0,120,0,127,224,127
       defb 224,127,128,255,0,255,0,252,0,248,1,224,1,192,1,0
       defb 0,16,0,16,0,56,0,56,0,120,0,124,0,254,192,255
       defb 224,255,193,255,1,255,3,252,3,224,7,128,6,0,0,0
       defb 0,8,0,24,0,24,0,60,0,124,0,124,0,252,1,255
       defb 193,255,227,255,7,255,7,240,14,0,0,0,0,0,0,0
       defb 0,0,0,2,0,6,0,14,0,30,0,62,0,126,0,254
       defb 1,255,131,255,231,255,239,255,0,0,0,0,0,0,0,0
       defb 0,0,0,1,0,7,0,14,0,62,0,126,1,252,3,252
       defb 15,254,31,255,3,255,128,31,192,1,0,0,0,0,0,0
       defb 0,0,0,0,192,0,128,3,128,15,0,127,1,255,7,254
       defb 31,254,7,255,1,255,128,127,128,15,192,3,192,0,0,0
       defb 0,0,0,0,0,0,192,1,128,63,3,255,31,255,15,254
       defb 3,252,1,252,0,126,0,62,0,14,0,7,0,1,0,0
       defb 0,0,0,0,0,0,0,0,0,0,239,255,231,255,195,255
       defb 1,255,0,254,0,126,0,62,0,30,0,14,0,6,0,2
       defb 0,0,0,0,0,0,14,0,7,224,7,255,227,255,193,255
       defb 1,255,0,252,0,124,0,124,0,56,0,24,0,24,0,8
       defb 0,0,0,0,6,0,7,128,3,224,3,252,1,255,193,255
       defb 224,255,192,255,0,254,0,124,0,120,0,56,0,56,0,16
       defb 0,0,1,0,1,192,1,224,0,248,0,252,0,255,128,255
       defb 224,255,224,127,128,127,0,120,0,120,0,48,0,48,0,32
       defb 0,0,0,128,0,192,0,224,0,240,0,248,0,252,0,254
       defb 0,255,128,255,192,255,224,255,0,240,0,224,0,224,0,192
       defb 0,64,0,96,0,96,0,240,0,248,0,248,0,252,0,254
       defb 1,254,1,255,129,255,129,231,195,192,3,0,2,0,0,0

       defb 0,8,0,8,0,28,0,28,0,62,0,62,0,127,0,127
       defb 0,127,128,255,128,255,193,255,193,243,227,192,35,0,0,0
       defb 0,2,0,6,0,6,0,15,0,31,0,31,0,63,128,127
       defb 128,127,128,255,129,255,129,231,195,3,192,0,64,0,0,0
       defb 0,0,0,1,0,3,0,7,0,15,0,31,0,63,0,127
       defb 0,255,1,255,3,255,7,255,0,15,0,7,0,7,0,3
       defb 0,0,128,0,128,3,128,7,0,31,0,63,0,255,1,255
       defb 7,254,15,254,0,254,0,30,0,30,0,12,0,12,0,4
       defb 0,0,0,0,96,0,224,1,192,7,192,63,128,255,131,255
       defb 15,255,3,255,0,127,0,62,0,30,0,28,0,28,0,8
       defb 0,0,0,0,0,0,112,0,224,15,224,255,199,255,131,255
       defb 128,255,0,63,0,62,0,62,0,60,0,24,0,24,0,16
       defb 0,0,0,0,0,0,0,0,0,0,255,255,231,255,195,255
       defb 128,255,0,127,0,126,0,124,0,120,0,112,0,96,0,64
       defb 0,0,0,0,0,0,3,128,1,248,192,255,240,255,240,127
       defb 192,63,128,63,0,126,0,124,0,112,0,224,0,128,0,0
       defb 0,0,0,0,3,0,3,192,1,240,1,254,128,255,224,255
       defb 240,127,224,127,128,255,0,254,1,240,1,192,3,0,0,0
       defb 0,0,0,128,0,224,0,112,0,124,0,126,128,63,192,63
       defb 240,127,240,255,192,255,1,252,3,128,0,0,0,0,0,0
       defb 0,0,0,64,0,96,0,112,0,120,0,124,0,126,0,127
       defb 128,255,195,255,231,255,255,255,0,0,0,0,0,0,0,0
       defb 0,16,0,24,0,24,0,28,0,62,0,62,0,63,128,255
       defb 131,255,199,255,224,255,224,7,112,0,0,0,0,0,0,0
       defb 0,8,0,8,0,28,0,28,0,30,0,62,0,127,3,255
       defb 15,255,131,255,128,255,192,63,192,7,224,1,96,0,0,0
       defb 0,0,0,4,0,12,0,12,0,30,0,30,1,254,15,254
       defb 7,255,1,255,0,255,0,63,0,31,128,7,128,3,128,0
       defb 0,1,0,3,0,7,0,7,0,15,7,255,3,255,1,255
       defb 0,255,0,127,0,63,0,31,0,15,0,7,0,3,0,1
       defb 0,0,0,0,64,0,192,0,195,3,129,231,129,255,128,255
       defb 128,127,0,127,0,63,0,31,0,31,0,15,0,6,0,6
       defb 0,0,0,0,98,0,227,129,193,231,193,255,128,255,128,255
       defb 0,127,0,127,0,127,0,62,0,62,0,28,0,28,0,8
       defb 0,0,0,0,1,0,1,128,97,224,192,243,192,255,128,255
       defb 0,255,0,255,0,126,0,124,0,124,0,120,0,48,0,48
       defb 0,64,0,96,0,112,0,112,0,120,240,127,224,127,192,127
       defb 128,127,0,127,0,126,0,124,0,120,0,112,0,96,0,64
       defb 0,0,0,16,0,24,0,24,0,60,0,60,128,63,240,63
       defb 240,63,192,127,128,127,0,126,0,124,0,240,0,224,0,128
       defb 0,8,0,8,0,28,0,28,0,60,0,62,0,127,224,127
       defb 240,127,224,255,128,255,1,254,1,240,3,192,3,0,0,0
       defb 0,4,0,12,0,12,0,30,0,62,0,62,0,126,128,255
       defb 224,255,241,255,131,255,3,248,7,0,0,0,0,0,0,0
       defb 0,0,0,1,0,3,0,7,0,15,0,31,0,63,0,127
       defb 128,255,193,255,243,255,247,255,0,0,0,0,0,0,0,0
       defb 0,0,128,0,128,3,0,7,0,31,0,63,0,254,1,254
       defb 7,255,143,255,129,255,192,15,224,0,0,0,0,0,0,0
       defb 0,0,0,0,96,0,192,1,192,7,128,63,128,255,3,255
       defb 15,255,131,255,128,255,192,63,192,7,224,1,96,0,0,0
       defb 0,0,0,0,0,0,224,0,192,31,129,255,143,255,7,255
       defb 1,254,0,254,0,63,0,31,0,7,128,3,128,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,247,255,243,255,225,255
       defb 128,255,0,127,0,63,0,31,0,15,0,7,0,3,0,1
       defb 0,0,0,0,0,0,7,0,3,240,131,255,241,255,224,255
       defb 128,255,0,126,0,62,0,62,0,28,0,12,0,12,0,4
       defb 0,0,0,0,3,0,3,192,1,240,1,254,128,255,224,255
       defb 240,127,224,127,0,127,0,62,0,60,0,28,0,28,0,8
       defb 0,0,0,128,0,224,0,240,0,124,0,126,128,127,192,127
       defb 240,127,240,63,192,63,0,60,0,60,0,24,0,24,0,16
       defb 0,0,0,64,0,96,0,112,0,120,0,124,0,126,0,127
       defb 128,127,192,127,224,127,240,127,0,120,0,112,0,112,0,96
       defb 0,32,0,48,0,48,0,120,0,124,0,124,0,126,0,127
       defb 0,255,128,255,192,255,192,243,97,224,1,128,1,0,0,0

       defb 0,4,0,4,0,14,0,14,0,31,0,31,128,63,128,63
       defb 128,63,192,127,192,127,224,255,224,249,113,224,17,128,0,0
       defb 0,1,0,3,0,3,128,7,128,15,128,15,128,31,192,63
       defb 192,63,192,127,192,255,192,243,225,129,96,0,32,0,0,0
       defb 0,0,128,0,128,1,128,3,128,7,128,15,128,31,128,63
       defb 128,127,128,255,129,255,131,255,128,7,128,3,128,3,128,1
       defb 0,0,64,0,192,1,192,3,128,15,128,31,128,127,128,255
       defb 3,255,7,255,0,127,0,15,0,15,0,6,0,6,0,2
       defb 0,0,0,0,48,0,240,0,224,3,224,31,192,127,193,255
       defb 135,255,129,255,128,63,0,31,0,15,0,14,0,14,0,4
       defb 0,0,0,0,0,0,56,0,240,7,240,127,227,255,193,255
       defb 192,127,128,31,0,31,0,31,0,30,0,12,0,12,0,8
       defb 0,0,0,0,0,0,0,0,0,0,255,255,243,255,225,255
       defb 192,127,128,63,0,63,0,62,0,60,0,56,0,48,0,32
       defb 0,0,0,0,0,0,1,192,0,252,224,127,248,127,248,63
       defb 224,31,192,31,0,63,0,62,0,56,0,112,0,64,0,0
       defb 0,0,0,0,1,128,1,224,0,248,0,255,192,127,240,127
       defb 248,63,240,63,192,127,0,127,0,248,0,224,1,128,0,0
       defb 0,0,0,64,0,112,0,56,0,62,0,63,192,31,224,31
       defb 248,63,248,127,224,127,0,254,1,192,0,0,0,0,0,0
       defb 0,0,0,32,0,48,0,56,0,60,0,62,0,63,128,63
       defb 192,127,225,255,243,255,255,255,0,0,0,0,0,0,0,0
       defb 0,8,0,12,0,12,0,14,0,31,0,31,128,31,192,127
       defb 193,255,227,255,240,127,240,3,56,0,0,0,0,0,0,0
       defb 0,4,0,4,0,14,0,14,0,15,0,31,128,63,129,255
       defb 135,255,193,255,192,127,224,31,224,3,240,0,48,0,0,0
       defb 0,0,0,2,0,6,0,6,0,15,0,15,0,255,7,255
       defb 131,255,128,255,128,127,128,31,128,15,192,3,192,1,64,0
       defb 128,0,128,1,128,3,128,3,128,7,131,255,129,255,128,255
       defb 128,127,128,63,128,31,128,15,128,7,128,3,128,1,128,0
       defb 0,0,0,0,32,0,96,0,225,129,192,243,192,255,192,127
       defb 192,63,128,63,128,31,128,15,128,15,128,7,0,3,0,3
       defb 0,0,0,0,49,0,241,192,224,243,224,255,192,127,192,127
       defb 128,63,128,63,128,63,0,31,0,31,0,14,0,14,0,4
       defb 0,0,0,0,0,128,0,192,48,240,224,121,224,127,192,127
       defb 128,127,128,127,0,63,0,62,0,62,0,60,0,24,0,24
       defb 0,32,0,48,0,56,0,56,0,60,248,63,240,63,224,63
       defb 192,63,128,63,0,63,0,62,0,60,0,56,0,48,0,32
       defb 0,0,0,8,0,12,0,12,0,30,0,30,192,31,248,31
       defb 248,31,224,63,192,63,0,63,0,62,0,120,0,112,0,64
       defb 0,4,0,4,0,14,0,14,0,30,0,31,128,63,240,63
       defb 248,63,240,127,192,127,0,255,0,248,1,224,1,128,0,0
       defb 0,2,0,6,0,6,0,15,0,31,0,31,0,63,192,127
       defb 240,127,248,255,193,255,1,252,3,128,0,0,0,0,0,0
       defb 0,0,128,0,128,1,128,3,128,7,128,15,128,31,128,63
       defb 192,127,224,255,249,255,251,255,0,0,0,0,0,0,0,0
       defb 0,0,64,0,192,1,128,3,128,15,128,31,0,127,0,255
       defb 131,255,199,255,192,255,224,7,112,0,0,0,0,0,0,0
       defb 0,0,0,0,48,0,224,0,224,3,192,31,192,127,129,255
       defb 135,255,193,255,192,127,224,31,224,3,240,0,48,0,0,0
       defb 0,0,0,0,0,0,112,0,224,15,192,255,199,255,131,255
       defb 0,255,0,127,128,31,128,15,128,3,192,1,64,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,251,255,249,255,240,255
       defb 192,127,128,63,128,31,128,15,128,7,128,3,128,1,128,0
       defb 0,0,0,0,0,0,3,128,1,248,193,255,248,255,240,127
       defb 192,127,0,63,0,31,0,31,0,14,0,6,0,6,0,2
       defb 0,0,0,0,1,128,1,224,0,248,0,255,192,127,240,127
       defb 248,63,240,63,128,63,0,31,0,30,0,14,0,14,0,4
       defb 0,0,0,64,0,112,0,120,0,62,0,63,192,63,224,63
       defb 248,63,248,31,224,31,0,30,0,30,0,12,0,12,0,8
       defb 0,0,0,32,0,48,0,56,0,60,0,62,0,63,128,63
       defb 192,63,224,63,240,63,248,63,0,60,0,56,0,56,0,48
       defb 0,16,0,24,0,24,0,60,0,62,0,62,0,63,128,63
       defb 128,127,192,127,224,127,224,121,48,240,0,192,0,128,0,0

       defb 0,2,0,2,0,7,0,7,128,15,128,15,192,31,192,31
       defb 192,31,224,63,224,63,240,127,240,124,56,240,8,192,0,0
       defb 128,0,128,1,128,1,192,3,192,7,192,7,192,15,224,31
       defb 224,31,224,63,224,127,224,121,240,192,48,0,16,0,0,0
       defb 0,0,64,0,192,0,192,1,192,3,192,7,192,15,192,31
       defb 192,63,192,127,192,255,193,255,192,3,192,1,192,1,192,0
       defb 0,0,32,0,224,0,224,1,192,7,192,15,192,63,192,127
       defb 129,255,131,255,128,63,128,7,128,7,0,3,0,3,0,1
       defb 0,0,0,0,24,0,120,0,240,1,240,15,224,63,224,255
       defb 195,255,192,255,192,31,128,15,128,7,0,7,0,7,0,2
       defb 0,0,0,0,0,0,28,0,248,3,248,63,241,255,224,255
       defb 224,63,192,15,128,15,128,15,0,15,0,6,0,6,0,4
       defb 0,0,0,0,0,0,0,0,0,0,255,255,249,255,240,255
       defb 224,63,192,31,128,31,0,31,0,30,0,28,0,24,0,16
       defb 0,0,0,0,0,0,0,224,0,126,240,63,252,63,252,31
       defb 240,15,224,15,128,31,0,31,0,28,0,56,0,32,0,0
       defb 0,0,0,0,0,192,0,240,0,124,128,127,224,63,248,63
       defb 252,31,248,31,224,63,128,63,0,124,0,112,0,192,0,0
       defb 0,0,0,32,0,56,0,28,0,31,128,31,224,15,240,15
       defb 252,31,252,63,240,63,0,127,0,224,0,0,0,0,0,0
       defb 0,0,0,16,0,24,0,28,0,30,0,31,128,31,192,31
       defb 224,63,240,255,249,255,255,255,0,0,0,0,0,0,0,0
       defb 0,4,0,6,0,6,0,7,128,15,128,15,192,15,224,63
       defb 224,255,241,255,248,63,248,1,28,0,0,0,0,0,0,0
       defb 0,2,0,2,0,7,0,7,128,7,128,15,192,31,192,255
       defb 195,255,224,255,224,63,240,15,240,1,120,0,24,0,0,0
       defb 0,0,0,1,0,3,0,3,128,7,128,7,128,127,131,255
       defb 193,255,192,127,192,63,192,15,192,7,224,1,224,0,32,0
       defb 64,0,192,0,192,1,192,1,192,3,193,255,192,255,192,127
       defb 192,63,192,31,192,15,192,7,192,3,192,1,192,0,64,0
       defb 0,0,0,0,16,0,48,0,240,192,224,121,224,127,224,63
       defb 224,31,192,31,192,15,192,7,192,7,192,3,128,1,128,1
       defb 0,0,0,0,24,128,120,224,240,121,240,127,224,63,224,63
       defb 192,31,192,31,192,31,128,15,128,15,0,7,0,7,0,2
       defb 0,0,0,0,0,64,0,96,24,120,240,60,240,63,224,63
       defb 192,63,192,63,128,31,0,31,0,31,0,30,0,12,0,12
       defb 0,16,0,24,0,28,0,28,0,30,252,31,248,31,240,31
       defb 224,31,192,31,128,31,0,31,0,30,0,28,0,24,0,16
       defb 0,0,0,4,0,6,0,6,0,15,0,15,224,15,252,15
       defb 252,15,240,31,224,31,128,31,0,31,0,60,0,56,0,32
       defb 0,2,0,2,0,7,0,7,0,15,128,15,192,31,248,31
       defb 252,31,248,63,224,63,128,127,0,124,0,240,0,192,0,0
       defb 0,1,0,3,0,3,128,7,128,15,128,15,128,31,224,63
       defb 248,63,252,127,224,255,0,254,1,192,0,0,0,0,0,0
       defb 0,0,64,0,192,0,192,1,192,3,192,7,192,15,192,31
       defb 224,63,240,127,252,255,253,255,0,0,0,0,0,0,0,0
       defb 0,0,32,0,224,0,192,1,192,7,192,15,128,63,128,127
       defb 193,255,227,255,224,127,240,3,56,0,0,0,0,0,0,0
       defb 0,0,0,0,24,0,112,0,240,1,224,15,224,63,192,255
       defb 195,255,224,255,224,63,240,15,240,1,120,0,24,0,0,0
       defb 0,0,0,0,0,0,56,0,240,7,224,127,227,255,193,255
       defb 128,127,128,63,192,15,192,7,192,1,224,0,32,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,253,255,252,255,248,127
       defb 224,63,192,31,192,15,192,7,192,3,192,1,192,0,64,0
       defb 0,0,0,0,0,0,1,192,0,252,224,255,252,127,248,63
       defb 224,63,128,31,128,15,128,15,0,7,0,3,0,3,0,1
       defb 0,0,0,0,0,192,0,240,0,124,128,127,224,63,248,63
       defb 252,31,248,31,192,31,128,15,0,15,0,7,0,7,0,2
       defb 0,0,0,32,0,56,0,60,0,31,128,31,224,31,240,31
       defb 252,31,252,15,240,15,0,15,0,15,0,6,0,6,0,4
       defb 0,0,0,16,0,24,0,28,0,30,0,31,128,31,192,31
       defb 224,31,240,31,248,31,252,31,0,30,0,28,0,28,0,24
       defb 0,8,0,12,0,12,0,30,0,31,0,31,128,31,192,31
       defb 192,63,224,63,240,63,240,60,24,120,0,96,0,64,0,0

       defb 0,1,0,1,128,3,128,3,192,7,192,7,224,15,224,15
       defb 224,15,240,31,240,31,248,63,120,62,28,120,4,96,0,0
       defb 64,0,192,0,192,0,224,1,224,3,224,3,224,7,240,15
       defb 240,15,240,31,240,63,240,60,120,96,24,0,8,0,0,0
       defb 0,0,32,0,96,0,224,0,224,1,224,3,224,7,224,15
       defb 224,31,224,63,224,127,224,255,224,1,224,0,224,0,96,0
       defb 0,0,16,0,112,0,240,0,224,3,224,7,224,31,224,63
       defb 192,255,193,255,192,31,192,3,192,3,128,1,128,1,128,0
       defb 0,0,0,0,12,0,60,0,248,0,248,7,240,31,240,127
       defb 225,255,224,127,224,15,192,7,192,3,128,3,128,3,0,1
       defb 0,0,0,0,0,0,14,0,252,1,252,31,248,255,240,127
       defb 240,31,224,7,192,7,192,7,128,7,0,3,0,3,0,2
       defb 0,0,0,0,0,0,0,0,0,0,255,255,252,255,248,127
       defb 240,31,224,15,192,15,128,15,0,15,0,14,0,12,0,8
       defb 0,0,0,0,0,0,0,112,0,63,248,31,254,31,254,15
       defb 248,7,240,7,192,15,128,15,0,14,0,28,0,16,0,0
       defb 0,0,0,0,0,96,0,120,0,62,192,63,240,31,252,31
       defb 254,15,252,15,240,31,192,31,0,62,0,56,0,96,0,0
       defb 0,0,0,16,0,28,0,14,128,15,192,15,240,7,248,7
       defb 254,15,254,31,248,31,128,63,0,112,0,0,0,0,0,0
       defb 0,0,0,8,0,12,0,14,0,15,128,15,192,15,224,15
       defb 240,31,248,127,252,255,255,255,0,0,0,0,0,0,0,0
       defb 0,2,0,3,0,3,128,3,192,7,192,7,224,7,240,31
       defb 240,127,248,255,252,31,252,0,14,0,0,0,0,0,0,0
       defb 0,1,0,1,128,3,128,3,192,3,192,7,224,15,224,127
       defb 225,255,240,127,240,31,248,7,248,0,60,0,12,0,0,0
       defb 0,0,128,0,128,1,128,1,192,3,192,3,192,63,193,255
       defb 224,255,224,63,224,31,224,7,224,3,240,0,112,0,16,0
       defb 32,0,96,0,224,0,224,0,224,1,224,255,224,127,224,63
       defb 224,31,224,15,224,7,224,3,224,1,224,0,96,0,32,0
       defb 0,0,0,0,8,0,24,0,120,96,240,60,240,63,240,31
       defb 240,15,224,15,224,7,224,3,224,3,224,1,192,0,192,0
       defb 0,0,0,0,12,64,60,112,248,60,248,63,240,31,240,31
       defb 224,15,224,15,224,15,192,7,192,7,128,3,128,3,0,1
       defb 0,0,0,0,0,32,0,48,12,60,120,30,248,31,240,31
       defb 224,31,224,31,192,15,128,15,128,15,0,15,0,6,0,6
       defb 0,8,0,12,0,14,0,14,0,15,254,15,252,15,248,15
       defb 240,15,224,15,192,15,128,15,0,15,0,14,0,12,0,8
       defb 0,0,0,2,0,3,0,3,128,7,128,7,240,7,254,7
       defb 254,7,248,15,240,15,192,15,128,15,0,30,0,28,0,16
       defb 0,1,0,1,128,3,128,3,128,7,192,7,224,15,252,15
       defb 254,15,252,31,240,31,192,63,0,62,0,120,0,96,0,0
       defb 128,0,128,1,128,1,192,3,192,7,192,7,192,15,240,31
       defb 252,31,254,63,240,127,0,127,0,224,0,0,0,0,0,0
       defb 0,0,32,0,96,0,224,0,224,1,224,3,224,7,224,15
       defb 240,31,248,63,254,127,254,255,0,0,0,0,0,0,0,0
       defb 0,0,16,0,112,0,224,0,224,3,224,7,192,31,192,63
       defb 224,255,241,255,240,63,248,1,28,0,0,0,0,0,0,0
       defb 0,0,0,0,12,0,56,0,248,0,240,7,240,31,224,127
       defb 225,255,240,127,240,31,248,7,248,0,60,0,12,0,0,0
       defb 0,0,0,0,0,0,28,0,248,3,240,63,241,255,224,255
       defb 192,63,192,31,224,7,224,3,224,0,112,0,16,0,0,0
       defb 0,0,0,0,0,0,0,0,0,0,254,255,254,127,252,63
       defb 240,31,224,15,224,7,224,3,224,1,224,0,96,0,32,0
       defb 0,0,0,0,0,0,0,224,0,126,240,127,254,63,252,31
       defb 240,31,192,15,192,7,192,7,128,3,128,1,128,1,128,0
       defb 0,0,0,0,0,96,0,120,0,62,192,63,240,31,252,31
       defb 254,15,252,15,224,15,192,7,128,7,128,3,128,3,0,1
       defb 0,0,0,16,0,28,0,30,128,15,192,15,240,15,248,15
       defb 254,15,254,7,248,7,128,7,128,7,0,3,0,3,0,2
       defb 0,0,0,8,0,12,0,14,0,15,128,15,192,15,224,15
       defb 240,15,248,15,252,15,254,15,0,15,0,14,0,14,0,12
       defb 0,4,0,6,0,6,0,15,128,15,128,15,192,15,224,15
       defb 224,31,240,31,248,31,120,30,12,60,0,48,0,32,0,0


; Drone graphics.
; frame 0.

drodat defb 6,96,30,120,62,252,126,254,254,255,254,127,1,252,63,252
       defb 63,252,63,128,254,127,255,127,127,126,63,124,30,120,6,96
       defb 3,48,15,60,31,126,63,127,255,127,255,63,0,254,31,254
       defb 31,254,31,192,255,63,255,191,63,191,31,190,15,60,3,48
       defb 1,152,7,158,15,191,159,191,255,191,255,159,0,127,15,255
       defb 15,255,15,224,255,159,255,223,159,223,15,223,7,158,1,152
       defb 0,204,3,207,135,223,207,223,255,223,255,207,128,63,135,255
       defb 135,255,7,240,255,207,255,239,207,239,135,239,3,207,0,204
       defb 0,102,129,231,195,239,231,239,255,239,255,231,192,31,195,255
       defb 195,255,3,248,255,231,255,247,231,247,195,247,129,231,0,102
       defb 0,51,192,243,225,247,243,247,255,247,255,243,224,15,225,255
       defb 225,255,1,252,255,243,255,251,243,251,225,251,192,243,0,51
       defb 128,25,224,121,240,251,249,251,255,251,255,249,240,7,240,255
       defb 240,255,0,254,255,249,255,253,249,253,240,253,224,121,128,25
       defb 192,12,240,60,248,125,252,253,255,253,255,252,248,3,248,127
       defb 248,127,0,127,255,252,255,254,252,254,248,126,240,60,192,12


; frame 1.

       defb 0,0,6,96,30,120,62,252,126,254,254,255,254,127,1,252
       defb 63,128,254,127,255,127,127,126,63,124,30,120,6,96,0,0
       defb 0,0,3,48,15,60,31,126,63,127,255,127,255,63,0,254
       defb 31,192,255,63,255,191,63,191,31,190,15,60,3,48,0,0
       defb 0,0,1,152,7,158,15,191,159,191,255,191,255,159,0,127
       defb 15,224,255,159,255,223,159,223,15,223,7,158,1,152,0,0
       defb 0,0,0,204,3,207,135,223,207,223,255,223,255,207,128,63
       defb 7,240,255,207,255,239,207,239,135,239,3,207,0,204,0,0
       defb 0,0,0,102,129,231,195,239,231,239,255,239,255,231,192,31
       defb 3,248,255,231,255,247,231,247,195,247,129,231,0,102,0,0
       defb 0,0,0,51,192,243,225,247,243,247,255,247,255,243,224,15
       defb 1,252,255,243,255,251,243,251,225,251,192,243,0,51,0,0
       defb 0,0,128,25,224,121,240,251,249,251,255,251,255,249,240,7
       defb 0,254,255,249,255,253,249,253,240,253,224,121,128,25,0,0
       defb 0,0,192,12,240,60,248,125,252,253,255,253,255,252,248,3
       defb 0,127,255,252,255,254,252,254,248,126,240,60,192,12,0,0






; Diamond sprites.

dmdspr defb 1,128,7,224,27,56,103,142,159,195,224,63,159,193,159,193
       defb 207,195,103,134,51,140,27,24,13,48,6,96,3,192,1,128

       defb 0,192,3,240,13,156,51,199,207,225,240,31,207,224,207,224
       defb 231,225,51,195,25,198,13,140,6,152,3,48,1,224,0,192

       defb 0,96,1,248,6,206,153,227,231,240,248,15,103,240,103,240
       defb 243,240,153,225,12,227,6,198,3,76,1,152,0,240,0,96

       defb 0,48,0,252,3,103,204,241,115,248,252,7,51,248,51,248
       defb 121,248,204,240,134,113,3,99,1,166,0,204,0,120,0,48

       defb 0,24,0,126,129,179,230,120,57,252,254,3,25,252,25,252
       defb 60,252,102,120,195,56,129,177,0,211,0,102,0,60,0,24
       defb 0,12,0,63,192,217,115,60,28,254,255,1,12,254,12,254
       defb 30,126,51,60,97,156,192,216,128,105,0,51,0,30,0,12

       defb 0,6,128,31,224,108,57,158,14,127,255,128,6,127,6,127
       defb 15,63,25,158,48,206,96,108,192,52,128,25,0,15,0,6
       defb 0,3,192,15,112,54,28,207,135,63,127,192,131,63,131,63
       defb 135,159,12,207,24,103,48,54,96,26,192,12,128,7,0,3

; Turret sprites.

turrsp defb 0,0,0,0,3,192,14,240,24,248,51,252,35,252,33,124
       defb 143,255,143,255,0,0,79,254,0,0,39,252,0,0,39,252
       defb 0,0,0,0,1,224,7,120,12,124,25,254,17,254,16,190
       defb 199,255,199,255,0,0,39,255,0,0,19,254,0,0,19,254
       defb 0,0,0,0,0,240,3,188,6,62,12,255,8,255,8,95
       defb 227,255,227,255,0,0,147,255,0,0,9,255,0,0,9,255
       defb 0,0,0,0,0,120,1,222,3,31,134,127,132,127,132,47
       defb 241,255,241,255,0,0,201,255,0,0,132,255,0,0,132,255
       defb 0,0,0,0,0,60,0,239,129,143,195,63,194,63,194,23
       defb 248,255,248,255,0,0,228,255,0,0,194,127,0,0,194,127
       defb 0,0,0,0,0,30,128,119,192,199,225,159,225,31,225,11
       defb 252,127,252,127,0,0,242,127,0,0,225,63,0,0,225,63
       defb 0,0,0,0,0,15,192,59,224,99,240,207,240,143,240,133
       defb 254,63,254,63,0,0,249,63,0,0,240,159,0,0,240,159
       defb 0,0,0,0,128,7,224,29,240,49,248,103,248,71,248,66
       defb 255,31,255,31,0,0,252,159,0,0,248,79,0,0,248,79





movdrn ld ix,dronet        ; drone table.
       ld b,4              ; maximum number of drones.
movpg0 ld a,(ix)           ; on/off switch.
       and a               ; test for on.
       call nz,movpg1      ; it's switched on, process sprite.
       ld de,8             ; size of drone table.
       add ix,de           ; look for next one.
       djnz movpg0         ; repeat for remaining patrols.
       ret

movpg1 ld a,(ix+1)         ; fetch direction.
       cp 4                ; are we static?
       jr nc,movskp        ; yes, skip movement stuff.
       ld a,(ix+4)         ; find position straddling tiles.
       add a,DRODIS        ; displacement in pixels.
       and 15              ; tiles are 16x16 pixels.
       ld (ix+4),a         ; new position.
       ret nz              ; not about to enter new tile.
movskp ld l,(ix+2)         ; drone address low.
       ld h,(ix+3)         ; drone address high.
       push hl             ; store drone address.
       call bplot          ; remove drone from scanner.
       pop hl              ; restore drone address.
       ld a,(ix+1)         ; check direction.
       call chkdrn         ; move drone in this direction.
       ld (ix+2),l         ; new drone address low.
       ld (ix+3),h         ; new drone address high.
       ld a,(hl)           ; examine tile.
       push hl             ; store drone address.
       call bplot          ; plot it on scanner.
       pop hl              ; restore drone address.
       ld a,(ix+1)         ; check direction.
       call chkdrn         ; check for walls in next tile along.
       and a               ; is it free?
       jr nz,movcd         ; no, change direction.
       ret

movcd  ld a,(ix+1)         ; get direction.
       and 2               ; vertical or horizontal bit.
       jr nz,movpv         ; it's horizontal, select new vertical direction.
movph  call random         ; fetch new pseudo-random number.
       rra                 ; 50/50 chance.
       jr c,movrf          ; look right first.
       ld c,2              ; look left.
       jr movph0
movrf  ld c,3              ; look right.
movph0 ld a,c              ; direction.
       ld l,(ix+2)         ; drone address low.
       ld h,(ix+3)         ; address high.
       call chkdrn         ; check for tile blocking drone's progress.
       and a               ; is it free?
       jr z,setpdh         ; yes, that's the horizontal direction then.
       ld a,1              ; toggle bit d7.
       xor c               ; combine with last direction.
       ld c,a              ; store new direction.
       ld l,(ix+2)         ; address low.
       ld h,(ix+3)         ; address high.
       call chkdrn         ; check for tile in new direction.
       and a               ; is it free?
       jr z,setpdh         ; yes, that's the horizontal direction then.
movpv  call random         ; fetch new pseudo-random number.
       rra                 ; 50/50 chance.
       jr c,movdf          ; look down first.
       ld c,0              ; look up.
       jr movpv0
movdf  ld c,1              ; look down.
movpv0 ld a,c              ; direction.
       ld l,(ix+2)         ; address low.
       ld h,(ix+3)         ; drone address high.
       call chkdrn         ; check for tile blocking drone's progress.
       and a               ; is it free?
       jr z,setpd          ; yes, that's the direction then.
       ld a,1              ; toggle bit d7.
       xor c               ; combine with last direction.
       ld c,a              ; store new direction.
       ld l,(ix+2)         ; address low.
       ld h,(ix+3)         ; address high.
       call chkdrn         ; check for tile in new direction.
       and a               ; is it free?
       jr z,setpd          ; yes, that's the direction then.
       call random         ; fetch new pseudo-random number.
       rra                 ; 50/50 chance.
       jr c,movrf0         ; look right first.
       ld c,2              ; look left.
       jr movph1
movrf0 ld c,3              ; look right.
movph1 ld a,c              ; direction.
       ld l,(ix+2)         ; drone address low.
       ld h,(ix+3)         ; drone address high.
       call chkdrn         ; check for tile blocking drone's progress.
       and a               ; is it free?
       jr z,setpdh         ; yes, that's the horizontal direction then.
       ld a,1              ; toggle bit d7.
       xor c               ; combine with last direction.
       ld c,a              ; store new direction.
       ld l,(ix+2)         ; drone address low.
       ld h,(ix+3)         ; drone address high.
       call chkdrn         ; check for tile in new direction.
       and a               ; is it free?
       jr z,setpdh         ; yes, that's the horizontal direction then.
       ld c,4              ; no direction.
       jp setpd            ; set direction = none.
setpdh ld a,c              ; 2=left, 3=right.
       sub 2               ; 0=left, 1=right.
setpd  ld (ix+1),c         ; set new direction.
       ret



; Moves drone position along and returns next tile address.
; C register is used by calling routine, so mustn't be corrupted.

chkdrn and a               ; zero = up.
       jr z,chkdru         ; move drone in that direction.
       dec a               ; 1 = down.
       jr z,chkdrd         ; move drone in that direction.
       dec a               ; 2 = left.
       jr z,chkdrl         ; move in that direction.
       dec a               ; 3 = right.
       jr z,chkdrr         ; move drone in that direction.
       ld a,(hl)           ; get tile at current block.
       ret
chkdrr ld de,16            ; 16 tiles per column.
       add hl,de           ; look 1 tile to the right.
chkdr0 ld a,(hl)           ; examine tile.
       ret
chkdrl ld de,65520         ; minus 16 tiles (one column).
       add hl,de           ; look 1 tile to the left.
       jp chkdr0           ; test block.
chkdrd inc hl              ; look 1 tile below.
       jp chkdr0           ; test block.
chkdru dec hl              ; look 1 tile above.
       jp chkdr0           ; test block.

shodro ld ix,dronet        ; drone table.
       ld b,4              ; maximum number of them.
shodr2 push bc             ; store count.
       ld (ix+7),224       ; put coords out of way for now.
       ld a,(ix)           ; on/off switch.
       and a               ; test for on.
       call nz,shodr1      ; it's switched on, process the thing.
       ld de,8             ; size of drone table.
       add ix,de           ; look for next drone.
       pop bc              ; restore counter.
       djnz shodr2         ; repeat for remaining enemies.
       ret

shodr1 ld de,(levptr)      ; find address of screen.
       ld (ix+7),224       ; default drone not on screen.
       ld l,(ix+2)         ; drone address low.
       ld h,(ix+3)         ; drone address high.
       and a               ; reset carry.
       sbc hl,de           ; subtract screen from drone's address.
       ret c               ; drone is to the left of the screen.
       ld a,h              ; high byte of result.
       and a               ; must be zero.
       ret nz              ; no, more than 16 columns imbetween.
       ld a,l              ; displacement low byte.
       cp 208              ; past right edge?
       ret nc              ; yes, off screen.
       and 15              ; want number 0-15.
       rlca                ; multiply by 16.
       rlca
       rlca
       rlca
       ld (dispx),a        ; that's the x coord then.
       ld a,l              ; fetch displacement again.
       and 240             ; multiple of 16 gives column.
       ld l,a
       ld a,(scrolc)       ; check scroll counter.
       neg                 ; curses, it's reversed!
       and 15              ; want it in range 0-15.
       jr nz,shodr0        ; not zero.
       ld a,16             ; zero is 16.
shodr0 ld (sfac),a         ; put it away for later.
       add a,l
       ld (dispy),a        ; that's the y coordinate.
       ld a,(ix+1)         ; find direction.
       and a               ; moving up.
       jp z,shodru         ; decrement x coordinate accordingly.
       dec a               ; moving down.
       jp z,shodrd         ; increment x coordinate accordingly.
       dec a               ; moving left.
       jp z,shodrl         ; increment y coordinate accordingly.
shodrr ld a,(dispy)        ; y coordinate.
       add a,(ix+4)        ; pixel displacement.
       ld (dispy),a        ; new y coordinate.
shodrs ld a,(dispy)        ; y coordinate.
       sub 16
       cp 192              ; overlapping edge of screen?
       ret nc              ; yes, so nothing to display.
       ld hl,(dispx)       ; coords we're about to use.
       ld (ix+6),l         ; drone's window coordinate.
       ld (ix+7),h         ; drone's window coordinate.
       ld hl,drodat        ; drone sprites.

       ld a,(ix+4)         ; frame counter.
       rra                 ; divide by 4.
       rra
       and 1               ; zero or one.
       ld d,a              ; counter * 256.
       ld e,0              ; low byte not needed.
       add hl,de           ; correct animation frame.
       jp sprite           ; show the sprite.

shodru ld a,(dispx)        ; x coordinate.
       sub (ix+4)          ; pixel displacement.
       ld (dispx),a        ; new x coordinate.
       jp shodrs           ; show drone sprite.
shodrd ld a,(dispx)        ; x coordinate.
       add a,(ix+4)        ; pixel displacement.
       ld (dispx),a        ; x coordinate.
       jp shodrs           ; show drone sprite.
shodrl ld a,(dispy)        ; y coordinate.
       sub (ix+4)          ; pixel displacement.
       ld (dispy),a        ; new coordinate.
       jp shodrs           ; show drone sprite.



; Show player sprite.

psprit ld a,(pdead)        ; player on?
       and a               ; zero means he's still alive.
       ret nz              ; he's dead.
       ld hl,(shipx)       ; player's coordinates.
       ld (dispx),hl       ; copy them into general purpose coords.
       ld hl,spdat         ; player sprite data.
       ld a,(dispy)        ; y coordinate.
       and 7               ; 8 pre-shifted positions.
       rlca                ; multiply by 1024.
       rlca
       ld d,a              ; high byte of displacement.
       ld e,0              ; no low byte.
       add hl,de           ; add y coordinate shift displacement.

       ld a,(angle)        ; angle we're facing.
       rlca                ; multiply by 32 and divide by 4.
       rlca
       ld e,a              ; store result.
       and 3               ; high mask.
       ld d,a              ; high byte.
       ld a,e              ; restore result.
       and 224             ; low mask.
       ld e,a              ; sprite displacement now in de.
       add hl,de           ; add disp for this sprite.
       jp xfer             ; jump to sprite routine.



; Take care of automatic vertical scrolling.

vscrol ld a,(shipx)        ; player vertical.
       ld hl,viewx         ; top of window.
       sub (hl)            ; find the difference.
       cp 32               ; pixels to top.
       jr c,vscrl0         ; pan up ASAP.
       cp 48               ; pixels to top.
       jr c,vscrl1         ; move up quickly.
       cp 64               ; pixels to top.
       jr c,vscrl2         ; move up slowly.
       cp 128              ; pixels to top.
       jr nc,vscrl3        ; pan down ASAP.
       cp 112              ; pixels to top.
       jr nc,vscrl4        ; move down quickly.
       cp 96               ; pixels to top.
       jr nc,vscrl5        ; move down slowly.
       ret
vscrl0 dec (hl)            ; move up very quickly.
vscrl1 dec (hl)            ; move up quickly.
vscrl2 dec (hl)            ; move up slowly.
       ld a,(hl)           ; check view coord.
       cp 250              ; have we gone negative?
       ret c               ; no, job done.
       ld (hl),0           ; stay at top of screen.
       ret
vscrl3 inc (hl)            ; move down very quickly.
       inc (hl)
vscrl4 inc (hl)            ; move down quickly.
vscrl5 inc (hl)            ; move down slowly.
       ld a,(hl)           ; check view coord.
       cp 79               ; have we gone too low?
       ret c               ; no, job done.
       ld (hl),80          ; stay at bottom of screen.
       ret







; Random number generator.

random ld hl,(seed)        ; pointer.
       ld a,(hl)           ; get "random" number from location.
       inc hl              ; increment pointer.
       res 5,h             ; keep within safe area of ROM.
       ld (seed),hl        ; new seed value.
       xor l               ; mix with low byte.
       ret
seed   defw 0


; Player bullet table.

bultab defw 0,0,0,0,0,0
       defw 0,0,0,0,0,0
       defw 0,0,0,0,0,0

; Enemy bullet table.

ebtab  defw 0,0,0,0,0,0

; Shrapnel table.

shrtab defw 0,0,0,0,0,0
       defw 0,0,0,0,0,0
       defw 0,0,0,0,0,0
       defw 0,0,0,0,0,0
       defw 0,0,0,0,0,0






dcount defb 0              ; done counter.
sfac   defb 0              ; stores scroll factor for drones.
scrolc defb 0              ; scroll counter.
pdead  defb 0              ; player dead flag.

dispx  defb 0              ; general purpose x coordinate.
dispy  defb 0              ; same for y.
viewx  defb 0              ; window viewing coordinate.

; Sprite masks for each y position, in multiples of 1.

spmask defb 255,0
       defb 127,128
       defb 63,192
       defb 31,224
       defb 15,240
       defb 7,248
       defb 3,252
       defb 1,254








; Window size = 24*32 (+2 at start).

       org 58620
window equ $
winend equ $+6145          ; last byte of window.


;       ld a,3              ; printer port.
;       call 5633           ; open channel.













       org 64766
cwndow equ $
cwnend equ $+769




