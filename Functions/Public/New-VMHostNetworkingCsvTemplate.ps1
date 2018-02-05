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
