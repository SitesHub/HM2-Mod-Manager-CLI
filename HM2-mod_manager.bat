@echo off
setlocal EnableDelayedExpansion

if "%1" == "" goto :help
if "%1" == "/?" goto :help
if "%1" == "/i" goto :install
if "%1" == "/un" goto :uninstall
if "%1" == "/r" goto :reset
if "%1" == "/s" goto :set_path
if "%1" == "/settings" goto :settings
goto :help

:help

    echo Manager of mods for HM2 
    echo.
    echo    /i           Installs the mods
    echo.
    echo    /un          Uninstalls the mods
    echo.
    echo    /r           Resets everything back to normal
    echo.
    echo    /s           Sets the path of the game's folder
    echo                 add /b after the first paramater to create the backup's path
    echo.
    echo    /settings    Shows all paths
    echo                 add /e to open up the settings' folder via Explorer

exit /b

:reset

    if not exist %appdata%\HM2-Mod_Manager\path_to_game_folder.dat (

        echo The path to the game's folder is missing
        echo You need to create it first
        goto :end_reset

    )

    if not exist %appdata%\HM2-Mod_Manager\path_to_backup.dat (

        echo The path to the backup is missing
        echo You need to create it first
        goto :end_reset

    )

    @REM Gets the paths and then it goes to the mods folder, resetting it
    @REM Same with the music
    set /p pathToFolder=<%appdata%\HM2-Mod_Manager\path_to_game_folder.dat
    set /p pathToBackup=<%appdata%\HM2-Mod_Manager\path_to_backup.dat


    cd "%userprofile%\Documents\My Games\HotlineMiami2"
    set directory="mods"

    rmdir /q /s %directory%
    mkdir %directory%

    cd /d %pathToBackup%
    copy /y hlm2_music_desktop.wad %pathToFolder% > nul

:end_reset
exit /b

:set_path

    @REM Creates the path file inside its folder named "HM2-Mod_Manager"
    cd /d %appdata%

    @REM Backup mode
    if "%2" == "/b" (

        if "%3" == "" (

            echo You typed nothing
            echo Exiting...
            exit /b

        )

        if exist HM2-Mod_Manager (

            cd HM2-Mod_Manager
            echo %3 > path_to_backup.dat
            goto :end_set_path

        ) else (

            mkdir HM2-Mod_Manager
            cd HM2-Mod_Manager
            echo %3 > path_to_backup.dat
            goto :end_set_path

        )

    )

    @REM Normal mode
    if "%2" == "" (
        
        echo You typed nothing
        echo Exiting...
        exit /b

    )


    set path=%2
    set pathWithoutFolderName=%path:Hotline=%
    set "pathWithFolderName=%pathWithoutFolderName%Hotline Miami 2"

    if exist HM2-Mod_Manager (

        cd HM2-Mod_Manager
        echo "%pathWithFolderName%" > path_to_game_folder.dat

    ) else (

        mkdir HM2-Mod_Manager
        cd HM2-Mod_Manager
        echo "%pathWithFolderName%" > path_to_game_folder.dat

    )

:end_set_path
exit /b

:settings

    if not exist %appdata%\HM2-Mod_Manager\path_to_game_folder.dat (

        echo The path to the game's folder is missing
        echo You need to create it first
        goto :end_reset

    )

    if not exist %appdata%\HM2-Mod_Manager\path_to_backup.dat (

        echo The path to the backup is missing
        echo You need to create it first
        goto :end_reset

    )

    @REM Explorer mode
    if "%2" == "/e" (

        cd %appdata%

        if not exist HM2-Mod_Manager mkdir HM2-Mod_Manager
        start "explorer.exe" HM2-Mod_Manager
        goto :end_settings

    )

    set /p pathToFolder=<%appdata%\HM2-Mod_Manager\path_to_game_folder.dat
    set /p pathToBackup=<%appdata%\HM2-Mod_Manager\path_to_backup.dat

    echo Game's folder path: %pathToFolder%
    echo Backup's folder path: %pathToBackup%

:end_settings
exit /b

:install

    if not exist %appdata%\HM2-Mod_Manager\path_to_game_folder.dat (

        echo The path to the game's folder is missing
        echo You need to create it first
        goto :end_install

    )

    @REM Gets the amount of files needed to be installed 
    @REM present in the same folder as the batch file and
    @REM the path to the game's folder
    for /F "delims=" %%A in ('dir ^| find /c ".patchwad"') do set patchwad=%%A
    for /F "delims=" %%A in ('dir ^| find /c ".wad"') do set wad=%%A
    set /p pathToFolder=<%appdata%\HM2-Mod_Manager\path_to_game_folder.dat


    @REM Install the files inside the correct folders
    @REM only if the amount isn't equal to 0
    if "%patchwad%" neq "0" move *.patchwad "%userprofile%\Documents\My Games\HotlineMiami2\mods" > nul
    if "%wad%" neq "0" move *.wad %pathToFolder% > nul

:end_install
exit /b

:uninstall

    if not exist %appdata%\HM2-Mod_Manager\path_to_game_folder.dat (

        echo The path to the game's folder is missing
        echo You need to create it first
        goto :end_uninstall

    )

    if not exist %appdata%\HM2-Mod_Manager\path_to_backup.dat (

        echo The path to the backup is missing
        echo You need to create it first
        goto :end_uninstall

    )

    set originalPath=%cd%

    @REM Gets to the folder where the mod files are, just 1 folder back
    @REM and gets the path to the game's folder too
    cd "%userprofile%\Documents\My Games\HotlineMiami2"
    set directory="mods"
    set /p pathToFolder=<%appdata%\HM2-Mod_Manager\path_to_game_folder.dat
    set /p pathToBackup=<%appdata%\HM2-Mod_Manager\path_to_backup.dat


    @REM Moves all mods to the current path and then cleans the "mods" folder
    robocopy /e %directory% %originalPath% > nul
    rmdir /q /s %directory%
    mkdir %directory%

    @REM Goes to the game's folder and moves the music to the current path
    cd /d %pathToFolder%
    copy /y hlm2_music_desktop.wad %originalPath% > nul
    

    @REM Goes to pick up the backup of the default music 
    @REM and puts it inside the game's folder 
    cd /d %pathToBackup%
    copy /y hlm2_music_desktop.wad %pathToFolder% > nul

:end_uninstall
exit /b