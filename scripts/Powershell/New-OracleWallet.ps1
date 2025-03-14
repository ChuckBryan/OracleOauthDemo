# Oracle Wallet Setup Script
# This script runs the necessary commands to create and configure the Oracle wallet
# for HTTPS connections from Oracle to the OpenIddict API

# Define the container name - Update this if your Oracle container has a different name
$containerName = "oracle-db"

Write-Host "===== Oracle Wallet Setup Process =====" -ForegroundColor Cyan
Write-Host "This script will perform the following steps:" -ForegroundColor Yellow
Write-Host "1. Create the Oracle wallet with auto-login enabled" -ForegroundColor Yellow
Write-Host "2. Add the OpenIddict API certificate to the wallet" -ForegroundColor Yellow
Write-Host "3. Verify the wallet configuration and certificate status" -ForegroundColor Yellow
Write-Host ""

# Step 1: Create the wallet
Write-Host "Step 1: Creating Oracle wallet..." -ForegroundColor Green
docker exec -it $containerName bash -c "cd /etc/ora_wallet/scripts && ./create_wallet.sh"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error creating wallet. Exiting." -ForegroundColor Red
    exit 1
}
Write-Host "Wallet creation completed." -ForegroundColor Green
Write-Host ""

# Step 2: Add the certificate to the wallet
Write-Host "Step 2: Adding certificate to wallet..." -ForegroundColor Green
docker exec -it $containerName bash -c "cd /etc/ora_wallet/scripts && ./add-cert-to-wallet.sh"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error adding certificate to wallet. Exiting." -ForegroundColor Red
    exit 1
}
Write-Host "Certificate added to wallet." -ForegroundColor Green
Write-Host ""

# Step 3: Verify the wallet configuration
Write-Host "Step 3: Verifying wallet configuration..." -ForegroundColor Green
docker exec -it $containerName bash -c "cd /etc/ora_wallet/scripts && ./check_wallet_files.sh"
if ($LASTEXITCODE -ne 0) {
    Write-Host "Wallet verification completed with warnings. Please review the output above." -ForegroundColor Yellow
} else {
    Write-Host "Wallet verification completed successfully." -ForegroundColor Green
}
Write-Host ""

Write-Host "===== Wallet Setup Complete =====" -ForegroundColor Cyan
Write-Host "The Oracle wallet has been configured for HTTPS connections." -ForegroundColor Green
Write-Host "You can now test the HTTPS connection with:" -ForegroundColor Yellow
Write-Host "SQL> SET SERVEROUTPUT ON" -ForegroundColor White
Write-Host "SQL> SELECT OAUTH_DEMO_USER.oauth_request() FROM DUAL;" -ForegroundColor White