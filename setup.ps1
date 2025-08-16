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
$gitattributesContent = @"
# Git LFS patterns
*.pdf filter=lfs diff=lfs merge=lfs -text
*.docx filter=lfs diff=lfs merge=lfs -text
*.xlsx filter=lfs diff=lfs merge=lfs -text
*.pptx filter=lfs diff=lfs merge=lfs -text

# Text files should have normal line endings
*.md text
*.ps1 text
*.txt text
"@

Set-Content -Path ".gitattributes" -Value $gitattributesContent -Encoding UTF8

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

Set-Content -Path ".gitignore" -Value $gitignoreContent -Encoding UTF8

# Initialize Git repository if not already initialized
if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git repository..." -ForegroundColor Green
    git init
}

# Add and commit the Git configuration files
git add .gitattributes .gitignore
git commit -m "chore: initialize repository with Git LFS configuration"

Write-Host "Repository setup complete!" -ForegroundColor Green
Write-Host "Git LFS is tracking: *.pdf, *.docx, *.xlsx, *.pptx" -ForegroundColor Cyan
