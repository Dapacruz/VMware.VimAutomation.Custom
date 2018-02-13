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
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory=$False, Position=0)]
        [Alias('Name')]
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
