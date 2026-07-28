#Requires -Version 7.0

$CorePath = Join-Path $PSScriptRoot "..\Core\Tweaks.Core.psm1"
$HWPath   = Join-Path $PSScriptRoot "..\Core\Hardware.Core.psm1"
$UIPath   = Join-Path $PSScriptRoot "Tweaks.UI.psm1"

Import-Module (Resolve-Path $CorePath) -Force
Import-Module (Resolve-Path $HWPath) -Force

$script:RestartWarningShown = $false


function Start-TweaksManager {

    while ($true) {

        $Categories = Get-ToolkitTweaks

        $Options = [ordered]@{}

        $Index = 1

        foreach ($Category in $Categories) {

            $Options["$Index"] = $Category.Name
            $Index++

        }

        $Options["$Index"] = "Back"

        $Choice = Show-ToolkitMenu `
            -Title "Windows Tweaks" `
            -Options $Options


        if (
            $Choice -eq "$Index" -or
            $Choice -eq "Exit"
        ) {
            break
        }


        if ($Choice -match '^\d+$') {

            Show-TweakCategory `
                -Category $Categories[[int]$Choice - 1]

        }

    }


    if (
        (Test-ToolkitRestartRequired) -and
        (-not $script:RestartWarningShown)
    ) {

        Clear-Host

        Write-Host ""
        Write-Host "================================="
        Write-Host "⚠ Restart Required"
        Write-Host "================================="
        Write-Host ""

        Write-Host "Some changes require a Windows restart."

        Pause

        $script:RestartWarningShown = $true

    }

}


function Show-TweakCategory {

    param(
        $Category
    )


    $Tweaks = $Category.Tweaks

    $PageSize =
    (Get-ToolkitSettings).Interface.PageSize
    $Page = 1


    while ($true) {

        $TotalPages = [Math]::Ceiling(
            $Tweaks.Count / $PageSize
        )


        $StartIndex = ($Page - 1) * $PageSize


        $PageTweaks = $Tweaks |
            Select-Object `
                -Skip $StartIndex `
                -First $PageSize


        $Options = [ordered]@{}

        $Index = 1


        foreach ($Tweak in $PageTweaks) {

            $Status = Get-ToolkitTweakStatus `
                -Name $Tweak.Name


            $Indicator = if ($Status -eq "Enabled") {
                "[✓]"
            }
            else {
                "[ ]"
            }


            $Options["$Index"] =
                "$Indicator $($Tweak.Name)"

            $Index++

        }


        $PreviousIndex = $null
        $NextIndex = $null


        if ($Page -gt 1) {

            $PreviousIndex = $Index
            $Options["$Index"] = "Previous Page"
            $Index++

        }


        if ($Page -lt $TotalPages) {

            $NextIndex = $Index
            $Options["$Index"] = "Next Page"
            $Index++

        }


        $BackIndex = $Index
        $Options["$Index"] = "Back"


        $Choice = Show-ToolkitMenu `
            -Title "$($Category.Name) Tweaks (Page $Page/$TotalPages)" `
            -Options $Options



        if (
            $Choice -eq "$BackIndex" -or
            $Choice -eq "Exit"
        ) {

            break

        }


        if (
            $PreviousIndex -and
            $Choice -eq "$PreviousIndex"
        ) {

            $Page--
            continue

        }


        if (
            $NextIndex -and
            $Choice -eq "$NextIndex"
        ) {

            $Page++
            continue

        }


        if ($Choice -match '^\d+$') {

            $SelectedIndex =
                $StartIndex + ([int]$Choice - 1)


            Show-TweakDetails `
                -Tweak $Tweaks[$SelectedIndex] `
                -Category $Category

        }

    }

}


function Show-TweakDetails {

    param(
        $Tweak,
        $Category
    )


    Clear-Host


    Write-Host ""
    Write-Host "================================="
    Write-Host "              Tweak"
    Write-Host "================================="
    Write-Host ""


    Write-Host ("Name: {0}" -f $Tweak.Name)


$Settings =
Get-ToolkitSettings


if (
    $Tweak.Description -and
    $Settings.Accessibility.ShowDescriptions
){

    Write-Host (
        "Description: {0}" -f
        $Tweak.Description
    )

}


    $Status = Get-ToolkitTweakStatus `
        -Name $Tweak.Name


    Write-Host ""
    Write-Host ("Status: {0}" -f $Status)


    $Reversible = if ($Tweak.UndoActions) {
        "Yes"
    }
    else {
        "No"
    }


    Write-Host ("Reversible: {0}" -f $Reversible)


    $RestartRequired = if ($Tweak.RestartRequired) {
        "Yes"
    }
    else {
        "No"
    }


    Write-Host ("Restart Required: {0}" -f $RestartRequired)

    Write-Host ""


    if (
        $Status -eq "Enabled" -and
        $Tweak.UndoActions
    ) {

        $Confirm = Read-Host "Undo this tweak? (Y/N)"

        if ($Confirm -match '^[Yy]$') {

            Invoke-ToolkitTweakUndo `
                -Name $Tweak.Name


            Write-ToolkitSuccess "Rollback complete."

        }

    }
    else {

        $Confirm = Read-Host "Apply this tweak? (Y/N)"

        if ($Confirm -match '^[Yy]$') {

            Invoke-ToolkitTweak `
                -Name $Tweak.Name


            Write-ToolkitSuccess "Tweak applied."

        }

    }


    Pause

}


Export-ModuleMember -Function *