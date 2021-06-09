param (
    [Alias('c')][string]$pCreate,
    [Alias('r')][string]$pRemove,
    [Alias('l')][switch]$pList,
    [Alias('a')][switch]$pAutoStart,
    [Alias('h')][switch]$pHelp,
    [Alias('u')][switch]$pUpdate
)

$teamsPath = "$($Env:LOCALAPPDATA)\Microsoft\Teams"
$taskNamePrefix = "ms-teams-account-"
$accountsFolder = "apps"

function init {
    param(
        $scriptBoundParams
    )

    Write-Host "Microsoft Teams multi account tool v1.0"
    Write-Host "Homepage: https://github.com/gloppr05/ms-teams-multi-account-tool`n"

    if ( -not ( Test-Path -Path $teamsPath ) ) {
        Write-Host "Microsoft teams is not installed."
        exit -1
    }

    if ( $scriptBoundParams.Count -eq 0) {
        Write-Host "No valid parameters found."
        showHelp
        exit -1
    }
}

function createProfile {
    param(
        $profileName,
        $autoStart
    )

    $teamsProfilePath = "$teamsPath\$accountsFolder\$profileName"
    $teamsProfileDownloadsPath = "$teamsProfilePath\Downloads"

    if ( -not ( Test-Path -Path $teamsProfileDownloadsPath ) ) {
        New-Item -ItemType Directory -Path $teamsProfileDownloadsPath | Out-Null
    }

    $currentUserProfile = $Env:USERPROFILE
    $Env:USERPROFILE = $teamsProfilePath
    Invoke-Expression "$teamsPath\Update.exe --processStart Teams.exe"
    $Env:USERPROFILE = $currentUserProfile

    if ( $autoStart ) {
        Write-Host "App is scheduled to automatically start when logging in."
        createTask $profileName
        copyScriptForAutoStart
    }

    Write-Host "OK, app created."
    Write-Host "Please wait a few seconds until the app initializes and the MS Teams welcome window appears." -Fore Black -BackgroundColor darkgray
}

function isProfileExist {
    param(
        $profileName
    )
    
    return (getProfiles | Where-Object {$_.BaseName -eq $profileName} | Measure-Object).Count
}

function removeProfile {
    param(
        $profileName
    )

    if (teamsRunning) {
        Write-Host "MS Teams is runnig. Please close all instances of MS Teams before removing the app."
        exit -1
    }

    if (isProfileExist $profileName) {
        $path = "$teamsPath\$accountsFolder\$profileName"
        Remove-Item -Recurse -Force $path
        removeTask $profileName
        Write-Host "OK, app removed."
        Write-Host "You can restart your existing apps with the command: ./ms-teams-multi-account.ps1 -c <name>"
    }
    else {
        Write-Host "Error, the app cannot be found."
    }
}
function getProfiles {
    $path = "$teamsPath\$accountsFolder"
    if (Test-Path -Path $path) {
        return Get-ChildItem -Path $path | Select-Object BaseName
    }
    return
}

function listProfiles {
    $profiles = getProfiles
    if (($profiles | Measure-Object).Count) {
        Write-Host "Installed Microsoft Teams apps:"
        foreach ($profile in $profiles) { 
            $profile.BaseName
        }
    }
    else {
        Write-Host "No additional Microsoft Teams apps were found."
    }
}

function showHelp {
    Write-Host @"
Use the following arguments. (For more examples check the Github page.)
-c <name> [-a]: create a Teams app
`tExamples:
`t- create an app for your personal account: ./ms-teams-multi-account.ps1 -c personal
`t- create an app for your work account and start it automatically when loggin in to Windows: ./ms-teams-multi-account.ps1 -c work -a
-a: auto start app when loggin in to Windows
-r <name>: remove app
-l: list created app
-h: show this help
"@
}

function createTask {
    param(
        $profileName
    )

    $scriptPath = "$Env:USERPROFILE\$(Split-Path $myInvocation.ScriptName -leaf)"
    removeTask $profileName
    $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "$scriptPath -c $profileName"
    $trigger = New-ScheduledTaskTrigger -AtLogOn -User $(whoami)
    Register-ScheduledTask -TaskName "$taskNamePrefix$profileName" -Action $action -Trigger $trigger | Out-Null
}
function removeTask {
    param(
        $profileName
    )
    Unregister-ScheduledTask -TaskName "$taskNamePrefix$profileName" -ErrorAction SilentlyContinue -Confirm:$false
}

function taskExist {
    param(
        $profileName
    )
    return $(Get-ScheduledTask -TaskName "$taskNamePrefix$profileName" -ErrorAction SilentlyContinue)
}

function copyScriptForAutoStart {
    if ( $Env:USERPROFILE -ne $(Split-Path $myInvocation.ScriptName) ) {
        Copy-Item $myInvocation.ScriptName -Destination $Env:USERPROFILE
    }
}

function teamsRunning {
    return $(Get-Process Teams -ErrorAction SilentlyContinue)
}

function main {
    param(
        $scriptBoundParams
    )

    init $scriptBoundParams
    Foreach ($key in $scriptBoundParams.Keys) {
        if ( $key -eq "pCreate") {
            createProfile $pCreate $scriptBoundParams.ContainsKey('pAutoStart')
            Break
        } elseif ( $key -eq "pRemove") {
            removeProfile $pRemove
            Break
        } elseif ( $key -eq "pList") {
            listProfiles
            Break
        } elseif ( $key -eq "pHelp") {
            showHelp
            Break
        } elseif ( $key -eq "pUpdate") {
            copyScriptForAutoStart
            Write-Host "Script updated for auto start."
            Break
        }
    }

    if ( -not $scriptBoundParams.Keys.Count ) {
        Write-Host "No valid parameters found."
        showHelp
    }
}

main $PSBoundParameters