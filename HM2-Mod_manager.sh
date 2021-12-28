#!/bin/sh

BOLD='\033[1m'
UNDERLINE='\033[4m'
NORMAL='\033[0m'
RED='\033[1;31m'
LIGHT_RED='\033[0;31m'
YELLOW='\033[1;33m'
firstArgument=$1
secondArgument=$2
thirdArgument=$3
appdata="$HOME/.HM2-Mod_Manager"

helpF() {

    echo "$BOLD""Manager of mods for HM2"    
    echo
    echo "   $BOLD-i$NORMAL           Installs the mods"
    echo "                    -$BOLD""x$NORMAL <$UNDERLINE""path/to/compressed-file$NORMAL>"
    echo "                       Extracts the compressed file inside $BOLD/tmp$NORMAL folder and installs its contents"
    echo
    echo "                    <$UNDERLINE""URL$NORMAL>"
    echo "                       Downloads the file from an url and installs it"
    echo "                       NOTE: if it's not from $BOLD""DropBox$NORMAL, it'll ask for user's confirmation"
    echo
    echo "   $BOLD-un$NORMAL          Uninstalls the mods"
    echo
    echo "   $BOLD-r$NORMAL           Resets everything back to normal"
    echo
    echo "   $BOLD-s$NORMAL           Sets the path of the game's folder"
    echo "                    $BOLD-b$NORMAL Creates the backup's path"
    echo
    echo "   $BOLD--settings$NORMAL   Shows all paths"
    echo "                    $BOLD-e$NORMAL Opens up the settings' folder via Finder"
    echo
    echo "   $BOLD--help$NORMAL, $BOLD-h$NORMAL   Shows this help page"

    exit 0

}


checkIfClicked() {

    [[ $(ps $$ -o command=) == "/bin/sh $0" && $0 =~ $HOME ]] && 
        return 0 || 
            return 1

}

helpF_mouse_click() {

    clear
    echo "$BOLD""Manager of mods for HM2"    
    echo
    echo "   $BOLD""1$NORMAL.  Installs the mods"
    echo
    echo "   $BOLD""2$NORMAL.  Uninstalls the mods"
    echo
    echo "   $BOLD""3$NORMAL.  Resets everything back to normal"
    echo
    echo "   $BOLD""4$NORMAL.  Sets the path of the game's folder"
    echo
    echo "   $BOLD""5$NORMAL.  Shows all paths"
    echo
    echo "   $BOLD""q$NORMAL to quit"
    echo

    read -p "Insert an option: " answer
    [[ "$answer" == "" ]] && helpF_mouse_click
    [[ "$answer" == "1" ]] && install
    [[ "$answer" == "2" ]] && uninstall
    [[ "$answer" == "3" ]] && reset
    [[ "$answer" == "4" ]] && set_path
    [[ "$answer" == "5" ]] && settings
    [[ "$answer" == "q" ]] && exit 0
    clear
    echo "$YELLOW$answer$NORMAL option doesn't exist"
    echo 
    read
    helpF_mouse_click

}

fixPath() { 
    fixedPath=${1//\\ / } 
    fixedPath=${fixedPath//\~/~}
}

reset() {

    checks
    [[ $? == 1 ]] && exit 1

    # Checks if the game is running and it shuts it down
    pgrep "HotlineMiami2" &>/dev/null && {

        wasGameRunning=true
        killall -SIGKILL "HotlineMiami2" 2>/dev/null

    }


    checkIfClicked && clear
    fixPath "~/Library/Application Support/HotlineMiami2/mods"
    modsDirectoryFolder=$fixedPath

    # Gets the paths and then it goes to the mods folder, resetting it
    # Same with the music
    if [[ ! -d $appdata ]] ;then

        echo "$RED""Couldn't load the files because \
                 their folder doesn't exists$NORMAL"
        exit 1

    fi
    pathToFolder=$(
        fixPath "$(cat $appdata/path_to_game_folder.dat)" && 
        echo $fixedPath
    )
    pathToBackup=$(
        fixPath "$(cat $appdata/path_to_backup.dat)" && 
        echo $fixedPath
    )


    cd "$modsDirectoryFolder"
    [[ ! -z $(ls) ]] && rm -r *
    echo Cleaned the /mods folder

    cd "$pathToBackup"
    originalSize=$(du -k "hlm2_music_desktop.wad" | awk '{print $1}')
    newSize=$(cd "$pathToFolder"/Contents/Resources; du -k "hlm2_music_desktop.wad" | awk '{print $1}')

    [[ "$newSize" != "$originalSize" ]] &&
        echo Resetting the music file; \
        cp hlm2_music_desktop.wad "$pathToFolder"/Contents/Resources

    echo
    echo Finished resetting


    # Checks if the game was running and if it was, it launches it again
    isGameRunning=$(
        pgrep "HotlineMiami2" &>/dev/null && 
            echo true || echo false
    )
    steamAppID=$(cat "$pathToFolder"/Contents/MacOS/steam_appid.txt 2>/dev/null || echo null)
    [[ $wasGameRunning == "true" && $isGameRunning == "false" ]] && {

        [[ $steamAppID == "null" ]] && open "$pathToFolder" || open steam://rungameid/$steamAppID

    }

    checkIfClicked && {
        echo
        read
        helpF_mouse_click
    }

    exit 0

}

set_path() {

    # Creates the path file inside its folder named "HM2-Mod_Manager"
    cd ~/

    showMenu() {  

        gamePath() {

            # Fixes the path, in particular the tilde and spaces
            fixPath "$1"
            pathWithFolderName=$fixedPath

            if [[ -d $appdata ]] ;then

                cd $appdata
                echo "$pathWithFolderName" > path_to_game_folder.dat
                echo Set the path to the Game\'s folder

            else

                mkdir .HM2-Mod_Manager &&
                cd $appdata
                echo "$pathWithFolderName" > path_to_game_folder.dat
                echo Set the path to the Game\'s folder

            fi

            read
            helpF_mouse_click

        }

        backupPath() {

            # Fixes the path, in particular the tilde and spaces
            fixPath "$1"

            if [[ -d $appdata ]] ;then

                cd $appdata
                echo "$fixedPath" > path_to_backup.dat
                echo Set the path to the Backup\'s folder

            else

                mkdir .HM2-Mod_Manager && 
                cd $appdata
                echo "$fixedPath" > path_to_backup.dat
                echo Set the path to the Backup\'s folder

            fi

            read
            helpF_mouse_click

        }

        clear
        echo "$BOLD""1$NORMAL.  Sets the path to the game's folder"
        echo "        To use it, paste in the $UNDERLINE""path$NORMAL after being prompted"
        echo
        echo "$BOLD""2$NORMAL.  Sets the path to the backup's folder"
        echo "        To use it, do the same as the 1st option but with the $UNDERLINE""backup's path$NORMAL"
        echo
        echo "$BOLD""b$NORMAL to go back"
        echo "$BOLD""q$NORMAL to quit"
        echo

        
        read -p "Choose an option: " answer

        [[ "$answer" == "" ]] && showMenu
        [[ "$answer" = "1" ]] && {

            read -ep "Insert the path: " answer
            ls "$answer" &>/dev/null && gamePath "$answer" || {
                
                clear
                echo "$RED$answer$NORMAL is not a valid path"
                echo
                read
                showMenu

            }

        }
        [[ "$answer" = "2" ]] && {

            read -ep "Insert the path: " answer
            ls "$answer" &>/dev/null && backupPath "$answer" || {
                
                clear
                echo "$RED$answer$NORMAL is not a valid path"
                echo
                read
                showMenu

            }

        }
        [[ "$answer" == "q" ]] && exit
        [[ "$answer" == "b" ]] && helpF_mouse_click
        clear
        echo "$YELLOW$answer$NORMAL is not an option"
        echo
        read
        showMenu
        
    }
    checkIfClicked && showMenu

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
            echo Set the path to the Backup\'s folder
            exit 0

        else

            mkdir .HM2-Mod_Manager && 
            cd $appdata
            echo "$fixedPath" > path_to_backup.dat
            echo Set the path to the Backup\'s folder
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
        echo Set the path to the Game\'s folder

    else

        mkdir .HM2-Mod_Manager &&
        cd $appdata
        echo "$pathWithFolderName" > path_to_game_folder.dat
        echo Set the path to the Game\'s folder

    fi

    exit 0

}

settings() {

    checks
    [[ $? == 1 ]] && exit 1

    showMenu() {

        showPaths() {

            clear
            pathToFolder=$(
                fixPath "$(cat $appdata/path_to_game_folder.dat)" && 
                echo $fixedPath
            )
            pathToBackup=$(
                fixPath "$(cat $appdata/path_to_backup.dat)" && 
                echo $fixedPath
            )

            echo "Game's folder path: $UNDERLINE$pathToFolder$NORMAL"
            echo "Backup's folder path: $UNDERLINE$pathToBackup$NORMAL"

            echo
            read
            showMenu

        }

        openFinder() {

            clear
            cd ~/
            echo Starting Finder...
            open .HM2-Mod_Manager/
            echo Opened Finder

            echo
            read
            showMenu

        }

        clear
        echo "$BOLD""1$NORMAL.  Shows all paths"
        echo
        echo "$BOLD""2$NORMAL.  Opens up the settings' folder via Finder"
        echo
        echo "$BOLD""b$NORMAL to go back"
        echo "$BOLD""q$NORMAL to quit"
        echo


        read -p "Choose an option: " answer
        [[ "$answer" == "" ]] && showMenu
        [[ "$answer" == "1" ]] && showPaths
        [[ "$answer" == "2" ]] && openFinder
        [[ "$answer" == "q" ]] && exit
        [[ "$answer" == "b" ]] && helpF_mouse_click
        clear
        echo "$YELLOW$answer$NORMAL is not an option"
        echo
        read
        showMenu

    }
    checkIfClicked && showMenu

    # Explorer mode
    if [[ "$secondArgument" == "-e" ]] ;then

        cd ~/
        echo Starting Finder...
        open .HM2-Mod_Manager/
        echo Opened Finder
        exit 0

    fi

    pathToFolder=$(
        fixPath "$(cat $appdata/path_to_game_folder.dat)" && 
        echo $fixedPath
    )
    pathToBackup=$(
        fixPath "$(cat $appdata/path_to_backup.dat)" && 
        echo $fixedPath
    )

    echo "Game's folder path: $pathToFolder"
    echo "Backup's folder path: $pathToBackup"

    exit 0

}

installation() {

    cd $1
    previousFolder=
    folders=()

    # Checks if there are folders in the same folder 
    # that have patchwad files inside them
    for file in */*.patchwad ; do

    	currentFolder="${file%/*}/ "

    	[[ $currentFolder != $previousFolder ]] && folders+=($currentFolder)
    	previousFolder=$currentFolder

    done


    # Gets the amount of files needed to be installed 
    # present in the same folder as the sh file and
    # the path to the game's folder
    patchwad_CurrentFolder=$(ls | grep -c ".patchwad")
    wad_CurrentFolder=$(ls | grep -c ".wad")
    pathToFolder=$(
        fixPath "$(cat $appdata/path_to_game_folder.dat)" && 
        echo $fixedPath
    )


    # Install the files inside the correct folders
    # only if the amount isn't equal to 0
    fixPath "~/Library/Application Support/HotlineMiami2/mods"
    modsDirectoryFolder=$fixedPath

    [[ $patchwad_CurrentFolder != 0 ]] && mv *.patchwad "$modsDirectoryFolder"/
    [[ ${#folders[*]} != 0 ]] && {

        # Loops through the folders found to have patchwad files inside them
        for i in ${!folders[*]} ;do

            folder=${folders[$i]}
            mv $folder "$modsDirectoryFolder"/ 2>/dev/null

        done    

    }
    echo Installed patchwad file/s inside /mods
    

    [[ $wad_CurrentFolder != 0 ]] && 
        mv *.wad "$pathToFolder"/Contents/Resources &&
            echo Installed wad file/s inside the game\'s folder

    
    isGameRunning=$(
        pgrep "HotlineMiami2" &>/dev/null && 
            echo true || echo false
    )
    steamAppID=$(cat "$pathToFolder"/Contents/MacOS/steam_appid.txt 2>/dev/null || echo null)
    [[ $wasGameRunning == "true" && $isGameRunning == "false" ]] && {

        [[ $steamAppID == "null" ]] && open "$pathToFolder" || open steam://rungameid/$steamAppID

    }

    exit 0

}

install() {

    checks
    [[ $? == 1 ]] && exit 1

    # Checks if the game is running and it shuts it down
    pgrep "HotlineMiami2" &>/dev/null && {

        checkIfClicked || {

            wasGameRunning=true
            killall -SIGKILL "HotlineMiami2" 2>/dev/null

        }

    }
    originalPath=$(pwd)


    showMenu() {

        fromCurrent() { 

            installation "$originalPath"
            # Checks if the game was running and if it was, it launches it again
            pathToFolder=$(
                fixPath "$(cat $appdata/path_to_game_folder.dat)" && 
                echo $fixedPath
            )
            isGameRunning=$(
                pgrep "HotlineMiami2" &>/dev/null && 
                    echo true || echo false
            )
            steamAppID=$(cat "$pathToFolder"/Contents/MacOS/steam_appid.txt 2>/dev/null || echo null)
            [[ $wasGameRunning == "true" && $isGameRunning == "false" ]] && {
            
                [[ $steamAppID == "null" ]] && open "$pathToFolder" || open steam://rungameid/$steamAppID
        
            }

            echo
            read
            helpF_mouse_click 

        }

        fromArchive() {

            # Checks if the game is running and it shuts it down
            pgrep "HotlineMiami2" &>/dev/null && {
            
                wasGameRunning=true
                killall -SIGKILL "HotlineMiami2" 2>/dev/null

            }

            clear
            [[ "$1" =~ \.(zip|rar) && -f "$1" ]] && {

                echo Extracting...
                tar -x -f $1 -C /tmp/$nameOfFolderForExtraction &>/dev/null
                    (( $? > 0 )) &&
                        echo &&
                        echo "Couldn't extract contents of $1" && exit 1
                installation /tmp/$nameOfFolderForExtraction

            } || {

                echo Couldn\'t find the zip/rar file or the path is incorrect
                read
                exit 1

            }


            # Checks if the game was running and if it was, it launches it again
            pathToFolder=$(
                fixPath "$(cat $appdata/path_to_game_folder.dat)" && 
                echo $fixedPath
            )
            isGameRunning=$(
                pgrep "HotlineMiami2" &>/dev/null && 
                    echo true || echo false
            )
            steamAppID=$(cat "$pathToFolder"/Contents/MacOS/steam_appid.txt 2>/dev/null || echo null)
            [[ $wasGameRunning == "true" && $isGameRunning == "false" ]] && {
            
                [[ $steamAppID == "null" ]] && open "$pathToFolder" || open steam://rungameid/$steamAppID

            }

            read
            helpF_mouse_click

        }

        fromURL() {

            # Checks if the game is running and it shuts it down
            pgrep "HotlineMiami2" &>/dev/null && {
            
                wasGameRunning=true
                killall -SIGKILL "HotlineMiami2" 2>/dev/null

            }

            clear
            # Direct download from the terminal
            # If the link is from dropbox, it'll be quiet
            [[ "$1" =~ "https://www.dropbox.com" ]] && {

                cd /tmp/$nameOfFolderForExtraction

                echo Starting the download...
                # Corrects the url first
                    correctURL=${1//?dl=0/?dl=1}
                    curl -OL "$correctURL"  
                        (( $? > 0 )) &&
                            echo &&
                            echo "$RED""URL$NORMAL could be wrong" && exit 1

                echo "Extracting if necessary..."
                # Corrects the file name first
                    correctFileName=$(
                        fileName=$(ls); 
                        echo ${fileName//?dl=1/}
                    )
                    mv * $correctFileName

                # Extracts the file and deletes the compressed file if it's extractable
                tar -xf $correctFileName &>/dev/null && 
                    rm $correctFileName

                installation /tmp/$nameOfFolderForExtraction

            }

            # If it's not, it'll ask the user to check 
            # if the link downloads a zip, rar, patchwad, wad file directly
            [[ "$1" =~ (http|https):\/\/ ]] && {

                cd /tmp/$nameOfFolderForExtraction

                check() {

                    echo "$YELLOW""$1"$NORMAL
                    echo Are you sure that this link is a direct download to a:
                    echo "-$RED""Patchwad$NORMAL file"
                    echo "-$RED""Wad$NORMAL file"
                    echo "-$RED""Zip$NORMAL file"
                    echo "-$RED""Rar$NORMAL file"
                    echo
                    read -p "(Yes|No): " answer

                    case $answer in
                        "Yes")

                            clear
                            echo Starting the download...
                            curl -OL "$1" 2>/dev/null
                                (( $? > 0 )) &&
                                    echo &&
                                    echo "$RED""URL$NORMAL could be wrong" && exit 1

                            echo "Extracting if necessary..."
                            tar -xf $correctFileName &>/dev/null && 
                                rm $correctFileName

                            installation /tmp/$nameOfFolderForExtraction

                        ;;
                        Y|y)

                            clear
                            echo Starting the download...
                            curl -OL "$1" 2>/dev/null
                                (( $? > 0 )) &&
                                    echo &&
                                    echo "$RED""URL$NORMAL could be wrong" && exit 1

                            echo "Extracting if necessary..."
                            tar -xf $correctFileName &>/dev/null && 
                                rm $correctFileName

                            installation /tmp/$nameOfFolderForExtraction

                        ;;
                        "No")

                            echo "Exiting then..."

                        ;;
                        N|n)

                            echo "Exiting then..."

                        ;;
                        *)

                            clear
                            echo Choose something, please
                            read
                            clear
                            check "$1"

                        ;;
                    esac 

                    echo
                    read
                    helpF_mouse_click 

                }
                check "$1"

            }


            installation "$originalPath"
            # Checks if the game was running and if it was, it launches it again
            pathToFolder=$(
                fixPath "$(cat $appdata/path_to_game_folder.dat)" && 
                echo $fixedPath
            )
            isGameRunning=$(
                pgrep "HotlineMiami2" &>/dev/null && 
                    echo true || echo false
            )
            steamAppID=$(cat "$pathToFolder"/Contents/MacOS/steam_appid.txt 2>/dev/null || echo null)
            [[ $wasGameRunning == "true" && $isGameRunning == "false" ]] && {
            
                [[ $steamAppID == "null" ]] && open "$pathToFolder" || open steam://rungameid/$steamAppID

            }

            echo
            read
            helpF_mouse_click

        }

        clear
        echo "$BOLD""1$NORMAL. Installs from $BOLD""current directory$NORMAL"
        echo
        echo "$BOLD""2$NORMAL. Installs from an $BOLD""archive$NORMAL:"
        echo "      To use it, paste in the $UNDERLINE""path$NORMAL"
        echo
        echo "$BOLD""3$NORMAL. Installs from an $BOLD""URL$NORMAL:"
        echo "      To use it, paste in the $UNDERLINE""URL$NORMAL"
        echo
        echo "$BOLD""b$NORMAL to go back"
        echo "$BOLD""q$NORMAL to quit"
        echo

        
        read -ep "Choose an option: " answer

        [[ "$answer" == "" ]] && showMenu
        [[ "$answer" == "q" ]] && exit
        [[ "$answer" == "b" ]] && helpF_mouse_click
        [[ "$answer" == "1" ]] && clear && fromCurrent
        [[ "$answer" =~ (http|https):\/\/ ]] && fromURL "$answer"
        [[ "$answer" != "" ]] && 
            ls "$answer" &>/dev/null && fromArchive "$answer" || {
                
                clear
                echo "$YELLOW$answer$NORMAL is not a correct path or option"
                echo
                read
                showMenu

            }

    }
    checkIfClicked && showMenu

    # Options for the parameter
    if [[ "$secondArgument" != "" ]] ;then

        nameOfFolderForExtraction="HM2-Mod_Manager"

        # Creates the temporary folder if it doesn't exist then 
        # it cleans the temporary folder if it has content inside it
        cd /tmp
        [[ ! $(ls | grep "$nameOfFolderForExtraction") ]] && mkdir "$nameOfFolderForExtraction"

        for i in $nameOfFolderForExtraction/* ;do

            [[ "$i" != "$nameOfFolderForExtraction/*" ]] && 
                rm -r $nameOfFolderForExtraction/* &>/dev/null

        done


        # Extraction of a zip file from the terminal
        cd "$originalPath"

        [[ "$secondArgument" == "-x" ]] && {

            [[ -f "$thirdArgument" ]] && {

                echo Extracting...
                tar -x -f $thirdArgument -C /tmp/$nameOfFolderForExtraction &>/dev/null
                    (( $? > 0 )) &&
                        echo &&
                        echo "Couldn't extract contents of $thirdArgument" && exit 1
                installation /tmp/$nameOfFolderForExtraction

            } || {

                echo Couldn\'t find the zip/rar file or the path is incorrect
                exit 1

            }

        }


        # Direct download from the terminal
        # If the link is from dropbox, it'll be quiet
        [[ "$secondArgument" =~ "https://www.dropbox.com" ]] && {

            cd /tmp/$nameOfFolderForExtraction

            echo Starting the download...
            # Corrects the url first
                correctURL=${secondArgument//?dl=0/?dl=1}
                curl -OL "$correctURL"  
                    (( $? > 0 )) &&
                        echo &&
                        echo "$RED""URL$NORMAL could be wrong" && exit 1

            echo "Extracting if necessary..."
            # Corrects the file name first
                correctFileName=$(
                    fileName=$(ls); 
                    echo ${fileName//?dl=1/}
                )
                mv * $correctFileName

            # Extracts the file and deletes the compressed file if it's extractable
            tar -xf $correctFileName &>/dev/null && 
                rm $correctFileName

            installation /tmp/$nameOfFolderForExtraction

        }

        # If it's not, it'll ask the user to check 
        # if the link downloads a zip, rar, patchwad, wad file directly
        [[ "$secondArgument" =~ (http|https):\/\/ ]] && {

            cd /tmp/$nameOfFolderForExtraction

            check() {

                echo "$YELLOW""$1"$NORMAL
                echo Are you sure that this link is a direct download to a:
                echo "-$RED""Patchwad$NORMAL file"
                echo "-$RED""Wad$NORMAL file"
                echo "-$RED""Zip$NORMAL file"
                echo "-$RED""Rar$NORMAL file"
                echo
                read -p "(Yes|No): " answer

                case $answer in
                    "Yes")

                        echo Starting the download...
                        curl -OL "$1" 2>/dev/null
                            (( $? > 0 )) &&
                                echo &&
                                echo "$RED""URL$NORMAL could be wrong" && exit 1

                        echo "Extracting if necessary..."
                        tar -xf $correctFileName &>/dev/null && 
                            rm $correctFileName

                        installation /tmp/$nameOfFolderForExtraction

                    ;;
                    Y|y)

                        echo Starting the download...
                        curl -OL "$1" 2>/dev/null
                            (( $? > 0 )) &&
                                echo &&
                                echo "$RED""URL$NORMAL could be wrong" && exit 1

                        echo "Extracting if necessary..."
                        tar -xf $correctFileName &>/dev/null && 
                            rm $correctFileName

                        installation /tmp/$nameOfFolderForExtraction

                    ;;
                    "No")

                        echo "Exiting then..."
                        exit

                    ;;
                    N|n)

                        echo "Exiting then..."
                        exit

                    ;;
                    *)

                        clear
                        echo Choose something, please
                        read
                        clear
                        check "$1"

                    ;;
                esac  

            }
            check "$secondArgument"

        }

    fi


    installation "$originalPath"
    # Checks if the game was running and if it was, it launches it again
    pathToFolder=$(
        fixPath "$(cat $appdata/path_to_game_folder.dat)" && 
        echo $fixedPath
    )
    isGameRunning=$(
        pgrep "HotlineMiami2" &>/dev/null && 
            echo true || echo false
    )
    steamAppID=$(cat "$pathToFolder"/Contents/MacOS/steam_appid.txt 2>/dev/null || echo null)
    [[ $wasGameRunning == "true" && $isGameRunning == "false" ]] && {

        [[ $steamAppID == "null" ]] && open "$pathToFolder" || open steam://rungameid/$steamAppID

    }

}

uninstall() {

    checks
    [[ $? == 1 ]] && exit 1

    # Checks if the game is running and it shuts it down
    pgrep "HotlineMiami2" &>/dev/null && {

        wasGameRunning=true
        killall -SIGKILL "HotlineMiami2" 2>/dev/null

    }
    

    checkIfClicked && clear
    originalPath=$(pwd)

    # Gets to the folder where the mod files are, just 1 folder back
    # and gets the path to the game's folder too
    fixPath "~/Library/Application Support/HotlineMiami2/mods"
    modsDirectoryFolder=$fixedPath

    cd "$modsDirectoryFolder"
    pathToFolder=$(
        fixPath "$(cat $appdata/path_to_game_folder.dat)" && 
        echo $fixedPath
    )
    pathToBackup=$(
        fixPath "$(cat $appdata/path_to_backup.dat)" && 
        echo $fixedPath
    )


    # Moves all mods to the current path and then cleans the "mods" folder
    cp -r ./ "$originalPath"
    [[ ! -z $(ls) ]] && rm -r *
    echo Cleaned the /mods folder


    # Checks if the music file changed by looking at the size
    cd "$pathToFolder"/Contents/Resources
    newSize=$(du -k "hlm2_music_desktop.wad" | awk '{print $1}')
    originalSize=$(cd "$pathToBackup"; du -k "hlm2_music_desktop.wad" | awk '{print $1}')

    if [[ "$newSize" != "$originalSize" ]] ;then

        # Goes to the game's folder and moves the music to the current path
        cp hlm2_music_desktop.wad "$originalPath"
        echo Moved the modded music to the current folder

        # Goes to pick up the backup of the default music 
        # and puts it inside the game's folder 
        cd "$pathToBackup"
        echo Copying the backup inside the game\'s folder...
        cp hlm2_music_desktop.wad "$pathToFolder"/Contents/Resources

    fi

    echo
    echo Finished uninstalling


    isGameRunning=$(
        pgrep "HotlineMiami2" &>/dev/null && 
            echo true || echo false
    )
    steamAppID=$(cat "$pathToFolder"/Contents/MacOS/steam_appid.txt 2>/dev/null || echo null)
    [[ $wasGameRunning == "true" && $isGameRunning == "false" ]] && {

        [[ $steamAppID == "null" ]] && open "$pathToFolder" || open steam://rungameid/$steamAppID

    }

    checkIfClicked && {
        echo
        read
        helpF_mouse_click
    }

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
    pathToFolder=$(
        fixPath "$(cat $appdata/path_to_game_folder.dat)" && 
        echo $fixedPath
    )

    if [[ $pathToFolder != *"HotlineMiami2.app"* ]] ;then

        echo "$LIGHT_RED""Make sure that inside the path there's included the .app folder$NORMAL"
        return 1

    fi

}


[[ "$1" == "" ]] && {
    checkIfClicked && 
        helpF_mouse_click || helpF
}

[[ "$1" == "--help" ]] && helpF
[[ "$1" == "-h" ]] && helpF
[[ "$1" == "-i" ]] && install
[[ "$1" == "-un" ]] && uninstall
[[ "$1" == "-r" ]] && reset
[[ "$1" == "-s" ]] && set_path
[[ "$1" == "--settings" ]] && settings
echo "$YELLOW$1$NORMAL parameter doesn't exist"
echo 
helpF