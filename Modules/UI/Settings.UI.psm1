function Show-ToolkitSettings {

while ($true) {

    $Options =
    [ordered]@{

        "1" = "Appearance"

        "2" = "Accessibility"

        "3" = "Interface"

        "4" = "Export Settings"

        "5" = "Import Settings"

        "6" = "Reset to Defaults"

        "7" = "Back"

    }


    $Choice =
        Show-ToolkitMenu `
            -Title "Settings" `
            -Options $Options



    switch ($Choice) {

        "1" {

            Show-AppearanceSettings

        }


        "2" {

            Show-AccessibilitySettings

        }


        "3" {

            Show-InterfaceSettings

        }


        "4" {

            Export-ToolkitSettings

        }


        "5" {

            Import-ToolkitSettings

        }


        "6" {

            Reset-ToolkitSettings

        }

        "7" {

            return

        }

        "Back" {

            return

        }


        "Exit" {

            return

        }

    }

}

}

function Show-AppearanceSettings {

while ($true) {


$Settings =
    Get-ToolkitSettings


$CurrentTheme =
    $Settings.Appearance.Theme


$CurrentAccent =
    $Settings.Appearance.AccentColor


$Animations =
    $Settings.Appearance.Animations



$Options =
[ordered]@{

    "1" =
    "Theme ($CurrentTheme)"


    "2" =
    "Accent Color ($CurrentAccent)"


    "3" =
    "Animations ($Animations)"


    "4" =
    "Back"

}



$Choice =
    Show-ToolkitMenu `
    -Title "Appearance" `
    -Options $Options



switch ($Choice) {


"1" {

    Show-ThemeSelector

}



"2" {

    Show-AccentSelector

}



"3" {


    $NewValue =
        -not $Animations


    Set-ToolkitSetting `
        -Name "Appearance.Animations" `
        -Value $NewValue


}



"4" {

    return

}

"Back" {

    return

}


"Exit" {

    return

}


}



}


}

function Show-ThemeSelector {


$Options =
[ordered]@{

    "1" = "Default"

    "2" = "Dark"

    "3" = "Light"

    "4" = "Back"

}



$Choice =
    Show-ToolkitMenu `
    -Title "Select Theme" `
    -Options $Options



switch ($Choice) {


"1" {

    Set-ToolkitSetting `
    -Name "Appearance.Theme" `
    -Value "Default"

}


"2" {

    Set-ToolkitSetting `
    -Name "Appearance.Theme" `
    -Value "Dark"

}


"3" {

    Set-ToolkitSetting `
    -Name "Appearance.Theme" `
    -Value "Light"

}

"4" {
    return
}

"Back" {

    return

}


"Exit" {

    return

}

}


}

function Show-AccentSelector {


$Options =
[ordered]@{

    "1" = "Cyan"

    "2" = "Green"

    "3" = "Purple"

    "4" = "Red"

    "5" = "Back"

}



$Choice =
    Show-ToolkitMenu `
    -Title "Accent Color" `
    -Options $Options



$Colors =
@{

    "1" = "Cyan"

    "2" = "Green"

    "3" = "Purple"

    "4" = "Red"

}

if (
    $Choice -eq "5" -or
    $Choice -eq "Back" -or
    $Choice -eq "Exit"
) {

    return

}

if ($Colors.ContainsKey($Choice)) {


    Set-ToolkitSetting `
    -Name "Appearance.AccentColor" `
    -Value $Colors[$Choice]


}


}

function Show-AccessibilitySettings {

while ($true) {


$Settings =
    Get-ToolkitSettings


$Options =
[ordered]@{


    "1" =
    "High Contrast ($($Settings.Accessibility.HighContrast))"


    "2" =
    "Reduce Motion ($($Settings.Accessibility.ReduceMotion))"


    "3" =
    "Show Descriptions ($($Settings.Accessibility.ShowDescriptions))"


    "4" =
    "Verbose Output ($($Settings.Accessibility.VerboseOutput))"


    "5" =
    "Back"

}



$Choice =
    Show-ToolkitMenu `
    -Title "Accessibility" `
    -Options $Options



switch ($Choice) {


"1" {

    Set-ToolkitSetting `
    -Name "Accessibility.HighContrast" `
    -Value (
        -not $Settings.Accessibility.HighContrast
    )

}



"2" {

    Set-ToolkitSetting `
    -Name "Accessibility.ReduceMotion" `
    -Value (
        -not $Settings.Accessibility.ReduceMotion
    )

}



"3" {

    Set-ToolkitSetting `
    -Name "Accessibility.ShowDescriptions" `
    -Value (
        -not $Settings.Accessibility.ShowDescriptions
    )

}



"4" {

    Set-ToolkitSetting `
    -Name "Accessibility.VerboseOutput" `
    -Value (
        -not $Settings.Accessibility.VerboseOutput
    )

}



"5" {

    return

}

"Back" {

    return

}


"Exit" {

    return

}


}



}

function Show-InterfaceSettings {

while ($true) {


$Settings =
    Get-ToolkitSettings


$Interface =
    $Settings.Interface



$Options =
[ordered]@{


    "1" =
    "Confirm Actions ($($Interface.ConfirmActions))"

    "2" =
    "Remember Position ($($Interface.RememberPosition))"


    "3" =
    "Page Size ($($Interface.PageSize))"


    "4" =
    "Back"


}



$Choice =
    Show-ToolkitMenu `
    -Title "Interface" `
    -Options $Options



switch ($Choice) {


"1" {

    Set-ToolkitSetting `
    -Name "Interface.ConfirmActions" `
    -Value (
        -not $Interface.ConfirmActions
    )

}


"2" {

    Set-ToolkitSetting `
    -Name "Interface.RememberPosition" `
    -Value (
        -not $Interface.RememberPosition
    )

}



"3" {

    $Size =
        Read-Host `
        "Enter page size"



    if (
        $Size -match '^\d+$'
    ) {


        Set-ToolkitSetting `
        -Name "Interface.PageSize" `
        -Value (
            [int]$Size
        )

    }

}



"4" {

    break

}

"Back" {

    break

}

"Exit" {

    break

}


}



}


}

}



Export-ModuleMember `
-Function *