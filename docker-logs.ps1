param(
    [Parameter(Mandatory=$true)]
    [ValidateSet('db', 'api')]
    [string]$Service,
    
    [Parameter(Mandatory=$false)]
    [switch]$Follow
)

$containerName = if ($Service -eq 'db') { 'oracle-db' } else { 'openiddict-api' }

if ($Follow) {
    docker logs --follow --tail 1 $containerName
} else {
    docker logs $containerName
}