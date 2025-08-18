Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Definition)
$root = Resolve-Path ".." | Select-Object -ExpandProperty Path
$coc = Join-Path $root 'package-20250818-000533/COC.md'
if (Test-Path $coc) {
    $lines = Get-Content $coc -Encoding UTF8
    if ($lines.Length -gt 0 -and $lines[0] -notmatch '^#') {
        $new = @('# Chain of Custody','') + $lines
        $new | Set-Content $coc -Encoding UTF8
        Write-Host "Prepended H1 to $coc"
    } else { Write-Host "COC already has H1" }
} else { Write-Host 'No package COC found' }
