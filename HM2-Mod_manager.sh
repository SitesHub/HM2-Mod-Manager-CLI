#!/bin/sh

BOLD='\033[1m'
NORMAL='\033[0m'
RED='\033[1;31m'
LIGHT_RED='\033[0;31m'
YELLOW='\033[1;33m'
secondArgument=$2
thirdArgument=$3
appdata="$HOME/.HM2-Mod_Manager"

helpF() {

    echo "$BOLD""Manager of mods for HM2"    
    echo
    echo "   $BOLD-i$NORMAL           Installs the mods"
    echo
    echo "   $BOLD-un$NORMAL          Uninstalls the mods"
    echo
    echo "   $BOLD-r$NORMAL           Resets everything back to normal"
    echo
    echo "   $BOLD-s$NORMAL           Sets the path of the game's folder"
    echo "                add $BOLD-b$NORMAL after the first paramater to create the backup's path"
    echo
    echo "   $BOLD--settings$NORMAL   Shows all paths"
    echo "                add $BOLD-e$NORMAL to open up the settings' folder via Explorer"
    echo
    echo "   $BOLD--help$NORMAL       Shows this help page"

    exit 0

}

fixPath() { 
    fixedPath=${1//\\ / } 
    fixedPath=${fixedPath//\~/~}
}

reset() {

    checks
    [[ $? == 1 ]] && exit 1

    fixPath "~/Library/Application Support/HotlineMiami2/mods"
    modsDirectoryFolder=$fixedPath

    # Gets the paths and then it goes to the mods folder, resetting it
    # Same with the music
    if [[ ! -d $appdata ]] ;then

        echo "$RED""Couldn't load the files because \
                 their folder doesn't exists$NORMAL"
        exit 1

    fi
    pathToFolder=$(fixPath "$(cat $appdata/path_to_game_folder.dat)" && echo $fixedPath)
    pathToBackup=$(fixPath "$(cat $appdata/path_to_backup.dat)" && echo $fixedPath)


    cd "$modsDirectoryFolder"
    [[ ! -z $(ls) ]] && rm -r *

    cd "$pathToBackup"
    cp hlm2_music_desktop.wad "$pathToFolder"/Contents/Resources

    exit 0

}

set_path() {

    # Creates the path file inside its folder named "HM2-Mod_Manager"
    cd ~/

    # Backup mode
    if [[ "$secondArgument" == "-b" ]] ;then

        if [[ "$thirdArgument" == "" ]] ;then

            echo You typed nothing
            echo "$BOLD"Exiting..."$NORMAL"
            exit 1

        fi


        # Fixes the path, in particular the tilde and spaces
        fixPath "$thirdArgument"

        if [[ -d $appdata ]] ;then

            cd $appdata
            echo "$fixedPath" > path_to_backup.dat
            exit 0

        else

            mkdir .HM2-Mod_Manager && 
            cd $appdata
            echo "$fixedPath" > path_to_backup.dat
            exit 0

        fi

    fi

    # Normal mode
    if [[ "$secondArgument" == "" ]] ;then
        
        echo You typed nothing
        echo "$BOLD"Exiting..."$NORMAL"
        exit 1

    fi


    # Fixes the path, in particular the tilde and spaces
    fixPath "$secondArgument"
    pathWithFolderName=$fixedPath

    if [[ -d $appdata ]] ;then

        cd $appdata
        echo "$pathWithFolderName" > path_to_game_folder.dat

    else

        mkdir .HM2-Mod_Manager &&
        cd $appdata
        echo "$pathWithFolderName" > path_to_game_folder.dat

    fi

    exit 0

}

settings() {

    checks
    [[ $? == 1 ]] && exit 1

    # Explorer mode
    if [[ "$secondArgument" == "-e" ]] ;then

        cd ~/
        open .HM2-Mod_Manager/
        exit 0

    fi

    pathToFolder=$(fixPath "$(cat $appdata/path_to_game_folder.dat)" && echo $fixedPath)
    pathToBackup=$(fixPath "$(cat $appdata/path_to_backup.dat)" && echo $fixedPath)

    echo "Game's folder path: $pathToFolder"
    echo "Backup's folder path: $pathToBackup"

    exit 0

}

install() {

    checks
    [[ $? == 1 ]] && exit 1

    # Gets the amount of files needed to be installed 
    # present in the same folder as the sh file and
    # the path to the game's folder
    patchwad=$(ls | grep -c ".patchwad")
    wad=$(ls | grep -c ".wad")
    pathToFolder=$(fixPath "$(cat $appdata/path_to_game_folder.dat)" && echo $fixedPath)


    # Install the files inside the correct folders
    # only if the amount isn't equal to 0
    fixPath "~/Library/Application Support/HotlineMiami2/mods"
    modsDirectoryFolder=$fixedPath

    [[ $patchwad != 0 ]] && mv *.patchwad "$modsDirectoryFolder"/
    [[ $wad != 0 ]] && mv *.wad "$pathToFolder"/Contents/Resources

    exit 0

}

uninstall() {

    checks
    [[ $? == 1 ]] && exit 1

    originalPath=$(pwd)

    # Gets to the folder where the mod files are, just 1 folder back
    # and gets the path to the game's folder too
    fixPath "~/Library/Application Support/HotlineMiami2/mods"
    modsDirectoryFolder=$fixedPath

    cd "$modsDirectoryFolder"
    pathToFolder=$(fixPath "$(cat $appdata/path_to_game_folder.dat)" && echo $fixedPath)
    pathToBackup=$(fixPath "$(cat $appdata/path_to_backup.dat)" && echo $fixedPath)


    # Moves all mods to the current path and then cleans the "mods" folder
    cp -r ./ "$originalPath"
    [[ ! -z $(ls) ]] && rm -r *

    # Goes to the game's folder and moves the music to the current path
    cd "$pathToFolder"/Contents/Resources
    cp hlm2_music_desktop.wad "$originalPath"
    

    # Goes to pick up the backup of the default music 
    # and puts it inside the game's folder 
    cd "$pathToBackup"
    cp hlm2_music_desktop.wad "$pathToFolder"/Contents/Resources

    exit 0

}


checks() {

    if [[ ! -f $appdata/path_to_game_folder.dat ]] ;then

        if [[ ! -f $appdata/path_to_backup.dat ]] ;then

            echo "$RED"The paths are missing
            echo You need to create them first"$NORMAL"

            return 1

        fi

    fi

    if [[ ! -f $appdata/path_to_game_folder.dat ]] ;then

        echo "$RED""The path to the game's folder is missing"
        echo You need to create it first"$NORMAL"

        return 1

    fi

    if [[ ! -f $appdata/path_to_backup.dat ]] ;then

        echo "$RED"The path to the backup is missing
        echo You need to create it first"$NORMAL"

        return 1

    fi

    # In case the user forgets that it needs the .app folder too
    pathToFolder=$(fixPath "$(cat $appdata/path_to_game_folder.dat)" && echo $fixedPath)

    if [[ $pathToFolder != *"HotlineMiami2.app"* ]] ;then

        echo "$LIGHT_RED""Make sure that inside the path there's included the .app folder$NORMAL"
        return 1

    fi

}


[[ "$1" == "" ]] && helpF
[[ "$1" == "--help" ]] && helpF
[[ "$1" == "-i" ]] && install
[[ "$1" == "-un" ]] && uninstall
[[ "$1" == "-r" ]] && reset
[[ "$1" == "-s" ]] && set_path
[[ "$1" == "--settings" ]] && settings
echo "$YELLOW$1$NORMAL argument doesn't exist"
echo 
helpF