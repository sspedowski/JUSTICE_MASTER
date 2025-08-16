<#
new_batch.ps1
Scaffolds a new Batch_## folder under 02_Batches with template files.
Usage: .\new_batch.ps1 -Number 3
#>
param(
    [Parameter(Mandatory=$true)]
    [int]$Number
)

$batchName = "Batch_{0:D2}" -f $Number
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$batchesDir = Join-Path $root "..\02_Batches" | Resolve-Path -Relative
$batchPath = Join-Path $batchesDir $batchName

if (Test-Path $batchPath) {
    Write-Host "Batch folder already exists: $batchPath" -ForegroundColor Yellow
    exit 1
}

New-Item -ItemType Directory -Path $batchPath -Force | Out-Null

# Create README template
$readmePath = Join-Path $batchPath "README.md"
$readmeContent = @"
# $batchName

## Original Documents

1. 
2. 
3. 
4. 
5. 
6. 
7. 
8. 
9. 
10. 

## Generated Files

- ${batchName}_Summary.md
- ${batchName}_Misconduct_Tables.md
- MasterFile_${batchName}.pdf (✅ items only)

This folder is part of the Justice_Master monorepo. See root README for process and usage.
"@

Set-Content -Path $readmePath -Value $readmeContent -Encoding UTF8

# Create template summary and misconduct files
Set-Content -Path (Join-Path $batchPath "${batchName}_Summary.md") -Value "# ${batchName} Summary\n\n" -Encoding UTF8
Set-Content -Path (Join-Path $batchPath "${batchName}_Misconduct_Tables.md") -Value "# ${batchName} Misconduct Tables\n\n" -Encoding UTF8

Write-Host "Created $batchPath with templates." -ForegroundColor Green
