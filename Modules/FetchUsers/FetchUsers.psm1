
function List-AzureDevOpsOrganizationUsers {
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
    $baseUrl = $baseUrl -replace "https://", "https://vssps."

    $userUri = "$baseUrl/_apis/graph/users?api-version=$apiVersion"

    $response = (Invoke-RestMethod -Uri $userUri -Method Get -Headers $headers)

    $users = New-Object System.Collections.Generic.List[PSCustomObject]

    foreach ($user in $response.value) {
        $userObject = [PSCustomObject]@{
            UserName = $user.directoryAlias
            Email = $user.mailAddress
            PrincipalName = $user.principalName
            DisplayName = $user.displayName
            Origin = $user.origin
            OriginId = $user.originId
            Domain = $user.domain
        }
        Write-Host "User: $($userObject.DisplayName) ($($userObject.UserName))"
        
        $users.Add($userObject)
    }

    return $users
}