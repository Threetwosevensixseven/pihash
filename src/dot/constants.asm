; constants.asm

; Application               
DisableScroll           equ 1                           ; 0 or 1
ErrDebug                equ 0                           ; 0 or 1
CoreMinVersion          equ $3105                       ; 3.01.05

; Defines
                        define ARG_PARAMS_DEHL 1        ; Needed for arguments.asm. Makes HL=tail address, DE=argument dest
                        define Files.PiSendName "p3"    ; Name of .pisend without the dot. Must be <=7 chars.   

; 48K ROM
ROM.IY                  equ $5C3A                       ; 48K ROM expects IY to point to sysvars
ROM.SCR_CT              equ $5C8C                       ; Scroll counter sysvar

; Registers
Reg.MachineID           equ $00                         ; 0x00 (00) => Machine ID
Reg.CoreMSB             equ $01                         ; 0x01 (01) => Core Version
Reg.Peripheral2         equ $06                         ; 0x06 (06) => Peripheral 2 Setting
Reg.CPUSpeed            equ $07                         ; 0x07 (07) => CPU Speed
Reg.CoreLSB             equ $0E                         ; 0x0E (14) => Core Version (sub minor number)
Reg.VideoTiming         equ $11                         ; 0x11 (17) => Video Timing (writable in config mode only)

; Ports
Port.ULA                equ $FE                         ; Border, keyboard, EAR, MIC
Port.Reg                equ $243B                       ; Nextreg register select

; esxDOS
esx.M_DOSVERSION        equ $88                         ; $88 (136) get NextZXOS version/mode information
esx.M_GETHANDLE         equ $8d                         ; $8d (141) get handle for current dot command
esx.M_P3DOS             equ $94                         ; $94 (148) execute +3DOS/IDEDOS/NextZXOS call
esx.M_ERRH              equ $95                         ; $95 (149) register dot command error handler
esx.F_OPEN              equ $9a                         ; $9a (154) open file
esx.F_CLOSE             equ $9b                         ; $9b (155) close file
esx.F_READ              equ $9d                         ; $9d (157) read file
esx.FA_READ             equ $01                         ; esx_mode_read $01 request read access

; NextZXOS
NextZXOS.IDE_MODE       equ $01d5                       ; Query NextBASIC display mode info, or change mode
NextZXOS.IDE_BANK       equ $01bd                       ; Allocate or free 8K banks in ZX or DivMMC memory

; Chars
SMC                     equ 0                           ; Used to xplicitly indicate an SMC target
UP                      equ 11
CR                      equ 13
LF                      equ 10
Space                   equ 32
Copyright               equ 127
