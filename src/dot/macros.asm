; macros.asm

                        include version.asm             ; Auto-generated by make. Has date/time and git commit count macros.

                        macro Border Colour?            ; Convenience macro to help during debugging.
                            if ((Colour?)==0)
                                xor a
                            else
                                ld a, +(Colour?)
                            endif
                            out (Port.ULA), a
                        endm

                        macro Freeze Colour1?, Colour2? ; Convenience macro to help during debugging. Alternates
.loop:                      Border Colour1?             ; the border rapidly between two colours. This really helps
                            Border Colour2?             ; to show that the machine hasn't crashed. Also it gives you
                            jr .loop                    ; 8*7=56 colour combinations to use, instead of 7.
                        endm

                        macro CSBreak                   ; Intended for CSpect debugging when -brk switch is supplied    
                            push bc                     ; enabled when the -brk switch is supplied                       
                            break                       ; break is db $dd, $01, enavbed with --zxNnext=cspect
                            nop                         ; On real Z80 or Z80N, this does NOP:LD BC, NNNN
                            nop                         ; so we set safe values for NN and NN,
                            pop bc                      ; then we restore the value of bc we saved earlier
                        endm

                        macro CSBreak1                  ; Intended for CSpect debugging when -brk switch is supplied                                                         
                            break                       ; break is db $dd, $01, enavbed with --zxNnext=cspect
                        endm                            ; This one is not safe to leave in non-CSpect code

                        macro MFBreak                   ; This turns off divMMC and triggers a NMI breakpoint
                            push bc                     ; You need to be in regular RAM >= $4000 to invoke this,
                            ld c, $e3                   ; and it will blow up if you try to return to divMMC memory.
                            ld b, 0                     ; For cores 3.01.10 and above.
                            out (c), b
                            pop bc
                            extreg 10, 8
                            nextreg 2, 8
                            nop
                        endm

                        macro MFBreak1                  ; This one works if divMMC is already disabled,
                            nextreg 2, 8                ; and shouldn't blow up at all.
                            nop                         ; For cores 3.01.10 and above.
                        endm

                        macro MFBreakOld                ; Intended for NextZXOS NMI debugging on cores < 3.01.10.
                            push af                     ; MF must be enabled first, by pressing M1 button
                            ld a, r                     ; then choosing Return from the NMI menu.
                            di
                            in a, ($3f)
                            rst 8                       ; It's possible the stack will end up unbalanced
                        endm

                        macro Rst8 Command?             ; Parameterised wrapper for esxDOS API routine
                            rst $08
                            db Command?
                        endm

                        macro PrintMsg Address?         ; Parameterised wrapper for null-terminated buffer print routine
                            ld hl, Address?
                            call PrintRst16
                        endm

                        macro SafePrintStart            ; Included at the start of every routine which calls rst 16
                            di                          ; Interrupts off while paging. Subsequent code will enable them.
                            ld (SavedStackPrint), sp    ; Save current stack to be restored in SafePrintEnd()
                            ld sp, (Return.Stack)       ; Set stack back to what BASIC had at entry, so safe for rst 16
                            ld (SavedIYPrint), iy
                            ld iy, ROM.IY
                        endm

                        macro SafePrintEnd              ; Included at the end of every routine which calls rst 16
                            di                          ; Interrupts off while paging. Subsequent code doesn't care.
SavedA+*:                   ld a, SMC                   ; <SMC Restore A so it's completely free of side-effects
                            ld sp, (SavedStackPrint)    ; Restore stack to what it was before SafePrintStart()
                            ld iy, (SavedIYPrint)
                        endm

                        macro NextRegRead Register?     ; Nextregs have to be read through the register I/O port pair,
                            ld bc, Port.Reg             ; as there is no dedicated ZX80N opcode like there is for
                            ld a, Register?             ; writes.
                            out (c), a
                            inc b
                            in a, (c)
                        endm

                        macro CpHL Register?            ; Convenience wrapper to compare HL with BC or DE
                            or a                        ; Note that sj macros can accept register literals,
                            sbc hl, Register?           ; so the call would be CpHL de without enclosing quotes.
                            add hl, Register?
                        endm

                        macro ErrorAlways ErrAddr?      ; Parameterised wrapper for unconditional custom error
                            ld hl, ErrAddr?
                            jp ErrorProc
                        endm

                        macro ErrorIfCarry ErrAddr?     ; Parameterised wrapper for throwing custom esxDOS-style error
                            jr nc, .continue
                            ld hl, ErrAddr?
                            jp ErrorProc
.continue:
                        endm

                        macro ErrorIfNoCarry ErrAddr?   ; Parameterised wrapper for throwing custom NextZXOS-style error
                            jr c, .continue
                            ld hl, ErrAddr?
                            jp ErrorProc
.continue:
                        endm

                        macro ErrorIfZero ErrAddr?      ; Parameterised wrapper for throwing error if loop overruns
                            jr nz, .continue
                            ld hl, ErrAddr?
                            jp ErrorProc
.continue:
                        endm

                        macro ErrorIfNotZero ErrAddr?   ; Parameterised wrapper for throwing error after comparison
                            jr z, .continue
                            ld hl, ErrAddr?
                            jp ErrorProc
.continue: 
                        endm

                        macro GetSizedArg \
                            ArgTailPtr?, DestAddr?      ; Parameterised wrapper for arg parser
                            ld hl, (ArgTailPtr?)
                            ld de, DestAddr?                           
                            call GetSizedArgProc
                        endm

                        macro Compare Char?, Addr?      ; Macro to compare a character   
                            ld a, (hl)
                            cp Char?                    ; Compare (HL) to Char? parameter
                            jr nz, Addr?                ; If not matched go to Addr? parameter
                            inc hl
                        endm