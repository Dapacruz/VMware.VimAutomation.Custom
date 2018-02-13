<#
        .Synopsis
        Display the CDP info for each vmnic
        .Description
        Display the CDP info for each vmnic of VMHosts provided
        .Parameter VMHost
        The VMHost you want to display the vmnic CDP info of. Can be a single host or multiple hosts provided by the pipeline. Wildcards are supported
        .Example
        PS C:\>Get-VMHostNetworkCdpInfo -VMHost esxi*

        Displays the vmnic CDP info of all ESXi hosts with names that begin with 'esxi'
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Get-VMHostNetworkCdpInfo {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position=0)]
        [Alias('Name', 'VMHosts')]
        [string[]]$VMHost = '*'
    )
    Begin {
        $results = @()
    }
    Process {
        # Expand to full hostname in case wildcards are used
        $esxi_host = Get-VMHost -Name $VMHost

        foreach ($h in $esxi_host) {
            foreach ($hv in Get-View $h) {
                $network_system_view = Get-View $hv.ConfigManager.NetworkSystem
        
                foreach ($pnic in $network_system_view.NetworkInfo.Pnic) {
                    $pnic_info = $network_system_view.QueryNetworkHint($pnic.Device)
            
                    foreach ($hint in $pnic_info) {
                        $obj = New-Object -TypeName PSObject
                        $obj.PSTypeNames.Insert(0,'VMware.VimAutomation.Custom.Get.VMHostNetworkCdpInfo')
                        $obj | Add-Member -MemberType NoteProperty -Name VMHost -Value $hv.Name
                        $obj | Add-Member -MemberType NoteProperty -Name Nic -Value $pnic.Device
                        if ($hint.ConnectedSwitchPort) {
                            $obj | Add-Member -MemberType NoteProperty -Name Switch -Value $hint.ConnectedSwitchPort.DevId
                            $obj | Add-Member -MemberType NoteProperty -Name PortId -Value $hint.ConnectedSwitchPort.PortId
                        }
                        else {
                            $obj | Add-Member -MemberType NoteProperty -Name Switch -Value 'n/a'
                            $obj | Add-Member -MemberType NoteProperty -Name PortId -Value  'n/a'
                        }
                        $results += $obj
                    }
                }
            }
        }
    }
    End {
        Write-Output $results
    }
}
