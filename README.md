## The Menace from Triton (MSX) by Santiago Ontañón Villar

Download latest compiled ROMs (v1.0.5) from: https://github.com/santiontanon/triton/releases/tag/v1.0

You will need an MSX emulator to play the game on a PC, for example OpenMSX: http://openmsx.org


## Introduction

The Menace from Triton is an MSX1 game, in a 48KB ROM cartridge format, built to participate in the MSXDev'20 competition ( https://www.msxdev.org ).

The Menace from Triton is a horizontal shooting game inspired in some of my favorite MSX classic shooters like Salamander or the Nemesis saga, but with elements of a few modern shooter games that I really like (in particular Steredenn and Z-Exemplar, which I recommend you trying!). The game combines arcade-style horisontal shooter action with the resource managing/shop mechanics of Z-Exemplar, and the procedural generation of Steredenn. The first levels start out quite easy, but the game gets harder and harder towards the end. So, make sure you upgrade your ship as much as possible, or it will be impossible to defeat Triton!

## Instructions

Screenshots (of version 1.0):

<img src="https://raw.githubusercontent.com/santiontanon/triton/master/media/ss1.png" alt="title" width="400"/> <img src="https://raw.githubusercontent.com/santiontanon/triton/master/media/ss2.png" alt="mission screen" width="400"/>

<img src="https://raw.githubusercontent.com/santiontanon/triton/master/media/ss3.png" alt="in game 1" width="400"/> <img src="https://raw.githubusercontent.com/santiontanon/triton/master/media/ss4.png" alt="in game 2" width="400"/>

You can see a video of the game at: ...

### Story

...

### Game Goal

...

### The Mission Screen

... controls ...

### The Upgrade Screen

... controls ...
- You can also press M or Button 2 to bring the pointer directly to the "back" button.
- List all upgrades, and damage / fire rate / recharge bonuses at each level

### In-Game Screen

... controls ...

Hints:
- Some enemies will drop power pellets. But remember that power pellets are fragile! If you kill an enemy too close to a wall, the power pellet that would have been dropped will disintegrate.
- ...



## Acknowledgments
- Thanks a lot to people who gave me feedback on earlier versions of the game, which I could use to fix bugs and improve the overall game play: NatyPC, Alejandro Gil Cal, Jose Luis Lerma, Pablibiris, Jandro, Andrés de Pedro



## Compatibility

The game was designed to be played on MSX1 computers with at least 16KB of RAM. I used the Philips VG8020 as the reference machine (since that's the MSX I owned as a kid), but I've tested it in some other machines using OpenMSX v0.15. If you detect an incompatibility, please let me know!


## Notes:

Some notes and useful links I used when coding XRacing

* There is a "build" script in the home folder. Use it to re-build the game from sources. There is a collection of data files that are generated via a collection of Java scripts. Those are found in the "java" folder. You can re-generate all the data files by running the "Main.java" class (some of them take quite some time to run, so be patient! Also, you will need oapack compiled for your operative system (not included) inside of the java folder as well)
* I used my own MDL Z80 code optimizer to help me save a few bytes/cycles here and there: https://github.com/santiontanon/mdlz80optimizer
* Math routines: http://z80-heaven.wikidot.com/math
* PSG (sound) registers: http://www.angelfire.com/art2/unicorndreams/msx/RR-PSG.html
* Z80 tutorial: http://sgate.emt.bme.hu/patai/publications/z80guide/part1.html
* Z80 user manual: http://www.zilog.com/appnotes_download.php?FromPage=DirectLink&dn=UM0080&ft=User%20Manual&f=YUhSMGNEb3ZMM2QzZHk1NmFXeHZaeTVqYjIwdlpHOWpjeTk2T0RBdlZVMHdNRGd3TG5Ca1pnPT0=
* MSX system variables: http://map.grauw.nl/resources/msxsystemvars.php
* MSX bios calls: 
    * http://map.grauw.nl/resources/msxbios.php
    * https://sourceforge.net/p/cbios/cbios/ci/master/tree/
* VDP reference: http://bifi.msxnet.org/msxnet/tech/tms9918a.txt
* VDP manual: http://map.grauw.nl/resources/video/texasinstruments_tms9918.pdf
* The game was compiled with Grauw's Glass compiler (cannot thank him enough for creating it): https://bitbucket.org/grauw/glass
* In order to compress data I used two compressors (it turned out that I saved space by having two of them, as some data gets more compression with one than with the other, and the best combinatino was to have them both!):
  * Pletter v0.5b - XL2S Entertainment 2008 (there is a Java port of the Pletter compressor in the Java JAR file in the repository).
  * Oapack: https://gitlab.com/eugene77/oapack


