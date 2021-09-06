# Environment and Tools Setup for Astroblast
To setup a development environment to build and run astroblast follow the following steps.  The versions used for development are mentioned but there is no known dependency on particular versions.

1. OS used for development: **Windows 10 Pro**, build: 19043.1165.  Most if not all of these tools are available for other OSes as well but that hasn't been tried.

2. Install the latest **java runtime**
  - Download from here: https://www.java.com/en/download/manual.jsp
  - Version for developmentersion for development: 1.8.0_291

3. Install **Kick Assembler**.  This is an assembler specifically for C64 code.
  - Download the latest released version here: http://theweb.dk/KickAssembler
  - VersiVersion for development:ment: V5.20  

4. Install the **VICE C64 emulator**. Technically not required if you want to run the result on real C64 hardware, but definitely convienent as it lets you run the software right on your development machine.
  - Download the latest version here: https://vice-emu.sourceforge.io/
  - Version for development: 3.5

5. Install **VS Code**.  This IDE along with the Kick Assembler extension was used to build the code rather than scripts or makefiles
  - Download from here: https://code.visualstudio.com/
  - Version for development: 1.56.2

6. Install the **Kick Assembler IDE Extension for VS Code** Named "Kick Assembler (C64) for Visual Studio Code" by Paul Hocker
  - Start up VS Code
  - Search for Extension (ctrl-shift-x) 
  - type in Kick Assembler (C64)
  - Install
  - Version used for development: 0.7.15
  - configure the extension in VS Code, specifically find and set the settings that point the extension where it can find
    - Kick assembler jar file (KickAss.jar)
    - Emulator runtime, which is the VICE C64 emulator (x64sc.exe)
    - C64 debugger runtime (C64Debugger.exe)
    - Java runtime (java.exe) 

Now you should be ready to try the build astroblast.

---------------------------------------------------------------------------------------------------------------------

Additional tools used during development of astroblast that are useful, if not required, when the desire is to do something more than just build the code.   


1. Install **C64 debugger**. This is also not technically required to simply build the software, but useful if you want to debug anything.
  - Download lastest from here: https://sourceforge.net/projects/c64-debugger/
  - Version for development: v0.64.58.4


2. Install **GoatTracker** if you are interested in looking at or editing the music or sound effects, if not then this isn't required.
  - Download from here: https://sourceforge.net/projects/goattracker2/
  - Version for development: v2.76 (not the stereo version)

3. **Install CBM Prg Studio**.  This was only used to edit and save the character set used in the game.  There are probably lots of other C64 charset editors that could do this job as well.
  - Download latest from here: https://www.ajordison.co.uk/download.html
  - Version used for development: v3.14.1 beta 1
  
4. **Spritemate** website was used to create the sprites for the game.
  - Nothing to download or install
  - Just use the website here: https://www.spritemate.com/

