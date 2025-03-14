# Script to convert Windows line endings (CRLF) to Unix line endings (LF)
# for shell scripts to work in Linux containers

Write-Host "Converting shell script line endings from CRLF to LF..." -ForegroundColor Cyan

$scripts = Get-ChildItem -Path "scripts/bash" -Filter "*.sh"
foreach ($script in $scripts) {
    Write-Host "Converting $($script.Name)..." -ForegroundColor Yellow
    $content = Get-Content -Path $script.FullName -Raw
    $content = $content -replace "`r`n", "`n"
    Set-Content -Path $script.FullName -Value $content -NoNewline
    Write-Host "✓ Converted $($script.Name)" -ForegroundColor Green
}

Write-Host "`nConversion complete. Shell scripts should now work in Linux containers." -ForegroundColor Cyan