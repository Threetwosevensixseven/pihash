; vars.asm

; Application
SavedArgs:              dw 0
SavedStackPrint:        dw $0000
SavedIYPrint:           dw $0000
IsNext:                 ds 0

; Buffers (will be at end of dot command)
ArgBuffer:              ds 256
LargeCmdLine:           db "a\"\"b", CR

