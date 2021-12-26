@echo off
setlocal enabledelayedexpansion

@REM Gets version of OS
for /f "tokens=4" %%A in ('ver') do (

    set rawVersion=%%A
    set correctedVersion=!rawVersion:]=!
    for /f "delims=." %%B in ('echo !correctedVersion!') do set version=%%B 

)
set ifVersion=if %version% == 10

@REM Sets the variables for colours and formatting
@REM only useful for an OS like windows 10 or above
for /F %%A in ('echo prompt $E^| CMD') do set "ESC=%%A"

set NORMAL=%ESC%[0m
set BOLD=%ESC%[1m
set UNDERLINE=%ESC%[4m

set YELLOW=%ESC%[33m
set RED=%ESC%[31m


@REM Looks for the installation path of either WinRAR or 7zip
@REM and sets it for the script inside the PATH variable
call :set_unrar-7z_path


@REM Double clicked
echo %cmdcmdline% | find /i """%~f0""" >nul && goto :help_double_click


if "%1" == "" goto :help
if "%1" == "/?" goto :help
if "%1" == "/i" goto :install
if "%1" == "/un" goto :uninstall
if "%1" == "/r" goto :reset
if "%1" == "/s" goto :set_path
if "%1" == "/settings" goto :settings
goto :help

:help

    @REM Checks what version of the OS is before displaying
    %ifVersion% (

        echo %BOLD%Manager of mods for HM2%NORMAL% 
        echo.
        echo    %BOLD%/i%NORMAL%           Installs the mods
        echo.
        echo                    %BOLD%/x%NORMAL% [%BOLD%%UNDERLINE%path\to\compressed-file%NORMAL%] 
        echo                       Extracts the compressed file inside %BOLD%%temp%%NORMAL% folder and installs its contents
        echo.
        echo                    [%BOLD%%UNDERLINE%URL%NORMAL%] 
        echo                       Downloads the file from an url and installs it
        echo                       NOTE: if it's not from %BOLD%DropBox%NORMAL%, it'll ask for user's confirmation
        echo.
        echo    %BOLD%/un%NORMAL%          Uninstalls the mods
        echo.
        echo    %BOLD%/r%NORMAL%           Resets everything back to normal
        echo.
        echo    %BOLD%/s%NORMAL%           Sets the path of the game's folder
        echo                    %BOLD%/b%NORMAL% Creates the backup's path
        echo.
        echo    %BOLD%/settings%NORMAL%    Shows all paths
        echo                    %BOLD%/e%NORMAL% Opens up the settings' folder via Explorer

    ) else (

        echo Manager of mods for HM2 
        echo.
        echo    /i           Installs the mods
        echo.
        echo                    /x [path\to\compressed-file] 
        echo                       Extracts the compressed file inside %temp% folder and installs its contents
        echo.
        echo                    [URL] 
        echo                       Downloads the file from an url and installs it
        echo                       NOTE: if it's not from DropBox, it'll ask for user's confirmation
        echo.
        echo    /un          Uninstalls the mods
        echo.
        echo    /r           Resets everything back to normal
        echo.
        echo    /s           Sets the path of the game's folder
        echo                    /b Creates the backup's path
        echo.
        echo    /settings    Shows all paths
        echo                    /e Opens up the settings' folder via Explorer

    )

exit /b

:help_double_click

    cls
    %ifVersion% (

        echo %BOLD%Manager of mods for HM2%NORMAL% 
        echo.
        echo    %BOLD%1%NORMAL%.   Installs the mods
        echo.
        echo    %BOLD%2%NORMAL%.   Uninstalls the mods
        echo.
        echo    %BOLD%3%NORMAL%.   Resets everything back to normal
        echo.
        echo    %BOLD%4%NORMAL%.   Sets the path of the game's folder
        echo.
        echo    %BOLD%5%NORMAL%.   Shows all paths
        echo.
        echo    %BOLD%q%NORMAL% to quit
        echo.

    ) else (

        echo Manager of mods for HM2 
        echo.
        echo    1.   Installs the mods
        echo.
        echo    2.   Uninstalls the mods
        echo.
        echo    3.   Resets everything back to normal
        echo.
        echo    4.   Sets the path of the game's folder
        echo.
        echo    5.   Shows all paths
        echo.
        echo    q to quit
        echo.

    )

    set /p answer="Choose an option: %BOLD%"

    if "%answer%" == "" goto :help_double_click
    if %answer% == 1 call :install
    if %answer% == 2 call :uninstall
    if %answer% == 3 call :reset
    if %answer% == 4 call :set_path
    if %answer% == 5 call :settings
    if %answer% == q exit /b
    goto :help_double_click

exit /b


:reset

    call :checks
    if "%quit%" == "yes" exit /b 1


    @REM Prevents a permanent freeze of the screen or breaking of the game
    tasklist | find "HotlineMiami2.exe" >nul && (

        set restartGame=true
        timeout /NOBREAK /T 5
        taskkill /IM "HotlineMiami2.exe"

    )

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

    if defined restartGame %pathToFolder%\HotlineMiami2.exe

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


    @REM Prevents a permanent freeze of the screen or breaking of the game
    tasklist | find "HotlineMiami2.exe" >nul && (

        set restartGame=true
        timeout /NOBREAK /T 5
        taskkill /IM "HotlineMiami2.exe"

    )

    @REM Options for the parameter
    if "%2" neq "" (

        set nameOfFolderForExtraction=HM2-Mod_Manager

        @REM Creates the temporary folder if it doesn't exist then 
        @REM it cleans the temporary folder if it has content inside it
        dir "%temp%\!nameOfFolderForExtraction!" >nul 2>nul || mkdir %temp%\!nameOfFolderForExtraction!

        for /f "delims=" %%A in ('dir /b %temp%\!nameOfFolderForExtraction!') do (

            rmdir /q /s %temp%\!nameOfFolderForExtraction!
            mkdir %temp%\!nameOfFolderForExtraction!

        )


        @REM Extraction of a zip file from the terminal
        echo "%2" | find "/x" >nul && (

            if "%3" == "" echo Passed no compressed file & echo Exiting... & exit /b

            echo "%3" | find ".zip" >nul && (


                dir "%3" >nul 2>nul && (

                    powershell -Command "Expand-Archive -Path %3 -DestinationPath ($env:TEMP + '\!nameOfFolderForExtraction!\')" 2>nul || echo Couldn't extract the zip file & exit /b
                    cd /d %temp%\!nameOfFolderForExtraction!

                ) || echo Couldn't find the zip file or the path is incorrect & exit /b


            ) || echo "%3" | find ".rar" >nul && (

                where unrar >nul 2>nul && (


                    dir "%3" >nul 2>nul && (

                        unrar x "%3" "%TEMP%"\!nameOfFolderForExtraction!\ >nul 2>nul || echo Couldn't extract the rar file & exit /b
                        cd /d %temp%\!nameOfFolderForExtraction!

                    ) || echo Couldn't find the rar file or the path is incorrect & exit /b


                ) || where 7z >nul 2>nul && (


                    dir "%3" >nul 2>nul && (

                        7z x "%3" -o"%TEMP%"\!nameOfFolderForExtraction!\ >nul 2>nul || echo Couldn't extract the rar file & exit /b
                        cd /d %temp%\!nameOfFolderForExtraction!

                    ) || echo Couldn't find the rar file or the path is incorrect & exit /b


                ) || echo Couldn't find neither unRAR.exe or 7z.exe & exit /b

            )

        )

        @REM Direct download from the terminal
        echo "%2" | find "https://www.dropbox.com" >nul && (

            cd /d %temp%\!nameOfFolderForExtraction!
            set "link='%2'.Replace('?dl', '?dl=1')"

            @REM Checks the file extension
            echo Checking the file to download...

            set getContentDisposition="[Net.HttpWebRequest]::Create(!link!).GetResponse().Headers['Content-Disposition']"
            powershell -Command !getContentDisposition! > %temp%\temp.dat

            set /p contentDisposition=<%temp%\temp.dat
            set fileName=[Regex]::Match('%contentDisposition%', 'filename="(.*)"').Groups[1].Value -replace '; .*'
            @REM -------------------------------------------------------------------------------------------------------------------


            powershell -Command %fileName% | find ".zip" && (

                echo Downloading...
                powershell -Command "(New-Object System.Net.WebClient).DownloadFile(!link!, ((Get-Location).path + '.\%fileName%'))" || echo URL could be wrong & exit /b

                echo Extracting...
                powershell -Command "Expand-Archive -Path .\%fileName% -DestinationPath .\fromURL" || echo Couldn't extract the zip file & exit /b
                cd fromURL

            ) || powershell -Command %fileName% | find ".rar" && (

                echo Downloading...
                powershell -Command "(New-Object System.Net.WebClient).DownloadFile(!link!, ((Get-Location).path + '.\%fileName%'))" || echo URL could be wrong & exit /b

                echo Extracting...
                where unrar >nul 2>nul && (


                    dir "%fileName%" >nul 2>nul && (

                        unrar x "%fileName%" "%cd%"\fromURL\ >nul 2>nul || echo Couldn't extract the rar file & exit /b

                    ) || echo Couldn't find the rar file or the path is incorrect & exit /b


                ) || where 7z >nul 2>nul && (


                    dir "%fileName%" >nul 2>nul && (

                        7z x "%fileName%" -o"fromURL" >nul 2>nul || echo Couldn't extract the rar file & exit /b

                    ) || echo Couldn't find the rar file or the path is incorrect & exit /b


                ) || echo Couldn't find neither unRAR.exe or 7z.exe & exit /b

                cd fromURL

            ) || (

                echo Downloading...
                powershell -Command "(New-Object System.Net.WebClient).DownloadFile(!link!, ((Get-Location).path + '.\%fileName%'))" || echo URL could be wrong & exit /b

            )

        )
        
        @REM Need to figure out ------ ! --------
        powershell -Command "'%2' -cmatch '(http|https):\/\/'" | find "True" >nul && (

            cd /d %temp%\!nameOfFolderForExtraction!

            :URL_confirmation
            %ifVersion% (

                echo %YELLOW%%2%NORMAL%
                echo Are you sure that this link is a direct download to a:
                echo -%RED%Patchwad%NORMAL% file
                echo -%RED%Wad%NORMAL% file
                echo -%RED%Zip%NORMAL% file
                echo -%RED%Rar%NORMAL% file
                echo.

            ) else (

                echo %2
                echo Are you sure that this link is a direct download to a:
                echo -Patchwad file
                echo -Wad file
                echo -Zip file
                echo -Rar file
                echo.

            )
            set /p answer="(Yes|No): "

            powershell -Command "'!answer!' -cmatch 'y|Y'" | find "True" >nul && (

                echo Starting the download...
                powershell -Command "(New-Object System.Net.WebClient).DownloadFile(%2, ((Get-Location).path + '.\level_campaign.zip'))" 2>nul || (

                    %ifVersion% ( echo. & echo %RED%URL%NORMAL% could be wrong ) else echo. & echo URL could be wrong
                    
                )
                
                echo Extracting if necessary...
                powershell -Command "Expand-Archive -Path .\level_campaign.zip -DestinationPath .\fromURL" 2>nul
                where unrar >nul 2>nul && (

                    dir "%2" >nul 2>nul && (

                        unrar x "%2" "%TEMP%"\!nameOfFolderForExtraction!\

                    ) || (

                        echo Couldn't find the rar file or the path is incorrect

                    )

                )

                goto :end_of_URL_confirmation
            
            )
            powershell -Command "'!answer!' -cmatch 'n|N'" | find "True" >nul && (

                echo Exiting then...
                exit /b

            ) || (

                cls
                echo Choose something, please
                pause
                cls
                goto :URL_confirmation

            ) 

            :end_of_URL_confirmation
            @REM Needed to work
            echo end >nul

        )

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

    if defined restartGame %pathToFolder%\HotlineMiami2.exe

exit /b

:uninstall

    call :checks
    if "%quit%" == "yes" exit /b 1


    @REM Prevents a permanent freeze of the screen or breaking of the game
    tasklist | find "HotlineMiami2.exe" >nul && (

        set restartGame=true
        timeout /NOBREAK /T 5
        taskkill /IM "HotlineMiami2.exe"

    )

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

    if defined restartGame %pathToFolder%\HotlineMiami2.exe

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

:set_unrar-7z_path

    @REM 32-bit version of WinRAR
    for /f "delims=" %%A in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\WinRAR /v exe32 2^>nul') do (

        echo %%A | find "HKEY" >nul || (

            set rawValue=%%A
            set pathToRAR=!rawValue:    exe32    REG_SZ    =!

            set pathToUnRAR_folder="'!pathToRAR!'.Replace('\WinRAR.exe', '')"
	        powershell -Command !pathToUnRAR_folder! > %temp%\temp1.dat
	        set /p pathToUnRAR_pwsh=<%temp%\temp1.dat


            set PATH=!PATH!;!pathToUnRAR_pwsh!

        ) 

    )

    @REM 64-bit version of WinRAR
    for /f "delims=" %%A in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\WinRAR /v exe64 2^>nul') do (

        echo %%A | find "HKEY" >nul || (

            set rawValue=%%A
            set pathToUnRAR=!rawValue:    exe64    REG_SZ    =!

            set pathToUnRAR_folder="'!pathToRAR!'.Replace('\WinRAR.exe', '')"
	        powershell -Command !pathToUnRAR_folder! > %temp%\temp1.dat
	        set /p pathToUnRAR_pwsh=<%temp%\temp1.dat

            
            set PATH=!PATH!;!pathToUnRAR_pwsh!

        ) 

    )

    @REM 32-bit version of 7zip
    for /f "delims=" %%A in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\7-Zip /v Path 2^>nul') do (

        echo %%A | find "HKEY" >nul || (

            set rawValue=%%A
            set pathTo7z_folder=!rawValue:    Path    REG_SZ    =!
            set finalPathTo7z_folder=!pathTo7z_folder:7-Zip\=7-Zip!

            
            set PATH=!PATH!;!finalPathTo7z_folder!

        ) 

    )

    @REM 64-bit version of 7zip
    for /f "delims=" %%A in ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\7-Zip /v Path64 2^>nul') do (

        echo %%A | find "HKEY" >nul || (

            set rawValue=%%A
            set pathTo7z_folder=!rawValue:    Path64    REG_SZ    =!
            set finalPathTo7z_folder=!pathTo7z_folder:7-Zip\=7-Zip!

            
            set PATH=!PATH!;!finalPathTo7z_folder!

        ) 

    )

exit /b