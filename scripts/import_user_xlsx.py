"""Import Top-10 rows from a user-specified XLSX into the repo's 99_Master_Index.csv.

Usage:
  .venv\Scripts\python.exe scripts\import_user_xlsx.py "C:\path\to\file.xlsx" --batch 3

Behavior:
- Backs up 99_Master_Index.csv to 99_Master_Index.csv.pre_import.TIMESTAMP.bak
- Reads XLSX (first sheet) and expects columns: Title, File, Failure, Exhibit
- Appends rows mapped to repo master columns (sets Status to '✅ Include')
- Skips rows where same Batch # and Filename already exist
"""
import sys
import os
from datetime import datetime
import pandas as pd

MASTER_COLS = [
    "Batch #","Filename","Category","Children (Jace/Josh/Other)",
    "Dates / Case #","Summary","Misconduct? (Yes/No)",
    "Law Violated (if any)","Page / Paragraph","Description of Violation",
    "Status (✅ Include / ❌ Remove)","Notes"
]


def main():
    import argparse
    ap = argparse.ArgumentParser()
    ap.add_argument('xlsx', help='Path to XLSX file')
    ap.add_argument('--batch', default=3, type=int)
    ap.add_argument('--index', default='99_Master_Index.csv')
    args = ap.parse_args()

    xlsx = args.xlsx
    batch = int(args.batch)
    master_csv = args.index

    if not os.path.exists(xlsx):
        print(f"[ERROR] XLSX not found: {xlsx}")
        sys.exit(2)
    if not os.path.exists(master_csv):
        print(f"[ERROR] master CSV not found: {master_csv}")
        sys.exit(2)

    ts = datetime.now().strftime('%Y%m%d%H%M%S')
    bak = f"{master_csv}.pre_import.{ts}.bak"
    import shutil
    shutil.copy2(master_csv, bak)
    print(f"[OK] Backup written: {bak}")

    master_df = pd.read_csv(master_csv, dtype=str).fillna("")

    xlsx_df = pd.read_excel(xlsx, dtype=str)
    xlsx_df = xlsx_df.fillna("")

    added = 0
    skipped = 0
    for _, r in xlsx_df.iterrows():
        filename = str(r.get('File') or r.get('Filename') or '').strip()
        title = str(r.get('Title') or r.get('Summary') or '').strip()
        failure = str(r.get('Failure') or r.get('Description') or '').strip()
        exhibit = str(r.get('Exhibit') or r.get('Notes') or '').strip()

        if not filename:
            # skip rows without filename
            skipped += 1
            continue

        exists = ((master_df['Batch #'].astype(str) == f"{batch:02d}") & (master_df['Filename'].astype(str) == filename)).any()
        if exists:
            skipped += 1
            continue

        new = {c: '' for c in MASTER_COLS}
        new['Batch #'] = f"{batch:02d}"
        new['Filename'] = filename
        new['Children (Jace/Josh/Other)'] = 'Jace, Josh'
        new['Summary'] = title
        new['Description of Violation'] = failure
        new['Misconduct? (Yes/No)'] = 'Yes'
        new['Status (✅ Include / ❌ Remove)'] = '✅ Include'
        if exhibit:
            new['Notes'] = f"Exhibit: {exhibit}"
        master_df = pd.concat([master_df, pd.DataFrame([new])], ignore_index=True)
        added += 1

    master_df.to_csv(master_csv, index=False)
    print(f"[OK] Added {added} rows, skipped {skipped} rows. Master CSV updated: {master_csv}")


if __name__ == '__main__':
    main()
