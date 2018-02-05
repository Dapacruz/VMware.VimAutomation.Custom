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
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory, Position=0)]
        [Alias('Name','VMHosts')]
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
                    $esxcli = Get-EsxCli -VMHost $h -V2
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
