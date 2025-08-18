# Create zip for 02_Batches\Batch_03 with EVIDENCE marker and compute SHA256
Set-StrictMode -Version Latest
$RepoRoot = 'C:\Users\ssped\Documents\JUSTICE_MASTER'
Set-Location -Path $RepoRoot
$Folder = Join-Path $RepoRoot '02_Batches\Batch_03'
if (-not (Test-Path $Folder)) { Write-Error "Folder missing: $Folder"; exit 1 }
$Date = Get-Date -Format 'yyyyMMdd-HHmm'
$Stage = "_exhibits_stage_$Date"
$ZipOut = "Exhibits_$Date.zip"
if (Test-Path $Stage) { Remove-Item -Recurse -Force $Stage -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Force -Path $Stage | Out-Null
Copy-Item -Recurse -Force -Path (Join-Path $Folder '*') -Destination $Stage
'EVIDENCE: THIS IS EVIDENCE' | Set-Content -Encoding UTF8 (Join-Path $Stage 'EVIDENCE.txt')
if (Test-Path $ZipOut) { Remove-Item -Force $ZipOut -ErrorAction SilentlyContinue }
Compress-Archive -Path (Join-Path $Stage '*') -DestinationPath $ZipOut -Force
Remove-Item -Recurse -Force $Stage -ErrorAction SilentlyContinue
$Hash = (Get-FileHash -Algorithm SHA256 $ZipOut).Hash
"$ZipOut`nSHA256: $Hash" | Tee-Object -FilePath 'EXHIBITS_SHA256.txt' | Out-Null
Write-Host "Created:" (Resolve-Path $ZipOut)
Write-Host "SHA256:" $Hash
exit 0
