# Batch 03 — One‑Command Run Sheet (Wrapper + PDF)

A crisp, lint‑clean run sheet to ingest your Top‑10 data **without Excel**, update `99_Master_Index.csv`, and build `MasterFile_Batch_03.pdf`.

---

## ✅ Prerequisites

* Windows PowerShell
* Git + Python 3.10+
* Repo root contains (or will create): `99_Master_Index.csv`
* Wrapper script at repo root: `top10_pipeline.ps1`

> If the wrapper isn’t present, see the Top‑10 pipeline QuickStart in `02_Batches/Batch_03/Top10_Pipeline_QuickStart.md`.

---

## 1) Run the pipeline (Excel‑free)

Open **PowerShell in the repo root** and run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
./top10_pipeline.ps1 -Batch 03
```

What this does:

1. Creates/activates `.venv` and installs deps (`pandas`, `openpyxl`, `python-docx`, `reportlab`).
2. Imports `Top_10_Failures_Marsh_Case_Summary.xlsx` if present; otherwise parses your two DOCX sources.
3. Appends normalized rows to `99_Master_Index.csv` (locked header preserved).
4. Builds `02_Batches/Batch_03/MasterFile_Batch_03.pdf` from rows with **Status** set to `✅ Include`.

---

## 2) Quick “✅ Include” helper (if PDF says none included)

If the generator prints **"No ✅ Include rows for Batch 03"**, set Include for the current Batch 03 rows:

```powershell
$csv = "99_Master_Index.csv"
$batch = "03"
$rows = Import-Csv $csv
foreach ($r in $rows) {
  if ($r.'Batch #' -eq $batch -and [string]::IsNullOrWhiteSpace($r.'Status (✅ Include / ❌ Remove)')) {
    $r.'Status (✅ Include / ❌ Remove)' = '✅ Include'
  }
}
$rows | Export-Csv -NoTypeInformation -Encoding UTF8 $csv
```

Re‑run the wrapper after setting status.

---

## 3) Optional: Prefill `Summary` from `Batch_03_Summary.md`

After your MD is filled, sync 1–2 line descriptions into the index:

```powershell
python scripts/prefill_summaries_from_md.py `
  --md 02_Batches/Batch_03/Batch_03_Summary.md `
  --batch 03 `
  --master 99_Master_Index.csv
```

Then re‑run the wrapper to rebuild the PDF with updated summaries.

---

## 4) Verify results

```powershell
# Confirm PDF exists and size
Get-Item ./02_Batches/Batch_03/MasterFile_Batch_03.pdf | Format-List Name,Length,LastWriteTime

# Peek at the last few index rows
Import-Csv 99_Master_Index.csv | Select-Object -Last 15 | Format-Table -AutoSize
```

---

## 5) Commit

```powershell
git add 99_Master_Index.csv 02_Batches/Batch_03/MasterFile_Batch_03.pdf
git commit -m "feat(batch03): import top10 + build MasterFile_Batch_03"
```

---

## 6) Troubleshooting

* **Python not found** → Install Python 3.10+ and reopen PowerShell.
* **ReportLab / pandas install issues** → Run in elevated PowerShell; if behind a network filter, set: `pip config set global.trusted-host pypi.org`.
* **Execution Policy** → Keep the first line (`Set-ExecutionPolicy ...`) in your session.
* **Duplicates** → The importer is append‑only. If you ingest the same source twice, open `99_Master_Index.csv`, remove extras, and commit.
* **Custom batch** → Change `-Batch 03` to another batch number (for example, `-Batch 04`).
