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
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory=$False, Position=0)]
        [Alias('Name')]
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
