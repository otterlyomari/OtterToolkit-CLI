#Requires -Version 7.0

<#
.SYNOPSIS
Windows tweak management engine.

.DESCRIPTION
Loads categorized tweak definitions from JSON
and safely applies tweak actions.
#>


#region Paths

$TweakDirectory =
Join-Path `
    $PSScriptRoot `
    "..\..\Tweaks"

#endregion

$script:ToolkitRestartRequired = $false


#region Loading

function Get-ToolkitTweakCategories {

    [CmdletBinding()]

    param()


    if (-not (Test-Path $TweakDirectory)) {

        throw "Tweak directory missing: $TweakDirectory"

    }


    $Categories =
        foreach ($File in (
            Get-ChildItem `
                -Path $TweakDirectory `
                -Filter "*.json"
        )) {


            try {

                $Tweaks =
                    Get-Content `
                        -Path $File.FullName `
                        -Raw |
                    ConvertFrom-Json


                [PSCustomObject]@{

                    Name =
                        $File.BaseName

                    File =
                        $File.Name

                    Path =
                        $File.FullName

                    Tweaks =
                        $Tweaks |
                        Where-Object {

                            Test-TweakRequirements `
                                -Tweak $_

                        }

                }

            }

            catch {

                Write-Warning `
                    "Failed loading $($File.Name)"

            }

        }


    return $Categories

}



function Get-ToolkitTweaks {

    [CmdletBinding()]

    param(
        [string]
        $Category
    )


    $Categories =
        Get-ToolkitTweakCategories


    if ($Category) {

        return (
            $Categories |
            Where-Object {
                $_.Name -eq $Category
            }
        ).Tweaks

    }


    return $Categories

}



function Get-ToolkitTweak {

param(

    [Parameter(Mandatory)]
    [string]
    $Name

)


Get-ToolkitTweakCategories |
ForEach-Object {

    $_.Tweaks

} |
Where-Object {

    $_.Name -eq $Name

}

}

function Restart-ToolkitExplorer {

    Write-Host ""
    Write-ToolkitInfo "Restarting Windows Explorer..."

    Stop-Process `
        -Name explorer `
        -Force `
        -ErrorAction SilentlyContinue

        $Settings =
    Get-ToolkitSettings


    if (
        $Settings.Appearance.Animations -and 
        -not $Settings.Accessibility.ReduceMotion
    ){

        Start-Sleep `
        -Milliseconds 100

    }
    Start-Process explorer.exe

}

#endregion

#region Requirements


function Test-HardwareRequirement {

param(
    $Hardware,
    $Requirement
)


foreach (
    $Rule in $Requirement.PSObject.Properties
) {


    $Name =
        $Rule.Name


    $Expected =
        $Rule.Value



    switch ($Name) {


        "GPUVendor" {


            if ($Expected -is [array]) {

                if (
                    $Expected -notcontains $Hardware.GPUVendor
                ) {

                    return $false

                }

            }

            elseif (
                $Hardware.GPUVendor -ne $Expected
            ){

                return $false

            }

        }



        "CPUVendor" {


            if ($Expected -is [array]) {


                if (
                    $Expected -notcontains $Hardware.CPUVendor
                ){

                    return $false

                }

            }

            elseif (
                $Hardware.CPUVendor -ne $Expected
            ){

                return $false

            }

        }



        "IntegratedGPU" {


            if (
                $Hardware.IntegratedGPU -ne $Expected
            ){

                return $false

            }

        }



        "Laptop" {


            if (
                $Hardware.Laptop -ne $Expected
            ){

                return $false

            }

        }



        "HasSSD" {


            if (
                $Hardware.HasSSD -ne $Expected
            ){

                return $false

            }

        }



        "MinimumRAM" {


            if (
                $Hardware.RAM_GB -lt $Expected
            ){

                return $false

            }

        }



        "MinimumVRAM" {


            if (
                $Hardware.VRAM_GB -lt $Expected
            ){

                return $false

            }

        }



        default {


            Write-Warning `
            "Unknown hardware requirement: $Name"


        }

    }


}


return $true

}


function Test-TweakRequirements {

param(
    $Tweak
)


if (-not $Tweak.Requirements) {

    return $true

}


$Hardware =
    Get-ToolkitHardwareSummary



foreach ($Requirement in
    $Tweak.Requirements.PSObject.Properties
) {


    $Property =
        $Requirement.Name


    $Expected =
        $Requirement.Value



    switch ($Property) {


        "GPUVendor" {


            if (
                $Hardware.GPUVendor -ne $Expected
            ){

                return $false

            }

        }



        "CPUVendor" {


            if (
                $Hardware.CPUVendor -ne $Expected
            ){

                return $false

            }

        }



        "IntegratedGPU" {


            if (
                $Hardware.IntegratedGPU -ne $Expected
            ){

                return $false

            }

        }



        "Laptop" {


            if (
                $Hardware.Laptop -ne $Expected
            ){

                return $false

            }

        }



        "HasSSD" {


            if (
                $Hardware.HasSSD -ne $Expected
            ){

                return $false

            }

        }



        default {


            Write-Warning `
            "Unknown tweak requirement: $Property"


        }


    }

}


return $true

}

function Test-TweakRequirements {

param(
    $Tweak
)

if (-not $Tweak.Requirements) {
    return $true
}


$Hardware =
    Get-ToolkitHardwareSummary



# ALL rules

if ($Tweak.Requirements.All) {

    if (
        -not (
            Test-HardwareRequirement `
                -Hardware $Hardware `
                -Requirement $Tweak.Requirements.All
        )
    ) {
        return $false
    }

}



# ANY rules

if ($Tweak.Requirements.Any) {

    $Passed = $false


    foreach (
        $Rule in $Tweak.Requirements.Any.PSObject.Properties
    ) {

        if (
            Test-HardwareRequirement `
                -Hardware $Hardware `
                -Requirement (
                    [PSCustomObject]@{
                        $Rule.Name = $Rule.Value
                    }
                )
        ) {

            $Passed = $true

        }

    }


    if (-not $Passed) {
        return $false
    }

}



# NOT rules

if ($Tweak.Requirements.Not) {

    if (
        Test-HardwareRequirement `
            -Hardware $Hardware `
            -Requirement $Tweak.Requirements.Not
    ) {

        return $false

    }

}



return $true

}


#endregion

#region Detection

function Test-TweakRegistryState {

param(
    $Action
)


try {

    $Value =
        Get-ItemPropertyValue `
            -Path $Action.Path `
            -Name $Action.Name `
            -ErrorAction Stop


    return (
        $Value -eq $Action.Value
    )

}

catch {

    return $false

}

}

function Test-TweakAction {

param(
    $Action
)

switch ($Action.Type) {


    "Registry" {

        return (
            Test-TweakRegistryState `
                -Action $Action
        )

    }


    "Service" {

        $Service =
            Get-Service `
                -Name $Action.Name `
                -ErrorAction SilentlyContinue


        if (-not $Service) {

            return $false

        }


        if ($Action.StartupType) {

            return (
                $Service.StartType -eq
                $Action.StartupType
            )

        }


        return $true

    }


    default {

        return $false

    }

}

}

function Write-ToolkitStatus {

param(
    [string]
    $Message
)

Write-Host (
    "[*] {0}" -f $Message
)

}


function Write-ToolkitSuccess {

param(
    [string]
    $Message
)

Write-Host (
    "[✓] {0}" -f $Message
)

}


function Write-ToolkitFailure {

param(
    [string]
    $Message
)

Write-Host (
    "[X] {0}" -f $Message
)

}

function Get-ToolkitTweakStatus {

param(
    [string]
    $Name
)


$Tweak =
Get-ToolkitTweak `
-Name $Name


if (-not $Tweak) {

    return "Unknown"

}


foreach ($Action in $Tweak.Actions) {


    if (-not (
        Test-TweakAction `
            -Action $Action
    )) {

        return "Disabled"

    }

}


return "Enabled"

}

#endregion

#region Actions


function Invoke-TweakRegistryAction {

    param(
        [Parameter(Mandatory)]
        $Action
    )


    if (-not (Test-Path $Action.Path)) {

        New-Item `
            -Path $Action.Path `
            -Force |
        Out-Null

    }


    New-ItemProperty `
        -Path $Action.Path `
        -Name $Action.Name `
        -Value $Action.Value `
        -PropertyType $Action.Kind `
        -Force |
    Out-Null

}

function Invoke-TweakAction {

param(
    [Parameter(Mandatory)]
    $Action
)


switch ($Action.Type) {


    "Registry" {

        Invoke-TweakRegistryAction `
            -Action $Action

    }


    "Command" {

        Invoke-TweakCommandAction `
            -Action $Action

    }


    "Service" {

        Invoke-TweakServiceAction `
            -Action $Action

    }


    default {

        throw `
        "Unsupported tweak action: $($Action.Type)"

    }

}

}

function Invoke-TweakCommandAction {

param(
    [Parameter(Mandatory)]
    $Action
)


Start-Process `
    -FilePath $Action.Command `
    -ArgumentList $Action.Arguments `
    -Wait `
    -NoNewWindow
}

function Invoke-TweakServiceAction {

param(
    [Parameter(Mandatory)]
    $Action
)


$Service =
    Get-Service `
        -Name $Action.Name `
        -ErrorAction SilentlyContinue


if (-not $Service) {

    throw `
    "Service not found: $($Action.Name)"

}



if ($Action.StartupType) {

    Set-Service `
        -Name $Action.Name `
        -StartupType $Action.StartupType

}



if ($Action.State) {


    if ($Action.State -eq "Stopped") {

        Stop-Service `
            -Name $Action.Name `
            -Force

    }


    elseif ($Action.State -eq "Running") {

        Start-Service `
            -Name $Action.Name

    }

}

}

#endregion

function Set-ToolkitRestartRequired {

    $script:ToolkitRestartRequired = $true

}


function Clear-ToolkitRestartRequired {

    $script:ToolkitRestartRequired = $false

}


function Test-ToolkitRestartRequired {

    return $script:ToolkitRestartRequired

}

#region Public API


function Invoke-ToolkitTweak {

    [CmdletBinding(
        SupportsShouldProcess = $true
    )]


    param(

        [Parameter(Mandatory)]
        [string]
        $Name

    )


    $Tweak =
        Get-ToolkitTweaks |
        ForEach-Object {

            $_.Tweaks

        } |
        Where-Object {

            $_.Name -eq $Name

        }



    if (-not $Tweak) {

        throw `
        "Tweak not found: $Name"

    }



    if (
        $PSCmdlet.ShouldProcess(
            $Name,
            "Apply tweak"
        )
    ) {


        Write-ToolkitWarning `
            "Applying tweak: $Name"



        foreach ($Action in $Tweak.Actions) {


    Write-ToolkitStatus `
        "Applying $($Action.Type) action..."


    Invoke-TweakAction `
        -Action $Action

}


    $Verified =
        $true


    foreach ($Action in $Tweak.Actions) {


        if (
            -not (
                Test-TweakAction `
                    -Action $Action
            )
        ){

            $Verified =
                $false

        }

    }



    if ($Verified) {

        Write-ToolkitSuccess `
            "Tweak verified successfully."

    }

    else {

        Write-ToolkitFailure `
            "Tweak applied, but verification failed."

    }


        Write-ToolkitInfo `
            "Tweak applied: $Name"

        if ($Tweak.RestartRequired) {

            Set-ToolkitRestartRequired

        }

    }

}

function Invoke-ToolkitTweakUndo {

[CmdletBinding(
    SupportsShouldProcess = $true
)]

param(

    [Parameter(Mandatory)]
    [string]
    $Name

)


$Tweak =
    Get-ToolkitTweaks |
    ForEach-Object {

        $_.Tweaks

    } |
    Where-Object {

        $_.Name -eq $Name

    }



if (-not $Tweak) {

    throw `
    "Tweak not found: $Name"

}



if (-not $Tweak.UndoActions) {

    throw `
    "Tweak does not support undo: $Name"

}



if (
    $PSCmdlet.ShouldProcess(
        $Name,
        "Undo tweak"
    )
) {


    Write-ToolkitWarning `
        "Reverting tweak: $Name"



    foreach ($Action in $Tweak.UndoActions) {


        Invoke-TweakAction `
            -Action $Action


    }



    Write-ToolkitInfo `
        "Tweak reverted: $Name"

}

}


#endregion



Export-ModuleMember `
-Function *