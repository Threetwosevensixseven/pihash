; main.asm

; Assembles with sjasmplus v1.20.3 or above, from https://github.com/z00m128/sjasmplus
; To build (win only, sorry): cd src/dot then make
; To build and run in CSpect: make emu
; To build, sync to hardware Next and run: make sync then F4
                           
                        opt reset --syntax=abfw \
                            --zxnext=cspect             ; Tighten up syntax and warnings
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
                        //ld hl, EscapedCmdLine         ; TESTING ONLY
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
                        NextRegRead $57                 ; Backup existing banks in all three slots,
                        ld (RestoreBanks.R57), a        ; and do it right now in case we take an early exit.
                        NextRegRead $56                 ; We can't do this backup before the IsANext check,
                        ld (RestoreBanks.R56), a        ; as reading these ports will have a bad effect on a non-Next.
                        NextRegRead $56                 ; We might still have exited before this point, but only on a                                                                   
                        ld (RestoreBanks.R56), a        ; classic Spectrum, where the default values will be correct.

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
                        ld l, a                         ; HL = version, should be >= $3105
                        ld de, CoreMinVersion
                        CpHL de
                        ErrorIfCarry Err.CoreMin        ; Raise minimum core error if < 3.01.05

                        ld hl, (SavedArgs)              ; Start at first arg
.argLoop:               ld ixl, 0                       ; Track matches during each loop pass in ix
                        ld de, ArgBuffer                ; Parse remaining args in a loop
                        call get_sizedarg               ; Garry's routine in arguments.asm
                        jr nc, .noMoreArgs
                        call ParseHelp
                        call ParseMd5
                        call ParseFileName              ; Must be last in the loop. Any unmatched arg is the filename.
                        jr .argLoop
.noMoreArgs:
                        ld a, (FileCount)               ; If we have more than one file,
                        cp 1                            ; then the args are bad,
                        jr nz, .forceHelp               ; and we should display the help and exit.
                        ld a, (WantsMd5)                ; If we don't want any of the action switches
                        or a                            ; then the args are also bad,
                        jr z, .forceHelp                ; and we should display the help and exit
                        
                        ld a, (WantsHelp)               ; Non-zero if we should print help
                        or a
                        jp z, .noHelp
.forceHelp:             if ((DisableScroll)==1)
                            ld a, 1
                            ld (PrintRst16.ScrollCnt), a; SMC> Always reenable scrolling 
                        endif                           ; when printing help and exiting.
                        PrintMsg Msg.Help               
                        if ((ErrDebug)==1)
                          Freeze 1,2
                        else
                          jp Return.ToBasic
                        endif
.noHelp:
                                                        ; Always consult the latest version of the NextZXOS 
                                                        ; and esxDOS API doc, available on the distro and here:
                                                        ; https://gitlab.com/thesmog358/tbblue/-/blob/master/docs/nextzxos/NextZXOS_and_esxDOS_APIs.pdf
                        xor a                           ; A=0, query current mode information
                        ld c, 7                         ; 16K Bank 7 required for most NextZXOS API calls
                        ld de, NextZXOS.IDE_MODE        ; M_P3DOS takes care of stack safety stack for us
                        Rst8(esx.M_P3DOS)               ; Make NextZXOS API call through esxDOS API with M_P3DOS
                        ErrorIfNoCarry(Err.NotOS)       ; Fatal error, exits dot command
                        and %000000'11                  ; A bits 1..0 are LAYER
                        jr z, .endLayerDetection        ; If LAYER 0, we will handle disabling scroll at print time
                        if ((DisableScroll)==1)         ; by poking ROM.SCR_CT. Otherwise,
                            PrintMsgAlt Msg.NoScroll    ; Print CHR$ 26;CHR$ 0; to disable scroll when not LAYER 0.
                        endif
.endLayerDetection:

                        ; This dot command is larger than 8KB, because the Pi binaries are included.
                        ; We have a strategy for dealing with that.
                        ; NextZXOS will automatically load the first 8KB, which contains all the core code,
                        ; and will leave the file handle open. If the core code is less than 8KB, 
                        ; the makefile will pad it to 8KB automatically.
                        ; Use of this feature means this dot cmd cannot run under vanilla esxDOS, so we 
                        ; must do an initial check for NextZXOS, and exit gracefully if not present.
                        ; We call M_GETHANDLE to get and save the handle.
                        Rst8(esx.M_GETHANDLE)           ; Get dot handle
                        ld (DotHandle), a               ; Save dot handle for later

                        ; We need one 8K bank to handle file buffers. 
                        ; Same bank buffer is used for loading Pi binaries and loading the file to be hashed.
                        ; We also need a second 8K bank to hold pisend,
                        ; and a third bank to backup and restore the current state of this .pihash command.
                        ; We will use IDE_BANK to allocate thee 8KB banks, 
                        ; which must be freed before exiting the dot command.
                        call Allocate8KBank             ; Bank number in A (not E), errors have already been handled.
                        ld (RestoreBanks.Bank1), a      ; Save bank number,
                        nextreg $57, a                  ; and set slot 7 to the allocated bank.
                        call Allocate8KBank             ; Bank number in A (not E), errors have already been handled.
                        ld (RestoreBanks.Bank2), a      ; Save bank number,
                        nextreg $56, a                  ; and set slot 6 to the allocated bank.                   
                        call Allocate8KBank             ; Bank number in A (not E), errors have already been handled.
                        ld (RestoreBanks.Bank3), a      ; Save bank number,
                        nextreg $55, a                  ; and set slot 5 to the allocated bank.  

                        call LoadAndCachePiSend
                        ld hl, Cmd.PisendQ+$C000        ; Load address of command line, adjusted for parking
                        ld (CallPiSend.Cmd-$C000), hl   ; Write into calling routine address, adjusted for parking
                        call ParkAndCallPiSend
                        PrintMsg Msg.EOLPad
                        NextRegRead $7f
                        cp 2
                        jr nz, .not115
                        PrintMsg Msg.115200
                        jr .endbaud
.not115:                cp 8
                        jr nz, .not2meg
                        PrintMsg Msg.2meg
                        jr .endbaud    
.not2meg:               PrintMsg Msg.PiNotFound
.endbaud:

FinishPiHashing:
                        if ((ErrDebug)==1)
                          Freeze 1,2
                        else
                          jp Return.ToBasic             ; This is the end of the main dot command routine
                        endif 

                        opt push --dirbol               ; Allow directives at beginning of line just for imported pasmo code
                        include arguments.asm           ; from https://gitlab.com/thesmog358/tbblue/-/blob/master/src/asm/dot_commands/arguments.asm
                        opt pop                         ; Disallow directives at beginning of line again
                        include general.asm             ; General dot command routines
                        include print.asm               ; Printing routines, message and error strings
                        include park.asm                ; Routines displaced to execute at $E000
                        include vars.asm                ; Allocate space to store variables   

                        ;org $3fff                      ; Pad dot command to 8KB
                        ;db 0;                             

End equ $                                               ; End of the dot command
Length equ End-Start                                    ; Length of the dot command

                        savebin "../../bin/pihash", \
                            Start, Length               ; Output the assembled dot command binary
