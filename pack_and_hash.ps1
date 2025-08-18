<#
PowerShell packer: pack_and_hash.ps1
Usage:
  .\pack_and_hash.ps1 -InputPath <path-to-dir-or-zip> -OutName <base-name>

If InputPath is a ZIP file, it will be extracted to a temp folder and processed.
Outputs: package-YYYYMMDD-HHMMSS\MANIFEST.csv, COC.md, <OutName>.zip
#>

param(
  [Parameter(Mandatory=$true)] [string] $InputPath,
  [Parameter(Mandatory=$false)] [string] $OutName = "EVIDENCE_PACKAGE",
  [Parameter(Mandatory=$false)] [string] $OutputRoot = "."
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Compute-Hash([string]$path) {
  $h = Get-FileHash -Algorithm SHA256 -Path $path
  return $h.Hash
}

function Write-Manifests([string]$workdir, [string]$manifestPath, [string]$cocPath) {
  $files = Get-ChildItem -Recurse -File -Path $workdir | Sort-Object FullName
  $rows = @()
  foreach ($f in $files) {
    $rel = $f.FullName.Substring($workdir.Length).TrimStart([io.path]::DirectorySeparatorChar)
    $hash = Compute-Hash $f.FullName
    $size = $f.Length
    $rows += [PSCustomObject]@{ Path = $rel; SizeBytes = $size; SHA256 = $hash }
  }
  $rows | Export-Csv -Path $manifestPath -NoTypeInformation -Encoding UTF8

  $now = (Get-Date).ToUniversalTime().ToString("o")
  $cocEntry = "`n$now,pack_and_hash.ps1,packaged,$($rows.Count) files"
  if (-Not (Test-Path $cocPath)) { "date_utc,handler_name,action,notes" | Out-File -FilePath $cocPath -Encoding UTF8 }
  Add-Content -Path $cocPath -Value $cocEntry -Encoding UTF8
}

# Normalize InputPath
$absInput = Resolve-Path -Path $InputPath -ErrorAction Stop
$absInput = $absInput.ProviderPath

$tempDir = Join-Path $env:TEMP ([System.Guid]::NewGuid().ToString())
$stageDir = $null
New-Item -ItemType Directory -Path $tempDir | Out-Null

try {
  if ([io.path]::GetExtension($absInput).ToLower() -eq '.zip') {
    Write-Host "Input is a ZIP, extracting to temp folder..."
    $stageDir = Join-Path $tempDir "stage"
    New-Item -ItemType Directory -Path $stageDir | Out-Null
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($absInput, $stageDir)
  } else {
    Write-Host "Input is a directory, copying to temp stage..."
    $stageDir = Join-Path $tempDir "stage"
    New-Item -ItemType Directory -Path $stageDir | Out-Null
    robocopy $absInput $stageDir /E /COPYALL | Out-Null
  }

  $stamp = Get-Date -Format "yyyyMMdd-HHmmss"
  $outputFolder = Join-Path (Resolve-Path $OutputRoot) ("package-$stamp")
  New-Item -ItemType Directory -Path $outputFolder | Out-Null

  # Move staged files into output folder
  robocopy $stageDir $outputFolder /E /MOVE | Out-Null

  $manifestPath = Join-Path $outputFolder "MANIFEST.csv"
  $cocPath = Join-Path $outputFolder "COC.md"
  Write-Manifests -workdir $outputFolder -manifestPath $manifestPath -cocPath $cocPath

  $zipName = "$OutName-$stamp.zip"
  $zipPath = Join-Path (Resolve-Path $OutputRoot) $zipName
  if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
  Add-Type -AssemblyName System.IO.Compression.FileSystem
  [System.IO.Compression.ZipFile]::CreateFromDirectory($outputFolder, $zipPath)

  $zipHash = Compute-Hash $zipPath
  Add-Content -Path $manifestPath -Value ([string]::Format("ARCHIVE,{0},{1}", $zipName, $zipHash))

  Write-Host "Created package:" $zipPath
  Write-Host "Manifest:" $manifestPath
  Write-Host "COC:" $cocPath
  Write-Host "Archive SHA-256:" $zipHash

  exit 0
} finally {
  if (Test-Path $tempDir) {
    # cleanup temp—be conservative and remove only the tempDir
    Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
  }
}
