<#
        .Synopsis
        Calculates the virtual to physcial CPU ratio
        .Description
        Calculates the virtual to physical CPU ratio of VMHosts provided
        .Parameter VMHost
        The VMHost you want to calculate the virtual to physical CPU ratio of. Can be a single host or multiple hosts provided by the pipeline. Wildcards are supported
        .Example
        PS C:\>Get-VMHostVirtualToPhysicalCpuRatio -VMHost esxi*

        Calculates the virtual to physical CPU ratio of all ESXi hosts with names that begin with 'esxi'
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Get-VMHostCpuRatio {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position=0)][Alias('Name', 'VMHosts')]
        [string[]]$VMHost = '*',
        [switch]$IncludeLogicalCores
    )
    Begin {
        $results = @()
    }
    Process {
        # Expand to full hostname in case wildcards are used
        $esxi_host = Get-VMHost -Name $VMHost

        foreach ($h in $esxi_host) {
            $vcpu_count = 0
            $physical_ratio = 0
            $logical_ratio = 0
            $pcpu_core_count = $h.ExtensionData.Hardware.CpuInfo.NumCpuCores
            $pcpu_thread_count = $h.ExtensionData.Hardware.CpuInfo.NumCpuThreads
            $virtual_machines = Get-VM -Location $h
            
            foreach ($vm in $virtual_machines) {
                $vcpu_count += $vm.NumCpu
            }
            
            if ($vcpu_count -ne 0) {
                $physical_ratio = $vcpu_count/$pcpu_core_count
                $logical_ratio = $vcpu_count/$pcpu_thread_count
            }
            
            $obj = New-Object PSObject
            $obj.PSTypeNames.Insert(0,'VMware.VimAutomation.Custom.Get.VMHostCpuRatio')
            $obj | Add-Member -MemberType NoteProperty -Name 'Name' -Value $h.Name
            $obj | Add-Member -MemberType NoteProperty -Name 'vCPUs' -Value $vcpu_count
            $obj | Add-Member -MemberType NoteProperty -Name 'PhysicalCores' -Value $pcpu_core_count
            $obj | Add-Member -MemberType NoteProperty -Name 'PhysicalRatio' -Value $('{0:N3}:1' -f $physical_ratio)
            $obj | Add-Member -MemberType NoteProperty -Name 'LogicalCores' -Value $pcpu_thread_count
            $obj | Add-Member -MemberType NoteProperty -Name 'LogicalRatio' -Value $('{0:N3}:1' -f $logical_ratio)
                                    
            $results += $obj
        }
    }
    End {
        Write-Output $results
    }
}
