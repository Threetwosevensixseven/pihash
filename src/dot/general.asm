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

; ***************************************************************************
; * Parse an argument from the command tail                                 *
; ***************************************************************************
; Entry: HL=command tail
;        DE=destination for argument
; Exit:  Fc=0 if no argument
;        Fc=1: parsed argument has been copied to DE and null-terminated
;        HL=command tail after this argument
;        BC=length of argument
; NOTE:  BC is validated to be 1..255; if not, it does not return but instead
;        exits via show_usage.
;
; Routine provided by Garry Lancaster, with thanks :) Original is here:
; https://gitlab.com/thesmog358/tbblue/blob/master/src/asm/dot_commands/defrag.asm#L599
GetSizedArgProc:
                        ld a, h
                        or l
                        ret z                           ; exit with Fc=0 if hl is $0000 (no args)
                        ld bc, 0                        ; initialise size to zero
.loop:                  ld a, (hl)
                        inc hl
                        and a
                        ret z                           ; exit with Fc=0 if $00
                        cp CR
                        ret z                           ; or if CR
                        cp ':'
                        ret z                           ; or if ':'
                        cp ' '
                        jr z, .loop                     ; skip any spaces
                        cp '"'
                        jr z, .quoted                   ; on for a quoted arg
.unquoted:              ld (de), a                      ; store next char into dest
                        inc de
                        inc c                           ; increment length
                        jr z, .badSize                  ; don't allow >255
                        ld  a, (hl)
                        and a
                        jr z, .complete                 ; finished if found $00
                        cp CR
                        jr z, .complete                 ; or CR
                        cp ':'
                        jr z, .complete                 ; or ':'
                        cp '"'
                        jr z, .complete                 ; or '"' indicating start of next arg
                        inc hl
                        cp ' '
                        jr nz, .unquoted                ; continue until space
.complete:               xor a
                        ld (de), a                      ; terminate argument with NULL
                        ld a, b
                        or c
                        jr z, .badSize                  ; don't allow zero-length args
                        scf                             ; Fc=1, argument found
                        ret
.quoted:                ld a, (hl)
                        and a
                        jr z, .complete                 ; finished if found $00
                        cp CR
                        jr z, .complete                 ; or CR
                        inc hl
                        cp '"'
                        jr z, .complete                 ; finished when next quote consumed
                        ld (de), a                      ; store next char into dest
                        inc de
                        inc c                           ; increment length
                        jr z, .badSize                  ; don't allow >255
                        jr .quoted
.badSize:               pop af                          ; discard return address
                        ErrorAlways Err.ArgsBad

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
                        ld a, (hl)
                        cp '-'
                        jr nz, .return
                        inc hl
                        ld a, (hl)
                        cp 'h'
                        jr nz, .return
                        ld a, 1
                        ld (WantsHelp), a
.return:                pop hl
                        pop bc
                        pop af
                        ret
