# Batch 03 Run Sheet

git add 99_Master_Index.csv 02_Batches/Batch_03/MasterFile_Batch_03.pdf
git commit -m "feat(batch03): import top10 + build MasterFile_Batch_03"

# Batch 03 — One‑Command Run Sheet (Wrapper + PDF)

**Purpose.** Ingest your Top‑10 data **without Excel**, update `99_Master_Index.csv`, and build `02_Batches/Batch_03/MasterFile_Batch_03.pdf`. Clean, repeatable, and aligned with the locked MASTER format.

---

## ✅ Prerequisites

* Windows PowerShell
* Git + Python 3.10+
* Repo root contains (or will create): `99_Master_Index.csv`
* Wrapper at repo root: `top10_pipeline.ps1`

> If the wrapper isn’t present, see the canvas: **Top‑10 Ingest & PDF Pipeline (Excel‑Free) — v2 QuickStart**.

---

## 1) Run the pipeline (Excel‑free)

Open **PowerShell in the repo root** and run:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
./top10_pipeline.ps1 -Batch 03
```

**What this does:**

1. Creates/activates `.venv` and installs deps (`pandas`, `openpyxl`, `python-docx`, `reportlab`).
2. Imports `Top_10_Failures_Marsh_Case_Summary.xlsx` if present; otherwise parses your two DOCX sources.
3. Appends normalized rows to `99_Master_Index.csv` (locked header preserved).
4. Builds `02_Batches/Batch_03/MasterFile_Batch_03.pdf` from rows with **Status** set to `✅ Include`.

---

## 2) Quick “✅ Include” helper (if PDF says none included)

If the generator prints *"No ✅ Include rows for Batch 03"*, set Include for the current Batch 03 rows:

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

## 3) Auto‑tag Children per Master Rules (Jace & Josh)

If **Children** is blank for any Batch 03 rows, set it to `Jace, Josh`:

```powershell
$csv = "99_Master_Index.csv"
$batch = "03"
$rows = Import-Csv $csv
foreach ($r in $rows) {
  if ($r.'Batch #' -eq $batch -and [string]::IsNullOrWhiteSpace($r.'Children (Jace/Josh/Other)')) {
    $r.'Children (Jace/Josh/Other)' = 'Jace, Josh'
  }
}
$rows | Export-Csv -NoTypeInformation -Encoding UTF8 $csv
```

---

## 4) Optional: Prefill `Summary` from `Batch_03_Summary.md`

After your MD is filled, sync 1–2 line descriptions into the index:

```powershell
python scripts/prefill_summaries_from_md.py `
  --md 02_Batches/Batch_03/Batch_03_Summary.md `
  --batch 03 `
  --master 99_Master_Index.csv
```

Then re‑run the wrapper to rebuild the PDF with updated summaries.

---

## 5) Verify results

```powershell
# Confirm PDF exists and size
Get-Item ./02_Batches/Batch_03/MasterFile_Batch_03.pdf | Format-List Name,Length,LastWriteTime

# Peek at the last few index rows
Import-Csv 99_Master_Index.csv | Select-Object -Last 15 | Format-Table -AutoSize
```

---

## 6) Re‑run safely (diff preview before commit)

Before committing, preview what changed in the master index:

```powershell
# Show unstaged + staged changes to the CSV (no pager)
git -c core.pager=cat diff -- 99_Master_Index.csv
```

If everything looks right, proceed to commit.

---

## 7) Commit (and push, if desired)

```powershell
git add 99_Master_Index.csv 02_Batches/Batch_03/MasterFile_Batch_03.pdf
git commit -m "feat(batch03): import top10 + build MasterFile_Batch_03"
# optional
# git push origin main
```

---

## 8) Troubleshooting

* **Python not found** → Install Python 3.10+ and reopen PowerShell.
* **ReportLab / pandas install issues** → Run in elevated PowerShell; if behind a network filter, set: `pip config set global.trusted-host pypi.org`.
* **Execution Policy** → Keep the first line (`Set-ExecutionPolicy ...`) in your session.
* **Duplicates** → The importer is append‑only. If you ingest the same source twice, open `99_Master_Index.csv`, remove extras, and commit.
* **Custom batch** → Change `-Batch 03` to another number (e.g., `-Batch 04`).
