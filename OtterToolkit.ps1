#Requires -Version 7.0
#Requires -RunAsAdministrator

<#
.SYNOPSIS
OtterToolkit main entry point.

.DESCRIPTION
Loads toolkit modules and starts
the interactive CLI interface.
#>


#region Module Loading

$ModulePath =
    Join-Path `
        $PSScriptRoot `
        "Modules"


Get-ChildItem `
    -Path $ModulePath `
    -Filter "*.psm1" `
    -Recurse |
Sort-Object FullName |
ForEach-Object {

    Import-Module `
        -Name $_.FullName `
        -Force

}

#endregion



#region Environment

Confirm-ToolkitEnvironment

Show-OtterDashboard

Write-ToolkitInfo `
    "Toolkit loaded successfully."

Read-Host "Press Enter to continue"


#endregion


#region Main Menu

$MainMenu = [ordered]@{

    "1" = "Windows Tweaks"

    "2" = "Applications"

    "3" = "Windows Components"

    "4" = "Diagnostics"

    "5" = "Settings"

}



while ($true) {


    $Selection =
        Show-ToolkitMenu `
            -Title "OtterToolkit" `
            -Options $MainMenu



    if (
        $Selection -eq "Exit"
    ) {

        Show-OtterExitAnimation

        break

    }



    switch ($Selection) {


        #----------------------------------
        # Tweaks
        #----------------------------------

        "1" {

            Start-TweaksManager

        }



        #----------------------------------
        # Applications
        #----------------------------------

        "2" {

            Start-ApplicationManager

        }



        #----------------------------------
        # Components
        #----------------------------------

        "3" {


            while ($true) {


                $ComponentMenu = [ordered]@{

                    "1" = "List Windows Components"

                    "2" = "Enable Component"

                    "3" = "Disable Component"

                    "4" = "Back"

                }



                $Choice =
                    Show-ToolkitMenu `
                        -Title "Windows Components" `
                        -Options $ComponentMenu



                if (
                    $Choice -eq "Exit" -or
                    $Choice -eq "4"
                ) {

                    break

                }



                switch ($Choice) {


                    "1" {


                        Get-ToolkitComponents |
                            Format-Table `
                                Name,
                                State,
                                Provider `
                                -AutoSize


                        Pause


                    }



                    "2" {


                        $Name =
                            Read-Host "Component name"


                        Enable-ToolkitComponent `
                            -Name $Name


                        Pause


                    }



                    "3" {


                        $Name =
                            Read-Host "Component name"


                        Disable-ToolkitComponent `
                            -Name $Name


                        Pause


                    }


                }


            }


        }



        #----------------------------------
        # Diagnostics
        #----------------------------------

        "4" {

            Start-DiagnosticsManager

        }



        #----------------------------------
        # Settings
        #----------------------------------

        "5" {

            Show-ToolkitSettings

        }


    }


}


#endregion