# PSake makes variables declared here available in other scriptblocks
# Init some things

Properties {
    # Define global variables used by tasks
    $projectRoot = $ENV:BHProjectPath
    if (-not $projectRoot)
    {
        $projectRoot = Resolve-Path "$PSScriptRoot\.."
    }
    $sut = $env:BHProjectName
    $tests = "$projectRoot\Tests"
    $lines = '----------------------------------------------------------------------'

    $Verbose = @{}
    if ($ENV:BHCommitMessage -match "!verbose")
    {
        $Verbose = @{Verbose = $True}
    }

}

task Default -depends Test

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*

    $modules = 'Pester', 'PSDeploy', 'PSScriptAnalyzer'
    Install-Module $modules -Confirm:$false
    Import-Module $modules -Verbose:$false -Force
}

# Test entire project
task Test -depends Init, Analyze, Pester {
}

task Analyze -Depends Init {
    $lines
    $saResults = Invoke-ScriptAnalyzer -Path $sut -Severity Error -Recurse -Verbose:$false -ExcludeRule 'PSUseToExportFieldsInManifest'

    if ($saResults)
    {
        $saResults | Format-Table
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'
    }
}

task Pester -Depends Init {
    $lines
    if (-not $ENV:BHProjectPath)
    {
        Set-BuildEnvironment -Path $PSScriptRoot\..
    }
    Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue
    Import-Module (Join-Path $ENV:BHProjectPath $ENV:BHProjectName) -Force

    $testResults = Invoke-Pester -Path $tests -PassThru
    if ($testResults.FailedCount -gt 0)
    {
        $testResults | Format-List
        Write-Error -Message 'One or more Pester tests failed. Build cannot continue!'
    }
}

task Build -depends Test {
    $lines

    # Load the module, read the exported functions, update the psd1 FunctionsToExport
    Set-ModuleFunctions

    # Bump the module version
    Try
    {
        $Version = Get-NextNugetPackageVersion -Name $env:BHProjectName -ErrorAction Stop
        Update-Metadata -Path $env:BHPSModuleManifest -PropertyName ModuleVersion -Value $Version -ErrorAction Stop
    }
    Catch
    {
        "Failed to update version for '$env:BHProjectName': $_.`nContinuing with existing version"
    }
}

task Deploy -depends Build {
    $lines

    $Params = @{
        Path    = "$ProjectRoot\Build"
        Force   = $true
        Recurse = $false # We keep psdeploy artifacts, avoid deploying those : )
    }
    Invoke-PSDeploy @Verbose @Params
}