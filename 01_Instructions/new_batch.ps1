<#
new_batch.ps1
Scaffolds a new Batch_## folder under 02_Batches with template files.
Usage: .\new_batch.ps1 -Number 3
#>
param(
    [int]$Number,
    [switch]$Force,
    [switch]$Open
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$batchRoot = Join-Path $root '..\02_Batches'
New-Item -ItemType Directory -Force -Path $batchRoot | Out-Null

if (-not $PSBoundParameters.ContainsKey('Number')) {
    $existing = Get-ChildItem -Path $batchRoot -Directory -Filter 'Batch_*' -ErrorAction SilentlyContinue |
        ForEach-Object { if ($_.Name -match 'Batch_(\d{1,})') { [int]$Matches[1] } } |
        Sort-Object -Descending
    $Number = if ($existing) { $existing[0] + 1 } else { 1 }
}

$batchName = ('Batch_{0:D2}' -f $Number)
$target = Join-Path $batchRoot $batchName

if (Test-Path $target) {
    if (-not $Force) {
        Write-Host "Target $batchName already exists. Use -Force to update the folder." -ForegroundColor Yellow
        exit 1
    } else {
        Write-Host "Updating existing $batchName (non-destructive)." -ForegroundColor Cyan
    }
}

New-Item -ItemType Directory -Force -Path $target | Out-Null

$stamp = Get-Date -Format "yyyy-MM-dd HH:mm"
$placeholders = @(
    "README.md",
    ("Batch_{0}_Summary.md" -f ('{0:D2}' -f $Number)),
    ("Batch_{0}_Misconduct_Tables.md" -f ('{0:D2}' -f $Number))
)
foreach ($f in $placeholders) {
    $p = Join-Path $target $f
    if (-not (Test-Path $p)) {
        "Place the 10 originals here. Generated summaries/tables live in this folder.  // created $stamp" |
            Out-File -Encoding UTF8 $p
    }
}

Write-Host "Ready: $batchName at $target" -ForegroundColor Green
if ($Open) { Invoke-Item $target }
