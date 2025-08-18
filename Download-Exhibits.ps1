$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path downloads | Out-Null
Set-Location downloads

# =====  Paste your PUBLIC links below  =====
$Bundles = @(
  @{ Url = "https://1drv.ms/f/c/3f95a286c2fabb4d/Ek27-sKGopUggD9oAAAAAAABhAJxoEGCvv-SUNno17kEgA?e=KizCPc&download=1"; Name = "Bundle_A_EX-001_to_EX-005.zip" },
  @{ Url = "https://1drv.ms/f/c/3f95a286c2fabb4d/Ek27-sKGopUggD9oAAAAAAABhAJxoEGCvv-SUNno17kEgA?e=KizCPc&download=1"; Name = "Bundle_B_EX-006_to_EX-011.zip" }
)

$Exhibits = @(
  @{ Url = "https://YOUR_PUBLIC_LINK/EX-001__CPS_Investigation_Report_5.23.20__BATES.pdf"; Name = "EX-001__CPS Investigation Report 5.23.20__BATES.pdf" },
  @{ Url = "https://YOUR_PUBLIC_LINK/EX-002__CPS_Investigation_Report_9.5.19__BATES.pdf"; Name = "EX-002__CPS Investigation Report 9.5.19__BATES.pdf" },
  @{ Url = "https://YOUR_PUBLIC_LINK/EX-004__CPS_Complaint_12.30.19__BATES.pdf"; Name = "EX-004__CPS Complaint 12.30.19__BATES.pdf" },
  @{ Url = "https://YOUR_PUBLIC_LINK/EX-005__CPS_Complaint_6.10.20__BATES.pdf"; Name = "EX-005__CPS Complaint 6.10.20__BATES.pdf" },
  @{ Url = "https://YOUR_PUBLIC_LINK/EX-006__CPS_Complaint_6.26.20__BATES.pdf"; Name = "EX-006__CPS Complaint 6.26.20__BATES.pdf" },
  @{ Url = "https://YOUR_PUBLIC_LINK/EX-007__CPS_Complaint_7.12.20__BATES.pdf"; Name = "EX-007__CPS Complaint 7.12.20__BATES.pdf" },
  @{ Url = "https://YOUR_PUBLIC_LINK/EX-008__CPS_Complaint_7.23.20__BATES.pdf"; Name = "EX-008__CPS Complaint 7.23.20__BATES.pdf" },
  @{ Url = "https://YOUR_PUBLIC_LINK/EX-009__CPS_Complaint_8.12.20__BATES.pdf"; Name = "EX-009__CPS Complaint 8.12.20__BATES.pdf" },
  @{ Url = "https://YOUR_PUBLIC_LINK/EX-010__CPS_Complaint_9.9.20__BATES.pdf"; Name = "EX-010__CPS Complaint 9.9.20__BATES.pdf" },
  @{ Url = "https://YOUR_PUBLIC_LINK/EX-011__Battle_Creek_Counseling_Psychological_Eval_8.31.20__BATES.pdf"; Name = "EX-011__Battle Creek Counseling Psychological Eval 8.31.20__BATES.pdf" }
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

$Bundles | ForEach-Object { if ($_.Url) { Download-File $_.Url $_.Name } }
$Exhibits | ForEach-Object { if ($_.Url) { Download-File $_.Url $_.Name } }

# Evidence marker
Set-Content -Path EVIDENCE.txt -Value "THIS IS EVIDENCE" -Encoding UTF8

Write-Host "Done. Files are in:" (Get-Location)
