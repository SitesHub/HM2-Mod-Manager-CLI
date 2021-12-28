# Hotline Miami 2 Mod Manager CLI

This is a Mod Manager designed to install, uninstall mods for Hotline miami 2 without the hassle of going back and forth with folders and for some links.

## How it works

Basically when you want to play a new level/campaign, you'll only need to put the .patchwad's and .wad's files in the same folder that the bash file is in and it'll do the work for you.

It can also be done through a direct extraction or link too.

## How to set it up properly

You'll need 2 paths:
1. The path that leads to the game's main folder
2. The path where you have stored the music file ( .wad )

### _Remember to quote them otherwise it won't be correct_

To set them, just use the following parameters: 
```
-s        for the first
-s -b     for the second
```

Or you can set them via the menu by choosing an option first and then pasting in the path

## Paramaters available:
```
-i            Install all mods that are in the same folder

                 -x <path/to/compressed-file>
                    Extracts the compressed file inside /tmp folder and installs its contents

                 <URL>
                    Downloads the file from an url and installs it
                    NOTE: if it's not from DropBox, it'll ask for user's confirmation

-un           Uninstalls all mods that are in the same folder

-r            Resets everything back to normal

-s            Sets the path of the game's folder
                  -b Creates the backup's path
     
-settings     Shows all paths
                  -e Opens up the settings' folder via Finder

--help        Shows the help page
```