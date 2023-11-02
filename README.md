# pihash

Spectrum Next dot command to do crypto operations on the Pi Accelerator.

## Roadmap

| Task | Done |
| :--- | :--: |
| Port best practice dot command template from zeus to sjasmplus | Y |
| Use template to create a .pihash command | Y |
| Dynamically load .pisend (or .pi3) from inside .pihash | Y |
| Create a simple python2 program to output MD5 hash for a file |   |
| Get CSpect UARTReplacement working with Pi as well as ESP UARTs | Y |
| Fix intermittent .p3 errors with CSPect UARTReplacement plugin | Y |
| Get a physical Pi working with a USB serial cable for .pihash test purposes | Y |
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

When completed, the end result will be a standalone dot command that contains the Pi binary and dynamically calls .nextpi.

## Copyright and Licence
Pihash is copyright © 2023 Robin Verhagen-Guest, and is licensed under [Apache-2.0](https://github.com/Threetwosevensixseven/pihash/blob/main/LICENSE).

[ZXVersion](https://github.com/Threetwosevensixseven/ZXVersion) is copyright © 2017 Robin Verhagen-Guest, and is licensed under [MIT](https://github.com/Threetwosevensixseven/ZXVersion/blob/master/LICENSE).

[Pisend old](https://github.com/em00k/pisend) and [new](https://github.com/em00k/pisend_src/tree/main/src) versions are copyright © 2020-2023 David Saphier.

[hdfmonkey](https://github.com/gasman/hdfmonkey) is copyright © Matt Westcott 2010, and is licensed under [GPL-3.0](https://github.com/gasman/hdfmonkey/blob/master/COPYING).

[sjasmplus](https://github.com/z00m128/sjasmplus) is copyright © aprisobal 2016, and is licensed under [BSD-3-Clause](https://github.com/z00m128/sjasmplus/blob/master/LICENSE.md).
