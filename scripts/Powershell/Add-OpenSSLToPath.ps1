$openSSLPath = "C:\Program Files\OpenSSL-Win64\bin"

# Check if OpenSSL path exists
if (-not (Test-Path $openSSLPath)) {
    Write-Error "OpenSSL path not found. Please ensure OpenSSL is installed."
    exit 1
}

# Get current user PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Check if path already exists
if ($currentPath -split ";" -contains $openSSLPath) {
    Write-Host "OpenSSL path already exists in the user PATH"
    exit 0
}

# Add OpenSSL to PATH
$newPath = $currentPath + ";" + $openSSLPath
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")

Write-Host "Successfully added OpenSSL to the user PATH"
