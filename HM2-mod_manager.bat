@echo off
setlocal enabledelayedexpansion

@REM Gets version of OS
for /f "tokens=4" %%A in ('ver') do (

    set rawVersion=%%A
    set correctedVersion=!rawVersion:]=!
    for /f "delims=." %%B in ('echo !correctedVersion!') do set version=%%B 

)

@REM Sets the variables for colours and formatting
@REM only useful for an OS like windows 10 or above
for /F %%A in ('echo prompt $E^| CMD') do set "ESC=%%A"

set NORMAL=%ESC%[0m
set BOLD=%ESC%[1m
set UNDERLINE=%ESC%[4m

set YELLOW=%ESC%[33m
set RED=%ESC%[31m

@REM Removes the colours in case that the version of windows is not 10
if %version% lss 10 (

    set NORMAL=%ESC%
    set BOLD=%ESC%
    set UNDERLINE=%ESC%

    set YELLOW=%ESC%
    set RED=%ESC%

)


@REM Double clicked
echo %cmdcmdline% | find /i """%~f0""" >nul && goto :help_click


if "%1" == "" goto :help
if "%1" == "/?" goto :help
if "%1" == "/i" goto :install
if "%1" == "/un" goto :uninstall
if "%1" == "/r" goto :reset
if "%1" == "/s" goto :set_path
if "%1" == "/settings" goto :settings
goto :help

:help

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

exit /b

:help_click

    cls
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

    set /p answer="Choose an option: %BOLD%"

    if "%answer%" == "" goto :help_click
    if %answer% == 1 call :install_click
    if %answer% == 2 cls & call :uninstall
    if %answer% == 3 cls & call :reset
    if %answer% == 4 call :set_path_click
    if %answer% == 5 call :settings_click
    if %answer% == q exit /b
    goto :help_click

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
    echo %NORMAL%Cleaned the \mods folder


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

    if defined restartGame call :restart_game

    echo %cmdcmdline% | find /i """%~f0""" >nul && (
        echo.
        pause
    )

exit /b

:set_path

    @REM Creates the path file inside its folder named "HM2-Mod_Manager"
    cd /d %appdata%

    @REM Backup mode
    if "%2" == "/b" (

        set path=%3

        set noQuotes=%path:"=%
        set pathWithFolderName=%noQuotes%

        if "%3" == "" (

            echo You typed nothing
            echo Exiting...
            exit /b

        )

        if exist HM2-Mod_Manager (

            cd HM2-Mod_Manager
            echo %pathWithFolderName% > path_to_backup.dat
            echo Set the path to the Backup's folder
            goto :end_set_path

        ) else (

            mkdir HM2-Mod_Manager
            cd HM2-Mod_Manager
            echo %pathWithFolderName% > path_to_backup.dat
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

    set noQuotes=%path:"=%
    set pathWithFolderName=%noQuotes%

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

:set_path_click

    @REM Creates the path file inside its folder named "HM2-Mod_Manager"
    cd /d %appdata%

    cls
    echo %BOLD%1%NORMAL%.  Sets the path to the game's folder
    echo         To use it, paste in the %UNDERLINE%path%NORMAL% after being prompted
    echo.
    echo %BOLD%2%NORMAL%.  Sets the path to the backup's folder
    echo         To use it, do the same as the 1st option but with the %UNDERLINE%backup's path%NORMAL%
    echo.
    echo %BOLD%b%NORMAL% to go back
    echo %BOLD%q%NORMAL% to quit
    echo.

    set /p answer="Choose an option: %BOLD%"

    if "%answer%" == "" goto :set_path_click
    if "%answer%" == "1" (

        set /p answer2="%NORMAL%Insert the path: %BOLD%"

        set removedQuotes_dir=!answer2:"=!
        dir "!removedQuotes_dir!" >nul 2>nul && call :game_path || (
            cls
            echo %RED%!answer2!%NORMAL% is not a valid path
            echo.
            pause
            goto :set_path_click
        )

    )
    if "%answer%" == "2" (

        set /p answer2="%NORMAL%Insert the path: %BOLD%"

        set removedQuotes_dir=!answer2:"=!
        dir "!removedQuotes_dir!" >nul 2>nul && call :backup_path || (
            cls
            echo %RED%!answer2!%NORMAL% is not a valid path
            echo.
            pause
            goto :set_path_click
        )

    )
    if "%answer%" == "q" exit /b
    if "%answer%" == "b" goto :help_click
    goto :set_path_click


    :game_path

        set path=%answer2%

        set noQuotes=%path:"=%
        set pathWithFolderName=%noQuotes%

        cls
        echo "%pathWithFolderName%"
        if exist HM2-Mod_Manager (

            cd HM2-Mod_Manager
            echo "%pathWithFolderName%" > path_to_game_folder.dat
            echo %NORMAL%Set the path to the Game's folder

        ) else (

            mkdir HM2-Mod_Manager
            cd HM2-Mod_Manager
            echo "%pathWithFolderName%" > path_to_game_folder.dat
            echo Set the path to the Game's folder

        )
        echo.
        pause

    exit /b

    :backup_path

        set path=%answer2%

        set noQuotes=%path:"=%
        set pathWithFolderName=%noQuotes%

        cls
        echo %pathWithFolderName%
        if exist HM2-Mod_Manager (

            cd HM2-Mod_Manager
            echo %pathWithFolderName% > path_to_backup.dat
            echo %NORMAL%Set the path to the Backup's folder

        ) else (

            mkdir HM2-Mod_Manager
            cd HM2-Mod_Manager
            echo %pathWithFolderName% > path_to_backup.dat
            echo Set the path to the Backup's folder

        )
        echo.
        pause

    exit /b

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

    echo Game's folder path: %UNDERLINE%%pathToFolder%%NORMAL%
    echo Backup's folder path: %UNDERLINE%%pathToBackup%%NORMAL%

:end_settings
exit /b

:settings_click

    call :checks
    if "%quit%" == "yes" exit /b 1

    cls
    echo %BOLD%1%NORMAL%.  Shows all paths
    echo.
    echo %BOLD%2%NORMAL%.  Opens up the settings' folder via Finder
    echo.
    echo %BOLD%b%NORMAL% to go back
    echo %BOLD%q%NORMAL% to quit
    echo.

    set /p answer="Choose an option: %BOLD%"

    if "%answer%" == "" goto :settings_click
    if "%answer%" == "1" call :show_paths
    if "%answer%" == "2" call :open_explorer
    if "%answer%" == "q" exit /b
    if "%answer%" == "b" goto :help_click
    goto :settings_click


    :show_paths

        cls
        set /p pathToFolder=<%appdata%\HM2-Mod_Manager\path_to_game_folder.dat
        set /p pathToBackup=<%appdata%\HM2-Mod_Manager\path_to_backup.dat

        echo %NORMAL%Game's folder path: %UNDERLINE%%pathToFolder%%NORMAL%
        echo Backup's folder path: %UNDERLINE%%pathToBackup%%NORMAL%
        echo.
        pause

    exit /b

    :open_explorer

        cls
        cd %appdata%

        if not exist HM2-Mod_Manager mkdir HM2-Mod_Manager
        echo %NORMAL%Starting Explorer...
        start "explorer.exe" HM2-Mod_Manager
        echo Opened Explorer
        echo.
        pause

    exit /b

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

        @REM Looks for the installation path of either WinRAR or 7zip
        @REM and sets it for the script inside the PATH variable
        call :set_unrar-7z_path


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


                ) || echo Couldn't find neither %RED%unRAR.exe%NORMAL% or %RED%7z.exe%NORMAL% & exit /b

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
                powershell -Command "(New-Object System.Net.WebClient).DownloadFile(!link!, ((Get-Location).path + '.\%fileName%'))" || ( 
                    echo %RED%URL%NORMAL% could be wrong & exit /b
                )

                echo Extracting...
                powershell -Command "Expand-Archive -Path .\%fileName% -DestinationPath .\fromURL" || echo Couldn't extract the zip file & exit /b
                cd fromURL

            ) || powershell -Command %fileName% | find ".rar" && (

                echo Downloading...
                powershell -Command "(New-Object System.Net.WebClient).DownloadFile(!link!, ((Get-Location).path + '.\%fileName%'))" || ( 
                    echo %RED%URL%NORMAL% could be wrong & exit /b
                )

                echo Extracting...
                where unrar >nul 2>nul && (


                    dir "%fileName%" >nul 2>nul && (

                        unrar x "%fileName%" "%cd%"\fromURL\ >nul 2>nul || echo Couldn't extract the rar file & exit /b

                    ) || echo Couldn't find the rar file or the path is incorrect & exit /b


                ) || where 7z >nul 2>nul && (


                    dir "%fileName%" >nul 2>nul && (

                        7z x "%fileName%" -o"fromURL" >nul 2>nul || echo Couldn't extract the rar file & exit /b

                    ) || echo Couldn't find the rar file or the path is incorrect & exit /b


                ) || echo Couldn't find neither %RED%unRAR.exe%NORMAL% or %RED%7z.exe%NORMAL% & exit /b

                cd fromURL

            ) || (

                echo Downloading...
                powershell -Command "(New-Object System.Net.WebClient).DownloadFile(!link!, ((Get-Location).path + '.\%fileName%'))" || ( 
                    echo %RED%URL%NORMAL% could be wrong & exit /b
                )

            )

        )
        
        @REM Need to figure out ------ ! --------
        powershell -Command "'%2' -cmatch '(http|https):\/\/'" | find "True" >nul && (

            cd /d %temp%\!nameOfFolderForExtraction!

            :URL_confirmation
            echo %YELLOW%%2%NORMAL%
            echo Are you sure that this link is a direct download to a:
            echo -%RED%Patchwad%NORMAL% file
            echo -%RED%Wad%NORMAL% file
            echo -%RED%Zip%NORMAL% file
            echo -%RED%Rar%NORMAL% file
            echo.

            set /p answer="(Yes|No): "

            powershell -Command "'!answer!' -cmatch 'y|Y'" | find "True" >nul && (

                powershell -Command "package | findstr '7Zip4Powershell'" >nul && (

                    :start_extraction
                    echo yes
                    exit /b

                ) || (

                    echo A powershell module is needed for this type of use of the parameter
                    echo Do you want to install it?

                    choice

                    if %errorlevel% == 1 (

                        echo Installng the module %UNDERLINE%%BOLD%7Zip4Powershell%NORMAL%
                        powershell -Command "Install-Module -Name 7Zip4Powershell -Scope CurrentUser"

                        goto :start_extraction

                    ) else exit /b

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


    :current_directory
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
    if defined restartGame call :restart_game

    echo %cmdcmdline% | find /i """%~f0""" >nul && (
        echo.
        pause
    )

exit /b

:install_click

    call :checks
    if "%quit%" == "yes" exit /b 1


    @REM Prevents a permanent freeze of the screen or breaking of the game
    tasklist | find "HotlineMiami2.exe" >nul && (

        set restartGame=true
        timeout /NOBREAK /T 5
        taskkill /IM "HotlineMiami2.exe"

    )

    cls
    echo %BOLD%1%NORMAL%. Installs from %BOLD%current directory%NORMAL%
    echo.
    echo %BOLD%2%NORMAL%. Installs from an %BOLD%archive%NORMAL%:
    echo       To use it, paste in the %UNDERLINE%path%NORMAL% after being prompted
    echo.
    echo %BOLD%3%NORMAL%. Installs from an %BOLD%URL%NORMAL%:
    echo       To use it, paste in the %UNDERLINE%URL%NORMAL% after being prompted
    echo.
    echo %BOLD%b%NORMAL% to go back
    echo %BOLD%q%NORMAL% to quit
    echo.

    set /p answer="Choose an option: %BOLD%"

    if "%answer%" == "" goto :install_click
    if "%answer%" == "1" cls & goto :current_directory
    if "%answer%" == "2" (

        set /p answer2="%NORMAL%Insert the path: %BOLD%"

        set removedQuotes_archive=!answer2:"=!
        dir "!removedQuotes_archive!" >nul 2>nul && goto :install_click_installation_archive || (
            cls
            echo %RED%!answer2!%NORMAL% is not a valid archive
            echo.
            pause
            goto :install_click
        )

    )
    if "%answer%" == "3" (

        set /p answer2="%NORMAL%Insert the path: %BOLD%"

        set removedQuotes_URL=!answer2:"=!
        goto :install_click_installation_URL

    )
    if "%answer%" == "q" exit /b
    if "%answer%" == "b" goto :help_click
    goto :install_click


    :install_click_installation_URL

        @REM Looks for the installation path of either WinRAR or 7zip
        @REM and sets it for the script inside the PATH variable
        call :set_unrar-7z_path


        set nameOfFolderForExtraction=HM2-Mod_Manager

        @REM Creates the temporary folder if it doesn't exist then 
        @REM it cleans the temporary folder if it has content inside it
        dir "%temp%\!nameOfFolderForExtraction!" >nul 2>nul || mkdir %temp%\!nameOfFolderForExtraction!

        for /f "delims=" %%A in ('dir /b %temp%\!nameOfFolderForExtraction!') do (

            rmdir /q /s %temp%\!nameOfFolderForExtraction!
            mkdir %temp%\!nameOfFolderForExtraction!

        )


        @REM Direct download from the terminal
        echo "!removedQuotes_URL!" | find "https://www.dropbox.com" >nul && (

            cd /d %temp%\!nameOfFolderForExtraction!
            set "link='!removedQuotes_URL!'.Replace('?dl', '?dl=1')"

            @REM Checks the file extension
            echo Checking the file to download...

            set getContentDisposition="[Net.HttpWebRequest]::Create(!link!).GetResponse().Headers['Content-Disposition']"
            powershell -Command !getContentDisposition! > %temp%\temp.dat

            set /p contentDisposition=<%temp%\temp.dat
            set fileName=[Regex]::Match('!contentDisposition!', 'filename="(.*)"').Groups[1].Value -replace '; .*'
            @REM -------------------------------------------------------------------------------------------------------------------


            powershell -Command %fileName% | find ".zip" && (

                echo Downloading...
                powershell -Command "(New-Object System.Net.WebClient).DownloadFile(!link!, ((Get-Location).path + '.\%fileName%'))" || ( 
                    echo %RED%URL%NORMAL% could be wrong & exit /b
                )

                echo Extracting...
                powershell -Command "Expand-Archive -Path .\%fileName% -DestinationPath .\fromURL" || echo Couldn't extract the zip file & exit /b
                cd fromURL

            ) || powershell -Command %fileName% | find ".rar" && (

                echo Downloading...
                powershell -Command "(New-Object System.Net.WebClient).DownloadFile(!link!, ((Get-Location).path + '.\%fileName%'))" || ( 
                    echo %RED%URL%NORMAL% could be wrong & exit /b
                )

                echo Extracting...
                where unrar >nul 2>nul && (


                    dir "%fileName%" >nul 2>nul && (

                        unrar x "%fileName%" "%cd%"\fromURL\ >nul 2>nul || echo Couldn't extract the rar file & exit /b

                    ) || echo Couldn't find the rar file or the path is incorrect & exit /b


                ) || where 7z >nul 2>nul && (


                    dir "%fileName%" >nul 2>nul && (

                        7z x "%fileName%" -o"fromURL" >nul 2>nul || echo Couldn't extract the rar file & exit /b

                    ) || echo Couldn't find the rar file or the path is incorrect & exit /b


                ) || echo Couldn't find neither %RED%unRAR.exe%NORMAL% or %RED%7z.exe%NORMAL% & exit /b

                cd fromURL

            ) || (

                echo Downloading...
                powershell -Command "(New-Object System.Net.WebClient).DownloadFile(!link!, ((Get-Location).path + '.\%fileName%'))" || ( 
                    echo %RED%URL%NORMAL% could be wrong & exit /b
                )

            )

        )
        
        @REM Need to figure out ------ ! --------
        powershell -Command "'!removedQuotes_URL!' -cmatch '(http|https):\/\/'" | find "True" >nul && (

            cd /d %temp%\!nameOfFolderForExtraction!

            :URL_confirmation
            echo %YELLOW%!removedQuotes_URL!%NORMAL%
            echo Are you sure that this link is a direct download to a:
            echo -%RED%Patchwad%NORMAL% file
            echo -%RED%Wad%NORMAL% file
            echo -%RED%Zip%NORMAL% file
            echo -%RED%Rar%NORMAL% file
            echo.

            set /p answer="(Yes|No): "

            powershell -Command "'!answer!' -cmatch 'y|Y'" | find "True" >nul && (

                powershell -Command "package | findstr '7Zip4Powershell'" >nul && (

                    :start_extraction
                    echo yes
                    exit /b

                ) || (

                    echo A powershell module is needed for this type of use of the parameter
                    echo Do you want to install it?

                    choice

                    if %errorlevel% == 1 (

                        echo Installng the module %UNDERLINE%%BOLD%7Zip4Powershell%NORMAL%
                        powershell -Command "Install-Module -Name 7Zip4Powershell -Scope CurrentUser"

                        goto :start_extraction

                    ) else exit /b

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

        goto :current_directory

    exit /b

    :install_click_installation_archive

        @REM Looks for the installation path of either WinRAR or 7zip
        @REM and sets it for the script inside the PATH variable
        call :set_unrar-7z_path


        set nameOfFolderForExtraction=HM2-Mod_Manager

        @REM Creates the temporary folder if it doesn't exist then 
        @REM it cleans the temporary folder if it has content inside it
        dir "%temp%\!nameOfFolderForExtraction!" >nul 2>nul || mkdir %temp%\!nameOfFolderForExtraction!

        for /f "delims=" %%A in ('dir /b %temp%\!nameOfFolderForExtraction!') do (

            rmdir /q /s %temp%\!nameOfFolderForExtraction!
            mkdir %temp%\!nameOfFolderForExtraction!

        )


        @REM Extraction of a zip file from the terminal
        echo "!removedQuotes_archive!" | find ".zip" >nul && (

            powershell -Command "Expand-Archive -Path %3 -DestinationPath ($env:TEMP + '\!nameOfFolderForExtraction!\')" 2>nul || echo Couldn't extract the zip file & exit /b
            cd /d %temp%\!nameOfFolderForExtraction!

        ) || echo "!removedQuotes_archive!" | find ".rar" >nul && (

            where unrar >nul 2>nul && (

                unrar x "!removedQuotes_archive!" "%TEMP%"\!nameOfFolderForExtraction!\ >nul 2>nul || echo Couldn't extract the rar file & exit /b
                cd /d %temp%\!nameOfFolderForExtraction!

            ) || where 7z >nul 2>nul && (

                7z x "!removedQuotes_archive!" -o"%TEMP%"\!nameOfFolderForExtraction!\ >nul 2>nul || echo Couldn't extract the rar file & exit /b
                cd /d %temp%\!nameOfFolderForExtraction!

            ) || echo Couldn't find neither %RED%unRAR.exe%NORMAL% or %RED%7z.exe%NORMAL% & exit /b

        )

        goto :current_directory

    exit /b

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
            echo %NORMAL%Moved the modded music to the current folder


            @REM Goes to pick up the backup of the default music 
            @REM and puts it inside the game's folder 
            cd /d %pathToBackup%
            echo Copying the backup inside the game's folder...
            copy /y hlm2_music_desktop.wad %pathToFolder% >nul

        )

    )

    echo.
    echo Finished uninstalling

    if defined restartGame call :restart_game

    echo %cmdcmdline% | find /i """%~f0""" >nul && (
        echo.
        pause
    )

exit /b


:checks

    if not exist %appdata%\HM2-Mod_Manager\path_to_game_folder.dat (

        if not exist %appdata%\HM2-Mod_Manager\path_to_backup.dat (

            echo %RED%The paths are missing
            echo You need to create them first%NORMAL%
            goto :end

        )

    )

    if not exist %appdata%\HM2-Mod_Manager\path_to_game_folder.dat (

        echo %RED%The path to the game's folder is missing
        echo You need to create it first%NORMAL%
        goto :end

    )

    if not exist %appdata%\HM2-Mod_Manager\path_to_backup.dat (

        echo %RED%The path to the backup is missing
        echo You need to create it first%NORMAL%
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

:restart_game

    @REM Runs the game through Steam if it finds Steam and 
    @REM if inside the game's folder it finds the dll file of the Steam's API
    @REM otherwise it runs it like normal
    reg query HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Valve\Steam /v InstallPath >nul 2>nul && (

        dir %pathToFolder%\steam_api.dll >nul 2>nul && (

            start steam://rungameid/274170
            exit /b

        )

    ) || %pathToFolder%\HotlineMiami2.exe

exit /b