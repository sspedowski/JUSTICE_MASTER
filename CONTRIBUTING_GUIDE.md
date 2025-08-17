# Contributing Guide — JUSTICE_MASTER

Quick setup

- Clone the repo and install Python 3.11+.
- Create and activate a venv: `python -m venv .venv` and then `.venv\Scripts\Activate` on Windows.
- Install runtime deps: `.venv\Scripts\python.exe -m pip install pandas openpyxl python-docx reportlab`

Running the Batch 03 pipeline

1. Place Top‑10 XLSX at repo root as `Top_10_Failures_Marsh_Case_Summary.xlsx` OR place DOCX files in `02_Batches/Batch_03/Top10` and supporting notes in `02_Batches/Batch_03/Notes`.
2. From repo root run (PowerShell):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\top10_pipeline.ps1 -Batch 03
```

1. Verify PDF and CSV:

```powershell
Get-Item .\02_Batches\Batch_03\MasterFile_Batch_03.pdf | Format-List Name,Length,LastWriteTime
Import-Csv 99_Master_Index.csv | Select-Object -Last 15 | Format-Table -AutoSize
```

Notes on input formatting

- XLSX expected columns (case-insensitive): `Title`, `File`, `Failure`, `Exhibit`.
- DOCX parser is tolerant but prefers records separated by blank lines and a `Filename:` or `File:` line for the filename.
- Master CSV canonical columns are in `99_Master_Index.csv` header. The `Status (✅ Include / ❌ Remove)` column controls PDF inclusion.

Troubleshooting

- If you see "No source files found", confirm the XLSX exists at repo root or DOCX files under the Batch Top10 folder.
- If the PDF is empty, check that Batch 03 rows have `✅ Include` in the status column.
- For parsing edge cases, open an issue and attach a minimal sample DOCX.
