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
                        ;call RestoreBanks              ; Restore original banks
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
                        ;call RestoreBanks              ; Restore original banks
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
