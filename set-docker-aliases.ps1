# Dictionary to store alias descriptions
$aliasDescriptions = @{
    'dsql'     = 'Connect to SQLPlus in Docker container'
    'dlogs'    = 'View Docker logs (generic)'
    'dlogsdb'  = 'View Oracle database logs'
    'dlogsapi' = 'View API logs'
    'dlogsdbf' = 'View Oracle database logs (following)'
    'dlogsapif'= 'View API logs (following)'
    'testapi'  = 'Run API tests'
    'ddown'    = 'Docker compose down'
    'ddownv'   = 'Docker compose down (with volumes)'
    'dup'      = 'Docker compose up (detached)'
    'dps'      = 'Docker compose ps'
    'dpsa'     = 'Docker compose ps (all containers)'
    'dhelp'    = 'Show all Docker aliases and their descriptions'
}

# Set alias for SQLPlus connection
Set-Alias -Name dsql -Value $PSScriptRoot\docker-sqlplus.ps1

# Set alias for Docker logs (generic)
Set-Alias -Name dlogs -Value $PSScriptRoot\docker-logs.ps1

# Set specific aliases for db and api logs
function Show-DbLogs { & $PSScriptRoot\docker-logs.ps1 db }
Set-Alias -Name dlogsdb -Value Show-DbLogs

function Show-ApiLogs { & $PSScriptRoot\docker-logs.ps1 api }
Set-Alias -Name dlogsapi -Value Show-ApiLogs

# Set specific aliases for following logs
function Show-DbLogsFollow { & $PSScriptRoot\docker-logs.ps1 db -Follow }
Set-Alias -Name dlogsdbf -Value Show-DbLogsFollow

function Show-ApiLogsFollow { & $PSScriptRoot\docker-logs.ps1 api -Follow }
Set-Alias -Name dlogsapif -Value Show-ApiLogsFollow

# Set alias for Test-Api script
Set-Alias -Name testapi -Value $PSScriptRoot\scripts\Powershell\Test-Api.ps1

# Set Docker Compose aliases
function Docker-ComposeDown { docker compose down }
Set-Alias -Name ddown -Value Docker-ComposeDown

function Docker-ComposeDownVolumes { docker compose down -v }
Set-Alias -Name ddownv -Value Docker-ComposeDownVolumes

function Docker-ComposeUp { docker compose up -d }
Set-Alias -Name dup -Value Docker-ComposeUp

function Docker-ComposePs { docker compose ps }
Set-Alias -Name dps -Value Docker-ComposePs

function Docker-ComposePsAll { docker compose ps -a }
Set-Alias -Name dpsa -Value Docker-ComposePsAll

# Function to list all Docker aliases
function Show-DockerAliases {
    Write-Host "Available Docker Aliases:" -ForegroundColor Cyan
    Write-Host "======================" -ForegroundColor Cyan
    $aliasDescriptions.GetEnumerator() | Sort-Object Name | ForEach-Object {
        Write-Host ("{0,-10} : {1}" -f $_.Name, $_.Value)
    }
}
Set-Alias -Name dhelp -Value Show-DockerAliases

# Show available aliases when the script is sourced
Show-DockerAliases