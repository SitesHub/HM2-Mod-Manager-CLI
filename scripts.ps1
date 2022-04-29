<#

    .SYNOPSIS
        A function that returns DropBox's Content-Disposition

    .DESCRIPTION
        The function gets a response header from DropBox and then it parses and returns it using regex.

    .LINK
        The public github repository:
            https://github.com/SitesHub/HM2-Mod-Manager-CLI 

    .PARAMETER link
        The link from where the request points to.

    .EXAMPLE
        dropbox_File_check https://www.dropbox.com/sh/6u7k9rzna6ehssx/AABlJrG2f-SyEoTF8n60QBL0a?dl

#>

function dropbox_File_check {

    param (
        [Parameter(Mandatory)] [string]$link
    )

    [string]$fixedLink = $link.Replace('?dl', '?dl=1')
    [System.Object]$response = [Net.HttpWebRequest]::Create($fixedLink).GetResponse()
    [string]$contentDisposition = $response.Headers['Content-Disposition']

    [string]$result_of_regex = [Regex]::Match($contentDisposition, 'filename="(.*)"').Groups[1].Value -replace '; .*'

    Write-Output $result_of_regex
	
}


<#

    .SYNOPSIS
        A function that downloads a file from an url

    .DESCRIPTION
        The function needs a link, a path to the output file and 
        the name of the file in order to download it to the pc.

    .LINK
        The public github repository:
            https://github.com/SitesHub/HM2-Mod-Manager-CLI 

    .PARAMETER link
        The link from where the request points to.

    .PARAMETER pathToFile
        The destination of the output file.

    .PARAMETER fileName
        The name of the output file.

    .EXAMPLE
        getFileFromURL https://www.dropbox.com/sh/6u7k9rzna6ehssx/AABlJrG2f-SyEoTF8n60QBL0a?dl C:\Users\joe\Downloads joe_file.txt

#>
function getFileFromURL {

    param (
        [Parameter(Mandatory)] [string]$link,
        [Parameter(Mandatory)] [string]$pathToFile,
        [Parameter(Mandatory)] [string]$fileName
    )

    [string]$fixedLink = $link.Replace('?dl', '?dl=1')
    [System.Object]$webClient_Obj = (New-Object System.Net.WebClient)
    
    $webClient_Obj.DownloadFile($fixedLink, ($pathToFile + $fileName))

}


<#

    .SYNOPSIS
        A function that extracts an archive from a path to another location

    .DESCRIPTION
        The function extracts the contents of the archive inside a path
        specified by the user, inside a folder named 'fromURL'.

    .LINK
        The public github repository:
            https://github.com/SitesHub/HM2-Mod-Manager-CLI 

    .PARAMETER pathToFile
        The path that directs to the input file.

    .PARAMETER fileName
        The name of the input file.

    .EXAMPLE
        extractFile C:\Users\joe\Downloads joe_file.txt

#>
function extractFile {

    param (
        [Parameter(Mandatory)] [string]$pathToFile,
        [Parameter(Mandatory)] [string]$fileName
    )

    Expand-Archive -Path $pathToFile'\'$fileName -DestinationPath $pathToFile'\fromURL'

}



<#

    .SYNOPSIS
        A function that extracts an archive from a path to another location

    .DESCRIPTION
        The function extracts the contents of the archive inside 
        the temporary folder (TEMP) with the specified name the user gave.

    .LINK
        The public github repository:
            https://github.com/SitesHub/HM2-Mod-Manager-CLI 

    .PARAMETER fileName
        The path and name combined of the input file.
        
    .PARAMETER nameOfFolderForExtraction
        The custom name of the folder inside the temporary folder.

    .EXAMPLE
        extractFromArchive C:\Users\joe\Downloads\joe_file.rar Custom-Folder-Name

#>
function extractFromArchive {

    param (
        [Parameter(Mandatory)] [string]$fileName,
        [Parameter(Mandatory)] [string]$nameOfFolderForExtraction
    )

    [string]$destination = ($env:TEMP + "\$nameOfFolderForExtraction\")

    Expand-Archive -Path $fileName -DestinationPath $destination

}


<#

    .SYNOPSIS
        A function that does a regex match against a string

    .DESCRIPTION
        The function extracts the contents of the archive inside 
        the temporary folder (TEMP) with the specified name the user gave.

    .LINK
        The public github repository:
            https://github.com/SitesHub/HM2-Mod-Manager-CLI 

    .PARAMETER thingToMatch
        The string needed to match.
        
    .PARAMETER regexPattern
        The regex pattern needed to match.

    .EXAMPLE
        regexMatch 'string' 'pattern'

#>
function regexMatch {

    param (
        [Parameter(Mandatory)] [string]$thingToMatch,
        [Parameter(Mandatory)] [string]$regexPattern
    )

    "$thingToMatch" -cmatch "$regexPattern"

}


<#

    .SYNOPSIS
        A function that spawns the windows selection tool for folders and gets its path

    .DESCRIPTION
        The function prompts for a folder to be selected and 
        then it restitutes the path of that selected folder.

    .LINK
        The public github repository:
            https://github.com/SitesHub/HM2-Mod-Manager-CLI 

    .EXAMPLE
        getPathFromWindowsFolderBrowser

#>
function getPathFromWindowsFolderBrowser {

    [System.__ComObject]$sysObj = (new-object -COM 'Shell.Application')
    [System.__ComObject]$wsBrowserFolderSelfObj = $sysObj.BrowseForFolder(0, 'Please choose a folder', 0, 0).Self
    [string]$path = $wsBrowserFolderSelfObj.Path

    if ([string]$wsBrowserFolderSelfObj.isFolder -eq $true) {

        Write-Output $path

    }

}


<#

    .SYNOPSIS
        A function that inside it can do different operations around 7Zip4Powershell

    .DESCRIPTION
        The function accepts a string operation and if it matches,
        it runs the 7Zip4Powershell related task.

    .LINK
        The public github repository:
            https://github.com/SitesHub/HM2-Mod-Manager-CLI 

    .EXAMPLE
        HM2_Mod_Manager_7Zip4Powershell 'checkLocalPackageAvailability'

#>
function HM2_Mod_Manager_7Zip4Powershell {

    param (
        [Parameter(Mandatory)] [string]$operation,
        [string]$pathToArchive,
        [string]$targetPathForArchive
    )

    switch ([string]$operation) {

        ([string]'checkAvailability') { 
            Get-Package | findstr '7Zip4Powershell'
            break
        }

        ([string]'install') {
            Install-Module -Name 7Zip4Powershell -Scope CurrentUser
            break
        }

        ([string]'checkArchive') {

            # Checks if it's a supported format
            try {
                Write-Output (Get-7ZipInformation -ArchiveFileName $pathToArchive).Format
            }
            catch [SevenZip.SevenZipArchiveException] {
                Write-Output "Error: Invalid archive: open/read error! Might be a not supported archive file name extension"
            }
            catch [System.ArgumentException] {
                Write-Output "Error: Not a supported archive file name extension"
            }
            catch {
                Write-Output "Error: Not an archive or not a supported type of format"
            }

            break

        }

        ([string]'extractArchive') {
            [string]$correctPathToArchive = ($pathToArchive).Replace('"', "\")
            Expand-7Zip -ArchiveFileName $correctPathToArchive -TargetPath $targetPathForArchive
            break
        }

        
        Default {
            Write-Error -Exception "Missing Operation, pick from one of these operations: `
                                  -checkAvailability; `
                                  -install; `
                                  -checkArchive; `
                                  -extractArchive;" -Category 'InvalidArgument'
        }

    }
    
}


<#

    .SYNOPSIS
        A function that gets the value of an option inside options.ini

    .DESCRIPTION
        The function requires the path to options.ini and
        the name of the option to get the value from.

    .LINK
        The public github repository:
            https://github.com/SitesHub/HM2-Mod-Manager-CLI 

    .EXAMPLE
        optionsManager 'path\to\options.ini' 'optionName'

#>
function optionsManager {

    param (
        [Parameter(Mandatory)] [string]$path,
        [Parameter(Mandatory)] [string]$nameOfOption,
        [string]$replacingString
    )

    $fileContents = (Get-Content $path)
    $pattern = "$nameOfOption=([a-z0-9]*)"
    $valueOfOption = [Regex]::Match($fileContents, $pattern).groups[1].value

    if ($null -ne $valueOfOption) {

        $fileContents -replace "$pattern", "$nameOfOption=$replacingString"

    }
    else { Write-Output $valueOfOption }

}