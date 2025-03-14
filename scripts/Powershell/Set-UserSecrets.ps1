# Initialize user secrets if not already done
Write-Host "Initializing user secrets..." -ForegroundColor Green
dotnet user-secrets init --project ..\src\OracleHttpDemo.csproj

# Set the Oracle connection string as a user secret
Write-Host "Setting Oracle connection string in user secrets..." -ForegroundColor Green
dotnet user-secrets set "Kestrel:Certificates:Default:Password" "pa55w0rd!" --project ..\src\OracleHttpDemo.csproj

Write-Host "User secrets have been configured successfully!" -ForegroundColor Green