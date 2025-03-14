param(
    [Parameter(Mandatory=$true)]
    [string]$PathToAdd
)

# Ensure the path exists
if (-not (Test-Path $PathToAdd)) {
    Write-Error "The specified path does not exist: $PathToAdd"
    exit 1
}

# Get the current user PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Check if the path is already in the PATH
if ($currentPath -split ";" -contains $PathToAdd) {
    Write-Host "Path already exists in the user PATH: $PathToAdd"
    exit 0
}

# Add the new path
$newPath = $currentPath + ";" + $PathToAdd

# Set the new PATH
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

Write-Host "Successfully added '$PathToAdd' to the user PATH"
