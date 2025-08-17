# Top‑10 Ingest & PDF Pipeline (Excel‑Free) — v2 QuickStart

Purpose. Take your Top‑10 source files (DOCX preferred, XLSX if available), normalize them into the locked master columns in `99_Master_Index.csv`, and auto‑build `02_Batches/Batch_03/MasterFile_Batch_03.pdf` (✅ rows only). No Excel dependency inside the repo.

---

What you get

* DOCX → CSV extractor (fallback that works even when Excel isn’t accepted).
* XLSX → CSV importer (used automatically if the sheet exists).
* PDF generator from the master index.
* PowerShell wrapper that sets up a venv, ingests sources, and builds the PDF in one command.

Assumptions

* Repo root contains or will contain: `99_Master_Index.csv` (created if missing).
* Your Top‑10 live at any path. Defaults used below:

  * `02_Batches/Batch_03/Top10/Justice_Master_Top10_AllPhases_EDITABLE.docx`
  * `02_Batches/Batch_03/Notes/MASTER TOP 10 FILES GPT5 STYLE CHAT.docx`
  * Optional: `Top_10_Failures_Marsh_Case_Summary.xlsx`

---

One‑command run (recommended)

From repo root (PowerShell):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
.\top10_pipeline.ps1 -Batch 03
```

What it does:

1. Creates/activates `.venv`, installs `pandas openpyxl python-docx reportlab`.
1. If `Top_10_Failures_Marsh_Case_Summary.xlsx` exists → imports it; otherwise parses the two DOCX.
1. Appends normalized rows to `99_Master_Index.csv` (keeps your header intact).
1. Builds `02_Batches/Batch_03/MasterFile_Batch_03.pdf` from rows with **Status** set to `✅ Include`.

Re‑runnable: You can run the wrapper again; it will append/merge and rebuild the PDF. Review the CSV before committing if you re‑ingest the same sources.

---

Manual usage (if you want step‑by-step)

1. Create venv + install deps

```powershell
python -m venv .venv
. .\.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install pandas openpyxl python-docx reportlab
```

1) Import from XLSX (if you have it)

```powershell
python scripts/import_top10_from_xlsx.py --xlsx .\Top_10_Failures_Marsh_Case_Summary.xlsx --batch 03 --master 99_Master_Index.csv
```

3) Extract from DOCX (Excel‑free fallback)

```powershell
python scripts/extract_top10_from_docx.py --batch 03 --master 99_Master_Index.csv `
  --docx "02_Batches/Batch_03/Top10/Justice_Master_Top10_AllPhases_EDITABLE.docx" `
         "02_Batches/Batch_03/Notes/MASTER TOP 10 FILES GPT5 STYLE CHAT.docx"
```

4) Generate the batch PDF

```powershell
python generate_batch_pdf.py --batch 03 --repo . --index 99_Master_Index.csv
```

Output: `02_Batches/Batch_03/MasterFile_Batch_03.pdf` (✅ rows only).

---

Locked master columns (header)

Use this exact header in CSV/XLSX:

Batch #,Filename,Category,Children (Jace/Josh/Other),Dates / Case #,Summary,Misconduct? (Yes/No),Law Violated (if any),Page / Paragraph,Description of Violation,Status (✅ Include / ❌ Remove),Notes
```
Batch #,Filename,Category,Children (Jace/Josh/Other),Dates / Case #,Summary,Misconduct? (Yes/No),Law Violated (if any),Page / Paragraph,Description of Violation,Status (✅ Include / ❌ Remove),Notes
```

Defaults enforced: If Children is blank, scripts set it to `Jace, Josh` per Master Rules.

---

Files this adds/uses

* `scripts/import_top10_from_xlsx.py` – normalizes any sheet → master columns.
* `scripts/extract_top10_from_docx.py` – parses semi‑structured blocks from your DOCX.
* `generate_batch_pdf.py` – builds the printable `MasterFile_Batch_##.pdf`.
* `top10_pipeline.ps1` – one‑button wrapper (venv → ingest → PDF).

These scripts are non‑destructive and append to the master index; always review diffs before committing.

---

Optional: Prefill the `Summary` column from `Batch_03_Summary.md`

If you want a 1–2 line description auto‑copied into `99_Master_Index.csv` for Batch 03 rows, create `scripts/prefill_summaries_from_md.py`:

```python
import argparse, re, pandas as pd
from pathlib import Path

HDR = [
  "Batch #","Filename","Category","Children (Jace/Josh/Other)",
  "Dates / Case #","Summary","Misconduct? (Yes/No)",
  "Law Violated (if any)","Page / Paragraph","Description of Violation",
  "Status (✅ Include / ❌ Remove)","Notes"
]

DOC_RX = re.compile(r"^##\\s*Document\\s*(\\d+)", re.I)
WHAT_RX = re.compile(r"^\\*\\*What happened:\\\*\\*\\s*(.+)$", re.I)

if __name__ == "__main__":
  ap = argparse.ArgumentParser()
  ap.add_argument('--md', required=True)
  ap.add_argument('--master', default='99_Master_Index.csv')
  ap.add_argument('--batch', default='03')
  a = ap.parse_args()

  txt = Path(a.md).read_text(encoding='utf-8').splitlines()
  summaries = {}
  cur = None
  for line in txt:
    m = DOC_RX.match(line.strip())
    if m:
      cur = int(m.group(1))
      continue
    m = WHAT_RX.match(line.strip())
    if m and cur is not None:
      summaries[cur] = m.group(1).strip()

  df = pd.read_csv(a.master, dtype=str).fillna("")
  mask = df["Batch #"].astype(str).str.zfill(2) == f"{int(a.batch):02d}"
  idx = df[mask].index.tolist()
  for i, ridx in enumerate(idx, start=1):
    if i in summaries:
      df.at[ridx, "Summary"] = summaries[i]
  df.to_csv(a.master, index=False)
  print(f"[OK] Updated Summary for {len(summaries)} rows in batch {a.batch}")
```

Run:

```powershell
python scripts/prefill_summaries_from_md.py --md 02_Batches/Batch_03/Batch_03_Summary.md --batch 03 --master 99_Master_Index.csv
```

---

Validate & commit

Validate

```powershell
# Preview last rows of master index
Import-Csv 99_Master_Index.csv | Select-Object -Last 15 | Format-Table -AutoSize

# Confirm PDF exists and has size
Get-Item .\\02_Batches\\Batch_03\\MasterFile_Batch_03.pdf | Format-List Name,Length,LastWriteTime
```

Commit

```powershell
git add 99_Master_Index.csv 02_Batches/Batch_03/MasterFile_Batch_03.pdf
git commit -m "feat(top10): import/extract + build MasterFile_Batch_03"
```

---

Troubleshooting

* “No ✅ Include rows for Batch 03” → Set the **Status** column to `✅ Include` for the docs you want in the PDF.
* “No records parsed” (DOCX) → Ensure each Top‑10 item has simple key/value lines like `Filename:`, `Summary:`, `Status:`. Free text is still appended to **Summary**.
* `python` not found → Install Python 3.10+ and re‑open PowerShell.
* ReportLab install issues → Re‑run the venv commands in an elevated PowerShell; ensure network access.
* Duplicates in CSV → Remove by editing the CSV or import only once per source; scripts are append‑only by design.

---

Customization

* Change batch: pass `-Batch 02` or `-Batch 04` to the wrapper.
* Use XLSX as master: switch to `99_Master_Index.xlsx` and adjust the `--index` flag in `generate_batch_pdf.py`.
* Add sources: edit `top10_pipeline.ps1` to include more DOCX paths.
