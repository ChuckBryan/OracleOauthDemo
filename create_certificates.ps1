# PowerShell script to generate self-signed certificates for HTTPS
# This script creates certificates with specific CN for openiddict-api and
# updates the Windows certificate store to trust them

# Configuration variables
$certsDir = ".\certs"
$certCN = "openiddict-api"
$certPassword = "pa55w0rd!"  # Updated to match your existing password
$certKeyFile = "$certsDir\$certCN.pem"
$certPublicFile = "$certsDir\$certCN.crt"
$certPfxFile = "$certsDir\$certCN.pfx"
$opensslConfigFile = "$certsDir\openssl.cnf"

# Ensure the certs directory exists
if (-not (Test-Path -Path $certsDir)) {
    Write-Host "Creating certs directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $certsDir | Out-Null
}

# Create OpenSSL config file with SAN extension for the hostname
Write-Host "Creating OpenSSL configuration file..." -ForegroundColor Yellow
$opensslConfig = @"
[req]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[dn]
C = US
ST = Virginia
L = Virginia Beach
O = Marathon Consulting, LLC
OU = IT
CN = $certCN
emailAddress = admin@example.com

[req_ext]
subjectAltName = @alt_names

[alt_names]
DNS.1 = $certCN
DNS.2 = localhost
"@

Set-Content -Path $opensslConfigFile -Value $opensslConfig

# Create a function to check if OpenSSL is available
function Test-OpenSSL {
    try {
        $null = & openssl version
        return $true
    }
    catch {
        return $false
    }
}

# Check for OpenSSL
if (-not (Test-OpenSSL)) {
    Write-Host "Error: OpenSSL is not available in the PATH. Please install OpenSSL or add it to your PATH." -ForegroundColor Red
    exit 1
}

Write-Host "===== Generating certificates for $certCN =====" -ForegroundColor Cyan

# Step 1: Generate private key and certificate
Write-Host "Step 1: Generating private key and self-signed certificate..." -ForegroundColor Green
& openssl req -x509 -new -nodes -newkey rsa:2048 -keyout $certKeyFile -out $certPublicFile -config $opensslConfigFile -days 3650
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error generating certificate. Exiting." -ForegroundColor Red
    exit 1
}

# Step 2: Export to PFX format for ASP.NET Core
Write-Host "Step 2: Creating PFX file for ASP.NET Core..." -ForegroundColor Green
& openssl pkcs12 -export -out $certPfxFile -inkey $certKeyFile -in $certPublicFile -password pass:$certPassword
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error creating PFX file. Exiting." -ForegroundColor Red
    exit 1
}

# Step 3: Trust the certificate in Windows certificate store
Write-Host "Step 3: Adding certificate to Windows Trusted Root Certification Authorities..." -ForegroundColor Green
$securePassword = ConvertTo-SecureString -String $certPassword -Force -AsPlainText
Import-Certificate -FilePath $certPublicFile -CertStoreLocation Cert:\LocalMachine\Root

Write-Host "===== Certificate Generation Complete =====" -ForegroundColor Cyan
Write-Host "Certificate files created in the $certsDir directory:" -ForegroundColor Green
Write-Host "  - Private Key:  $certKeyFile" -ForegroundColor Yellow
Write-Host "  - Public Cert:  $certPublicFile" -ForegroundColor Yellow
Write-Host "  - PFX File:     $certPfxFile" -ForegroundColor Yellow
Write-Host ""
Write-Host "Certificate has been added to the Windows Trusted Root Certificate Store." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Use the OpenIddict API with these certificates" -ForegroundColor White
Write-Host "2. Import the certificate into Oracle Wallet using run_create_wallet.ps1" -ForegroundColor White
Write-Host ""
Write-Host "Certificate Password: $certPassword" -ForegroundColor Magenta
Write-Host "Make sure to save this password for later use with ASP.NET Core and Oracle Wallet." -ForegroundColor Magenta