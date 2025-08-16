param(
  [string]$Batch = "03",
  [string]$Xlsx = "Top_10_Failures_Marsh_Case_Summary.xlsx",
  [string]$Docx1 = "02_Batches/Batch_03/Top10/Justice_Master_Top10_AllPhases_EDITABLE.docx",
  [string]$Docx2 = "02_Batches/Batch_03/Notes/MASTER TOP 10 FILES GPT5 STYLE CHAT.docx"
)

$ErrorActionPreference = 'Stop'

# Ensure venv + deps
if (-not (Test-Path ".venv")) { python -m venv .venv }
. .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install pandas openpyxl python-docx reportlab --quiet

# Prefer XLSX if present, else DOCX fallback
if (Test-Path $Xlsx) {
  python scripts/import_top10_from_xlsx.py --xlsx $Xlsx --batch $Batch --master 99_Master_Index.csv
} else {
  $docxList = @(); if (Test-Path $Docx1) { $docxList += $Docx1 }; if (Test-Path $Docx2) { $docxList += $Docx2 }
  if (-not $docxList) { throw "No source files found (XLSX or DOCX)." }
  python scripts/extract_top10_from_docx.py --batch $Batch --master 99_Master_Index.csv --docx $docxList
}

# Build PDF
python generate_batch_pdf.py --batch $Batch --repo . --index 99_Master_Index.csv
Write-Host "Pipeline complete for Batch $Batch" -ForegroundColor Green
