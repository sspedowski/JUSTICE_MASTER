# Adds a top-level H1 heading to markdown files that don't have one.
# Skips files that start with YAML front matter.

$mdFiles = Get-ChildItem -Recurse -Filter *.md | Where-Object { $_.FullName -notmatch '\\(node_modules|\.venv)\\' }
foreach ($f in $mdFiles) {
  $lines = Get-Content -LiteralPath $f.FullName -Encoding UTF8
  if ($lines.Count -eq 0) { continue }

  $idx = 0
  if ($lines[0].Trim() -eq '---') {
    $idx = 1
    while ($idx -lt $lines.Count -and $lines[$idx].Trim() -ne '---') { $idx++ }
    if ($idx -lt $lines.Count) { $idx++ }
  }

  # find first non-empty after front matter
  $first = $null
  for ($i = $idx; $i -lt $lines.Count; $i++) { if ($lines[$i].Trim().Length -gt 0) { $first = $lines[$i]; break } }
  if ($first -and $first.Trim().StartsWith('#')) { continue }

  # compose title from filename
  $base = [IO.Path]::GetFileNameWithoutExtension($f.Name)
  $title = ($base -split '[-_]') | Where-Object { $_ -ne '' } | ForEach-Object { $_.Substring(0,1).ToUpper() + $_.Substring(1) } -join ' '
  $heading = "# $title"

  if ($idx -gt 0) {
    $new = @()
    $new += $lines[0..($idx-1)]
    $new += $heading
    $new += ""
    if ($idx -lt $lines.Count) { $new += $lines[$idx..($lines.Count-1)] }
    Set-Content -LiteralPath $f.FullName -Encoding UTF8 -Value $new
  } else {
    Set-Content -LiteralPath $f.FullName -Encoding UTF8 -Value (@($heading, "") + $lines)
  }
}
