# insert_sha.ps1 - find latest EVIDENCE package, compute SHA-256, insert into FBI_Submission_Email.txt, commit & push
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$pkg = Get-ChildItem -Recurse -Filter 'EVIDENCE_PACKAGE-*.zip' | Select-Object -First 1
if (-not $pkg) { Write-Error 'Package not found (EVIDENCE_PACKAGE-*.zip)'; exit 1 }

Write-Host "Found package: $($pkg.FullName)"
$hash = (Get-FileHash -Algorithm SHA256 -Path $pkg.FullName).Hash
Write-Host "SHA-256: $hash"

$emailPath = Join-Path (Get-Location) 'FBI_Submission_Email.txt'
if (-not (Test-Path $emailPath)) { Write-Error "FBI_Submission_Email.txt not found in current dir"; exit 1 }

$content = Get-Content -Path $emailPath -Raw -Encoding UTF8
$content = $content -replace '<compute-and-insert-sha256-here>', $hash
Set-Content -Path $emailPath -Value $content -Encoding UTF8

Write-Host "Updated $emailPath"

# Git commit & push
git add $emailPath
if (git commit -m "docs(email): embed SHA-256 for evidence package") {
  git push
} else {
  Write-Host "No changes to commit or commit failed."
}
