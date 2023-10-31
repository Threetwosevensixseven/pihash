; park.asm

                        ;DISPLAY "Before park DISP: ", $; This section must be the FIRST entry in park.asm.            
                        DISP $C000+$                    ; Routines in park.asm are inside the 8K dot command, 
                        ;DISPLAY "After park DISP: ", $ ; but are displaced to execute at $E000 instead of $2000.                  

CallPiSend:            
                        call UnparkPiSend
CallPiSend.Cmd+*:       ld hl, SMC                      ; <SMC Write the address of a cmdline (>=$4000) here.
                        call $2000                      ; PiSend is at $2000, expecting cmdline in (HL).
                        jp UnparkPiHash

UnparkPiSend:
                        ld hl, $C000
                        ld de, $2000
                        ld bc, $2000
                        ldir
                        ret

UnparkPiHash:
                        ld hl, $E000                    ; Copy Pihash back inside $2000 bank
                        ld de, $2000
                        ld bc, $2000
                        ldir
                        ld (.stack), sp                 ; Adjust the stack pointer...
.stack+*:               ld hl, SMC
                        ld de, $C000
                        or a
                        sbc hl, de
                        ld sp, hl                       ; ...back inside $2000 bank
                        pop hl                          ; Get the top value off the stack,
                        or a
                        sbc hl, de                      ; recalculate it inside $2000 bank,
                        jp (hl)                         ; and return to it.

                        ;DISPLAY "Before park ENT: ", $ ; This section must be the LAST entry in park.asm.
                        ENT                             ; Remaining asm files included after park.asm
                        ;DISPLAY "After park ENT: ", $  ; are assembled to execute at $2000 again.
