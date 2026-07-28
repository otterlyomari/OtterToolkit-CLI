#Requires -Version 7.0

<#
.SYNOPSIS
OtterToolkit settings manager.
#>


$ConfigDirectory =
Join-Path `
    $PSScriptRoot `
    "..\..\Config"


$SettingsPath =
Join-Path `
    $ConfigDirectory `
    "Settings.json"



function Initialize-ToolkitSettings {


    if (-not (Test-Path $ConfigDirectory)) {

        New-Item `
            -Path $ConfigDirectory `
            -ItemType Directory |
        Out-Null

    }


    if (-not (Test-Path $SettingsPath)) {


        @{
            FirstRunComplete = $false

            Version = "0.2.0-beta"


            Appearance = @{
                Theme = "Default"
                AccentColor = "Cyan"
                Animations = $true
            }


            Accessibility = @{
                HighContrast = $false
                ReduceMotion = $false
                ShowDescriptions = $true
            }


            Interface = @{
                ConfirmActions = $true
                CompactMenus = $false
                RememberPosition = true
                PageSize = 10
            }

        } |
        ConvertTo-Json |
        Set-Content `
            -Path $SettingsPath

    }


}



function Get-ToolkitSettings {


    Initialize-ToolkitSettings


    return (
        Get-Content `
            -Path $SettingsPath `
            -Raw |
        ConvertFrom-Json
    )

}



function Set-ToolkitSetting {

param(
    [Parameter(Mandatory)]
    [string]
    $Name,

    [Parameter(Mandatory)]
    $Value
)


$Settings =
    Get-ToolkitSettings


$Parts =
    $Name.Split(".")


$Target =
    $Settings


for (
    $i = 0;
    $i -lt ($Parts.Count - 1);
    $i++
) {

    if (
        -not $Target.($Parts[$i])
    ) {

        $Target |
        Add-Member `
        -MemberType NoteProperty `
        -Name $Parts[$i] `
        -Value ([PSCustomObject]@{}) `
        -Force

    }


    $Target =
        $Target.($Parts[$i])

}


$Target |
Add-Member `
-MemberType NoteProperty `
-Name $Parts[-1] `
-Value $Value `
-Force



$Settings |
ConvertTo-Json -Depth 5 |
Set-Content `
$SettingsPath

}

function Export-ToolkitSettings {

param(
    [string]
    $Path
)

$Settings =
    Get-ToolkitSettings


$Settings |
ConvertTo-Json -Depth 5 |
Set-Content `
    -Path $Path
}

function Import-ToolkitSettings {

param(
    [string]
    $Path
)


if (-not (Test-Path $Path)) {

    throw "Settings file not found."

}


$Imported =
    Get-Content `
        -Path $Path `
        -Raw |
    ConvertFrom-Json



$Imported |
ConvertTo-Json -Depth 5 |
Set-Content `
    -Path $SettingsPath

}

function Get-DefaultToolkitSettings {

return @{
    FirstRunComplete = $false

    Version = "0.2.0-beta"


    Appearance = @{
        Theme = "Default"
        AccentColor = "Cyan"
        Animations = $true
    }


    Accessibility = @{
        HighContrast = $false
        ReduceMotion = $false
        ShowDescriptions = $true
        VerboseOutput = $false
    }


    Interface = @{
        ConfirmActions = $true
        CompactMenus = $false
        RememberPosition = true
        PageSize = 10
    }

}

}

function Reset-ToolkitSettings {


$Defaults =
    Get-DefaultToolkitSettings



$Defaults |
ConvertTo-Json -Depth 5 |
Set-Content `
    -Path $SettingsPath


}

Export-ModuleMember `
-Function *