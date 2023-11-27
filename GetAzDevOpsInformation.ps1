
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string] $organization,
    [Parameter(Mandatory = $true)]
    [string] $personalAccessToken,
    [Parameter()]
    [string] $serverUrl = "https://dev.azure.com",
    [Parameter()]
    [ValidateSet("Services", "2022", "2020", "2019", "2018.2", "2018")]
    [string] $type = "Services",
    [Parameter()]
    [boolean] $skipReleases = $false
)

# Api Version Matrix
$versions = @{
    "Services" = "7.1"
    "2022" = "7.0"
    "2020" = "6.0"
    "2019" = "5.0"
    "2018.2" = "4.1"
    "2018" = "4.0"
}

# Set Api Version
$apiVersion = $versions[$type]

$scriptPath = $PSScriptRoot

$modulesPath = "$scriptPath/Modules"
$modules = Get-ChildItem -Path $modulesPath -Directory

# Import all modules
foreach ($module in $modules) {
    $moduleName = $module.Name
    $modulePath = "$modulesPath/$moduleName/$moduleName.psm1"
    Write-Host "Importing module $moduleName from $modulePath"
    Import-Module $modulePath -Force -Verbose
}

# List all build definitions
Write-Information "Fetching build definitions"
$pipelines = List-AzureDevOpsOrganizationBuildDefinitions -organization $organization -personalAccessToken $personalAccessToken -serverUrl $serverUrl -apiVersion $apiVersion

$pipelines | Export-Csv -Path builddefinitions.csv -NoTypeInformation

# List all release definitions
if(!$skipReleases) {
    Write-Information "Fetching release definitions"
    $releaseDefinitions = List-AzureDevOpsOrganizationReleaseDefinitions -organization $organization -personalAccessToken $personalAccessToken -serverUrl $serverUrl -apiVersion $apiVersion
    $releaseDefinitions | Export-Csv -Path releasesdefinitions.csv -NoTypeInformation
}

# List Changesets
Write-Information "Fetching changesets"
$changesets = Get-AzureDevOpsAmountOfChangesets -organization $organization -personalAccessToken $personalAccessToken -serverUrl $serverUrl -apiVersion $apiVersion
$changesets | Export-Csv -Path changesets.csv -NoTypeInformation

