; general.asm

InstallErrorHandler:                                    ; Our error handler gets called by the OS if SCROLL? N happens
                        ld hl, ErrorHandler             ; during printing, or any other ROM errors get thrown. We trap
                        Rst8 esx.M_ERRH                 ; the error in our ErrorHandler routine to give us a chance to
                        ret                             ; clean up the dot cmd before exiting to BASIC.


ErrorHandler:                                           ; If we trap any errors thrown by the ROM, we currently just
                        ld hl, Err.Break                ; exit the dot cmd with a  "D BREAK - CONT repeats" custom
                        jr Return.WithCustomError       ; error.

Return:                                                 ; This routine restores everything preserved at the start of
Return.ToBasic:                                         ; the dot cmd, for success and errors, then returns to BASIC.                                
                        call RestoreSpeed               ; Restore original CPU speed
                        call RestoreF8                  ; Restore original F8 enable/disable state.
                        call RestoreBanks               ; Restore original banks
Return.RestoreStack:
Return.Stack+*:         ld sp, SMC                      ; <SMC Unwind stack to original point.
Return.IY+*:            ld iy, SMC                      ; <SMC Restore IY.
Return.SetError+*:      ld a, SMC                       ; <SMC Standard esxDOS error code gets patched here.    
                        ei
                        ret                             ; Return to BASIC.
Return.WithCustomError:
                        push hl
                        call RestoreSpeed               ; Restore original CPU speed
                        call RestoreF8                  ; Restore original F8 enable/disable state
                        call RestoreBanks               ; Restore original banks
                        xor a
                        scf                             ; Signal error, hl = custom error message
                        pop hl                          ; (NextZXOS is not currently displaying standard error messages,
                        jr Return.RestoreStack          ;  with a>0 and carry cleared, so we use a custom message.)                         

RestoreF8:
RestoreF8.Set+*:        ld a, SMC                       ; <SMC If still non-zero,                                   
                        or a                            ; then the value hasn't been read and set,
                        ret z                           ; so return immediately
RestoreF8.Saved+*:      ld a, SMC                       ; <SMC This was saved here when we entered the dot command
                        and %1000'0000                  ; Mask out everything but the F8 enable bit
                        ld d, a
                        NextRegRead Reg.Peripheral2     ; Read the current value of Peripheral 2 register
                        and %0111'1111                  ; Clear the F8 enable bit
                        or d                            ; Mask back in the saved bit
                        nextreg Reg.Peripheral2, a      ; Save back to Peripheral 2 register
                        ret

RestoreSpeed:
RestoreSpeed.Set+*:     ld a, SMC                       ; <SMC If still non-zero,                                   
                        or a                            ; then the value hasn't been read and set,
                        ret z                           ; so return immediately
RestoreSpeed.Saved+*:   nextreg Reg.CPUSpeed, SMC       ; <SMC Restore speed to what it originally was at dot cmd entry
                        ret

RestoreBanks:
                        push af
RestoreBanks.Bank1+*:   ld a, -2                        ; <SMC Read the MMU bank that was previously in slot 7.
                        cp -2                           ; If it was -2 then we never changed it,
                        jr z, RestoreBanks.Restore2     ; so skip this part,
                        call Deallocate8KBank           ; otherwise deallocate the bank,
RestoreBanks.Restore2:
RestoreBanks.Bank2+*:   ld a, -2                        ; <SMC Read the MMU bank that was previously in slot 6.
                        cp -2                           ; If it was -2 then we never changed it,
                        jr z, RestoreBanks.Restore3     ; so skip this part,
                        call Deallocate8KBank           ; otherwise deallocate the bank,
RestoreBanks.Restore3:
RestoreBanks.Bank3+*:   ld a, -2                        ; <SMC Read the MMU bank that was previously in slot 5.
                        cp -2                           ; If it was -2 then we never changed it,
                        jr z, RestoreBanks.Restore4     ; so skip this part,
                        call Deallocate8KBank           ; otherwise deallocate the bank,
RestoreBanks.Restore4:
RestoreBanks.R55+*:     nextreg $55, 5                  ; Restore what BASIC is expecting to find at $A000 (16K bank 5)
RestoreBanks.R56+*:     nextreg $56, 0                  ; Restore what BASIC is expecting to find at $C000 (16K bank 0)
RestoreBanks.R57+*:     nextreg $57, 1                  ; Restore what BASIC is expecting to find at $E000 (16K bank 0)      
                        pop af
                        ret

BanksBackToBasic:
                        push af
                        ld a, (RestoreBanks.R55)
                        nextreg $55, a
                        ld a, (RestoreBanks.R56)
                        nextreg $56, a
                        ld a, (RestoreBanks.R57)
                        nextreg $57, a
                        pop af
                        ret

BanksBackToDot:
                        push af
                        ld a, (RestoreBanks.Bank1)
                        cp -2
                        jp z, .continue1
                        nextreg $57, a
.continue1:             ld a, (RestoreBanks.Bank2)
                        cp -2
                        jp z, .continue2
                        nextreg $56, a
.continue2:             ld a, (RestoreBanks.Bank3)
                        cp -2
                        jp z, .continue3
                        nextreg $55, a
.continue3:             pop af
                        ret

ErrorProc:
                        if ((ErrDebug)==1)
                          call PrintRst16Error
.stop:                     Border 2 
                          jr .stop
                        else                            ; The normal (non-debug) error routine shows the error in both
                          push hl                       ; If we want to print the error at the top of the screen,
                          call PrintRst16Error          ; as well as letting BASIC print it in the lower screen,
                          pop hl                        ; then uncomment this code.
                          jp Return.WithCustomError     ; Straight to the error handing exit routine
                        endif

show_usage:                                             ; get_sizedarg in arguments.asm exits here if args length > 255, 
                        ErrorAlways Err.ArgsBad         ; in which case exit with "Invalid Arguments" error.

ParseHelp:
                        ret nc                          ; Return immediately if no arg found
                        push af
                        push bc
                        push hl
                        ld a, b
                        or c
                        cp 2
                        jr nz, .return
                        ld hl, ArgBuffer
                        Compare '-', .return            ; Does arg match -h ?
                        Compare 'h', .return            
                        ld a, 1                         ; Matches, set a flag
                        ld (WantsHelp), a
                        ld ixl, 1                       ; Signal we matched an arg in this loop pass  
.return:                pop hl                          ; Does not match
                        pop bc
                        pop af
                        ret

ParseMd5:
                        ret nc                          ; Return immediately if no arg found
                        push af
                        push bc
                        push hl
                        ld a, b
                        or c
                        cp 4
                        jr nz, .return
                        ld hl, ArgBuffer
                        Compare '-', .return            ; Does arg match -md5 ?
                        Compare 'm', .return
                        Compare 'd', .return
                        Compare '5', .return        
                        ld a, 1                         ; Matches, set a flag
                        ld (WantsMd5), a
                        ld ixl, 1                       ; Signal we matched an arg in this loop pass                
.return:                pop hl                          ; Does not match
                        pop bc
                        pop af
                        ret

ParseFileName:
                        push af
                        push bc
                        push hl
                        ld a, ixl                       ; Did we match this arg already?
                        or a
                        jr nz, .noFile                  ; Does not match 
                        ld a, (FileCount)               ; Any unmatched arg is a file,
                        inc a                           ; so increase
                        ld (FileCount), a               ; the file count.
                        ld hl, ArgBuffer                ; Copy the arg from the temp buffer
                        ld de, FileName                 ; to the filename buffer
                        ldir                                                    
                        xor a
                        ld (de), a
.noFile:                pop hl
                        pop bc         
                        pop af
                        ret

Allocate8KBank:
                        ld hl, $0001                    ; H = $00: rc_banktype_zx, L = $01: rc_bank_alloc
Allocate8KBank.Internal:exx
                        ld c, 7                         ; 16K Bank 7 required for most NextZXOS API calls
                        ld de, NextZXOS.IDE_BANK        ; M_P3DOS takes care of stack safety stack for us
                        Rst8(esx.M_P3DOS)               ; Make NextZXOS API call through esxDOS API with M_P3DOS
                        ErrorIfNoCarry(Err.NoMem)       ; Fatal error, exits dot command
                        ld a, e                         ; Return in a more conveniently saveable register (A not E)
                        ret

Deallocate8KBank:                                       ; Takes bank to deallocate in A (not E) for convenience
                        cp $FF                          ; If value is $FF it means we never allocated the bank,
                        ret z                           ; so return with carry clear (error) if that is the case
                        ld e, a                         ; Now move bank to deallocate into E for the API call
                        ld hl, $0003                    ; H = $00: rc_banktype_zx, L = $03: rc_bank_free
                        jr Allocate8KBank.Internal      ; Rest of deallocate is the same as the allocate routine

ParkPiHash:
                        ld hl, $2000                    ; Copy the entire 8K block of the current state of .pihash
                        ld de, $E000                    ; to $E000 (park it).
                        ld b, h
                        ld c, l
                        ldir 
                        ld hl, $C000
                        add hl, sp
                        ld sp, hl                       ; Point stack in $E000 bank instead of $2000 bank
                        pop hl
                        ld de, $C000
                        add hl, de
                        jp (hl)                         ; Pop the top stack value, convert to $E000 and return

LoadAndCachePiSend:
                        
                        ld hl, Files.PiSend             ; HL not IX because we are in a dot command
                        ld a, '$'                       ; System drive, where dot commands always live
                        ld b, esx.FA_READ               ; b = open mode (esx_mode_read $01 request read access)
                        Rst8 esx.F_OPEN                 ; $9a (154) open file
                        ErrorIfCarry Err.PiSendNFF      ; Raise missing .pisend error if not loaded
                        ld (Files.PiSendHandle), a      ; Store open .pisend handle for later use                 
                        ld hl, $C000                    ; Read .pisend command file into $C000
                        ld bc, $2000                    ; Maximum 8KB (probably smaller)
                        Rst8 esx.F_READ                 ; ; $9d (157) read file
                        ErrorIfCarry(Err.PiSendNFF)     ; Raise missing .pisend error if not read
                                                        ; CF is guaranteed clear here,
                                                        ; but don't insert other code before zeroize!
                        ex de, hl                       ; Put address of second byte to be zeroed in de.
                        ld hl, $1FFF                    ; Take the size of an 8K block minus 1,
                        sbc hl, bc                      ; and subtract the bytes loaded (returned in bc).
                        ld c, l                        
                        ld b, h                         ; Put count of bytes to zeroize in bc.                     
                        push de                         ; Put address first byte 
                        pop hl                          ; to be zeroed in hl,
                        inc de                          ; and address of second byte in de.
                        ld (hl), 0                      ; Zeroize first byte
                        ldir                            ; then zeroize the rest.
                        ret

ParkAndCallPiSend:     
                        call ParkPiHash                 ; Park .pihash at $E000
                        jp $+$C003                      ; Jump to the next line but in the parked version 
                        call CallPiSend
                        ret