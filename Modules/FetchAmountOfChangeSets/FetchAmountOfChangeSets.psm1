
function Get-AzureDevOpsAmountOfChangesets {
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
    
    Write-Information "Fetching projects from $projectUri"
    $projects = (Invoke-RestMethod -Uri $projectUri -Method Get -Headers $headers).value
    Write-Host $projects        
    Write-Information "Found $($projects.count) projects"
    # List amount of changesets for each project
    $changesets = @()
    
    Write-Information "Fetching changesets for each project"
    foreach ($project in $projects) {
        $projectName = $project.name
        $changesetUrl = "$baseUrl/$projectName/_apis/tfvc/changesets?api-version=$apiVersion"
        
        $changesetCount = 0
        $skip = 0
        $top = 100
        $hasMoteChangesets = $true
    
        do {
            Write-Host "Fetching for project $projectName skipping $skip ChangeSets"
    
            $uri = "$changesetUrl&`$top=$top&`$skip=$skip"
            $response = Invoke-RestMethod -Uri $uri -Method Get -Headers $headers
            $changesetCount += $response.count
            $skip += $response.value.count
    
            # Write-Host $response.value
            if($response.value.count -lt $top) {
                $hasMoteChangesets = $false
            }
        }
        while ($hasMoteChangesets)   
    
        $changeset = [PSCustomObject]@{
            ProjectName = $projectName
            ChangesetCount = $changesetCount
            LastChange = $project.lastUpdateTime
            State = $project.state
        }
        $changesets += $changeset
    }

    return $changesets

}
