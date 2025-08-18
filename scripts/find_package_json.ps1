Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Definition)
$root = Resolve-Path ".." | Select-Object -ExpandProperty Path
Get-ChildItem -Path $root -Recurse -Filter package.json -File -ErrorAction SilentlyContinue | ForEach-Object { Write-Host $_.FullName }
