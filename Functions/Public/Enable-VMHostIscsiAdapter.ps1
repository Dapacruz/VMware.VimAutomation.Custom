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
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory, Position=0)]
        [Alias('Name', 'VMHosts')]
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
