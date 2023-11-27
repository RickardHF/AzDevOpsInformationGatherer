
function List-AzureDevOpsOrganizationBuildDefinitions {
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

    # List all build definitions
    $pipelines = @()

    foreach ($project in $projects) {
        $projectName = $project.name
        $buildDefinitionUrl = "$baseUrl/$projectName/_apis/build/definitions?api-version=$apiVersion"
        $projectPipelines = (Invoke-RestMethod -Uri $buildDefinitionUrl -Method Get -Headers $headers).value
        foreach ($projectPipeline in $projectPipelines) {
            $pipeline = [PSCustomObject]@{
                ProjectName = $projectName
                PipelineName = $projectPipeline.name
                PipelineId = $projectPipeline.id
                PipelineType = $projectPipeline.type
                PipelineStatus = $projectPipeline.queueStatus
            }
            $pipelines += $pipeline
        }
    }

    return $pipelines

}
