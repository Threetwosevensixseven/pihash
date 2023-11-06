# Pihash

Pihash is a [ZX Spectrum™ Next](https://www.specnext.com/about/) [dot command](https://www.specnext.com/forum/viewtopic.php?t=1257#p8099)
to do crypto operations on the [Raspberry Pi Zero](https://en.wikipedia.org/wiki/Raspberry_Pi#Raspberry_Pi_Zero) Accelerator.

When completed, it will be a demonstrator project for how to interoperate with [NextPi](https://wiki.specnext.dev/Pi:NextPi)
(the operating system of the Pi Accelerator), dynamically link executable binaries to NextPi libraries, upload and execute binaries on the Pi,
and transparently use Next system tools, such as the [.pisend](https://github.com/em00k/pisend_src/tree/main/src) dot command, from other
dot commands written in Z80 assembly language.

While some hash functions like [MD5](https://en.wikipedia.org/wiki/MD5#Algorithm) are within the realm of eight-bit assembly language,
especially when running on a 28MHz Z80 CPU, other hashing and crypto operations are definitely not. So as well as being a Pi Accelerator
demonstrator, Pihash can serve a useful purpose.

## Roadmap

| Task | Done |
| :--- | :--: |
| Port best practice dot command template from [Zeus](https://www.desdes.com/products/oldfiles) to [sjasmplus](https://github.com/z00m128/sjasmplus) | Y |
| Use template to create a .pihash command | Y |
| Create makefile to build, launch in [CSpect](https://dailly.blogspot.com/) and send to Next via [NextSync](https://solhsa.com/specnext.html#NEXTSYNC) | Y |
| Create [VSCode](https://code.visualstudio.com/) build tasks and key bindings for makefile | Y |
| Dynamically load .pisend (or .pi3) from inside .pihash | Y |
| Create a simple python2 program to output MD5 hash for a file |   |
| Get CSpect [UARTReplacement](https://github.com/Threetwosevensixseven/CSpectPlugins) plugin working with Pi as well as ESP UARTs | Y |
| Fix intermittent errors using with .p3 and UARTReplacement plugin | Y |
| Get a physical Pi working with a USB serial cable for .pihash test purposes | Y |
| Get a physical Pi working with a wired ethernet OTG adaptor | Y |
| Get NextPi SSH and SCP clients working with Windows SSH and SCP servers | Y |
| Use .pisend to dynamically upload py2 program |   |
| Use .pisend to dynamically upload py2 program if not already present and set permissions |   |
| Use .pisend to execute py2 program and return output |   |
| Fully implement .pisend quiet mode |   |
| Create a NextPi hash bucket |   |
| Store my Pi command in a bucket |   |
| Add -md5, -sha1 and filename switches to .pihash | Y |
| Use .pisend to (always) upload file from these switches to Pi |   |
| Get .pihash to return results from executed program |   |
| Replace python2 program with C/C++ program |   |
| Dynamically link to libstdc++.so.6.0.22 |   |
| Test all failure scenarios |   |
| Extend with other hash and crypto algorithms |   |
| Support control pin commands (exit at least) |   |
| Demonstrate the problems third party NextPi replacements have with this |   |

When completed, the end result will be a standalone dot command that contains the compiled Pi binary and dynamically calls .pisend.

## Copyright and Licence

### Code

Pihash is copyright © 2023 Robin Verhagen-Guest, and is licensed under 
[Apache-2.0](https://github.com/Threetwosevensixseven/pihash/blob/main/LICENSE).

Dot command [argument parser](https://gitlab.com/thesmog358/tbblue/-/blob/master/src/asm/dot_commands/arguments.asm) 
is copyright @2017-2023 Garry Lancaster, and is used in Pihash with kind permission.

### Tools

CSpect [UARTReplacement](https://github.com/Threetwosevensixseven/CSpectPlugins) plugin is copyright © 2020-2023 Robin Verhagen-Guest, 
and is licensed under [Apache-2.0](https://github.com/Threetwosevensixseven/CSpectPlugins/blob/master/LICENSE).

[ZXVersion](https://github.com/Threetwosevensixseven/ZXVersion) is copyright © 2017 Robin Verhagen-Guest, and is licensed under 
[MIT](https://github.com/Threetwosevensixseven/ZXVersion/blob/master/LICENSE).

[Pisend old](https://github.com/em00k/pisend) and [new](https://github.com/em00k/pisend_src/tree/main/src) versions are copyright © 2020-2023 
David Saphier. Pihash currently uses a [slightly modified version](https://github.com/Threetwosevensixseven/pisend_src) of new Pisend.

[hdfmonkey](https://github.com/gasman/hdfmonkey) is copyright © Matt Westcott 2010, and is licensed under 
[GPL-3.0](https://github.com/gasman/hdfmonkey/blob/master/COPYING).

[sjasmplus](https://github.com/z00m128/sjasmplus) is copyright © aprisobal 2016, and is licensed under 
[BSD-3-Clause](https://github.com/z00m128/sjasmplus/blob/master/LICENSE.md).

[CSpect](https://dailly.blogspot.com/) by [Mike Dailly](https://lemmings.info/) is (c) Copyright 1998-2023 All rights reserved.

[NextSync](https://solhsa.com/specnext.html#NEXTSYNC) is by [Jari Komppa](https://solhsa.com/who.html),
and is licensed under [Unlicense](https://github.com/jarikomppa/specnext/blob/master/LICENSE).

[Sinclair](https://trademarks.ipo.gov.uk/ipo-tmcase/page/Results/1/UK00001034487) and
[ZX Spectrum](https://trademarks.ipo.gov.uk/ipo-tmcase/page/Results/1/UK00001171866) are Registered Trademarks of Sky In-Home Service Limited,
and are used under licence by [SpecNext Ltd](https://www.specnext.com/about/).