; print.asm

; Messages
Msg.Startup:            db "PiHash v1.", BuildNoValue, CR
                        db Copyright, " 2023 Robin Verhagen-Guest", CR, CR, 0
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
Err.NotNext:            db "Spectrum Next required"C
Err.CoreMin:            db "Core 3.05.00 required"C
;Err.ArgsTooBig:        db "Arguments too long"C
Err.ArgsBad:            db "Invalid Arguments"C

PrintRst16:
                        SafePrintStart
                        if ((DisableScroll)==1)
                            ld a, 24                    ; Set upper screen to not scroll
                            ld (ROM.SCR_CT), a          ; for another 24 rows of printing
                        endif
                        ei
.loop:                  ld a, (hl)
                        inc hl
                        or a
                        jr z, PrintRst16.Return
                        rst 16
                        jr .loop
PrintRst16.Return:      SafePrintEnd
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
