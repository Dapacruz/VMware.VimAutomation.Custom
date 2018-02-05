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
        [Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
        [Alias('Name')]
        [string]$VMHosts, 
        
        [string]$Cluster
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
