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
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Position=0)]
        [Alias('Name', 'VMHosts')]
        [string[]]$VMHost = '*',

        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string[]]$Nic,

        [Parameter(ValueFromPipeline)]
        [Alias('UserName')]
        [string]$User = 'root',
        [boolean]$AcceptKey = $true
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
            Write-Host "Host: $h"
            $h_addr = (Get-VMHostNetworkAdapter -VMHost $h -VMKernel).Where{$_.ManagementTrafficEnabled -eq $true}.IP
            $Nic = Get-VMHostNetworkAdapter -VMHost $h -Physical -Name $Nic | Sort-Object -Property Name

            Write-Host 'Establisting an SSH connection ... ' -NoNewline
            try {
                $ssh = New-SSHSession -ComputerName $h_addr -Credential $credential -AcceptKey:$AcceptKey -ErrorAction Stop
                Write-Host 'success'
            } catch {
                Write-Host 'fail'
                Write-Warning "Failed to establish an SSH connection to $h ($h_addr)."
                continue
            }

            foreach ($vmnic in $Nic) {
                $raw = ''
                $device_id = ''
                $port_id = ''

                $obj = New-Object -TypeName PSObject
                $obj.PSTypeNames.Insert(0,'VMware.VimAutomation.Custom.Get.VMHostNetworkLldpInfo')
                Add-Member -InputObject $obj -MemberType NoteProperty -Name VMHost -Value $h
                Add-Member -InputObject $obj -MemberType NoteProperty -Name Nic -Value $vmnic
                
                try {
                    Write-Host "Listening for LLDP on $vmnic ... " -NoNewline
                    # Capture one LLDP frame
                    $cmd = "pktcap-uw --uplink $vmnic --ethtype 0x88cc -c 1 -o /tmp/vmnic_lldp.pcap > /dev/null"
                    Invoke-SSHCommand -SessionId $ssh.SessionId -Command $cmd -TimeOut 45 -ErrorAction Stop | Out-Null
                    
                    # Convert the packet capture to hex and save the ASCII content
                    $cmd = "tcpdump-uw -r /tmp/vmnic_lldp.pcap -v | grep -E 'System Name TLV|Subtype Interface Name'"
                    $raw = Invoke-SSHCommand -SessionId $ssh.SessionId -Command $cmd -ErrorAction Stop
                    
                    Write-Host 'success'
                } catch {
                    # Kill the pktcap-uw process
                    $cmd = "kill -2 `$(lsof | grep pktcap-uw | awk '{print `$1}' | sort -u)"
                    Invoke-SSHCommand -SessionId $ssh.SessionId -Command $cmd -ErrorAction Stop | Out-Null

                    Write-Host 'fail'
                    Write-Warning "Operation timed out while listening for LLDP on $h ($vmnic)."
                } finally {
                    # Remove capture files
                    $cmd = "rm /tmp/vmnic_lldp.pcap"
                    Invoke-SSHCommand -SessionId $ssh.SessionId -Command $cmd -ErrorAction Stop | Out-Null
                }

                foreach ($tlv in $raw.Output) {
                    $tlv = $tlv.Trim()

                    $regex = "System Name TLV.*?`:\s(.*)"
                    if ($tlv -match $regex) {
                        $device_id = $tlv -replace $regex, '$1' -as [string]
                    }

                    $regex = "Subtype Interface Name.*?`:\s(.*)"
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
            Write-Host ''
        }
    }
    End {
        Write-Output $results
    }
}
