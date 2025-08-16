# setup.ps1
# Initializes Git LFS and creates necessary Git configuration files for Justice_Master

# Check if Git LFS is installed
if (-not (Get-Command git-lfs -ErrorAction SilentlyContinue)) {
    Write-Host "Git LFS is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Initialize Git LFS
Write-Host "Initializing Git LFS..." -ForegroundColor Green
git lfs install

# Create .gitattributes with LFS patterns
# Desired gitattributes entries
$desiredGitattributes = @(
    "*.pdf filter=lfs diff=lfs merge=lfs -text",
    "*.docx filter=lfs diff=lfs merge=lfs -text",
    "*.xlsx filter=lfs diff=lfs merge=lfs -text",
    "*.pptx filter=lfs diff=lfs merge=lfs -text",
    "",
    "# Text files should have normal line endings",
    "*.md text",
    "*.ps1 text",
    "*.txt text"
)

if (-not (Test-Path ".gitattributes")) {
    $desiredGitattributes -join "`n" | Set-Content -Path ".gitattributes" -Encoding UTF8
} else {
    $existing = Get-Content -Path ".gitattributes" -ErrorAction SilentlyContinue
    $toAdd = @()
    foreach ($line in $desiredGitattributes) {
        if (-not ($existing -contains $line)) { $toAdd += $line }
    }
    if ($toAdd.Count -gt 0) {
        "`n" + ($toAdd -join "`n") | Out-File -FilePath ".gitattributes" -Encoding UTF8 -Append
    }
}

# Create .gitignore file
$gitignoreContent = @"
# OS generated files
.DS_Store
.DS_Store?

.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo

# Temporary files
*~
*.bak
*.tmp

# Node modules (for dashboard)
05_Dashboard/frontend/node_modules/
05_Dashboard/backend/node_modules/

# Build outputs
05_Dashboard/frontend/build/
05_Dashboard/backend/dist/

# Environment files
.env
.env.local
*.env.*
"@

if (-not (Test-Path ".gitignore")) {
    Set-Content -Path ".gitignore" -Value $gitignoreContent -Encoding UTF8
} else {
    $existingIgnore = Get-Content -Path ".gitignore" -ErrorAction SilentlyContinue
    $toAddIgnore = @()
    foreach ($line in ($gitignoreContent -split "`n")) {
        $trim = $line.Trim()
        if ($trim -ne "" -and -not ($existingIgnore -contains $trim)) { $toAddIgnore += $trim }
    }
    if ($toAddIgnore.Count -gt 0) {
        "`n" + ($toAddIgnore -join "`n") | Out-File -FilePath ".gitignore" -Encoding UTF8 -Append
    }
}

# Initialize Git repository if not already initialized
if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git repository..." -ForegroundColor Green
    git init
}

# Add and commit the Git configuration files
git add .gitattributes .gitignore 2>$null
$status = git status --porcelain
if ($status) {
    git commit -m "chore: initialize repository with Git LFS configuration"
} else {
    Write-Host "No changes to commit." -ForegroundColor Yellow
}

Write-Host "Repository setup complete!" -ForegroundColor Green
Write-Host "Git LFS is tracking: *.pdf, *.docx, *.xlsx, *.pptx" -ForegroundColor Cyan
