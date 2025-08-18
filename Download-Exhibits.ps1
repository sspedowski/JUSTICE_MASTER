$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force -Path downloads | Out-Null
Set-Location downloads

# =====  Paste your PUBLIC links below  =====
$Bundles = @(
  @{ Url = "https://YOUR_PUBLIC_LINK/Bundle_A_EX-001_to_EX-005.zip"; Name = "Bundle_A_EX-001_to_EX-005.zip" },
  @{ Url = "https://YOUR_PUBLIC_LINK/Bundle_B_EX-006_to_EX-011.zip"; Name = "Bundle_B_EX-006_to_EX-011.zip" }
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
  Write-Host "→ $Name"
  Invoke-WebRequest -Uri $Url -OutFile $Name -UseBasicParsing
}

$Bundles | ForEach-Object { if ($_.Url) { Download-File $_.Url $_.Name } }
$Exhibits | ForEach-Object { if ($_.Url) { Download-File $_.Url $_.Name } }

# Evidence marker
Set-Content -Path EVIDENCE.txt -Value "THIS IS EVIDENCE" -Encoding UTF8

Write-Host "Done. Files are in:" (Get-Location)
