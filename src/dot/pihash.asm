; pihash.asm

DoPiHashing:
                        ld a, (WantsMd5)
                        or a
                        jr z, .noMd5
                        PrintMsg Msg.Md5
.noMd5







FinishPiHashing:
                        if ((ErrDebug)==1)
                          Freeze 1,2
                        else
                          jp Return.ToBasic             ; This is the end of the main dot command routine
                        endif 
