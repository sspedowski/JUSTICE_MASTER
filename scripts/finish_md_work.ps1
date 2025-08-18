Set-Location (Split-Path -Parent $MyInvocation.MyCommand.Definition)
$root = Resolve-Path ".." | Select-Object -ExpandProperty Path
Set-Location $root

# 1) Add enable marker if missing
$p = 'EVIDENCE_PACKAGE.md'
$marker = '<!-- markdownlint-enable MD013 MD033 -->'
if (-not (Test-Path $p)) { Write-Host "File not found: $p"; return }
if (-not (Select-String -Path $p -Pattern [regex]::Escape($marker) -Quiet)) {
  Add-Content -Path $p -Value "`r`n$marker`r`n" -Encoding UTF8
  git add -- $p
  $c = git commit -m 'chore(md): re-enable MD013/MD033 at EOF in EVIDENCE_PACKAGE' 2>&1
  if ($c -match 'nothing to commit') { Write-Host 'Nothing to commit' } else { Write-Host $c }
  git push
} else {
  Write-Host 'Enable marker already present; nothing to do.'
}

# 2) Expand .markdownlintignore
$ignore = @(
  'node_modules/'
  '.venv/'
  'downloads/'
  'dist/'
  'build/'
)
$ig = '.markdownlintignore'
if (!(Test-Path $ig)) { New-Item -ItemType File -Path $ig | Out-Null }
$cur = Get-Content $ig -ErrorAction SilentlyContinue
foreach ($line in $ignore) {
  if (-not ($cur -contains $line)) { Add-Content $ig $line }
}
git add $ig
$c2 = git commit -m "chore(md): expand .markdownlintignore (node_modules, .venv, downloads, dist, build)" 2>&1
if ($c2 -match 'nothing to commit') { Write-Host 'No changes to .markdownlintignore' } else { Write-Host $c2 }
git push

# 3) Run markdownlint list
Write-Host 'Remaining markdownlint issues:'
$npx = Get-Command npx -ErrorAction SilentlyContinue
if ($null -eq $npx) { Write-Host 'npx not found in PATH; skip listing' ; return }
& npx --yes markdownlint-cli **/*.md --ignore node_modules --ignore .venv
