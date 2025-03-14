# Dictionary to store alias descriptions
$sqlAliasDescriptions = @{
    'sql-oauth-request' = 'Creates or updates the OAUTH_REQUEST function in the database'
    'sql-extract-token' = 'Creates or updates the EXTRACT_ACCESS_TOKEN function in the database'
    'sql-get-token'     = 'Creates or updates the GET_ACCESS_TOKEN function in the database'
    'sql-call-api'      = 'Creates or updates the CALL_PROTECTED_API function in the database'
    'sqlplus'           = 'Opens a SQLPlus session in the Docker container'
    'sql-help'          = 'Shows all available SQL aliases and their descriptions'
}

# Set up functions for SQL commands
function Invoke-OAuthRequest {
    <#
    .SYNOPSIS
        Runs the OAuth request function creation script in SQLPlus
    .DESCRIPTION
        Executes the script that creates the OAUTH_REQUEST function in the Oracle database
    .EXAMPLE
        sql-oauth-request
    #>
    & "$PSScriptRoot\docker-sqlplus.ps1" "/container-entrypoint-initdb.d/004_create_oauth_request_function.sql"
}

function Invoke-ExtractToken {
    <#
    .SYNOPSIS
        Runs the extract access token function creation script in SQLPlus
    .DESCRIPTION
        Executes the script that creates the EXTRACT_ACCESS_TOKEN function in the Oracle database
    .EXAMPLE
        sql-extract-token
    #>
    & "$PSScriptRoot\docker-sqlplus.ps1" "/container-entrypoint-initdb.d/005_create_extract_access_token_function.sql"
}

function Invoke-GetToken {
    <#
    .SYNOPSIS
        Runs the get access token function creation script in SQLPlus
    .DESCRIPTION
        Executes the script that creates the GET_ACCESS_TOKEN function in the Oracle database
    .EXAMPLE
        sql-get-token
    #>
    & "$PSScriptRoot\docker-sqlplus.ps1" "/container-entrypoint-initdb.d/006_create_get_access_token_function.sql"
}

function Invoke-CallApi {
    <#
    .SYNOPSIS
        Runs the call protected API function creation script in SQLPlus
    .DESCRIPTION
        Executes the script that creates the CALL_PROTECTED_API function in the Oracle database
    .EXAMPLE
        sql-call-api
    #>
    & "$PSScriptRoot\docker-sqlplus.ps1" "/container-entrypoint-initdb.d/007_create_call_protected_api_function.sql"
}

function Invoke-SqlPlus {
    <#
    .SYNOPSIS
        Opens a SQLPlus session in the Docker container
    .DESCRIPTION
        Connects to SQLPlus in the Oracle Docker container using the OAUTH_DEMO_USER credentials
    .EXAMPLE
        sqlplus
    #>
    & "$PSScriptRoot\docker-sqlplus.ps1"
}

# Function to list all SQL aliases
function Show-SqlAliases {
    Write-Host "Available SQL Aliases:" -ForegroundColor Cyan
    Write-Host "====================" -ForegroundColor Cyan
    $sqlAliasDescriptions.GetEnumerator() | Sort-Object Name | ForEach-Object {
        Write-Host ("{0,-20} : {1}" -f $_.Name, $_.Value)
    }
}

# Create aliases
Set-Alias -Name sql-oauth-request -Value Invoke-OAuthRequest
Set-Alias -Name sql-extract-token -Value Invoke-ExtractToken
Set-Alias -Name sql-get-token -Value Invoke-GetToken
Set-Alias -Name sql-call-api -Value Invoke-CallApi
Set-Alias -Name sqlplus -Value Invoke-SqlPlus
Set-Alias -Name sql-help -Value Show-SqlAliases

# Show available aliases when the script is sourced
Show-SqlAliases