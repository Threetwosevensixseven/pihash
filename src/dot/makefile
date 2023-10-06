# Makefile for .pihash.
# Only tested with Embarcadero MAKE 5.41 for Windows. 
# Let me know if other Windows MAKEs have issues.
# If you fix this up for linux or mac, please contribute your changes.

# Change these variables to suit your own environment
SRCDIR = .
BINDIR = ..\..\bin
SJASMPLUS = ..\..\tools\sjasmplus
HDFMONKEY = ..\..\tools\hdfmonkey
ZXVERSION = ..\..\tools\zxversion
EMUDIR = C:\spec\CSpect2_19_4_3
EMUSD = C:\spec\sd208\cspect-next-2gb.img
SYNCDIR = C:\spec\sync\ON
RM = del /F /Q
MD = md
KILL = taskkill /F /IM

# Default target is to build the dot command from source
build: 
	$(ZXVERSION)
	$(SJASMPLUS) $(SRCDIR)\main.asm

# Removes all build-generated files
clean:
	$(RM) "$(BINDIR)\pihash."

# Builds, injects built dot and autoexec into CSpect SD image, and starts CSpect asynchronously.
emu: build
	$(HDFMONKEY) put $(EMUSD) $(BINDIR)/pihash. dot
	$(HDFMONKEY) put $(EMUSD) $(SRCDIR)/autoexec.bas NextZXOS
    -$(KILL) cspect.exe 
    start /d $(EMUDIR) cspect -w2 -zxnext -nextrom -basickeys -exit -brk -tv -emu -mmc=$(EMUSD)

# Builds, copies dot and autoexec to NextSync sync directory, and starts starts the server asynchronously.
# WHen you F4, autoexec will skip running .fastsync (because CSpect defaults to core version 4.0.0), then run the dot command.
# The first time you make sync, run .fastsync manually to get the files.
sync: build
	-$(MD) "$(SYNCDIR)\dot"
	copy "$(BINDIR)\pihash." "$(SYNCDIR)\dot\*.*"
	-$(MD) "$(SYNCDIR)\NextZXOS"
	copy "$(SRCDIR)\autoexec.bas" "$(SYNCDIR)\NextZXOS\*.*"

# Warning: kills all running python processes
# Remove these two lines and start the server manually if that bothers you
	-$(KILL) py.exe
	start /d $(SYNCDIR) /min nextsync.py
