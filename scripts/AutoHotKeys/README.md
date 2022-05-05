# AutoHotKey (a.k.a AHK)

[official website](https://www.autohotkey.com/)

## Requirements

In order to use this tool you need:

* a Windows machine (script and EXE mode)
* a version of AHK installed (only in script mode)

## Usage strategy

AHK allows actions to be stored in separate scripts or in a single script with multiple actions. When kept as one big script, it makes it simpler to transform into an EXE (to use without installing AHK). Either way, please use the following convention:

* when it is a big script, please name it with the applications/automations inside and how many actions per applications/automations
* when storing them with 1 file per action, please use sub-folders (based on the application/action) and make sure to be explicit in the name

## Gotchas

When writing a big script (or regroupping several single scripts), keep in mind that you'd better use "Exit" at the end of your action otherwise it will keep executing the next action in the script.

## Caveats & Tricks

### JW Library windows management

When configured to use 2 monitors, JW Library creates the secondary window as fullscreen by default. Unfortunately, this window does not register like a regular window and cannot be detected by WindowsTitle.

That means that you must double-click on it after launch to transform it into a regular window (you should see the controls on the top-right corner).
REMINDER: you should maximise it to have a result similar to the fullscreen mode (but Zoom will more frequently show up when starting/stopping a screen share).
