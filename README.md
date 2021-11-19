# HM2 Mod Manager CLI

This is a Mod Manager designed to install, uninstall mods for Hotline miami 2 without the hastle of going back and fourth with folders

## How it works

Basically when you want to play a new level/campaign, you'll only need to put the .patchwad's and .wad's files in the same folder that the batch file is in and it'll do the work for you

## How to set it up properly

You'll need 2 paths:
1. The path that leads to the game's main folder
2. The path where you have stored the music file ( .wad )

To set them, just use the following parameters: 
```
/s        for the first
/s /b     for the second
```

## Paramaters available:
```
/i            Install all mods that are in the same folder

/un           Uninstalls all mods that are in the same folder

/r            Resets everything back to normal

/s            Sets the path of the game's folder
              add /b after the first paramater to create the backup's path
     
/settings     Shows all paths
              add /e to open up the settings' folder via Explorer
```