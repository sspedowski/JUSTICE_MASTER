# setup.ps1
# Initializes Git LFS and creates necessary Git configuration files for Justice_Master
# Enable strict mode and error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Test-CommandExists {
    param($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {
        if (Get-Command $command) { return $true }
    }
    catch { return $false }
    finally { $ErrorActionPreference = $oldPreference }
}
# Verify Git is installed
if (-not (Test-CommandExists 'git')) {
    Write-Host "Git is not installed. Please install Git first." -ForegroundColor Red
    exit 1
}
# setup.ps1
# Initializes Git LFS and creates necessary Git configuration files for Justice_Master
# Enable strict mode and error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
function Test-CommandExists {
    param($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {
        if (Get-Command $command) { return $true }
    }
    catch { return $false }
    finally { $ErrorActionPreference = $oldPreference }
}
# Verify Git is installed
if (-not (Test-CommandExists 'git')) {
    Write-Host "Git is not installed. Please install Git first." -ForegroundColor Red
    exit 1
}
# Check if Git LFS is installed
if (-not (Test-CommandExists 'git-lfs')) {
    Write-Host "Git LFS is not installed. Please install it first." -ForegroundColor Red
    Write-Host "Visit https://git-lfs.github.com/ for installation instructions." -ForegroundColor Yellow
    exit 1
}
# Initialize Git LFS
Write-Host "Initializing Git LFS..." -ForegroundColor Green
try {
    $output = git lfs install 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error initializing Git LFS: $output" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "Failed to initialize Git LFS: $_" -ForegroundColor Red
    exit 1
}
# Create .gitattributes with LFS patterns
$desiredGitattributes = @(
    "*.pdf filter=lfs diff=lfs merge=lfs -text",
    "*.docx filter=lfs diff=lfs merge=lfs -text",
    "*.xlsx filter=lfs diff=lfs merge=lfs -text",
    "*.pptx filter=lfs diff=lfs merge=lfs -text",
    "",
    "# Text files should have normal line endings",
    "*.md text eol=lf",
    "*.ps1 text eol=lf",
    "*.txt text eol=lf",
    "*.csv text eol=lf"
)
try {
    if (-not (Test-Path ".gitattributes")) {
        $desiredGitattributes -join "`n" | Out-File -FilePath ".gitattributes" -Encoding utf8NoBOM
        Write-Host "Created .gitattributes file" -ForegroundColor Green
    } else {
        $existing = Get-Content -Path ".gitattributes" -Encoding utf8NoBOM -ErrorAction Stop
        $toAdd = @()
        foreach ($line in $desiredGitattributes) {
            if (-not ($existing -contains $line)) { $toAdd += $line }
        }
        if ($toAdd.Count -gt 0) {
            "`n" + ($toAdd -join "`n") | Out-File -FilePath ".gitattributes" -Encoding utf8NoBOM -Append
            Write-Host "Updated .gitattributes with new patterns" -ForegroundColor Green
        }
    }
}
catch {
    Write-Host "Error managing .gitattributes: $_" -ForegroundColor Red
    exit 1
}
# Create .gitignore file with improved patterns
$gitignoreContent = @"
# OS generated files
.DS_Store*
@"
# OS generated files
.DS_Store*
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
# IDE files
.vscode/
.idea/
*.swp
*.swo
*~
# Temporary files
*.bak
*.tmp
*.temp
# Node modules (for dashboard)
node_modules/
05_Dashboard/frontend/node_modules/
05_Dashboard/backend/node_modules/
# Build outputs
dist/
build/
05_Dashboard/frontend/build/
05_Dashboard/backend/dist/
# Environment files
.env*
!.env.example
# Logs
*.log
npm-debug.log*
"@
try {
    if (-not (Test-Path ".gitignore")) {
        Set-Content -Path ".gitignore" -Value $gitignoreContent -Encoding utf8NoBOM
        Write-Host "Created .gitignore file" -ForegroundColor Green
    } else {
        $existingIgnore = Get-Content -Path ".gitignore" -Encoding utf8NoBOM -ErrorAction Stop
        $toAddIgnore = @()
        foreach ($line in ($gitignoreContent -split "`n")) {
            $trim = $line.Trim()
            if ($trim -ne "" -and -not ($existingIgnore -contains $trim)) { 
                $toAddIgnore += $trim 
            }
        }
        if ($toAddIgnore.Count -gt 0) {
            "`n" + ($toAddIgnore -join "`n") | Out-File -FilePath ".gitignore" -Encoding utf8NoBOM -Append
            Write-Host "Updated .gitignore with new patterns" -ForegroundColor Green
        }
    }
}
catch {
    Write-Host "Error managing .gitignore: $_" -ForegroundColor Red
    exit 1
}
# Initialize Git repository if needed
if (-not (Test-Path ".git")) {
    Write-Host "Initializing Git repository..." -ForegroundColor Green
    try {
        git init
        if ($LASTEXITCODE -ne 0) {
            throw "Git init failed"
        }
    }
    catch {
        Write-Host "Failed to initialize Git repository: $_" -ForegroundColor Red
        exit 1
    }
}
# Add and commit the Git configuration files
try {
    git add .gitattributes .gitignore
    $status = git status --porcelain
    if ($status) {
        git commit -m "chore: initialize repository with Git LFS configuration"
        Write-Host "Committed Git configuration files" -ForegroundColor Green
    } else {
        Write-Host "No changes to commit" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Error committing configuration files: $_" -ForegroundColor Red
    exit 1
}
Write-Host "`nRepository setup complete!" -ForegroundColor Green
Write-Host "Git LFS is tracking: *.pdf, *.docx, *.xlsx, *.pptx" -ForegroundColor Cyan
Write-Host "Text files are configured with LF line endings" -ForegroundColor Cyan