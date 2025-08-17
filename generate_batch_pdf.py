import argparse, os
import pandas as pd
from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from datetime import datetime

MASTER_COLS = [
    "Batch #","Filename","Category","Children (Jace/Josh/Other)",
    "Dates / Case #","Summary","Misconduct? (Yes/No)",
    "Law Violated (if any)","Page / Paragraph","Description of Violation",
    "Status (✅ Include / ❌ Remove)","Notes"
]


def build_pdf(master_csv, batch, out_pdf):
    df = pd.read_csv(master_csv, dtype=str).fillna("")
    # normalize column names
    df.columns = [c.strip() for c in df.columns]
    # filter rows for the given batch (zero-padded two-digit batch numbers expected)
    df = df[df['Batch #'] == f"{int(batch):02d}"]
    # tolerate multiple possible status column names (different encodings / edits)
    def _find_status_col(columns):
        candidates = [
            'Status (✅ Include / ❌ Remove)',
            'Status ( ✅ Include / ❌ Remove)',
            'Status ( ? Include / ? Remove)',
            'Status (? Include / ? Remove)',
            'Status (Include / Remove)',
            'Status',
            'status'
        ]
        for c in candidates:
            if c in columns:
                return c
        # fallback: any column containing the word 'status'
        for c in columns:
            if 'status' in c.lower():
                return c
        return None

    status_col = _find_status_col(df.columns)
    if status_col:
        s = df[status_col].astype(str)
        # include rows explicitly marked with a check or containing the word 'include'
        mask = s.str.contains('✅') | s.str.contains('Include', case=False)
        # treat empty cells as 'include' conservatively
        mask = mask | (s.str.strip() == '')
        df = df[mask]
    else:
        # no status column found; keep all rows for this batch (safe default)
        pass

    c = canvas.Canvas(out_pdf, pagesize=letter)
    width, height = letter
    margin = 50
    y = height - margin

    # Title page
    c.setFont('Helvetica-Bold', 16)
    c.drawString(margin, y, f"MasterFile_Batch_{int(batch):02d} - {datetime.now():%Y-%m-%d}")
    y -= 40

    for idx, row in df.iterrows():
        if y < margin + 120:
            c.showPage()
            y = height - margin
        c.setFont('Helvetica-Bold', 12)
        c.drawString(margin, y, row['Filename'] if row['Filename'] else 'Unnamed')
        y -= 18
        c.setFont('Helvetica', 10)
        summary = (row['Summary'] or '')
        if summary:
            for line in summary.split('\n'):
                c.drawString(margin+10, y, line)
                y -= 14
                if y < margin + 60:
                    c.showPage(); y = height - margin
        # misconduct table brief
        if str(row.get('Misconduct? (Yes/No)')).strip().lower().startswith('y'):
            c.setFont('Helvetica-Oblique', 9)
            c.drawString(margin+10, y, 'Misconduct: ' + (row.get('Description of Violation') or 'See misconduct tables'))
            y -= 14
        y -= 8

    c.save()


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--batch', required=True)
    ap.add_argument('--repo', default='.')
    ap.add_argument('--index', default='99_Master_Index.csv')
    ap.add_argument('--out', default=None)
    args = ap.parse_args()

    out_pdf = args.out or os.path.join(args.repo, f"02_Batches/Batch_{int(args.batch):02d}/MasterFile_Batch_{int(args.batch):02d}.pdf")
    os.makedirs(os.path.dirname(out_pdf), exist_ok=True)
    build_pdf(args.index, args.batch, out_pdf)
    print(f"[OK] Wrote {out_pdf}")
