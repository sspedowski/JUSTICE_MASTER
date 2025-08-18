#!/usr/bin/env pwsh
# Normalize Markdown files:
# - remove trailing spaces
# - collapse multiple blank lines to a single blank line
# - normalize ordered list prefixes to repeated `1.` style
# - preserve YAML front matter block if present

Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Definition)

$root = Resolve-Path ".." | Select-Object -ExpandProperty Path
Get-ChildItem -Path $root -Recurse -Filter *.md -File | ForEach-Object {
    $file = $_.FullName
    try {
        $text = Get-Content -Path $file -Raw -Encoding UTF8
    } catch {
        Write-Host "Skipping unreadable file: $file"
        return
    }

    # Split into lines (preserve original endings later)
    $lines = $text -split "\r?\n"

    # Detect YAML front matter
    $startIndex = 0
    $yaml = ''
    if ($lines.Length -gt 0 -and $lines[0].Trim() -eq '---') {
        $i = 1
        while ($i -lt $lines.Length -and $lines[$i].Trim() -ne '---') { $i++ }
        if ($i -lt $lines.Length) {
            $yaml = ($lines[0..$i] -join "`n")
            $startIndex = $i + 1
        }
    }

    $bodyLines = @()
    if ($startIndex -le $lines.Length - 1) { $bodyLines = $lines[$startIndex..($lines.Length - 1)] } else { $bodyLines = @() }

    # Remove trailing spaces on each line
    $bodyLines = $bodyLines | ForEach-Object { [regex]::Replace($_, '\s+$','') }

    # Normalize ordered list prefixes to '1.' while preserving indentation and spacing
    $bodyLines = $bodyLines | ForEach-Object {
        [regex]::Replace($_, '^(\s*)\d+\.(\s+)', '${1}1.${2}')
    }

    # Collapse multiple consecutive blank lines to a single blank line
    $outLines = @()
    $prevEmpty = $false
    foreach ($ln in $bodyLines) {
        if ($ln -match '^\s*$') {
            if (-not $prevEmpty) { $outLines += '' ; $prevEmpty = $true }
        } else {
            $outLines += $ln; $prevEmpty = $false
        }
    }

    # Reconstruct file text
    $newParts = @()
    if ($yaml -ne '') { $newParts += $yaml; $newParts += '' }
    $newParts += $outLines

    $newText = $newParts -join "`r`n"

    if ($newText -ne $text) {
        Set-Content -Path $file -Value $newText -Encoding UTF8
        Write-Host "Updated: $file"
    }
}
