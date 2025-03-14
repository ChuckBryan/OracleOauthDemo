# Script to remove files from Git tracking that are now in .gitignore
# This helps when you've already committed files that you now want to ignore

Write-Host "===== Removing gitignored files from Git tracking =====" -ForegroundColor Cyan
Write-Host "This script will remove the following types of files from Git tracking (but keep them on disk):" -ForegroundColor Yellow
Write-Host "- Certificate files (*.pfx, *.p12, *.pem, *.crt, etc.)" -ForegroundColor Yellow
Write-Host "- Oracle Wallet files (wallet folder, cwallet.sso, ewallet.p12, etc.)" -ForegroundColor Yellow
Write-Host "- Build outputs and user-specific files" -ForegroundColor Yellow
Write-Host ""

# First check if we're in a git repository
$isGitRepo = git rev-parse --is-inside-work-tree 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: This directory is not a Git repository." -ForegroundColor Red
    Write-Host "Please run this script from the root of your Git repository." -ForegroundColor Red
    exit 1
}

# Function to remove files by pattern
function Remove-GitTrackedPattern {
    param (
        [string]$Pattern,
        [string]$Description
    )
    
    Write-Host "Removing $Description..." -ForegroundColor Green
    
    # Find tracked files matching the pattern
    $files = git ls-files $Pattern 2>$null
    
    if ($files) {
        $fileArray = $files -split "`n"
        foreach ($file in $fileArray) {
            if ($file) {
                Write-Host "  Removing from Git tracking: $file" -ForegroundColor Yellow
                git rm --cached --quiet "$file" 2>$null
            }
        }
        return $fileArray.Count
    }
    
    return 0
}

# Remove certificate files
$certCount = Remove-GitTrackedPattern "*.pfx" "PFX certificate files"
$certCount += Remove-GitTrackedPattern "*.p12" "P12 certificate files"
$certCount += Remove-GitTrackedPattern "*.pem" "PEM certificate files"
$certCount += Remove-GitTrackedPattern "*.crt" "CRT certificate files"
$certCount += Remove-GitTrackedPattern "*.key" "KEY files"

# Remove wallet files
$walletCount = Remove-GitTrackedPattern "wallet/*" "wallet directory files"
$walletCount += Remove-GitTrackedPattern "cwallet.sso*" "Oracle SSO wallet files"
$walletCount += Remove-GitTrackedPattern "ewallet.p12*" "Oracle P12 wallet files"
$walletCount += Remove-GitTrackedPattern "certs/*" "certificate files in certs directory"

# Remove binary and build files
$buildCount = Remove-GitTrackedPattern "bin/*" "binary output files"
$buildCount += Remove-GitTrackedPattern "obj/*" "object files"

# Summarize
Write-Host ""
Write-Host "===== Summary =====" -ForegroundColor Cyan
Write-Host "Removed $certCount certificate files from tracking" -ForegroundColor Green
Write-Host "Removed $walletCount wallet files from tracking" -ForegroundColor Green
Write-Host "Removed $buildCount build files from tracking" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Verify everything looks correct with: git status" -ForegroundColor Yellow
Write-Host "2. Commit these changes with: git commit -m 'Remove sensitive files from tracking'" -ForegroundColor Yellow
Write-Host ""
Write-Host "Note: The files still exist on your disk, they're just no longer tracked by Git." -ForegroundColor White