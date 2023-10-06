; main.asm

; Assembles with sjasmplus v1.20.3 or above, from https://github.com/z00m128/sjasmplus
; To build: cd build then make
; To build and run in CSpect: make emu
; To build, sync to hardware Next and run: make sync then F4
                           
                        opt reset --syntax=abfw --zxnext=cspect ; tighten up syntax and warnings
                        device ZXSPECTRUMNEXT           ; Make sjasmplus aware of Next memory map
                        include constants.asm           ; Define labels and constant values
                        include macros.asm              ; Define helper macros

                        org $2000                       ; Dot commands load into divMMC RAM and execute from $2000
Start:
                        jr .begin
                        db "PiHashv1."                  ; Put a signature and version in the file, in case we ever
                        BuildNo                         ; need to detect it programmatically.
                        db 0                            ; Terminate signature string

.begin:
                        di                              ; We run with interrupts off apart from printing and halts
                        ld (Return.Stack), sp           ; SMC> Save so we can always return without needing to balance stack
                        ld (Return.IY), iy              ; SMC> Put IY safe, just in case
                        ld sp, $4000                    ; Put stack safe inside dot command
                        ld hl, LargeCmdLine
                        ld (SavedArgs), hl              ; Save args for later

                        call InstallErrorHandler        ; Handle scroll errors during printing and API calls
                        PrintMsg Msg.Startup            ; "PiHash v1.x"

                        ld a, %0000'0001                ; Test for Next courtesy of Simon N Goodwin, thanks :)
                        mirror                          ; Z80N-only opcode. If standard Z80 or successors, this will
                        nop                             ; be executed as benign opcodes that don't affect the A register.
                        nop
                        cp %1000'0000                   ; Test that the bits of A were mirrored as expected
                        ld hl, Err.NotNext              ; If not a Spectrum Next,
                        jp nz, Return.WithCustomError   ; exit with an error.
                        ld a, 1
                        ld (IsNext), a                  ; Set flag indicating we are running on a Next

                        NextRegRead Reg.MachineID       ; If we passed that test we are safe to read machine ID.
                        and %0000'1111                  ; Only look at bottom four bits, to allow for Next clones
                        cp 10                           ; 10 = ZX Spectrum Next
                        jp z, .isANext                  ;  8 = Emulator
                        cp 8                            ; Exit with error if not a Next. HL still points to err message,
                        jp nz, Return.WithCustomError   ; be careful if adding code between the Next check and here!
.isANext:
                        NextRegRead Reg.Peripheral2     ; Read Peripheral 2 register.
                        ld (RestoreF8.Saved), a         ; Save current value so it can be restored on exit.                   
                        and %0111'1111                  ; Clear the F8 enable bit,
                        nextreg Reg.Peripheral2, a      ; And write the entire value back to the register.
                        ld a, 1
                        ld (RestoreF8.Set), a           ; Indicate the saved value is restorable.

                        NextRegRead Reg.CPUSpeed        ; Read CPU speed.
                        and %11                         ; Mask out everything but the current desired speed.
                        ld (RestoreSpeed.Saved), a      ; Save current speed so it can be restored on exit.
                        nextreg Reg.CPUSpeed, %11       ; Set current desired speed to 28MHz.
                        ld a, 1
                        ld (RestoreSpeed.Set), a        ; Indicate the saved value is restorable.

                        NextRegRead Reg.CoreMSB         ; Core Major/Minor version
                        ld h, a
                        NextRegRead Reg.CoreLSB         ; Core Sub version
                        ld l, a                         ; HL = version, should be >= $3500
                        ld de, CoreMinVersion
                        CpHL de
                        ErrorIfCarry Err.CoreMin        ; Raise minimum core error if < 3.05.00

                        ld hl, (SavedArgs)              ; Start at first arg
.argLoop:               ld de, ArgBuffer                ; Parse remaining args in a loop
                        call GetSizedArgProc
                        break
                        jr nc, .noMoreArgs
                        call ParseHelp
                        jr .argLoop
.noMoreArgs:
WantsHelp+*:            ld a, SMC                       ; <SMC Non-zero if we should print help
                        or a
                        jr z, .noHelp
                        PrintMsg Msg.Help
                        if ((ErrDebug)==1)
                          Freeze 1,2
                        else
                          jp Return.ToBasic
                        endif
.noHelp:

command_tail:
temparg:
show_usage:


                        if ((ErrDebug)==1)
                          Freeze 1,2
                        else
                          jp Return.ToBasic             ; This is the end of the main dot command routine
                        endif            

                        include arguments.asm           ; from https://gitlab.com/thesmog358/tbblue/-/blob/master/src/asm/dot_commands/arguments.asm
                        include general.asm             ; General dot command routines
                        include print.asm               ; Printing routines, message and error strings
                        include vars.asm                ; Allocate space to store variables        

End equ $                                               ; End of the dot command
Length equ End-Start                                    ; Length of the dot command

                        savebin "../../bin/pihash", Start, Length ; Output the assembled dot command binary
