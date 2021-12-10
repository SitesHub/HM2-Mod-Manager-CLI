@echo off
setlocal enabledelayedexpansion

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

    call :checks
    if "%quit%" == "yes" exit /b 1

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

    call :checks
    if "%quit%" == "yes" exit /b 1

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

    call :checks
    if "%quit%" == "yes" exit /b 1

    @REM Gets the amount of files needed to be installed 
    @REM present in the same folder as the batch file and
    @REM the path to the game's folder

    @REM If there are patchwad files inside other folders that are in the current one,
    @REM it'll get the main folder, closest to the current one and place it inside the mods' folder
    set count=0
    set existPatchwadsInsideFolders=false
    for /R %%A in (*.patchwad) do (

        if %existPatchwadsInsideFolders% == false set existPatchwadsInsideFolders=true

        set normalPath=%%A
	    call set onlyFolder_Name=%%normalPath:!cd!\=%%
	    for /f "delims=\" %%B in ('echo !onlyFolder_Name!') do set finalPath=%%B

        set list[!count!]=!finalPath!
        set /A count=%count%+1 > nul

    )


    @REM Moves folders inside mods if found any
    if %existPatchwadsInsideFolders% == true (

        set /A amount=%count%-1

        for /L %%A in (0, 1, !amount!) do (

            move !list[%%A]! "%userprofile%\Documents\My Games\HotlineMiami2\mods" > nul 2> nul

        )

    )
    set /p pathToFolder=<%appdata%\HM2-Mod_Manager\path_to_game_folder.dat

    for /F "delims=" %%A in ('dir ^| find /c ".patchwad"') do set patchwad=%%A
    for /F "delims=" %%A in ('dir ^| find /c ".wad"') do set wad=%%A


    @REM Install the files inside the correct folders
    @REM only if the amount isn't equal to 0
    if "%patchwad%" neq "0" move *.patchwad "%userprofile%\Documents\My Games\HotlineMiami2\mods" > nul
    if "%wad%" neq "0" move *.wad %pathToFolder% > nul

exit /b

:uninstall

    call :checks
    if "%quit%" == "yes" exit /b 1

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

exit /b


:checks

    if not exist %appdata%\HM2-Mod_Manager\path_to_game_folder.dat (

        if not exist %appdata%\HM2-Mod_Manager\path_to_backup.dat (

            echo The paths are missing
            echo You need to create them first
            goto :end

        )

    )

    if not exist %appdata%\HM2-Mod_Manager\path_to_game_folder.dat (

        echo The path to the game's folder is missing
        echo You need to create it first
        goto :end

    )

    if not exist %appdata%\HM2-Mod_Manager\path_to_backup.dat (

        echo The path to the backup is missing
        echo You need to create it first
        goto :end

    )

exit /b
:end
set quit=yes
exit /b