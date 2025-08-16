# Justice_Master Repository Setup Script

# Initialize Git LFS
Write-Host "Initializing Git LFS..." -ForegroundColor Green
git lfs install

# Create main directory structure
$directories = @(
    "01_Instructions",
    "02_Batches",
    "02_Batches/Batch_1",
    "02_Batches/Batch_2",
    "02_Batches/Batch_N",
    "03_Exhibits",
    "03_Exhibits/By_Recipient/Courts",
    "03_Exhibits/By_Recipient/DOJ",
    "03_Exhibits/By_Recipient/FBI",
    "03_Exhibits/By_Recipient/Media",
    "04_Analysis",
    "04_Analysis/SideBySide",
    "04_Analysis/Timelines",
    "04_Analysis/Whistleblower",
    "05_Dashboard",
    "05_Dashboard/frontend",
    "05_Dashboard/backend",
    "05_Dashboard/tests",
    "06_Distribution",
    "07_Book_Project"
)

# Create directories
foreach ($dir in $directories) {
    $path = Join-Path $PSScriptRoot $dir
    if (-not (Test-Path $path)) {
        Write-Host "Creating directory: $dir" -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $path -Force | Out-Null
    }
}

# Configure Git LFS tracking for common file types
$lfsTypes = @(
    "*.pdf",
    "*.docx",
    "*.xlsx",
    "*.png",
    "*.jpg",
    "*.jpeg"
)

foreach ($type in $lfsTypes) {
    Write-Host "Setting up Git LFS tracking for $type" -ForegroundColor Cyan
    git lfs track $type
}

Write-Host "`nRepository setup completed successfully!" -ForegroundColor Green
