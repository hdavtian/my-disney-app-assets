# ===============================================
# upload-test.ps1
# Uploads a few sample images to Azure Blob Storage
# ===============================================

# --- Config ---
$ACCOUNT = "disneyimages"
$CONTAINER = "images"
$PREFIX = "disney-movies-app"

# --- Local test files (adjust paths as needed) ---
$CHAR_FILE = "C:\sites\my-disney-app-assets\dist\characters\prf_3_peas-in-a-pod.png"
$MOVIE_FILE = "C:\sites\my-disney-app-assets\dist\movies\101_dalmatians_1.jpg"

Write-Host "Uploading test images to Azure Blob Storage..." -ForegroundColor Cyan

# --- Character image ---
az storage blob upload `
    --account-name $ACCOUNT `
    --auth-mode login `
    --container-name $CONTAINER `
    --file "$CHAR_FILE" `
    --name "$PREFIX/characters/prf_3_peas-in-a-pod.png" `
    --content-type "image/png" `
    --overwrite

# --- Movie image ---
az storage blob upload `
    --account-name $ACCOUNT `
    --auth-mode login `
    --container-name $CONTAINER `
    --file "$MOVIE_FILE" `
    --name "$PREFIX/movies/101_dalmatians_1.jpg" `
    --content-type "image/jpeg" `
    --overwrite

Write-Host "`n✅ Upload complete! Test URLs:" -ForegroundColor Green
Write-Host "https://$ACCOUNT.blob.core.windows.net/$CONTAINER/$PREFIX/characters/prf_3_peas-in-a-pod.png"
Write-Host "https://$ACCOUNT.blob.core.windows.net/$CONTAINER/$PREFIX/movies/101_dalmatians_1.jpg"
