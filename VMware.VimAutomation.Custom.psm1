<#
        This module extends the functionality of PowerCLI

        VMware.VimAutomation.Custom.psm1 1.2

        Author: David Cruz (davidcruz72@gmail.com)

        PowerCLI version: 6.5.1
        PowerShell version: 5.1

        Required modules:
        None.

        Features:
        Get/Start/Stop ESXi host SSH service
        Get ESXi host uptime
        List ESXi host datastores
        Create ESXi host networking CSV import template
        Export ESXi host networking to CSV
        Import ESXi host networking from CSV
        Test ESXi host networking
#>


<#
        .Synopsis
        Shows the status of the SSH service
        .Description
        Retrieves the status of the SSH service of VMHosts provided, or VMHosts in the cluster provided
        .Parameter VMHosts
        The VMHosts you want to get the SSH service status of. Can be a single host or multiple hosts provided by the pipeline
        .Example
        Get-VMHostSSHServiceStatus
        Shows the SSH service status of all VMHosts in your vCenter
        .Example
        Get-VMHostSSHServiceStatus vmhost1
        Shows the SSH service status of vmhost1
        .Example
        Get-VMHostSSHServiceStatus -cluster cluster1
        Shows the SSH service status of all vmhosts in cluster1
        .Example
        Get-VMHost -location folder1 | Get-VMHostSSHServiceStatus
        Shows the SSH service status of VMHosts in folder1
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Get-VMHostSSHServiceStatus {
    [CmdletBinding()] 
    Param (
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory=$False, Position=0)][Alias('Name')]
        [string[]]$VMHosts,
        [parameter(Mandatory=$False)]
        [string]$Cluster
    )
    Process {
        If ($VMHosts) {
            foreach ($VMHost in $VMHosts) {
                get-vmhostservice $VMHost | Where-Object { $_.key -eq "tsm-ssh" } | Select-Object VMHost, Label, Running
            }
        }
        elseif ($Cluster) {
            foreach ($VMHost in (Get-VMHost -Location $Cluster)) {
                get-vmhostservice $VMHost | Where-Object { $_.key -eq "tsm-ssh" } | Select-Object VMHost, Label, Running
            }
        }
        else {
            get-vmhostservice '*' | Where-Object { $_.key -eq "tsm-ssh" } | Select-Object VMHost, Label, Running
        }
    }
}


<#
        .Synopsis
        Starts the SSH service
        .Description
        Starts the SSH service of VMHosts provided, or VMHosts in the cluster provided
        .Parameter VMHosts
        The VMHosts you want to start the SSH service on. Can be a single host or multiple hosts provided by the pipeline
        .Example
        Start-VMHostSSHService
        Starts the SSH service on all VMHosts in your vCenter
        .Example
        Start-VMHostSSHService vmhost1
        Starts the SSH service on vmhost1
        .Example
        Start-VMHostSSHService -cluster cluster1
        Starts the SSH service on all vmhosts in cluster1
        .Example
        Get-VMHost -location folder1 | Start-VMHostSSHService
        Starts the SSH service on VMHosts in folder1
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Start-VMHostSSHService {
    [CmdletBinding(SupportsShouldProcess=$True)] 
    Param (
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory=$False, Position=0)][Alias('Name')]
        [string[]]$VMHosts,
        [parameter(Mandatory=$False)]
        [string]$Cluster
    )
    Process {
        If ($VMHosts) {
            foreach ($VMHost in $VMHosts) {
                start-vmhostservice -hostservice (get-vmhostservice $VMHost | Where-Object { $_.key -eq "tsm-ssh"}) > $null
            }
            
            Get-VMHostSSHServiceStatus -VMHosts $VMHosts
        }
        elseif ($Cluster) {
            foreach ($VMHost in (Get-VMHost -Location $Cluster)) {
                start-vmhostservice -hostservice (get-vmhostservice $VMHost | Where-Object { $_.key -eq "tsm-ssh"}) > $null
            }
            
            Get-VMHostSSHServiceStatus -Cluster $Cluster
        }
        else {
            start-vmhostservice -hostservice (get-vmhostservice '*' | Where-Object { $_.key -eq "tsm-ssh"}) > $null
            
            Get-VMHostSSHServiceStatus
        }
    }
}


<#
        .Synopsis
        Stops the SSH service
        .Description
        Stops the SSH service of VMHosts provided, or VMHosts in the cluster provided
        .Parameter VMHosts
        The VMHosts you want to stops the SSH service on. Can be a single host or multiple hosts provided by the pipeline
        .Example
        Stop-VMHostSSHService
        Stops the SSH service on all VMHosts in your vCenter
        .Example
        Stop-VMHostSSHService vmhost1
        Stops the SSH service on vmhost1
        .Example
        Stop-VMHostSSHService -cluster cluster1
        Stops the SSH service on all vmhosts in cluster1
        .Example
        Get-VMHost -location folder1 | Stop-VMHostSSHService
        Stops the SSH service on VMHosts in folder1
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Stop-VMHostSSHService {
    [CmdletBinding(SupportsShouldProcess=$True)] 
    Param (
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory=$False, Position=0)][Alias('Name')]
        [string[]]$VMHosts,
        [parameter(Mandatory=$False)]
        [string]$Cluster
    )
    Process {
        If ($VMHosts) {
            foreach ($VMHost in $VMHosts) {
                stop-vmhostservice -hostservice (get-vmhostservice $VMHost | Where-Object { $_.key -eq "tsm-ssh"}) > $null
            }
            
            Get-VMHostSSHServiceStatus -VMHosts $VMHosts
        }
        elseif ($Cluster) {
            foreach ($VMHost in (Get-VMHost -Location $Cluster)) {
                stop-vmhostservice -hostservice (get-vmhostservice $VMHost | Where-Object { $_.key -eq "tsm-ssh"}) > $null
            }
            
            Get-VMHostSSHServiceStatus -Cluster $Cluster
        }
        else {
            stop-vmhostservice -hostservice (get-vmhostservice '*' | Where-Object { $_.key -eq "tsm-ssh"}) > $null
            
            Get-VMHostSSHServiceStatus
        }
    }
}


<#
        .Synopsis
        Shows the uptime of VMHosts
        .Description
        Calculates the uptime of VMHosts provided, or VMHosts in the cluster provided
        .Parameter VMHosts
        The VMHosts you want to get the uptime of. Can be a single host or multiple hosts provided by the pipeline
        .Example
        Get-VMHostUptime
        Shows the uptime of all VMHosts in your vCenter
        .Example
        Get-VMHostUptime vmhost1
        Shows the uptime of vmhost1
        .Example
        Get-VMHostUptime -cluster cluster1
        Shows the uptime of all vmhosts in cluster1
        .Example
        Get-VMHost -location folder1 | Get-VMHostUptime
        Shows the uptime of VMHosts in folder1
        .Link
        http://cloud.kemta.net
#>
function Get-VMHostUptime {
    [CmdletBinding()] 
    Param (
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)][Alias('Name')]
        [string]$VMHosts, [string]$Cluster
    )

    Process {
        If ($VMHosts) {
            foreach ($VMHost in $VMHosts) {Get-View  -ViewType hostsystem -Property name,runtime.boottime -Filter @{"name" = "$VMHost"} | Select-Object Name, @{N="Uptime (Days)"; E={[math]::round((((Get-Date) - ($_.Runtime.BootTime)).TotalDays),1)}}, @{N="Uptime (Hours)"; E={[math]::round((((Get-Date) - ($_.Runtime.BootTime)).TotalHours),1)}}, @{N="Uptime (Minutes)"; E={[math]::round((((Get-Date) - ($_.Runtime.BootTime)).TotalMinutes),1)}}}
        }
        elseif ($Cluster) {
            foreach ($VMHost in (Get-VMHost -Location $Cluster)) {Get-View  -ViewType hostsystem -Property name,runtime.boottime -Filter @{"name" = "$VMHost"} | Select-Object Name, @{N="Uptime (Days)"; E={[math]::round((((Get-Date) - ($_.Runtime.BootTime)).TotalDays),1)}}, @{N="Uptime (Hours)"; E={[math]::round((((Get-Date) - ($_.Runtime.BootTime)).TotalHours),1)}}, @{N="Uptime (Minutes)"; E={[math]::round((((Get-Date) - ($_.Runtime.BootTime)).TotalMinutes),1)}}}
        }
        else {
            Get-View  -ViewType hostsystem -Property name,runtime.boottime | Select-Object Name, @{N="Uptime (Days)"; E={[math]::round((((Get-Date) - ($_.Runtime.BootTime)).TotalDays),1)}}, @{N="Uptime (Hours)"; E={[math]::round((((Get-Date) - ($_.Runtime.BootTime)).TotalHours),1)}}, @{N="Uptime (Minutes)"; E={[math]::round((((Get-Date) - ($_.Runtime.BootTime)).TotalMinutes),1)}}
        }
    }
}


<#
        .Synopsis
        Shows the datastore usage
        .Description
        Retrieves the datastore usage of VMHosts provided
        .Parameter VMHosts
        The VMHosts you want to get datastore usage of. Can be a single host or multiple hosts provided by the pipeline
        .Example
        Get-VMHostDatastores
        Shows the usage statistics of all unique datastores in vCenter
        .Example
        Get-VMHostDatastores vmhost1
        Shows the usage statistics of all datastores on vmhost1
        .Example
        Get-VMHost -location folder1 | Get-VMHostDatastores
        Shows the usage statistics of all datastores of hosts in 'folder1'
        .Example
        Get-VMHostDatastores (get-cluster 'cluster1' | get-vmhost)
        Shows the usage statistics of all datastores of all hosts in vCenter cluster 'cluster1'
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Get-VMHostDatastores {
    [CmdletBinding()] 
    Param (
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory=$False, Position=0)][Alias('Name')]
        [string[]]$VMHosts
    )
    Process {
        If ($VMHosts) {
            Get-Datastore -VMHost $VMHosts | select-object -unique Name, @{N='Capacity (GB)'; E={{{0:N2}} -f $_.CapacityGB}}, @{N='UsedSpace (GB)'; E={{{0:N2}} -f ($_.CapacityGB - $_.FreeSpaceGB)}}, @{N='FreeSpace (GB)'; E={{{0:N2}} -f $_.FreeSpaceGB}}
        }
        else {
            Get-Datastore | select-object -unique Name, @{N='Capacity (GB)'; E={{{0:N2}} -f $_.CapacityGB}}, @{N='UsedSpace (GB)'; E={{{0:N2}} -f ($_.CapacityGB - $_.FreeSpaceGB)}}, @{N='FreeSpace (GB)'; E={{{0:N2}} -f $_.FreeSpaceGB}}
        }
    }
}


<#
        .Synopsis
        Create a host networking CSV import template
        .Description
        Creates a host networking CSV import template to be used with Import-VMHostNetworkingFromCsv
        .Parameter NoSampleData
        Creates a host networking CSV import template without sample data
        .Example
        New-VMHostNetworkingCsvTemplate
        Creates a host networking CSV import template with sample data
        .Link
        https://github.com/Dapacr
#>
function New-VMHostNetworkingCsvTemplate {
    [CmdletBinding()]
    Param (
        [switch]$NoSampleData,
        [string]$VirtualSwitchesCsvPath = 'Virtual_Switches.csv',
        [string]$VirtualPortGroupsCsvPath = 'Virtual_Port_Groups.csv',
        [string]$VMHostNetworkAdaptersCsvPath = 'VMHost_Network_Adapters.csv'
    )
    Begin {
        if (Test-Path -Path $VirtualSwitchesCsvPath) {
            Throw "$VirtualSwitchesCsvPath already exists!"
        }
        if (Test-Path -Path $VirtualPortGroupsCsvPath) {
            Throw "$VirtualPortGroupsCsvPath already exists!"
        }
        if (Test-Path -Path $VMHostNetworkAdaptersCsvPath) {
            Throw "$VMHostNetworkAdaptersCsvPath already exists!"
        }
    }
    Process { 
        # Generate virtual switches template
        if ($NoSampleData) {
            $virtual_switches = @(
                'VMHost,Name,Nic,Mtu'
                ',,,'
            )
        } else {
            $virtual_switches = @(
                'VMHost,Name,Nic,Mtu'
                'esx1,vSwitch0,"vmnic0,vmnic4",1500'
                'esx1,vSwitch1,"vmnic1,vmnic5",9000'
            )
        }
        
        ConvertFrom-Csv -InputObject $virtual_switches -Delimiter ',' | Export-Csv $VirtualSwitchesCsvPath -NoTypeInformation
        
        # Generate virtual port groups template
        if ($NoSampleData) {
            $virtual_port_groups = @(
                'VMHost,Name,VirtualSwitch,VLanId,ActiveNic,StandbyNic,UnusedNic'
                ',,,,,,'
            )
        } else {
            $virtual_port_groups = @(
                'VMHost,Name,VirtualSwitch,VLanId,ActiveNic,StandbyNic,UnusedNic'
                'esx1,vMotion1,vSwitch0,115,vmnic0,,vmnic4'
                'esx1,vMotion2,vSwitch0,115,vmnic4,,vmnic0'
                'esx1,Management Network,vSwitch0,0,"vmnic4,vmnic0",,'
                'esx1,DMZ,vSwitch0,200,"vmnic4,vmnic0",,'
                'esx1,Production,vSwitch0,0,"vmnic4,vmnic0",,'
                'esx1,iSCSI2,vSwitch1,0,vmnic5,,vmnic1'
                'esx1,iSCSI1,vSwitch1,0,vmnic1,,vmnic5'
            )
        }
        
        ConvertFrom-Csv -InputObject $virtual_port_groups -Delimiter ',' | Export-Csv $VirtualPortGroupsCsvPath -NoTypeInformation
        
        # Generate vmhost network adapaters template
        if ($NoSampleData) {
            $vmhost_network_adapaters = @(
                'VMHost,DeviceName,PortGroup,IP,SubnetMask,Mtu,VMotionEnabled,FaultToleranceLoggingEnabled,ManagementTrafficEnabled,VsanTrafficEnabled'
                ',,,,,,,,,'
            )
        } else {
            $vmhost_network_adapaters = @(
                'VMHost,DeviceName,PortGroup,IP,SubnetMask,Mtu,VMotionEnabled,FaultToleranceLoggingEnabled,ManagementTrafficEnabled,VsanTrafficEnabled'
                'esx1,vmk0,Management Network,1.1.1.1,255.255.255.0,1500,FALSE,FALSE,TRUE,FALSE'
                'esx1,vmk1,vMotion1,2.1.1.1,255.255.255.0,1500,TRUE,FALSE,FALSE,FALSE'
                'esx1,vmk2,vMotion2,2.1.1.2,255.255.255.0,1500,TRUE,FALSE,FALSE,FALSE'
                'esx1,vmk3,iSCSI1,3.1.1.1,255.255.255.0,9000,FALSE,FALSE,FALSE,FALSE'
                'esx1,vmk4,iSCSI2,3.1.1.2,255.255.255.0,9000,FALSE,FALSE,FALSE,FALSE'
            )
        }
        
        ConvertFrom-Csv -InputObject $vmhost_network_adapaters -Delimiter ',' | Export-Csv $VMHostNetworkAdaptersCsvPath -NoTypeInformation
        
        Invoke-Item -Path $VirtualSwitchesCsvPath, $VirtualPortGroupsCsvPath, $VMHostNetworkAdaptersCsvPath
    }
    End {}
}


<#
        .Synopsis
        Export host networking
        .Description
        Exports host networking of VMHosts provided
        .Parameter VMHosts
        The VMHosts you want to export networking for. Can be a single host or multiple hosts provided by the pipeline
        .Example
        Export-VMHostNetworkingToCsv vmhost*
        Exports networking for vmhosts with names that begin with "vmhost"
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Export-VMHostNetworkingToCsv {
    # TODO Export software iSCSI adapter configuration
    
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory=$True, Position=0)][Alias('Name')]
        [string[]]$VMHosts,
        [string]$VirtualSwitchesCsvPath = 'Virtual_Switches.csv',
        [string]$VirtualPortGroupsCsvPath = 'Virtual_Port_Groups.csv',
        [string]$VMHostNetworkAdaptersCsvPath = 'VMHost_Network_Adapters.csv'
    )
    Begin {
        if (Test-Path -Path $VirtualSwitchesCsvPath) {
            Throw "$VirtualSwitchesCsvPath already exists!"
        }
        if (Test-Path -Path $VirtualPortGroupsCsvPath) {
            Throw "$VirtualPortGroupsCsvPath already exists!"
        }
        if (Test-Path -Path $VMHostNetworkAdaptersCsvPath) {
            Throw "$VMHostNetworkAdaptersCsvPath already exists!"
        }
        
        $virtual_switches = @()
        $virtual_port_groups = @()
        $vmhost_network_adapters = @()
    }
    Process {
        # Expand to full hostname in case wildcards are used
        $VMHosts = Get-VMHost -Name $VMHosts

        foreach ($VMHost in $VMHosts) {
            # Export virtual switches
            foreach ($s in Get-VirtualSwitch -VMHost $VMHost) {
                $obj = New-Object PSObject
                $obj | Add-Member -MemberType NoteProperty -Name 'VMHost' -Value $VMHost
                $obj | Add-Member -MemberType NoteProperty -Name 'Name' -Value $s.Name
                # Convert array to a comma separated string
                $obj | Add-Member -MemberType NoteProperty -Name 'Nic' -Value "$($s.Nic)".Replace(' ', ',')
                $obj | Add-Member -MemberType NoteProperty -Name 'Mtu' -Value $s.Mtu

                $virtual_switches += $obj
            }

            # Export virtual port groups
            foreach ($s in Get-VirtualPortGroup -VMHost $VMHost) {
                $nic_teaming_policy = Get-NicTeamingPolicy -VirtualPortGroup $s
                $obj = New-Object PSObject
                $obj | Add-Member -MemberType NoteProperty -Name 'VMHost' -Value $VMHost
                $obj | Add-Member -MemberType NoteProperty -Name 'Name' -Value $s.Name
                $obj | Add-Member -MemberType NoteProperty -Name 'VirtualSwitch' -Value $s.VirtualSwitch
                $obj | Add-Member -MemberType NoteProperty -Name 'VLanId' -Value $s.VLanId
                $obj | Add-Member -MemberType NoteProperty -Name 'ActiveNic' -Value "$($nic_teaming_policy.ActiveNic)".Replace(' ', ',')
                $obj | Add-Member -MemberType NoteProperty -Name 'StandbyNic' -Value "$($nic_teaming_policy.StandbyNic)".Replace(' ', ',')
                $obj | Add-Member -MemberType NoteProperty -Name 'UnusedNic' -Value "$($nic_teaming_policy.UnusedNic)".Replace(' ', ',')
                
                $virtual_port_groups += $obj
            }

            # Export host network adapters
            # TODO Include vmnic teaming (active/standby/unused) settings
            foreach ($s in Get-VMHostNetworkAdapter -VMHost $VMHost -VMKernel) {
                $obj = New-Object PSObject
                $obj | Add-Member -MemberType NoteProperty -Name 'VMHost' -Value $VMHost
                $obj | Add-Member -MemberType NoteProperty -Name 'DeviceName' -Value $s.DeviceName
                $obj | Add-Member -MemberType NoteProperty -Name 'PortGroup' -Value $s.PortGroupName
                $obj | Add-Member -MemberType NoteProperty -Name 'IP' -Value $s.IP
                $obj | Add-Member -MemberType NoteProperty -Name 'SubnetMask' -Value $s.SubnetMask
                $obj | Add-Member -MemberType NoteProperty -Name 'Mtu' -Value $s.Mtu
                $obj | Add-Member -MemberType NoteProperty -Name 'VMotionEnabled' -Value $s.VMotionEnabled
                $obj | Add-Member -MemberType NoteProperty -Name 'FaultToleranceLoggingEnabled' -Value $s.FaultToleranceLoggingEnabled
                $obj | Add-Member -MemberType NoteProperty -Name 'ManagementTrafficEnabled' -Value $s.ManagementTrafficEnabled
                $obj | Add-Member -MemberType NoteProperty -Name 'VsanTrafficEnabled' -Value $s.VsanTrafficEnabled

                $vmhost_network_adapters += $obj
            }
        }
    }
    End {         
        $virtual_switches | Export-Csv -Path $VirtualSwitchesCsvPath -NoTypeInformation
        $virtual_port_groups | Export-Csv -Path $VirtualPortGroupsCsvPath -NoTypeInformation
        $vmhost_network_adapters | Export-Csv -Path $VMHostNetworkAdaptersCsvPath -NoTypeInformation
    
        Invoke-Item -Path $VirtualSwitchesCsvPath, $VirtualPortGroupsCsvPath, $VMHostNetworkAdaptersCsvPath
    }
}


<#
        .Synopsis
        Imports host networking
        .Description
        Imports host networking for VMHosts provided utilizing the output from Export-VMHostNetworkingToCsv
        .Parameter VMHosts
        The VMHosts you want to import networking for. Can be a single host or multiple hosts provided by the pipeline. Wildcards are supported
        .Example
        Import-VMHostNetworkingFromCsv vmhost*
        Imports networking for all vmhosts with names that begin with "vmhost"
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Import-VMHostNetworkingFromCsv {
    # TODO Configure software iSCSI adapter
    
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)][Alias('Name')]
        [string[]]$VMHosts,
        [string]$VirtualSwitchesCsvPath = 'Virtual_Switches.csv',
        [string]$VirtualPortGroupsCsvPath = 'Virtual_Port_Groups.csv',
        [string]$VMHostNetworkAdaptersCsvPath = 'VMHost_Network_Adapters.csv'
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
    }
    Process {
        # Expand to full hostname in case wildcards are used
        $VMHosts = Get-VMHost -Name $VMHosts

        foreach ($VMHost in $VMHosts) {
            foreach ($s in $virtual_switches) {
                # Skip virtual switches not associated with the current vmhost
                if ($s.VMHost -ne $VMHost) {
                    continue
                }
                
                $virtual_switch = Get-VirtualSwitch -VMHost $VMHost -Name $s.Name -ErrorAction SilentlyContinue

                # Create virtual switches. Skip vSwitch0 since it exists by default
                $s.Nic = $s.Nic.Split(',').Trim()
                if ($s.Name -eq 'vSwitch0') {
                    '{0} already exists, skipping.' -f $s.Name
                    
                    # Add additional vmnics
                    foreach ($nic in $s.Nic) {
                        # Skip vmnic0 since it is linked by default
                        if ($nic -match 'vmnic0') {
                            continue
                        }
                        Add-VirtualSwitchPhysicalNetworkAdapter -VMHostPhysicalNic (Get-VMHostNetworkAdapter -VMHost $VMHost -Physical -Name $nic) -VirtualSwitch $virtual_switch -Confirm:$false
                    }
                    
                    continue
                }
                
                $params = @{
                    'VMHost'=$VMHost
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

            # Remove default 'VM Network' virtual port group since it exists by default
            $vm_network_exists = Get-VirtualPortGroup -VMHost $VMHost -Name 'VM Network' -ErrorAction SilentlyContinue
            if ($vm_network_exists) {
                Write-Host "Removing default 'VM Network' virtual port group."
                Remove-VirtualPortGroup -VirtualPortGroup $vm_network_exists -Confirm:$false -ErrorAction SilentlyContinue
            }

            # Create virtual port groups
            foreach ($vpg in $virtual_port_groups) {
                # Skip virtual port groups not associated with the current vmhost
                if ($vpg.VMHost -ne $VMHost) {
                    continue
                }
                
                $virtual_switch = Get-VirtualSwitch -VMHost $VMHost -Name $vpg.VirtualSwitch
                $params = @{
                    'Name'=$vpg.Name
                    'VirtualSwitch'=$virtual_switch
                    'VLanId'=$vpg.VLanId
                }
                $vpg_exists = Get-VirtualPortGroup -VMHost $VMHost -VirtualSwitch $virtual_switch -Name $vpg.Name -ErrorAction SilentlyContinue
                if (-not $vpg_exists) {
                        $ntp = New-VirtualPortGroup @params | Get-NicTeamingPolicy
                        if ($vpg.ActiveNic) {
                            $ntp | Set-NicTeamingPolicy -MakeNicActive $vpg.ActiveNic.Split(',').Trim()
                        }
                        if ($vpg.StandbyNic) {
                            $ntp | Set-NicTeamingPolicy -MakeNicStandby $vpg.StandbyNic.Split(',').Trim()
                        }
                        if ($vpg.UnusedNic) {
                            $ntp | Set-NicTeamingPolicy -MakeNicUnused $vpg.UnusedNic.Split(',').Trim()
                        }
                } else {
                    "{0} already exists, skipping." -f $vpg.Name
                }
                
                # Set NIC teaming policy for Management Network virtual port group
                if ($vpg.Name -eq 'Management Network') {
                    $ntp = Get-VirtualPortGroup -VMHost $VMHost -VirtualSwitch $virtual_switch -Name $vpg.Name | Get-NicTeamingPolicy
                    if ($vpg.ActiveNic) {
                            $ntp | Set-NicTeamingPolicy -MakeNicActive $vpg.ActiveNic.Split(',').Trim()
                        }
                        if ($vpg.StandbyNic) {
                            $ntp | Set-NicTeamingPolicy -MakeNicStandby $vpg.StandbyNic.Split(',').Trim()
                        }
                        if ($vpg.UnusedNic) {
                            $ntp | Set-NicTeamingPolicy -MakeNicUnused $vpg.UnusedNic.Split(',').Trim()
                        }
                }
            }

            # Create host network adapters in their original order to maintain device name
            foreach ($n in $vmhost_network_adapters | Sort-Object -Property DeviceName ) {
                if ($n.VMHost -ne $VMHost) {
                    continue
                }
                # Skip Management Network port group since it exists by default
                if ($n.PortGroup -eq 'Management Network') {
                    continue
                }
        
                # Convert empty properties to FALSE
                foreach ($p in $n.PSObject.Properties) {
                    if ($p.Value -eq 'true') {
                        $p.Value = $true
                    }
                    elseif ($p.Value -eq 'false' -or $p.Value -eq '') {
                        $p.Value = $false
                    }
                }

                $virtual_switch = (Get-VirtualPortGroup -VMHost $VMHost -Name $n.PortGroup).VirtualSwitch
                $params = @{
                    'VMHost'= $VMHost
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
                $vmhost_network_adapter_exists = Get-VMHostNetworkAdapter -VMHost $VMHost -VirtualSwitch $virtual_switch -PortGroup $n.PortGroup -ErrorAction SilentlyContinue
                if (-not $vmhost_network_adapter_exists) {
                    New-VMHostNetworkAdapter @params
                } else {
                    "{0} already exists, skipping." -f $vmhost_network_adapter_exists.Name
                }
            }
        }
    }
}


<#
        .Synopsis
        Test host networking
        .Description
        Pings addresses from each provided VMkernel port for VMHosts provided
        .Parameter VMHosts
        The VMHosts you want to ping from. Can be a single host or multiple hosts provided by the pipeline. Wildcards are supported
        .Parameter VMkernel
        The VMkernel ports to ping from
        .Parameter IpAddress
        The IP addresses to ping
        .Parameter Mtu
        The ping buffer size (Use 1472 for standard frames and 8972 for jumbo frames)
        .Example
        PS C:\>$vmhosts = "esxi*"
        PS C:\>$mgmt_vmks = 'vmk0'
        PS C:\>$mgmt_addrs = Get-VMHostNetworkAdapter -VMHost $vmhosts -Name $mgmt_vmks | select -ExpandProperty IP

        PS C:\>Test-VMHostNetworking -VMHosts $vmhosts -VMkernelPort $mgmt_vmks -IpAddress $mgmt_addrs

        Ping sweep complete. No failures detected.
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Test-VMHostNetworking {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory, Position=0)][Alias('Name')]
        [string[]]$VMHosts,
        [Parameter(Mandatory)]
        [string[]]$VMkernelPort,
        [Parameter(Mandatory)]
        [string[]]$IpAddress,
        [int]$Mtu = 1472
    )
    Begin {
        $failures = 0
    }
    Process {
        # Expand to full hostname in case wildcards are used
        $VMHosts = Get-VMHost -Name $VMHosts
        
        foreach ($VMHost in $VMHosts) {
            $esxcli = Get-EsxCli -VMHost $vmhost -V2
            $ping = $esxcli.network.diag.ping
            
            foreach ($vmk in $VMkernelPort) {
                foreach ($addr in $IpAddress) {
                    $params = $ping.CreateArgs()
                    $params.host = $addr
                    $params.interface = $vmk
                    $params.size = $mtu
                    $params.df = $true
                    $params.wait = '.1'
                    $params.count = 1

                    Write-Verbose "Pinging $addr from $vmk on $VMHost ..."
                    $results = $ping.Invoke($params)
                    if ($results.Summary.PacketLost -ne 0) {
                        Write-Warning "Ping failed on $vmhost ($vmk): $addr"
                        $failures += 1
                    }
                }
            }
        }
    }
    End {
        if ($failures -eq 0) {
            Write-Host 'Ping sweep complete. No failures detected.'
        } else {
            Write-Host "Ping sweep complete. Failures detected: $failures."
        }
    }
}


<#
        .Synopsis
        Calculate the virtual to physcial CPU ratio
        .Description
        Calculate the virtual to physical CPU ratio for VMHosts provided
        .Parameter VMHost
        The VMHost you want to calculate the virtual to physical CPU ratio of. Can be a single host or multiple hosts provided by the pipeline. Wildcards are supported
        .Example
        PS C:\>Get-VMHostVirtualToPhysicalCpuRatio -VMHost esxi*

        Calculate the virtual to physical CPU ratio of all ESXi hosts with names that begin with 'esxi'
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Get-VMHostVirtualToPhysicalCpuRatio {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory, Position=0)][Alias('Name', 'VMHosts')]
        [string[]]$VMHost
    )
    Begin {
        $results = @()
    }
    Process {
        # Expand to full hostname in case wildcards are used
        $esxi_host = Get-VMHost -Name $VMHost

        foreach ($h in $esxi_host) {
            $vcpu_count = 0
            $ratio = 0
            $pcpu_core_count = $h.ExtensionData.Hardware.CpuInfo.NumCpuCores
            $pcpu_thread_count = $h.ExtensionData.Hardware.CpuInfo.NumCpuThreads
            $virtual_machines = Get-VM -Location $h
            
            foreach ($vm in $virtual_machines) {
                $vcpu_count += $vm.NumCpu
            }
            
            if ($vcpu_count -ne 0) {
                $physical_ratio = $vcpu_count/$pcpu_core_count
                $logical_ratio = $vcpu_count/$pcpu_thread_count
             } else {
                $physical_ratio = 0
                $logical_ratio = 0
            }
            
            $obj = New-Object PSObject
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