; print.asm

; Messages
Msg.Startup:            db "PiHash v1.", BuildNoValue, CR
                        db Copyright, " 2023 Robin Verhagen-Guest", CR, CR, 0
Msg.NoScroll:           db 26, 0, -1 ; Printed with PrintMsgAlt macro          
Msg.Md5:                db "Generating MD5 hash...", CR, 0                   
Msg.Help:               db "Do crypto operations on the", CR, "Spectrum Next Pi Accelerator", CR, CR
                        db "pihash -md5 | -sha1 \"FILE\"", CR
                        db "pihash [-h]", CR, CR                     
                        db "OPTIONS", CR, CR
                        db "  -md5", CR
                        db "  Generate an MD5 hash of FILE", CR, CR  
                        db "  -sha1", CR
                        db "  Generate a SHA1 hash of FILE", CR, CR   
                        db "  FILE", CR
                        db "  Filename to be processed", CR, CR  
                        db "  -h", CR
                        db "  Display this help", CR, CR                
                        db "PiHash v1.", BuildNoValue, CR
                        db BuildDateValue, " ", BuildTimeSecsValue, " ", CommitHashShortValue, CR
                        db Copyright, " 2023 Robin Verhagen-Guest", CR, 0

; Errors                ;  "<-Longest valid error>"C    ; C sets bit 7 of final character
Err.Break:              db "D BREAK - CONT repeats"C
Err.NoMem:              db "4 Out of memory"C
Err.NotNext:            db "Spectrum Next required"C
Err.CoreMin:            db "Core 3.01.05+ required"C
Err.ArgsBad:            db "Invalid Arguments"C
Err.NotOS:              db "NextZXOS required"C

PrintRst16:
                        SafePrintStart
                        if ((DisableScroll)==1)
PrintRst16.ScrollCnt+*:     ld a, 22                    ; Set upper screen to not scroll
                            ld (ROM.SCR_CT), a          ; for another 24 rows of printing
                        endif
                        ei
PrintRst16.Loop:        ld a, (hl)
                        inc hl
PrintRst16.Terminator+*:cp SMC                          ; <SMC can be changed to different terminator
                        jp z, PrintRst16.Return
                        rst 16
                        jr PrintRst16.Loop
PrintRst16.Return:      SafePrintEnd
                        ret

PrintRst16Alt:
                        push af
                        ld a, -1
                        ld (PrintRst16.Terminator), a   ; SMC> Change terminator
                        pop af
                        call PrintRst16
                        push af
                        xor a
                        ld (PrintRst16.Terminator), a   ; SMC> Restore terminator
                        pop af
                        ret                      

PrintRst16Error:
                        SafePrintStart
.loop:                  ld a, (hl)
                        ld b, a
                        and %1'0000000
                        ld a, b
                        jr nz, .lastChar
                        inc hl
                        rst 16
                        jr .loop
.return:                jr PrintRst16.Return
.lastChar:              and %0'1111111
                        rst 16
                        ld a, CR                        ; The error message doesn't include a trailing CR in the
                        rst 16                          ; definition, so we want to add one when we print it
                        jr .return                      ; in the upper screen.
