import argparse, os, re
from datetime import datetime
import pandas as pd
from docx import Document

MASTER_COLS = [
    "Batch #","Filename","Category","Children (Jace/Josh/Other)",
    "Dates / Case #","Summary","Misconduct? (Yes/No)",
    "Law Violated (if any)","Page / Paragraph","Description of Violation",
    "Status (✅ Include / ❌ Remove)","Notes"
]

HEAD_RX = re.compile(r"^(?:Top\s*\d+\s*[-:])?\s*(?:Item|Doc|File)?\s*#?\s*(\d{1,2})\b", re.I)
KEYVAL_RX = re.compile(r"^(filename|category|children|dates?|summary|misconduct|law|page|paragraph|violation|status)\s*[:\-]\s*(.+)$", re.I)

FIELDS = {
    "filename":"Filename",
    "category":"Category",
    "children":"Children (Jace/Josh/Other)",
    "date":"Dates / Case #",
    "dates":"Dates / Case #",
    "summary":"Summary",
    "misconduct":"Misconduct? (Yes/No)",
    "law":"Law Violated (if any)",
    "page":"Page / Paragraph",
    "paragraph":"Page / Paragraph",
    "violation":"Description of Violation",
    "status":"Status (✅ Include / ❌ Remove)",
}


def doc_to_blocks(path:str):
    d = Document(path)
    cur = {"n":None, "lines":[]}
    for p in d.paragraphs:
        t = (p.text or "").strip()
        if not t: continue
        m = HEAD_RX.match(t)
        if m:
            if cur["n"] is not None and cur["lines"]:
                yield cur
            cur = {"n": int(m.group(1)), "lines": []}
        else:
            cur["lines"].append(t)
    if cur["n"] is not None and cur["lines"]:
        yield cur


def parse_block(block):
    row = {k: "" for k in FIELDS.values()}
    for line in block["lines"]:
        m = KEYVAL_RX.match(line)
        if m:
            key = m.group(1).lower()
            val = m.group(2).strip()
            tgt = FIELDS.get(key)
            if tgt:
                row[tgt] = val
        else:
            # If no key: treat first free line as Summary continuation
            row["Summary"] = (row["Summary"] + ("\n" if row["Summary"] else "") + line).strip()
    return row


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--docx", nargs="+", required=True)
    ap.add_argument("--batch", required=True)
    ap.add_argument("--master", default="99_Master_Index.csv")
    args = ap.parse_args()

    records = []
    for p in args.docx:
        if os.path.exists(p):
            for blk in doc_to_blocks(p):
                r = parse_block(blk)
                r["Notes"] = f"Imported DOCX {os.path.basename(p)} {datetime.now():%Y-%m-%d %H:%M}"
                r["Children (Jace/Josh/Other)"] = r.get("Children (Jace/Josh/Other)") or "Jace, Josh"
                r["Batch #"] = f"{int(args.batch):02d}"
                records.append(r)

    if not records:
        print("[!] No records parsed.")
        raise SystemExit(1)

    df = pd.DataFrame(records)
    # ensure all columns
    for c in MASTER_COLS:
        if c not in df:
            df[c] = ""
    df = df[MASTER_COLS]

    if not os.path.exists(args.master):
        df.to_csv(args.master, index=False)
    else:
        ex = pd.read_csv(args.master, dtype=str).fillna("")
        pd.concat([ex, df], ignore_index=True)[MASTER_COLS].to_csv(args.master, index=False)

    print(f"[OK] Appended {len(df)} rows to {args.master}")
