<#
        .Synopsis
        Imports host networking
        .Description
        Imports host networking, of VMHosts provided, utilizing the output from Export-VMHostNetworkingToCsv
        .Parameter VMHost
        The VMHosts you want to import networking for. Can be a single host or multiple hosts provided by the pipeline. Wildcards are supported
        .Parameter IncludeIscsiAdapter
        Include the software iSCSI adapter
        .Example
        Import-VMHostNetworkingFromCsv -VMHost vmhost*
        Imports networking for all vmhosts with names that begin with "vmhost"
        .Example
        Import-VMHostNetworkingFromCsv -VMHost vmhost* -IncludeIscsiAdapter
        Imports networking, including the software iSCSI adapter, for all vmhosts with names that begin with "vmhost"
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Import-VMHostNetworkingFromCsv {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    Param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory, Position=0)]
        [Alias('Name', 'VMHosts')]
        [string[]]$VMHost,

        [switch]$IncludeIscsiAdapter,

        [string]$VirtualSwitchesCsvPath = 'VMHost_Virtual_Switches.csv',

        [string]$VirtualPortGroupsCsvPath = 'VMHost_Virtual_Port_Groups.csv',

        [string]$VMHostNetworkAdaptersCsvPath = 'VMHost_Network_Adapters.csv',
        
        [string]$VMHostIscsiAdapterCsvPath = 'VMHost_iSCSI_Adapter.csv'
    )
    Begin {
        if (Test-Path -Path $VirtualSwitchesCsvPath) {
            $virtual_switches = Import-Csv $VirtualSwitchesCsvPath
        } else {
            Throw "$VirtualSwitchesCsvPath not found!"
        }
        if (Test-Path -Path $VirtualPortGroupsCsvPath) {
            $virtual_port_groups = Import-Csv $VirtualPortGroupsCsvPath
        } else {
            Throw "$VirtualPortGroupsCsvPath not found!"
        }
        if (Test-Path -Path $VMHostNetworkAdaptersCsvPath) {
            $vmhost_network_adapters = Import-Csv $VMHostNetworkAdaptersCsvPath
        } else {
            Throw "$VMHostNetworkAdaptersCsvPath not found!"
        }
        if ($IncludeIscsiAdapter -and (Test-Path -Path $VMHostIscsiAdapterCsvPath)) {
            $vmhost_iscsi_adapter = Import-Csv $VMHostIscsiAdapterCsvPath
        } elseif ($IncludeIscsiAdapter) {
            Throw "$VMHostIscsiAdapterCsvPath not found!"
        }
            }
    Process {
        # Expand to full hostname in case wildcards are used
        $VMHost = Get-VMHost -Name $VMHost | Sort-Object -Property Name

        foreach ($h in $VMHost) {
            Write-Host "`nSetting up networking on $h ..."
            if ($pscmdlet.ShouldProcess($h, 'Configure virtual switches')) {
                foreach ($s in $virtual_switches) {
                    # Skip virtual switches not associated with the current vmhost
                    if ($s.VMHost -ne $h) {
                        continue
                    }
                
                    $virtual_switch = Get-VirtualSwitch -VMHost $h -Name $s.Name -ErrorAction SilentlyContinue

                    # Skip vSwitch0 since it exists by default
                    $s.Nic = $s.Nic.Split(',').Trim()
                    if ($s.Name -eq 'vSwitch0') {
                        '{0} already exists, skipping.' -f $s.Name
                    
                        # Add additional vmnics
                        foreach ($nic in $s.Nic) {
                            # Skip vmnic0 since it is linked by default
                            if ($nic -match 'vmnic0') {
                                continue
                            }
                            Add-VirtualSwitchPhysicalNetworkAdapter -VMHostPhysicalNic (Get-VMHostNetworkAdapter -VMHost $h -Physical -Name $nic) -VirtualSwitch $virtual_switch -Confirm:$false
                        }
                    
                        continue
                    }
                
                    $params = @{
                        'VMHost'=$h
                        'Name'=$s.Name
                        'Nic'=$s.Nic
                        'Mtu'=$s.Mtu
                    }
                    if (-not $virtual_switch) {
                        New-VirtualSwitch @params
                    } else {
                        '{0} already exists, skipping.' -f $s.Name
                    }
                }
            }

            if ($pscmdlet.ShouldProcess($h, 'Remove default "VM Network" virtual port group')) {
                $vm_network_exists = Get-VirtualPortGroup -VMHost $h -Name 'VM Network' -ErrorAction SilentlyContinue
                if ($vm_network_exists) {
                    Write-Host "Removing default 'VM Network' virtual port group."
                    Remove-VirtualPortGroup -VirtualPortGroup $vm_network_exists -Confirm:$false -ErrorAction SilentlyContinue
                }
            }

            if ($pscmdlet.ShouldProcess($h, 'Configure virtual port groups')) {
                foreach ($vpg in $virtual_port_groups) {
                    # Skip virtual port groups not associated with the current vmhost
                    if ($vpg.VMHost -ne $h) {
                        continue
                    }
                
                    $virtual_switch = Get-VirtualSwitch -VMHost $h -Name $vpg.VirtualSwitch
                    $params = @{
                        'Name'=$vpg.Name
                        'VirtualSwitch'=$virtual_switch
                        'VLanId'=$vpg.VLanId
                    }
                    $vpg_exists = Get-VirtualPortGroup -VMHost $h -VirtualSwitch $virtual_switch -Name $vpg.Name -ErrorAction SilentlyContinue
                    if (-not $vpg_exists) {
                        $ntp = New-VirtualPortGroup @params | Get-NicTeamingPolicy
                        if ($vpg.ActiveNic) {
                            $ntp | Set-NicTeamingPolicy -MakeNicActive $vpg.ActiveNic.Split(',').Trim() | Out-Null
                        }
                        if ($vpg.StandbyNic) {
                            $ntp | Set-NicTeamingPolicy -MakeNicStandby $vpg.StandbyNic.Split(',').Trim() | Out-Null
                        }
                        if ($vpg.UnusedNic) {
                            $ntp | Set-NicTeamingPolicy -MakeNicUnused $vpg.UnusedNic.Split(',').Trim() | Out-Null
                        }
                    } else {
                        "{0} already exists, skipping." -f $vpg.Name
                    }
                
                    # Set NIC teaming policy for Management Network virtual port group
                    if ($vpg.Name -eq 'Management Network') {
                        $ntp = Get-VirtualPortGroup -VMHost $h -VirtualSwitch $virtual_switch -Name $vpg.Name | Get-NicTeamingPolicy
                        if ($vpg.ActiveNic) {
                            $ntp | Set-NicTeamingPolicy -MakeNicActive $vpg.ActiveNic.Split(',').Trim() | Out-Null
                        }
                        if ($vpg.StandbyNic) {
                            $ntp | Set-NicTeamingPolicy -MakeNicStandby $vpg.StandbyNic.Split(',').Trim() | Out-Null
                        }
                        if ($vpg.UnusedNic) {
                            $ntp | Set-NicTeamingPolicy -MakeNicUnused $vpg.UnusedNic.Split(',').Trim() | Out-Null
                        }
                    }
                }
            }

            if ($pscmdlet.ShouldProcess($h, 'Configure network adapters')) {
                # Create host network adapters in their original order to maintain device name
                foreach ($n in $vmhost_network_adapters | Sort-Object -Property DeviceName ) {
                    # Skip network adapters not associated with the current vmhost
                    if ($n.VMHost -ne $h) {
                        continue
                    }
                    # Skip Management Network port group since it exists by default
                    if ($n.PortGroup -eq 'Management Network') {
                        continue
                    }
        
                    # Convert 'true' to $true, and 'false' or empty properties to $false
                    foreach ($p in $n.PSObject.Properties) {
                        if ($p.Value -eq 'true') {
                            $p.Value = $true
                        }
                        elseif ($p.Value -eq 'false' -or $p.Value -eq '') {
                            $p.Value = $false
                        }
                    }

                    $virtual_switch = (Get-VirtualPortGroup -VMHost $h -Name $n.PortGroup).VirtualSwitch
                    $params = @{
                        'VMHost'= $h
                        'PortGroup'=$n.PortGroup
                        'VirtualSwitch'=$virtual_switch
                        'IP'=$n.IP
                        'SubnetMask'=$n.SubnetMask
                        'Mtu'=$n.Mtu
                        'VMotionEnabled'=$n.VMotionEnabled
                        'FaultToleranceLoggingEnabled'=$n.FaultToleranceLoggingEnabled
                        'ManagementTrafficEnabled'=$n.ManagementTrafficEnabled
                        'VsanTrafficEnabled'=$n.VsanTrafficEnabled
                    }
                    $vmhost_network_adapter_exists = Get-VMHostNetworkAdapter -VMHost $h -VirtualSwitch $virtual_switch -PortGroup $n.PortGroup -ErrorAction SilentlyContinue
                    if (-not $vmhost_network_adapter_exists) {
                        New-VMHostNetworkAdapter @params
                    } else {
                        "{0} already exists, skipping." -f $vmhost_network_adapter_exists.Name
                    }
                }
            }
                
            if ($IncludeIscsiAdapter -and $pscmdlet.ShouldProcess($h, 'Configure software iSCSI adapter')) {
                foreach ($a in $vmhost_iscsi_adapter) {
                    # Skip iSCSI adapters not associated with the current vmhost
                    if ($a.VMHost -ne $h) {
                        continue
                    }
                        
                    if ($a.Chaptype -eq 'Prohibited') {
                        $params = @{
                            'VMHost'= $h
                            'IscsiTarget'=$a.IscsiTarget.Split(',').Trim()
                            'VMkernelPort'=$a.VMkernelPort.Split(',').Trim()
                            'ChapType'=$a.ChapType
                            'MutualChapEnabled'=$false
                        }
                    } else {
                        $params = @{
                            'VMHost'= $h
                            'IscsiTarget'=$a.IscsiTarget.Split(',').Trim()
                            'VMkernelPort'=$a.VMkernelPort.Split(',').Trim()
                            'ChapType'=$a.ChapType
                            'ChapName'=$a.ChapName
                            'ChapPassword'=$a.ChapPassword
                            'MutualChapEnabled'=$false
                        }
                        if ($a.MutualChapEnabled -eq 'true') {
                            $params['MutualChapEnabled'] = $true
                            $params.Add('MutualChapName', $a.MutualChapName)
                            $params.Add('MutualChapPassword', $a.MutualChapPassword)
                        }
                    }
                    
                    Enable-VMHostIscsiAdapter @params -Confirm:$false
                }
            }
        }
    }
    END {}
}
