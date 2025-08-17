"""Small helper: scan `02_Batches/Batch_03` Markdown summary files for headings and prefill `99_Master_Index.csv` Summary column when filenames match.

Usage: .venv\\Scripts\\python.exe scripts\\prefill_summaries_from_md.py
"""
import os
import re
import pandas as pd

MASTER_CSV = '99_Master_Index.csv'
BATCH_DIR = os.path.join('02_Batches','Batch_03')


def find_md_summaries(batch_dir):
    summaries = {}
    rx = re.compile(r"^#\s+(.*)")
    for root,_,files in os.walk(batch_dir):
        for f in files:
            if f.lower().endswith('.md'):
                path = os.path.join(root,f)
                with open(path,encoding='utf-8') as fh:
                    for line in fh:
                        m = rx.match(line)
                        if m:
                            summaries[f] = m.group(1).strip()
                            break
    return summaries


def main():
    if not os.path.exists(MASTER_CSV):
        print('[ERROR] Master CSV not found')
        return
    df = pd.read_csv(MASTER_CSV, dtype=str).fillna('')
    summaries = find_md_summaries(BATCH_DIR)
    updated = 0
    for idx,row in df.iterrows():
        fname = str(row.get('Filename') or '').strip()
        if fname in summaries and not row.get('Summary'):
            df.at[idx,'Summary'] = summaries[fname]
            updated += 1
    if updated:
        df.to_csv(MASTER_CSV, index=False)
        print(f'[OK] Updated {updated} rows in {MASTER_CSV}')
    else:
        print('[OK] No updates made')

if __name__ == '__main__':
    main()
