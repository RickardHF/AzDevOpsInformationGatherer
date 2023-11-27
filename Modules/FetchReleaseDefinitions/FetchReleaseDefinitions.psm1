
function List-AzureDevOpsOrganizationReleaseDefinitions {

    param (
        [string] $organization,
        [string] $personalAccessToken,
        [string] $serverUrl = "https://dev.azure.com",
        [string] $apiVersion = "6.0"
    )
    $headers = @{
        Authorization = "Basic " + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$personalAccessToken"))
    }
    
    $baseUrl = "$serverUrl/$organization"
    
    $projectUri = "$baseUrl/_apis/projects?api-version=$apiVersion"
    
    $projects = (Invoke-RestMethod -Uri $projectUri -Method Get -Headers $headers).value
    
    # List all release definitions for each project
    $releaseDefinitions = @()
    
    foreach ($project in $projects) {
        $projectName = $project.name
        $releaseDefinitionUrl = "$baseUrl/$projectName/_apis/release/definitions?api-version=$apiVersion"
        $projectReleaseDefinitions = (Invoke-RestMethod -Uri $releaseDefinitionUrl -Method Get -Headers $headers).value
        foreach ($projectReleaseDefinition in $projectReleaseDefinitions) {
            $releaseDefinition = [PSCustomObject]@{
                ProjectName = $projectName
                ReleaseDefinitionId = $projectReleaseDefinition.id
                ReleaseDefinitionName = $projectReleaseDefinition.name
            }
            $releaseDefinitions += $releaseDefinition
        }
    }

    return $releaseDefinitions
}
