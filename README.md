# MagicMouseMiddleClick

The Magic Mouse has a full multi-touch compatible surface but is very limited by its OS driver. I just want to be able to middle click to use 3D modeling and CAD applications. This does the trick, although it uses a private framework; thus, it may stop working at any time. I am developing/testing on an Intel Mac Mini, macOS Monterey (12.6).

## Build

You will need XCode or the Command Line Tools installed.

    $ git clone https://github.com/tdwiser/MagicMouseMiddleClick
	$ cd MagicMouseMiddleClick
	$ make

## Run

You will need to give Terminal.app permission to 'control your computer' via Accessibility in System Preferences.

    $ ./mmmc

## Use

A middle click is initiated by placing a third finger down between two other fingers on the surface. It's a touch, not a click. Lifting any finger ends the click. "Drag" events are not sent, but middle click drags seem to work in all software I've tested (Blender, Fusion 360).
