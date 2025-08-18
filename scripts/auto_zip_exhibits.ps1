# Auto ZIP exhibits: pick top PDF folder, stage, add EVIDENCE, zip, and write SHA256
# Safe to run from any location; script sets repo root explicitly.

Set-StrictMode -Version Latest

$RepoRoot = 'C:\Users\ssped\Documents\JUSTICE_MASTER'
Set-Location -Path $RepoRoot

Write-Host "Repo root: $RepoRoot"

# Find PDF files
$files = Get-ChildItem -Path $RepoRoot -Recurse -File -Include *.pdf,*.PDF -ErrorAction SilentlyContinue
if (-not $files -or $files.Count -eq 0) {
    Write-Error 'No PDFs found under repo. Aborting.'
    exit 1
}

# Group by folder and pick the top folder
$group = $files | Group-Object DirectoryName | Sort-Object Count -Descending | Select-Object -First 1
$SourceFolder = $group.Name

$Date = Get-Date -Format 'yyyyMMdd-HHmm'
$Stage = "_exhibits_stage_$Date"
$ZipOut = "Exhibits_$Date.zip"

Write-Host "Selected folder: $SourceFolder (contains $($group.Count) PDFs)"

# Stage folder copy
if (Test-Path $Stage) { Remove-Item -Recurse -Force $Stage -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Force -Path $Stage | Out-Null
Copy-Item -Recurse -Force -Path (Join-Path $SourceFolder '*') -Destination $Stage

# Add evidence marker
'EVIDENCE: THIS IS EVIDENCE' | Set-Content -Encoding UTF8 (Join-Path $Stage 'EVIDENCE.txt')

# Build zip at repo root
if (Test-Path $ZipOut) { Remove-Item -Force $ZipOut -ErrorAction SilentlyContinue }
Compress-Archive -Path (Join-Path $Stage '*') -DestinationPath $ZipOut -Force

# Clean stage
Remove-Item -Recurse -Force $Stage -ErrorAction SilentlyContinue

# Compute SHA256
$Hash = (Get-FileHash -Algorithm SHA256 $ZipOut).Hash
"$ZipOut`nSHA256: $Hash" | Tee-Object -FilePath 'EXHIBITS_SHA256.txt' | Out-Null

Write-Host "`nCreated: " (Resolve-Path $ZipOut)
Write-Host "SHA256: $Hash"

# Exit 0
exit 0
