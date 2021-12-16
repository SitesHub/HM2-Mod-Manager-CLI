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
    echo                    [path_to_zip] 
    echo                       Extracts the zip file inside %TEMP% and installs its contents
    echo.
    echo                    [URL] 
    echo                       Downloads the zip file from DropBox and installs it
    echo.
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
    echo Cleaned the \mods folder


    @REM Checks if there's need to reset the music file or not
    cd /d %pathToBackup%
    for %%S in (hlm2_music_desktop.wad) do (

        set originalSize=%%~zS

        cd /d %pathToFolder%
        for %%A in (hlm2_music_desktop.wad) do set newSize=%%~zA


        if "!newSize!" neq "!originalSize!" (

            cd /d %pathToBackup%
            echo Resetting the music file
            copy /y hlm2_music_desktop.wad %pathToFolder% >nul

        )

    )

    echo.
    echo Finished resetting

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
            echo Set the path to the Backup's folder
            goto :end_set_path

        ) else (

            mkdir HM2-Mod_Manager
            cd HM2-Mod_Manager
            echo %3 > path_to_backup.dat
            echo Set the path to the Backup's folder
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
        echo Set the path to the Game's folder

    ) else (

        mkdir HM2-Mod_Manager
        cd HM2-Mod_Manager
        echo "%pathWithFolderName%" > path_to_game_folder.dat
        echo Set the path to the Game's folder

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
        echo Starting Explorer...
        start "explorer.exe" HM2-Mod_Manager
        echo Opened Explorer
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

    @REM Options for the parameter
    if "%2" neq "" (

        set nameOfFolderForExtraction=HM2-Mod_Manager

        @REM Creates the temporary folder if it doesn't exist then 
        @REM it cleans the temporary folder if it has content inside it
        if not exist %temp%\%nameOfFolderForExtraction%\* mkdir %temp%\%nameOfFolderForExtraction%

        for /f "delims=" %%A in ('dir /b %temp%\%nameOfFolderForExtraction%') do (

            rmdir /q /s %temp%\%nameOfFolderForExtraction%
            mkdir %temp%\%nameOfFolderForExtraction%

        )


        @REM Extraction of a zip file from the terminal
        echo "%2" | find ".zip" >nul && (

            dir "%2" >nul 2>nul && (

                powershell -Command "Expand-Archive -Path %2 -DestinationPath ($env:TEMP + '\%nameOfFolderForExtraction%\')"
                cd /d %temp%\%nameOfFolderForExtraction%

            ) || (

                echo Couldn't find the zip file or the path is incorrect

            )

        )

        @REM Direct download from the terminal
        @REM --------Zip files only----------- (as of today)
        @REM ---------DropBox only------------
        echo "%2" | find "https://www.dropbox.com" >nul && (

            cd /d %temp%\%nameOfFolderForExtraction%
            set "link='%2'.Replace('?dl', '?dl=1')"

            @REM Checks if if it's a zip file
            echo Checking the file to download...

            echo "%2" | find ".zip" >nul || (

                set getContentType="[Net.HttpWebRequest]::Create(!link!).GetResponse().ContentType"

                powershell -Command !getContentType! | find "application/zip" >nul || (

                    echo The file is not a zip
                    echo Exiting...
                    exit /b

                )

            )

            echo Downloading...
            powershell -Command "(New-Object System.Net.WebClient).DownloadFile(!link!, ((Get-Location).path + '.\level_campaign.zip'))" || echo URL could be wrong

            echo Extracting...
            powershell -Command "Expand-Archive -Path .\level_campaign.zip -DestinationPath .\fromURL" || echo Couldn't extract zip file
            cd fromURL

        ) || echo Check if the url is correct

    )


    @REM Gets the amount of files needed to be installed 
    @REM present in the same folder as the batch file and
    @REM the path to the game's folder

    @REM If there are patchwad files inside other folders that are in the current one,
    @REM it'll get the main folder, closest to the current one and place it inside the mods' folder
    set count=0
    set existPatchwadsInsideFolders=false
    for /R %%A in (*.patchwad) do (

        if "%existPatchwadsInsideFolders%" == "false" set existPatchwadsInsideFolders=true

        set normalPath=%%A
	    call set onlyFolder_Name=%%normalPath:!cd!\=%%
	    for /f "delims=\" %%B in ('echo !onlyFolder_Name!') do set finalPath=%%B

        set list[!count!]=!finalPath!
        set /A count=%count%+1 >nul

    )


    @REM Moves folders inside mods if found any
    if "%existPatchwadsInsideFolders%" == "true" (

        set /A amount=%count%-1

        for /L %%A in (0, 1, !amount!) do (

            move !list[%%A]! "%userprofile%\Documents\My Games\HotlineMiami2\mods" >nul 2>nul

        )
        echo Moved modded folders inside \mods

    )
    set /p pathToFolder=<%appdata%\HM2-Mod_Manager\path_to_game_folder.dat

    for /F "delims=" %%A in ('dir ^| find /c ".patchwad"') do set patchwad=%%A
    for /F "delims=" %%A in ('dir ^| find /c ".wad"') do set wad=%%A


    @REM Install the files inside the correct folders
    @REM only if the amount isn't equal to 0
    if "%patchwad%" neq "0" (

        move *.patchwad "%userprofile%\Documents\My Games\HotlineMiami2\mods" >nul
        echo Installed patchwad file\s inside \mods

    )
    if "%wad%" neq "0" (
        
        move *.wad %pathToFolder% >nul
        echo Installed wad file\s inside the game's folder

    )

    echo Finished the installation

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
    robocopy /e %directory% %originalPath% >nul
    rmdir /q /s %directory%
    mkdir %directory%


    @REM Checks if the music file changed by looking at the size
    cd /d %pathToFolder%
    for %%S in (hlm2_music_desktop.wad) do (

        set newSize=%%~zS
        
        cd /d %pathToBackup%
        for %%A in (hlm2_music_desktop.wad) do set originalSize=%%~zA


        if "!newSize!" neq "!originalSize!" (

            @REM Goes to the game's folder and moves the music to the current path
            cd /d %pathToFolder%
            copy /y hlm2_music_desktop.wad %originalPath% >nul
            echo Moved the modded music to the current folder


            @REM Goes to pick up the backup of the default music 
            @REM and puts it inside the game's folder 
            cd /d %pathToBackup%
            echo Copying the backup inside the game's folder...
            copy /y hlm2_music_desktop.wad %pathToFolder% >nul

        )

    )

    echo.
    echo Finished uninstalling

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