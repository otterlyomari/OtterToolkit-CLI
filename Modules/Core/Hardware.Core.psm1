#Requires -Version 7.0

<#
.SYNOPSIS
OtterToolkit hardware detection engine.

.DESCRIPTION
Provides hardware information used
for conditional tweak availability.
#>


#region GPU Detection


function Get-ToolkitGPU {


$GPUs =
    Get-CimInstance `
        Win32_VideoController



foreach ($GPU in $GPUs) {


    $Vendor =
        if ($GPU.Name -match "NVIDIA") {
            "NVIDIA"
        }
        elseif ($GPU.Name -match "AMD|ATI|Radeon") {
            "AMD"
        }
        elseif ($GPU.Name -match "Intel") {
            "Intel"
        }
        else {
            "Unknown"
        }



    [PSCustomObject]@{


        Name =
            $GPU.Name


        Vendor =
            $Vendor


        VRAM_GB =
            if ($GPU.AdapterRAM) {

                [math]::Round(
                    $GPU.AdapterRAM / 1GB,
                    1
                )

            }
            else {

                0

            }



        DriverVersion =
            $GPU.DriverVersion



        Integrated =
            (
                $GPU.Name -match
                "Intel|UHD|Iris|Vega|Integrated|Radeon Graphics"
            )

    }

}

}

function Get-ToolkitMaxVRAM {


$GPUs =
    Get-ToolkitGPU



return (
    $GPUs |
    Measure-Object `
        VRAM_GB `
        -Maximum
).Maximum


}


function Get-ToolkitGPUVendor {


$GPUs =
    Get-ToolkitGPU



if (
    $GPUs.Name -match "NVIDIA"
){

    return "NVIDIA"

}


if (
    $GPUs.Name -match "AMD|ATI|Radeon"
){

    return "AMD"

}


if (
    $GPUs.Name -match "Intel"
){

    return "Intel"

}


return "Unknown"

}



function Test-ToolkitIntegratedGPU {

    $GPUs =
        Get-ToolkitGPU


    foreach ($GPU in $GPUs) {


        if (
            $GPU.Name -match
            "Integrated|Intel|Vega|Radeon Graphics"
        ) {

            return $true

        }


    }


    return $false

}



#endregion



#region CPU Detection


function Get-ToolkitCPU {

    Get-CimInstance `
        Win32_Processor |
    Select-Object `
        Name,
        Manufacturer,
        NumberOfCores,
        NumberOfLogicalProcessors

}



function Get-ToolkitCPUVendor {

    $CPU =
        Get-ToolkitCPU


    if (
        $CPU.Manufacturer -match "AMD"
    ) {

        return "AMD"

    }


    if (
        $CPU.Manufacturer -match "Intel"
    ) {

        return "Intel"

    }


    return "Unknown"

}



#endregion



#region Memory Detection


function Get-ToolkitMemory {


    $Memory =
        Get-CimInstance `
            Win32_PhysicalMemory


    $Total =
        (
            $Memory |
            Measure-Object `
                Capacity `
                -Sum
        ).Sum



    [PSCustomObject]@{

        TotalGB =
            [math]::Round(
                $Total / 1GB,
                2
            )

        Modules =
            $Memory.Count

    }

}



#endregion



#region Storage Detection


function Get-ToolkitStorage {


    Get-PhysicalDisk |
    Select-Object `
        FriendlyName,
        MediaType,
        Size,
        HealthStatus

}



function Test-ToolkitSSD {


    $Disks =
        Get-ToolkitStorage


    foreach ($Disk in $Disks) {


        if (
            $Disk.MediaType -eq "SSD"
        ) {

            return $true

        }

    }


    return $false

}

function Test-ToolkitNVMe {


$Disks =
    Get-PhysicalDisk `
        -ErrorAction SilentlyContinue



foreach ($Disk in $Disks) {


    if (
        $Disk.BusType -eq "NVMe"
    ){

        return $true

    }

}


return $false

}


#endregion



#region System Detection


function Test-ToolkitLaptop {


    $Battery =
        Get-CimInstance `
            Win32_Battery `
            -ErrorAction SilentlyContinue


    return (
        $null -ne $Battery
    )

}



function Test-ToolkitVirtualMachine {


    $System =
        Get-CimInstance `
            Win32_ComputerSystem



    return (
        $System.Model -match
        "Virtual|VMware|VirtualBox|Hyper-V"
    )

}



#endregion



#region Hardware SummaryOkagy
$script:ToolkitHardwareCache = $null



function Update-ToolkitHardwareCache {


    $script:ToolkitHardwareCache =
        [PSCustomObject]@{


            GPU =
                Get-ToolkitGPU



            GPUVendor =
                Get-ToolkitGPUVendor



            IntegratedGPU =
                Test-ToolkitIntegratedGPU

            
            VRAM_GB =
                Get-ToolkitMaxVRAM

            RAM_GB =
                (
                    Get-ToolkitMemory
                ).TotalGB

            CPU =
                Get-ToolkitCPU



            CPUVendor =
                Get-ToolkitCPUVendor



            Memory =
                Get-ToolkitMemory



            HasSSD =
                Test-ToolkitSSD

            HasNVMe =
                Test-ToolkitNVMe

            Laptop =
                Test-ToolkitLaptop



            VirtualMachine =
                Test-ToolkitVirtualMachine



            ScanTime =
                Get-Date


        }



    return $script:ToolkitHardwareCache

}



function Get-ToolkitHardwareSummary {


    if (
        $null -eq $script:ToolkitHardwareCache
    ) {


        return (
            Update-ToolkitHardwareCache
        )


    }



    return (
        $script:ToolkitHardwareCache
    )

}



function Clear-ToolkitHardwareCache {


    $script:ToolkitHardwareCache =
        $null


}


#endregion



Export-ModuleMember `
-Function *