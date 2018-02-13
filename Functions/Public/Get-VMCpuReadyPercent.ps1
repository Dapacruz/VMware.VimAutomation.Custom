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
