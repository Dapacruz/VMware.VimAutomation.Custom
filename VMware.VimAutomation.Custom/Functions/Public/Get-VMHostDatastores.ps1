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
        [Parameter(ValueFromPipeline=$True, ValueFromPipelineByPropertyName=$True, Mandatory=$False, Position=0)]
        [Alias('Name')]
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
