; vars.asm

; Application
SavedArgs:              dw 0
SavedStackPrint:        dw $0000
SavedIYPrint:           dw $0000
IsNext:                 db 0
WantsMd5:               db 0
WantsHelp:              db 0
FileCount:              db 0
DotHandle:              db 0

; Files
Files.PiSend:           db "/dot/", Files.PiSendName, 0 ; This is where .pisend lives on the user's SD card
Files.PiSendHandle:     db 255                          ; .pisend handle will be stored here for later closing

; Command Lines
Cmd.PisendQ             db "-q", 0

; Buffers (will be at end of dot command)
ArgBuffer:              ds 256
FileName:               ds 256
EscapedCmdLine:         db "a\"\"b", CR
LargeCmdLine:           db "12345678901234567890123456789012345678901234567890"
                        db "12345678901234567890123456789012345678901234567890"
                        db "12345678901234567890123456789012345678901234567890"
                        db "12345678901234567890123456789012345678901234567890"
                        db "12345678901234567890123456789012345678901234567890"
                        db "12345678901234567890123456789012345678901234567890", CR

; In many scenarios we wouldn't want to include these large swathes of zero bytes
; inside the dot command binary. It would be cleaner to define the addresses but
; exclude them from the binary and include a zeroizing init routine instead.
; However, for this dot command I'm planning on padding the binary to 8KiB and 
; appending some compiled linux Pi binaries.
