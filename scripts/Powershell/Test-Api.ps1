# Test API script for OpenIddict demo

# Skip certificate validation for local testing
$PSDefaultParameterValues = @{
    "Invoke-RestMethod:SkipCertificateCheck" = $true
    "Invoke-WebRequest:SkipCertificateCheck" = $true
}

# Configuration
$baseUrl = "https://localhost:7104"
$tokenEndpoint = "$baseUrl/connect/token"
$clientId = "test-client"
$clientSecret = "test-secret"

Write-Host "Requesting access token..." -ForegroundColor Cyan

# Request token using client credentials flow
$tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenEndpoint -Body @{
    grant_type = "client_credentials"
    client_id = $clientId
    client_secret = $clientSecret
    scope = "api"
} -ContentType "application/x-www-form-urlencoded"

Write-Host "Access token received successfully!" -ForegroundColor Green

# Access the protected API
Write-Host "`nTesting protected API endpoint..." -ForegroundColor Cyan
$apiResponse = Invoke-RestMethod -Method Get -Uri "$baseUrl/api/testapi" -Headers @{
    Authorization = "Bearer $($tokenResponse.access_token)"
}

Write-Host "API Response:" -ForegroundColor Green
$apiResponse | ConvertTo-Json
