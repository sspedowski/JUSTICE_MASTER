Param(
  [Parameter(Mandatory=$true)] [string] $NewUrl
)

$path = Join-Path (Get-Location) 'Download-Exhibits.ps1'
if (-not (Test-Path $path)) { Write-Error "$path not found"; exit 1 }

$content = Get-Content -Path $path -Raw -Encoding UTF8

# Use regex to replace any existing 1drv.ms/f/... URL occurrences
$pattern1 = 'https://1drv\.ms/f/[^"\'']+'
$content = [regex]::Replace($content, $pattern1, [regex]::Escape($NewUrl))

# Replace the explicit placeholder for bundle B if present
$content = $content -replace 'https://YOUR_PUBLIC_LINK/Bundle_B_EX-006_to_EX-011.zip', [regex]::Escape($NewUrl)

Set-Content -Path $path -Value $content -Encoding UTF8
Write-Host "Updated $path"

git add $path
try {
  git commit -m "chore(docs): replace bundle URLs with direct OneDrive link" | Out-Null
  git push
} catch {
  Write-Host "No changes to commit or git push failed: $_"
}
