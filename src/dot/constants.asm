; constants.asm

; Application               
DisableScroll           equ 0                           ; 0 or 1
ErrDebug                equ 0                           ; 0 or 1
CoreMinVersion          equ $3500                       ; 3.05.00

; Defines
                        define ARG_PARAMS_DEHL (1==0)   ; Needed for arguments.asm (pasmo syntax)

; 48K ROM
ROM.IY                  equ $5C3A                       ; 48K ROM expects IY to point to sysvars
ROM.SCR_CT              equ $5C8C                       ; Scroll counter sysvar

; Registers
Reg.MachineID           equ $00
Reg.CoreMSB             equ $01
Reg.Peripheral2         equ $06
Reg.CPUSpeed            equ $07
Reg.CoreLSB             equ $0E
Reg.VideoTiming         equ $11

; Ports
Port.ULA                equ $FE                         ; Border, keyboard
Port.Reg                equ $243B

; esxDOS
esx.M_DOSVERSION        equ $88
esx.M_ERRH              equ $95

; Chars
SMC                     equ 0                           ; Used to xplicitly indicate an SMC target
UP                      equ 11
CR                      equ 13
LF                      equ 10
Space                   equ 32
Copyright               equ 127