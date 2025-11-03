# Disney App Assets - Automated Deployment

This repository contains static image assets for the Disney movies application. The assets are automatically deployed to Azure Blob Storage whenever changes are pushed to the main branch.

## Repository Structure

```
├── dist/
│   ├── movies/          # Movie poster images
│   └── characters/      # Character profile images
├── scripts/
│   └── upload-test.ps1  # Manual upload test script
└── .github/
    └── workflows/
        └── publish-assets.yml  # Automated deployment workflow
```

## Automated Deployment

### Overview

The GitHub Actions workflow automatically uploads all images from the `dist/` directory to Azure Blob Storage when:

- Changes are pushed or merged to the `main` branch AND files in `dist/**` are modified
- The workflow is manually triggered via GitHub Actions UI

### Target Storage Location

- **Storage Account**: `disneyimages`
- **Container**: `images`
- **Prefix**: `disney-movies-app`
- **Public Base URL**: `https://disneyimages.blob.core.windows.net/images/disney-movies-app`

## Setup Guide (One-Time Configuration)

### Step 1: Create Azure Service Principal

We've provided a helper script to simplify this process:

```powershell
# Run this ONE TIME on your local machine (requires Azure CLI)
.\scripts\setup-azure-auth.ps1 -SubscriptionId "your-subscription-id" -ResourceGroupName "your-resource-group"
```

**What this script does:**

1. Creates an Azure Service Principal with proper permissions
2. Generates the credentials JSON needed for GitHub Actions
3. Displays the JSON for you to copy

**Alternative manual approach:**

```bash
az ad sp create-for-rbac \
  --name "github-actions-disney-assets" \
  --role "Storage Blob Data Contributor" \
  --scopes "/subscriptions/{subscription-id}/resourceGroups/{resource-group}/providers/Microsoft.Storage/storageAccounts/disneyimages" \
  --sdk-auth
```

### Step 2: Configure GitHub Repository Secret

After running the setup script:

1. **Copy the JSON output** from the script
2. Go to your GitHub repository → **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. **Name**: `AZURE_CREDENTIALS`
5. **Value**: Paste the JSON from step 1

### Required GitHub Secrets

#### AZURE_CREDENTIALS (Required)

This contains the Service Principal credentials as JSON. Created using the setup script above.

#### 2. Optional Repository Variables

You can also configure these as repository variables (not secrets) for easier management:

- `AZURE_STORAGE_ACCOUNT`: Storage account name (default: `disneyimages`)
- `AZURE_STORAGE_CONTAINER`: Container name (default: `images`)
- `AZURE_DEST_PREFIX`: Destination prefix (default: `disney-movies-app`)

### Setting up GitHub Secrets and Variables

1. Go to your repository on GitHub
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Add the required secrets and optionally the variables mentioned above

### Supported Image Formats

The workflow automatically detects and uploads the following image formats:

- `.jpg` / `.jpeg`
- `.png`
- `.gif`
- `.webp`
- `.svg`

Content types are automatically set based on file extensions.

## Manual Testing

### Using the PowerShell Script

For local testing, use the provided PowerShell script:

```powershell
# From the repository root
./scripts/upload-test.ps1
```

This script uploads a few sample images and displays the public URLs.

### Manual Workflow Trigger

You can manually trigger the deployment workflow:

1. Go to **Actions** tab in your GitHub repository
2. Select **Deploy Assets to Azure Blob Storage**
3. Click **Run workflow**
4. Optionally enable debug mode for verbose output

## Accessing Deployed Assets

After deployment, your assets will be available at:

### Base URLs

- **Movies**: `https://disneyimages.blob.core.windows.net/images/disney-movies-app/movies/`
- **Characters**: `https://disneyimages.blob.core.windows.net/images/disney-movies-app/characters/`

### Example URLs

```
https://disneyimages.blob.core.windows.net/images/disney-movies-app/movies/101_dalmatians_1.jpg
https://disneyimages.blob.core.windows.net/images/disney-movies-app/characters/prf_3_peas-in-a-pod.png
```

## Security & Authentication

- The workflow uses **Azure AD Service Principal authentication** (no storage account keys)
- Credentials are securely stored as GitHub encrypted secrets
- The workflow only runs on the `main` branch for security
- Manual triggers are available for testing purposes

## Troubleshooting

### Common Issues

1. **Authentication Failed**

   - Verify `AZURE_CREDENTIALS` secret is properly formatted JSON
   - Ensure the Service Principal has `Storage Blob Data Contributor` role
   - Check that the subscription, resource group, and storage account paths are correct

2. **Files Not Uploading**

   - Verify files exist in `dist/movies/` and `dist/characters/` directories
   - Check that file extensions are supported image formats
   - Enable debug mode in manual workflow trigger for detailed logs

3. **Wrong Public URLs**
   - Verify storage account name, container name, and prefix in repository variables
   - Check that the storage account allows public blob access

### Viewing Deployment Logs

1. Go to **Actions** tab in GitHub
2. Click on a workflow run
3. Expand the job steps to see detailed upload logs
4. Look for the public URLs printed at the end of the deployment

## Development Workflow

1. Add/modify images in the `dist/` directory
2. Commit and push changes to a feature branch
3. Create a pull request to `main`
4. After merge, the workflow automatically deploys the assets
5. Verify deployment by checking the public URLs

---

## Local Development

To serve the assets locally for testing:

```bash
npm run serve
```

This starts a local server at `http://localhost:5001` serving the `dist/` directory.
