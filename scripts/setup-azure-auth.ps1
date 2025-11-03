# ===============================================
# setup-azure-auth.ps1
# Helper script to create Azure Service Principal for GitHub Actions
# ===============================================

param(
    [Parameter(Mandatory = $true)]
    [string]$SubscriptionId,
    
    [Parameter(Mandatory = $true)]
    [string]$ResourceGroupName,
    
    [string]$StorageAccountName = "disneyimages",
    
    [string]$ServicePrincipalName = "github-actions-disney-assets"
)

Write-Host "Setting up Azure Service Principal for GitHub Actions..." -ForegroundColor Cyan
Write-Host "Subscription ID: $SubscriptionId" -ForegroundColor Gray
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Gray
Write-Host "Storage Account: $StorageAccountName" -ForegroundColor Gray
Write-Host "Service Principal Name: $ServicePrincipalName" -ForegroundColor Gray
Write-Host ""

# Check if already logged in to Azure
$context = az account show --output json 2>$null | ConvertFrom-Json
if (-not $context) {
    Write-Host "Please log in to Azure first:" -ForegroundColor Yellow
    Write-Host "az login" -ForegroundColor Cyan
    exit 1
}

Write-Host "Current Azure account: $($context.user.name)" -ForegroundColor Green
Write-Host ""

# Set the subscription
Write-Host "Setting active subscription..." -ForegroundColor Yellow
az account set --subscription $SubscriptionId

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to set subscription. Please check the subscription ID." -ForegroundColor Red
    exit 1
}

# Build the scope for the storage account
$scope = "/subscriptions/$SubscriptionId/resourceGroups/$ResourceGroupName/providers/Microsoft.Storage/storageAccounts/$StorageAccountName"

Write-Host "Creating Service Principal with scope:" -ForegroundColor Yellow
Write-Host $scope -ForegroundColor Gray
Write-Host ""

# Create the service principal
Write-Host "Creating service principal..." -ForegroundColor Yellow
$credentials = az ad sp create-for-rbac `
    --name $ServicePrincipalName `
    --role "Storage Blob Data Contributor" `
    --scopes $scope `
    --sdk-auth

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to create service principal." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "✅ Service Principal created successfully!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Copy the following JSON and add it as a GitHub repository secret named 'AZURE_CREDENTIALS':" -ForegroundColor Cyan
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host $credentials -ForegroundColor White
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "🔗 To add this secret to your GitHub repository:" -ForegroundColor Yellow
Write-Host "1. Go to your GitHub repository" -ForegroundColor Gray
Write-Host "2. Click Settings → Secrets and variables → Actions" -ForegroundColor Gray
Write-Host "3. Click 'New repository secret'" -ForegroundColor Gray
Write-Host "4. Name: AZURE_CREDENTIALS" -ForegroundColor Gray
Write-Host "5. Value: Paste the JSON above" -ForegroundColor Gray
Write-Host ""
Write-Host "🚀 After adding the secret, your GitHub Actions workflow will be ready to deploy!" -ForegroundColor Green