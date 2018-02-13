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
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName, Mandatory, Position=0)]
        [Alias('Name')]
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
