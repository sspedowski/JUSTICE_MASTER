import argparse, os
import pandas as pd
from datetime import datetime

MASTER_COLS = [
    "Batch #","Filename","Category","Children (Jace/Josh/Other)",
    "Dates / Case #","Summary","Misconduct? (Yes/No)",
    "Law Violated (if any)","Page / Paragraph","Description of Violation",
    "Status (✅ Include / ❌ Remove)","Notes"
]

MAP = {
    # adapt these keys to your XLSX; unknowns become empty strings
    "filename": "Filename",
    "file": "Filename",
    "doc": "Filename",
    "category": "Category",
    "children": "Children (Jace/Josh/Other)",
    "dates": "Dates / Case #",
    "date": "Dates / Case #",
    "summary": "Summary",
    "misconduct": "Misconduct? (Yes/No)",
    "law": "Law Violated (if any)",
    "page": "Page / Paragraph",
    "paragraph": "Page / Paragraph",
    "violation": "Description of Violation",
    "status": "Status (✅ Include / ❌ Remove)",
}


def load_any_sheet(path: str) -> pd.DataFrame:
    xls = pd.ExcelFile(path)
    for name in xls.sheet_names:
        df = pd.read_excel(path, sheet_name=name, dtype=str).fillna("")
        if len(df):
            return df
    return pd.DataFrame()


def normalize(df: pd.DataFrame, batch: str) -> pd.DataFrame:
    out = pd.DataFrame(columns=MASTER_COLS)
    for col in df.columns:
        key = col.strip().lower()
        if key in MAP:
            tgt = MAP[key]
            out[tgt] = df[col].astype(str)
    # fill missing
    for c in MASTER_COLS:
        if c not in out:
            out[c] = ""
    out["Batch #"] = f"{int(batch):02d}"
    # defaults per Master Rules
    out["Children (Jace/Josh/Other)"] = out["Children (Jace/Josh/Other)"].replace("", "Jace, Josh")
    out["Notes"] = out["Notes"].replace("", f"Imported XLSX {datetime.now():%Y-%m-%d %H:%M}")
    return out[MASTER_COLS]


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--xlsx", required=True)
    ap.add_argument("--batch", required=True)
    ap.add_argument("--master", default="99_Master_Index.csv")
    args = ap.parse_args()

    df = load_any_sheet(args.xlsx)
    norm = normalize(df, args.batch)

    if not os.path.exists(args.master):
        norm.to_csv(args.master, index=False)
    else:
        existing = pd.read_csv(args.master, dtype=str).fillna("")
        pd.concat([existing, norm], ignore_index=True)[MASTER_COLS].to_csv(args.master, index=False)

    print(f"[OK] Appended {len(norm)} rows to {args.master}")
