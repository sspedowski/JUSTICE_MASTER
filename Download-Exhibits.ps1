$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path downloads | Out-Null
Set-Location downloads

# =====  Paste your PUBLIC links below  =====
$Bundles = @(
  @{ Url = "https://www.dropbox.com/scl/fi/1o8m6jb4nxrvolkbdnpyd/zip-ai-1.zip?rlkey=s76d7mkf9g1e07vqucjb8ghy6&st=5iun9q7k&dl=1"; Name = "Exhibits_20250818-0321.zip" }
)

$Exhibits = @(
  @{ Url = "https://www.dropbox.com/scl/fi/1o8m6jb4nxrvolkbdnpyd/zip-ai-1.zip?rlkey=s76d7mkf9g1e07vqucjb8ghy6&st=5iun9q7k&dl=1"; Name = "zip-ai-1.zip" }
)
# ===========================================

function Download-File($Url, $Name) {
  if ([string]::IsNullOrWhiteSpace($Url)) { return }
  $headers = @{
    "User-Agent" = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124 Safari/537.36"
    "Accept"     = "*/*"
    "Referer"    = $Url
  }
  try {
    Write-Host "→ $Name"
    Invoke-WebRequest -Uri $Url -OutFile $Name -Headers $headers -MaximumRedirection 10 -UseBasicParsing -ErrorAction Stop
  } catch {
    Write-Warning "Invoke-WebRequest failed ($($_.Exception.Message)). Trying curl.exe fallback..."
    try {
      & curl.exe -L -A "Mozilla/5.0" -o "$Name" "$Url"
      if ($LASTEXITCODE -ne 0 -or -not (Test-Path "$Name")) {
        throw "curl failed or file not created"
      }
    } catch {
      throw "Download failed for $Name. OneDrive likely needs a direct FILE link or authenticated cookies. Original error: $($_.Exception.Message)"
    }
  }
}

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'

function Ensure-DropboxDirect([string]$u) {
  if (-not $u) { return $u }
  if ($u -match 'dropbox.com') {
    if ($u -match '[\?&]dl=0') { return ($u -replace '([\?&])dl=0', '${1}dl=1') }
    if ($u -notmatch '[\?&]dl=') { return "$u&dl=1" }
  }
  return $u
}

$function:Normalize = $null
function Normalize-Url {
  param([string]$Url)
  if (-not $Url) { return $Url }
  # Dropbox
  if ($Url -match 'dropbox\.com') {
    if ($Url -match '[\?&]dl=0') { $Url = $Url -replace '([\?&])dl=0', '${1}dl=1' }
    elseif ($Url -notmatch '[\?&]dl=') { $Url = "$Url&dl=1" }
  }
  # OneDrive / SharePoint
  if ($Url -match 'onedrive\.live\.com|1drv\.ms|sharepoint\.com') {
    if ($Url -notmatch '[\?&]download=1') { $Url = ($Url + (if ($Url.Contains('?') ) { '&download=1' } else { '?download=1' })) }
  }
  return $Url
}

$Bundles | ForEach-Object { if ($_.Url) { Download-File (Normalize-Url $_.Url) $_.Name } }
$Exhibits | ForEach-Object { if ($_.Url) { Download-File (Normalize-Url $_.Url) $_.Name } }

# Evidence marker
Set-Content -Path EVIDENCE.txt -Value "THIS IS EVIDENCE" -Encoding UTF8

Write-Host "Done. Files are in:" (Get-Location)
