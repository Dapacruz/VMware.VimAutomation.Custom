<#
        This module extends the functionality of PowerCLI

        VMware.VimAutomation.Custom.psm1 1.2

        Author: David Cruz (davidcruz72@gmail.com)

        PowerCLI version: 6.5.1
        PowerShell version: 5.1

        Required modules:
        Posh-SSH (Get-VMHostNetworkLldpInfo).

        Features:
        Get/Start/Stop ESXi host SSH service
        Get ESXi host uptime
        List ESXi host datastores
        Create a set of ESXi host networking CSV import templates
        Export ESXi host networking to CSV
        Import ESXi host networking from CSV
        Test ESXi host networking
        Calculate the virtual to physcial CPU ratio
        Display the CDP info for each vmnic
        Display the LLDP info for each vmnic
        Calculate virtual machine CPU ready percent average
        Enable and configure the software iSCSI adapter
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
        .Parameter IncludeIscsiAdapter
        Include the software iSCSI adapter
        .Example
        New-VMHostNetworkingCsvTemplate
        Creates a set of host networking CSV import templates with sample data
        .Example
        New-VMHostNetworkingCsvTemplate -IncludeIscsiAdapter
        Creates a set of host networking CSV import templates, including a software iSCSI adapter template, with sample data
        .Example
        New-VMHostNetworkingCsvTemplate -NoSampleData
        Creates a set of host networking CSV import templates without sample data
        .Link
        https://github.com/Dapacr
#>
function New-VMHostNetworkingCsvTemplate {
    [CmdletBinding()]
    Param (
        [switch]$NoSampleData,
        [switch]$IncludeIscsiAdapter,
        [string]$VirtualSwitchesCsvPath = 'VMHost_Virtual_Switches.csv',
        [string]$VirtualPortGroupsCsvPath = 'VMHost_Virtual_Port_Groups.csv',
        [string]$VMHostNetworkAdaptersCsvPath = 'VMHost_Network_Adapters.csv',
        [string]$VMHostIscsiAdapterCsvPath = 'VMHost_iSCSI_Adapter.csv'
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
        if ($IncludeIscsiAdapter -and (Test-Path -Path $VMHostIscsiAdapterCsvPath)) {
            Throw "$VMHostIscsiAdapterCsvPath already exists!"
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
        
        # Generate iSCSI adapter template
        if ($IncludeIscsiAdapter) {
            if ($NoSampleData) {
                $iscsi_adapter = @(
                    'VMHost,IscsiTarget,VMkernelPort,ChapType,ChapName,ChapPassword,MutualChapEnabled,MutualChapName,MutualChapPassword'
                    ',,,'
                )
            } else {
                $iscsi_adapter = @(
                    'VMHost,IscsiTarget,VMkernelPort,ChapType,ChapName,ChapPassword,MutualChapEnabled,MutualChapName,MutualChapPassword'
                    'esx1,192.168.100.50,"vmk1,vmk2",Required,user,password,TRUE,user,password'
                    'esx2,192.168.100.50,"vmk1,vmk2",Required,user,password,,,'
                )
            }
        
            ConvertFrom-Csv -InputObject $iscsi_adapter -Delimiter ',' | Export-Csv $VMHostIscsiAdapterCsvPath -NoTypeInformation
            
            Invoke-Item -Path $VMHostIscsiAdapterCsvPath
        }
    }
    End {}
}


<#
        .Synopsis
        Export host networking
        .Description
        Exports host networking of VMHosts provided
        .Parameter VMHost
        The VMHosts you want to export networking for. Can be a single host or multiple hosts provided by the pipeline
        .Parameter IncludeIscsiAdapter
        Include the software iSCSI adapter
        .Example
        Export-VMHostNetworkingToCsv -VMHost vmhost*
        Exports networking of vmhosts with names that begin with "vmhost"
        .Example
        Export-VMHostNetworkingToCsv -VMHost vmhost* -IncludeIscsiAdapter
        Exports networking, including the software iSCSI adapter, of vmhosts with names that begin with "vmhost"
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Export-VMHostNetworkingToCsv {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory, Position=0)][Alias('Name','VMHosts')]
        [string[]]$VMHost,
        [switch]$IncludeIscsiAdapter,
        [string]$VirtualSwitchesCsvPath = 'VMHost_Virtual_Switches.csv',
        [string]$VirtualPortGroupsCsvPath = 'VMHost_Virtual_Port_Groups.csv',
        [string]$VMHostNetworkAdaptersCsvPath = 'VMHost_Network_Adapters.csv',
        [string]$VMHostIscsiAdapterCsvPath = 'VMHost_iSCSI_Adapter.csv'
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
        if ($IncludeIscsiAdapter -and (Test-Path -Path $VMHostIscsiAdapterCsvPath)) {
            Throw "$VMHostIscsiAdapterCsvPath already exists!"
        }
        
        $virtual_switches = @()
        $virtual_port_groups = @()
        $vmhost_network_adapters = @()
        $vmhost_iscsi_adapter = @()
    }
    Process {
        # Expand to full hostname in case wildcards are used
        $VMHost = Get-VMHost -Name $VMHost

        foreach ($h in $VMHost) {
            # Export virtual switches
            foreach ($s in Get-VirtualSwitch -VMHost $h) {
                $obj = New-Object PSObject
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'VMHost' -Value $h
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'Name' -Value $s.Name
                # Convert array to a comma separated string
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'Nic' -Value "$($s.Nic)".Replace(' ', ',')
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'Mtu' -Value $s.Mtu

                $virtual_switches += $obj
            }

            # Export virtual port groups
            foreach ($s in Get-VirtualPortGroup -VMHost $h) {
                $nic_teaming_policy = Get-NicTeamingPolicy -VirtualPortGroup $s
                $obj = New-Object PSObject
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'VMHost' -Value $h
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'Name' -Value $s.Name
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'VirtualSwitch' -Value $s.VirtualSwitch
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'VLanId' -Value $s.VLanId
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'ActiveNic' -Value "$($nic_teaming_policy.ActiveNic)".Replace(' ', ',')
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'StandbyNic' -Value "$($nic_teaming_policy.StandbyNic)".Replace(' ', ',')
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'UnusedNic' -Value "$($nic_teaming_policy.UnusedNic)".Replace(' ', ',')
                
                $virtual_port_groups += $obj
            }

            # Export host network adapters
            foreach ($s in Get-VMHostNetworkAdapter -VMHost $h -VMKernel) {
                $obj = New-Object PSObject
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'VMHost' -Value $h
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'DeviceName' -Value $s.DeviceName
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'PortGroup' -Value $s.PortGroupName
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'IP' -Value $s.IP
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'SubnetMask' -Value $s.SubnetMask
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'Mtu' -Value $s.Mtu
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'VMotionEnabled' -Value $s.VMotionEnabled
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'FaultToleranceLoggingEnabled' -Value $s.FaultToleranceLoggingEnabled
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'ManagementTrafficEnabled' -Value $s.ManagementTrafficEnabled
                Add-Member -InputObject $obj -MemberType NoteProperty -Name 'VsanTrafficEnabled' -Value $s.VsanTrafficEnabled

                $vmhost_network_adapters += $obj
            }
            
            # Export iSCSI adapter
            if ($IncludeIscsiAdapter) {
                $iscsi_hba = Get-VMHostHba -VMHost $h -Type IScsi
                if ($iscsi_hba) {
                    $obj = New-Object PSObject
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name 'VMHost' -Value $h
                
                    # iSCSI targets
                    $iscsi_target = Get-IScsiHbaTarget -IScsiHba $iscsi_hba -Type Send | Select-Object -ExpandProperty Address
                
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name 'IscsiTarget' -Value "$iscsi_target".Replace(' ', ',')
                
                    # Bound VMkernel ports
                    $esxcli = Get-EsxCli -VMHost esxi01.cruz.dev -V2
                    $vmknic = $esxcli.iscsi.networkportal.list.Invoke().vmknic
                
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name 'VMkernelPort' -Value "$vmknic".Replace(' ', ',')
                
                    # CHAP type
                
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name 'ChapType' -Value  $iscsi_hba.AuthenticationProperties.ChapType
                
                    # CHAP credentials
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name 'ChapName' -Value $iscsi_hba.AuthenticationProperties.ChapName
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name 'ChapPassword' -Value ''
                
                    # Mutual CHAP status
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name 'MutualChapEnabled' -Value $iscsi_hba.AuthenticationProperties.MutualChapEnabled
                
                    # Mutual CHAP credentials
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name 'MutualChapName' -Value $iscsi_hba.AuthenticationProperties.MutualChapName
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name 'MutualChapPassword' -Value ''
                
                    $vmhost_iscsi_adapter += $obj
                }
            }
        }
    }
    End {         
        $virtual_switches | Export-Csv -Path $VirtualSwitchesCsvPath -NoTypeInformation
        $virtual_port_groups | Export-Csv -Path $VirtualPortGroupsCsvPath -NoTypeInformation
        $vmhost_network_adapters | Export-Csv -Path $VMHostNetworkAdaptersCsvPath -NoTypeInformation
    
        Invoke-Item -Path $VirtualSwitchesCsvPath, $VirtualPortGroupsCsvPath, $VMHostNetworkAdaptersCsvPath
        
        if ($IncludeIscsiAdapter) {
            $vmhost_iscsi_adapter | Export-Csv $VMHostIscsiAdapterCsvPath -NoTypeInformation
            
            Invoke-Item -Path $VMHostIscsiAdapterCsvPath
        }
    }
}


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
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory, Position=0)][Alias('Name', 'VMHosts')]
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


<#
        .Synopsis
        Test host networking
        .Description
        Pings addresses from each provided VMkernel port of VMHosts provided
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
        [int]$Mtu = 1472,
        [int]$Count = 1,
        [float]$Wait = .001,
        [switch]$ShowReport
    )
    Begin {
        $failures = 0
        $report = @()
    }
    Process {
        # Expand to full hostname in case wildcards are used
        $VMHosts = Get-VMHost -Name $VMHosts
        
        foreach ($VMHost in $VMHosts) {
            $esxcli = Get-EsxCli -VMHost $vmhost -V2
            $ping = $esxcli.network.diag.ping
            
            foreach ($vmk in $VMkernelPort) {
                for ($i=1; $i -le $Count; $i++) {
                    $obj = New-Object -TypeName PSObject
                    $obj.PSTypeNames.Insert(0,'VMware.VimAutomation.Custom.Test.VMHostNetworking')
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name VMHost -Value $VMHost
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name VMkernelPort -Value $vmk
                    if ($Count -gt 1) {
                        Add-Member -InputObject $obj -MemberType NoteProperty -Name Count -Value $i
                    }
                    
                    foreach ($addr in $IpAddress) {
                        $params = $ping.CreateArgs()
                        $params.host = $addr
                        $params.interface = $vmk
                        $params.size = $mtu
                        $params.df = $true
                        $params.wait = $Wait
                        $params.count = 1

                        Write-Verbose "Pinging $addr from $vmk on $VMHost ..."
                        $results = $ping.Invoke($params)
                        $rtt = $results.Summary.RoundtripAvgMS
                        if ($results.Summary.PacketLost -ne 0) {
                            Write-Warning "Ping failed on $vmhost ($vmk): $addr"
                            Add-Member -InputObject $obj -MemberType NoteProperty -Name "$addr RTT (ms)" -Value -
                            $failures++
                        } else {
                            Add-Member -InputObject $obj -MemberType NoteProperty -Name "$addr RTT (ms)" -Value $rtt
                        }
                        if ($results.Summary.Duplicated -gt 0) {
                            Write-Warning "Duplicate address detected on $vmhost ($vmk): $addr"
                        }
                    }
                    
                    $report += $obj
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
        
        if ($ShowReport) {
            Write-Output $report
        }
    }
}


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
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position=0)][Alias('Name', 'VMHosts')]
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


<#
        .Synopsis
        Display the LLDP info for each vmnic
        .Description
        Display the LLDP info for each vmnic of hosts provided. The Posh-SSH module is required. An SSH connection is established with each host to capture LLDP info. If the switch name or port ID are missing/incorrect, view the RawOutput property
        .Parameter VMHost
        The host you want to display the vmnic LLDP info of. Can be a single host or multiple hosts provided by the pipeline. Wildcards are supported
        .Parameter User
        A local host user with permission to establish an SSH connection. The user 'root' is default
        .Example
        PS C:\>Get-VMHostNetworkLldpInfo -VMHost esxi* -Nic vmnic0, vmnic1

        Displays the vmnic LLDP info of all ESXi hosts with names that begin with 'esxi'
        .Example
        PS C:\>Get-VMHostNetworkLldpInfo -VMHost esxi* -Nic *

        Displays the vmnic LLDP info, for all vmnics, of all ESXi hosts with names that begin with 'esxi'
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Get-VMHostNetworkLldpInfo {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position=0)][Alias('Name', 'VMHosts')]
        [string[]]$VMHost = '*',
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$Nic,
        [Parameter(ValueFromPipeline)][Alias('UserName')]
        [string]$User = 'root'
    )
    Begin {
        if (-not (Get-Module -Name Posh-SSH -ListAvailable)) {
            throw "The Posh-SSH module is required. Execute 'Install-Module -Name Posh-SSH -Scope CurrentUser' to install it."
        }

        $credential = Get-Credential -UserName $User -Message 'Enter host SSH credentials.'
        $results = @()

        trap { Get-SSHSession | Remove-SSHSession }
    }
    Process {
        # Expand to full hostname in case wildcards are used
        $VMHost = Get-VMHost -Name $VMHost | Sort-Object -Property Name

        foreach ($h in $VMHost) {
            $h_addr = (Get-VMHostNetworkAdapter -VMHost $h -VMKernel).Where{$_.ManagementTrafficEnabled -eq $true}.IP
            $Nic = Get-VMHostNetworkAdapter -VMHost $h -Physical -Name $Nic | Sort-Object -Property Name

            try {
                $ssh = New-SSHSession -ComputerName $h_addr -Credential $credential -ErrorAction Stop
            } catch { 
                Write-Warning "Failed to establish an SSH connection to $h ($h_addr)."
                continue
            }

            foreach ($vmnic in $Nic) {
                $obj = New-Object -TypeName PSObject
                $obj.PSTypeNames.Insert(0,'VMware.VimAutomation.Custom.Get.VMHostNetworkLldpInfo')
                Add-Member -InputObject $obj -MemberType NoteProperty -Name VMHost -Value $h
                Add-Member -InputObject $obj -MemberType NoteProperty -Name Nic -Value $vmnic
                
                try {
                    # Capture one LLDP frame
                    $cmd = "pktcap-uw --uplink $vmnic --ethtype 0x88cc -c 1 -o /tmp/vmnic_lldp.pcap > /dev/null"
                    Invoke-SSHCommand -SessionId $ssh.SessionId -Command $cmd -ErrorAction Stop | Out-Null
                    
                    # Convert the packet capture to hex and save the ASCII content
                    $cmd = "tcpdump-uw -r /tmp/vmnic_lldp.pcap -v | grep -E 'System Name TLV|Port Description TLV'"
                    $raw = Invoke-SSHCommand -SessionId $ssh.SessionId -Command $cmd -ErrorAction Stop

                    # Remove capture files
                    $cmd = "rm /tmp/vmnic_lldp.pcap"
                    Invoke-SSHCommand -SessionId $ssh.SessionId -Command $cmd -ErrorAction Stop | Out-Null
                } catch {
                    Write-Warning "Operation timed out while listening for LLDP on $h ($vmnic)."
                    $raw = ''
                }

                foreach ($tlv in $raw.Output) {
                    $tlv = $tlv.Trim()

                    $regex = "System Name TLV.*?`:\s(.*)"
                    if ($tlv -match $regex) {
                        $device_id = $tlv -replace $regex, '$1' -as [string]
                    }

                    $regex = "Port Description TLV.*?`:\s(.*)"
                    if ($tlv -match $regex) {
                        $port_id = $tlv -replace $regex, '$1' -as [string]
                    }
                }
                
                if ($device_id) {
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Switch -Value $device_id
                } else {
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name Switch -Value 'n/a'
                }
                
                if ($port_id) {
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name PortId -Value $port_id                    
                } else {
                    Add-Member -InputObject $obj -MemberType NoteProperty -Name PortId -Value 'n/a'
                }
                
                # Include the raw output in case regex replace fails
                Add-Member -InputObject $obj -MemberType NoteProperty -Name RawOutput -Value ($raw.Output -as [string]).Trim()
                
                $results += $obj
            }
            
            Remove-SSHSession -SessionId $ssh.SessionId | Out-Null
        }
    }
    End {
        Write-Output $results
    }
}


<#
        .Synopsis
        Calculates virtual machine CPU ready percent average
        .Description
        Calculates the CPU ready percent average of virtual machines provided
        .Parameter VM
        The virtual machine you want to calculate the CPU ready percent of. Can be a single virtual mahcine or multiple virtual machines provided by the pipeline. Wildcards are supported
        .Example
        PS C:\>Get-VMCpuReadyPercent -VM vm* -TimePeriod Realtime

        Calculates the realtime CPU ready percent average of all virtual machines with names that begin with 'vm'
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Get-VMCpuReadyPercent {
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position=0)][Alias('Name')]
        [string[]]$VM = '*',
        [ValidateSet('Realtime', 'PastDay', 'PastWeek', 'PastMonth', 'PastYear')]
        [string]$TimePeriod = 'Realtime'
    )
    Begin {
        switch ($TimePeriod) {
            'Realtime' {
                $default_update_interval = 20
            }
            'PastDay' {
                $default_update_interval = 300
                $start = (Get-Date).AddHours(-24)
                $finish = Get-Date
            }
            'PastWeek' {
                $default_update_interval = 1800
                $start = (Get-Date).AddDays(-7)
                $finish = Get-Date
            }
            'PastMonth' {
                $default_update_interval = 7200
                $start = (Get-Date).AddDays(-30)
                $finish = Get-Date
            }
            'PastYear' {
                $default_update_interval = 86400
                $start = (Get-Date).AddYears(-1)
                $finish = Get-Date
            }
        }
        $results = @()
        
        # Expand to full name if wildcards are used
        if ($VM -match '\*|\?') {
            $VM = (Get-VM -Name $VM).Name
        }
    }
    Process {
        foreach ($m in $VM) {
            $m = Get-VM $m
            
            # Skip VMs that are not powered on
            if ($m.PowerState -ne 'PoweredOn') {
                continue
            }
            
            # Collect CPU Ready Summation stats
            try {
                if ($TimePeriod -eq 'Realtime') {
                    $stat = Get-Stat -Entity $m -Realtime -Stat cpu.ready.summation -ErrorAction Stop |
                    Where-Object { $_.Instance -eq '' }
                } else {
                    $stat = Get-Stat -Entity $m -Start $start -Finish $finish -Stat cpu.ready.summation -ErrorAction Stop |
                    Where-Object { $_.Instance -eq '' }
                }
            } catch {
                Write-Warning "CPU Ready Summation stat not available for $m"
                continue
            }
            
            # Calculate CPU Ready percent
            $cpu_summation_avg = ($stat | Measure-Object -Property Value -Average).Average
            [double]$cpu_ready_percent = '{0:N3}' -f ((($cpu_summation_avg / ($default_update_interval * 1000)) * 100) / $m.NumCpu)
            
            $obj = New-Object -TypeName PSObject
            $obj.PSTypeNames.Insert(0,'VMware.VimAutomation.Custom.Get.VMCpuReadyPercent')
            Add-Member -InputObject $obj -MemberType NoteProperty -Name Name -Value $stat.Entity[0]
            Add-Member -InputObject $obj -MemberType NoteProperty -Name Cores -Value $($m.NumCpu)
            Add-Member -InputObject $obj -MemberType NoteProperty -Name CpuReady -Value $cpu_ready_percent
    
            $status = switch ($cpu_ready_percent) {
                {$_ -lt 4} {'OK'}
                {$_ -ge 4 -and $_ -lt 5} {'Borderline'}
                {$_ -ge 5} {'High'}
            }
            Add-Member -InputObject $obj -MemberType NoteProperty -Name Status -Value $status
    
            $results += $obj
        }
    }
    End {
        Write-Output $results
    }
}


<#
        .Synopsis
        Enables the software iSCSI adapter.
        .Description
        Enables the software iSCSI adapter on VMHosts provided.
        .Parameter VMHosts
        The VMHosts you want to enable the software iSCSI adapater for. Can be a single host or multiple hosts provided by the pipeline. Wildcards are supported.
        .Parameter IscsiTarget
        Specifies the address of the new iSCSI HBA target.
        .Parameter VMkernelPort
        The VMKernel port to bind to the  software iSCSI initiator.
        .Parameter ChapType
        Specifies the type of the CHAP (Challenge Handshake Authentication Protocol) you want the new target to use. The valid values are Prohibited, Discouraged, Preferred, and Required.
        .Parameter ChapName
        Specifies a CHAP authentication name for the new target.
        .Parameter ChapPassword
        Specifies a CHAP authentication password for the new target.
        .Parameter MutualChapEnabled
        Indicates that Mutual CHAP is enabled.
        .Parameter MutualChapName
        Specifies a Mutual CHAP authentication name for the new target.
        .Parameter MutualChapPassword
        Specifies a Mutual CHAP authentication password for the new target.
        .Example
        Enable-VMHostIscsiAdapter -VMHost vmhost* -IscsiTarget 172.30.0.50 -VMkernelPort vmk2, vmk3 -ChapName 'vmware' -ChapPassword 'password'
        Enables the software iSCSI adapter for all vmhosts with names that begin with "vmhost".
        .Link
        https://github.com/Dapacruz/VMware.VimAutomation.Custom
#>
function Enable-VMHostIscsiAdapter {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='High')]
    Param (
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory, Position=0)][Alias('Name', 'VMHosts')]
        [string[]]$VMHost,
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [string[]]$IscsiTarget,
        [Parameter(ValueFromPipelineByPropertyName, Mandatory)]
        [string[]]$VMkernelPort,
        [Parameter(ValueFromPipelineByPropertyName)]
        [ValidateSet('Preferred', 'Required', 'Discouraged', 'Prohibited')]
        [string]$ChapType = 'Required',
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ChapName,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$ChapPassword,
        [Parameter(ValueFromPipelineByPropertyName)]
        [switch]$MutualChapEnabled,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$MutualChapName,
        [Parameter(ValueFromPipelineByPropertyName)]
        [string]$MutualChapPassword
    )
    Begin {
        # Expand to full name if wildcards are used
        if ($VMhost -match '\*|\?') {
            $VMhost = (Get-VMHost -Name $VMhost).Name
        }
    }
    Process {
        # TODO Add delayed ack and login timeout options
        foreach ($h in $VMHost) {
            $h = Get-VMHost $h
            
            if ($pscmdlet.ShouldProcess($h, 'Enable software iSCSI adapter')) {
                $vmhost_storage = Get-VMHostStorage -VMHost $h
                
                if (-not $vmhost_storage.SoftwareIScsiEnabled) {
                    'Enabling software iSCSI adapter on host {0}' -f $h
                    $vmhost_storage | Set-VMHostStorage -SoftwareIScsiEnabled $true | Out-Null
                } else {
                    'Software iSCSI adpater is already enabled on {0}, skipping.' -f $h
                }
                
                # Wait for the the software iSCSI adapter enablement to finish
                while (-not (Get-VMHostStorage -VMHost $h).SoftwareIScsiEnabled) {
                    Start-Sleep -Seconds 1
                }
            }

            if ($pscmdlet.ShouldProcess($h, 'Bind network VMkernel port to iSCSI adapter')) {
                $iscsi_hba = Get-VMHostHba -VMHost $h -Type IScsi
                $esxcli = Get-EsxCli -VMHost $h -V2
                $vmknic = $esxcli.iscsi.networkportal.list.Invoke().vmknic
                foreach ($vmk in $VMkernelPort) {
                    if ($vmk -notin $vmknic) {
                        'Binding {0} to the software iSCSI adapter.' -f $vmk
                        $esxcli_args = $esxcli.iscsi.networkportal.add.CreateArgs()
                        $esxcli_args.nic = $vmk
                        $esxcli_args.adapter = $iscsi_hba.Device
                        $esxcli.iscsi.networkportal.add.Invoke($esxcli_args) | Out-Null
                    } else {
                        '{0} is already bound to the software iSCSI adapter, skipping.' -f $vmk
                    }
                }
            }
            
            if ($pscmdlet.ShouldProcess($h, 'Add iSCSI target')) {
                foreach ($target in $IscsiTarget) {
                    # Check to see if the SendTarget exists, if not add it
                    if (Get-IScsiHbaTarget -IScsiHba $iscsi_hba -Type Send | Where-Object { $_.Address -cmatch $target } ) {
                        'iSCSI target {0} already exists, skipping.' -f $target
                    }
                    else {
                        'iSCSI target {0} does not exist, creating.' -f $target
                        New-IScsiHbaTarget -IScsiHba $iscsi_hba -Address $target | Out-Null
                    }
                }
            }
                if ($ChapType -and $ChapPassword -and $pscmdlet.ShouldProcess($h, 'Enable CHAP')) {
                    'Enabling CHAP on {0}.' -f $iscsi_hba
                    # Set default chap name to iSCSI initiator name if not provided
                    if (-not $ChapName){
                        $ChapName = $iscsi_hba.IScsiName
                    }
                    if (-not $MutualChapName) {
                        $MutualChapName = $iscsi_hba.IScsiName
                    }
                    $params = @{
                        'IScsiHba'=$iscsi_hba
                        'ChapType'=$ChapType
                        'ChapName'=$ChapName
                        'ChapPassword'=$ChapPassword
                        'MutualChapEnabled'=$false
                    }
                    if ($MutualChapEnabled) {
                        $params['MutualChapEnabled'] = $true
                        $params.Add('MutualChapName', $MutualChapName)
                        $params.Add('MutualChapPassword', $MutualChapPassword)
                    }
                    Set-VMHostHba @params | Out-Null
                }
        }
    }
    END {
        Write-Host "Software iSCSI adapter enablement and configuration is complete."
    }
}


Update-FormatData -PrependPath $PSScriptRoot\format.ps1xml