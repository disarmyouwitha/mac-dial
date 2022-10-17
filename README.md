# Mac Dial

## What's New?
- I have forked `jerrywoohu/mac-dial` branch and merged feature-haptics into main. I've tested this and think it should be part of the main repo.
- Added Mode switching by holding down button for longer than 1 second.
- Double-click is implemented, but has a bug where it triggers single-click too. (single-click in Playback mode will Mute, and double-click will pause/play)
- Also added click & rotate logic to control brightness in Playback mode
- Experimenting with other uses: Scroll mode click will do a single alt+tab

## What would I like to do?
I am just hopping into the code now, and new to swift.. but a lot of this code seems very accessible.
- Ability to configure press, rotate, rotate while pressed, and double click for each mode.

## ORIGINAL GITHUB TEXT:

macOS support for the Surface Dial. The surface dial can be paired with macOS but any input results in invalid mouse inputs on macOS. This app reads the raw data from the dial and translates them to correct mouse and media inputs for macOS.

## Building

Make sure to clone the hidapi submodule and build the library using the build_hidapi.sh script. Note: This app depends on a hidapi fork, check the submodule to see what changed. App should then build with XCode.

You can find universal builds of the app under "releases". Note that these builds can be outdated.

## Usage

The app will continously try to open any Surface Dial connected to the computer and then process inpout controls. You will need to pair and connect the device  as any other bluetooth device.

The app currently supports two modes:
* Scroll mode: Turning the dial will result in scrolling. Pressing the dial is interpreteded as a mouse click at the current cursor position.
* Playback mode: Turning the dial controls the system volume of your mac. Pressing the dial plays / pauses any current playback while a double click sends the "next" media action.

To change mode, click the Mac Dial icon in the system menu bar.

If you want to app to run at startup you will need to add it yourself to the "login items" for your user.

## Improvements

* More input modes
* Change input mode using the dial itself
* ~~Smarter device discovery (currently tries to open the dial every 50 ms)~~
