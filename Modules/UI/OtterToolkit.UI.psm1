#Requires -Version 7.0

<#
.SYNOPSIS
OtterToolkit terminal UI framework.
#>


#region Display


function Show-ToolkitHeader {

    Clear-Host

    Write-Host ""
    Write-Host "================================="
    Write-Host "          OtterToolkit"
    Write-Host "================================="
    Write-Host ""

}



function Show-ToolkitFooter {

    Write-Host ""
    Write-Host "---------------------------------"
    Write-Host "↑ ↓ Navigate   ENTER Select"
    Write-Host "Q Quit / ESC Back"
    Write-Host ""

}

function Show-OtterDashboard {

    
$Settings =
    Get-ToolkitSettings


if (
    $Settings.FirstRunComplete
){

    return

}



Clear-Host


Write-Host ""
Write-Host "================================="
Write-Host "        Welcome to OtterToolkit"
Write-Host "================================="
Write-Host ""

Write-Host "Preparing your system..."

Write-Host ""

$Hardware =
    Get-ToolkitHardwareSummary



Write-Host "Hardware Detection:"
Write-Host ""


foreach ($GPU in $Hardware.GPU) {

    Write-Host (
        "✓ GPU: {0}" -f
        $GPU.Name
    )

}


Write-Host (
"✓ CPU: {0}" -f
$Hardware.CPU.Name
)


Write-Host (
"✓ RAM: {0} GB" -f
$Hardware.RAM_GB
)



Write-Host ""


Write-Host "Loading Tweaks:"


$Categories =
    Get-ToolkitTweaks


foreach ($Category in $Categories) {

    Write-Host (
        "✓ {0}" -f
        $Category.Name
    )

}



Write-Host ""

Read-Host `
"Press Enter to continue"



Set-ToolkitSetting `
    -Name "FirstRunComplete" `
    -Value $true

}



function Show-OtterExitAnimation {

    Clear-Host

    Write-Host ""
    Write-Host "Closing OtterToolkit..."
    Write-Host ""

    $Frames = @("|", "/", "-", "\")

    $EndTime = (Get-Date).AddSeconds(2)

    $Index = 0

    while ((Get-Date) -lt $EndTime) {

        Write-Host -NoNewline "`rGoodbye! $($Frames[$Index])"

        $Index = ($Index + 1) % $Frames.Count

        $Settings =
Get-ToolkitSettings


if (
    $Settings.Appearance.Animations -and
    -not $Settings.Accessibility.ReduceMotion
){

    Start-Sleep `
    -Milliseconds 100

}
    }

    Write-Host -NoNewline "`rGoodbye! Done!      "
    Write-Host ""

    $Settings =
Get-ToolkitSettings


if (
    $Settings.Appearance.Animations -and
    -not $Settings.Accessibility.ReduceMotion
){

    Start-Sleep `
    -Milliseconds 100

}
    Clear-Host

    exit
}


#endregion

#region Helpers
function Get-ToolkitUISettings {

    return Get-ToolkitSettings

}

function Get-ToolkitThemeColor {

$Settings =
    Get-ToolkitUISettings


switch (
    $Settings.Appearance.AccentColor
){

    "Cyan" {

        return "Cyan"

    }


    "Green" {

        return "Green"

    }


    "Purple" {

        return "Magenta"

    }


    "Red" {

        return "Red"

    }


    default {

        return "Cyan"

    }

}

}

#endregion

#region Interactive Menu


function Show-ToolkitMenu {


param(

    [Parameter(Mandatory)]
    [string]
    $Title,


    [Parameter(Mandatory)]
    [hashtable]
    $Options

)



$Items =
    $Options.Keys |
    Sort-Object |
    ForEach-Object {

        [PSCustomObject]@{

            Key = $_

            Value =
                $Options[$_]

        }

    }



$Index = 0



while ($true) {


    Show-ToolkitHeader


    Write-Host $Title
    Write-Host ""



    for (
        $i = 0;
        $i -lt $Items.Count;
        $i++
    ) {


        if (
            $i -eq $Index
        ) {


            Write-Host `
                "> $($Items[$i].Value)"


        }

        else {


            Write-Host `
                "  $($Items[$i].Value)"


        }


    }



    Show-ToolkitFooter



    $Key =
        [Console]::ReadKey($true)



    switch (
        $Key.Key
    ) {



        "UpArrow" {


            $Index--


            if (
                $Index -lt 0
            ) {

                $Index =
                    $Items.Count - 1

            }


        }



        "DownArrow" {


            $Index++


            if (
                $Index -ge $Items.Count
            ) {

                $Index = 0

            }


        }



        "Enter" {


            return (
                $Items[$Index].Key
            )


        }



        "Escape" {


            return "Back"


        }



        "Q" {

            return "Exit"


        }


    }


}



}


#endregion



#region Confirmation


function Confirm-ToolkitAction {


param(

    [Parameter(Mandatory)]
    [string]
    $Message

)



Write-Host ""
Write-Host $Message
Write-Host ""



$key =
    [Console]::ReadKey()



return (
    $key.Key -eq "Y"
)


}



#endregion



Export-ModuleMember `
    -Function *