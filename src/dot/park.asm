; park.asm

                        ;DISPLAY "Before park DISP: ", $; This section must be the FIRST entry in park.asm.            
                        DISP $C000+$                    ; Routines in park.asm are inside the 8K dot command, 
                        ;DISPLAY "After park DISP: ", $ ; but are displaced to execute at $E000 instead of $2000.                  

CallPiSend:                                             ; We start off here running part of PiHash inside $E000 bank.
                        call UnparkPiSend               ; Copy PiSend down from $C000 bank to $2000 bank.
CallPiSend.Cmd+*:       ld hl, SMC                      ; <SMC Write the address of a cmdline (>=$4000) here.
                        call $2000                      ; PiSend is at $2000, expecting cmdline in (HL).
                        jp UnparkPiHash                 ; PiSend returns back to $E000 bank.

UnparkPiSend:
                        ld hl, $C000                    ; We start off here running part of PiHash inside $E000 bank.
                        ld de, $2000
                        ld b, d
                        ld c, e
                        ldir                            ; Copy Pisend back inside $2000 bank,
                        ret                             ; and return to PiHash, still inside $E000 bank.

UnparkPiHash:                                           
                        ld hl, $E000                    ; We start off here running part of PiHash inside $E000 bank.
                        ld de, $2000
                        ld b, d
                        ld c, e
                        ldir                            ; Copy Pihash back inside $2000 bank.
                        ld hl, -$C000                   ; Adjust the stack pointer...
                        ld d, h
                        ld e, l
                        add hl, sp
                        ld sp, hl                       ; ...back inside $2000 bank.
                        pop hl                          ; Get the top value off the stack,
                        add hl, de                      ; recalculate it inside $2000 bank,                     
                        jp (hl)                         ; and return to it.

                        ;DISPLAY "Before park ENT: ", $ ; This section must be the LAST entry in park.asm.
                        ENT                             ; Remaining asm files included after park.asm
                        ;DISPLAY "After park ENT: ", $  ; are assembled to execute at $2000 again.
