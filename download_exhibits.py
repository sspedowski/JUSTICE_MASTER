import os, sys
from pathlib import Path
from urllib.request import urlretrieve

OUT = Path("downloads"); OUT.mkdir(exist_ok=True)

# =====  Paste your PUBLIC links below  =====
BUNDLES = [
  ("https://1drv.ms/f/c/3f95a286c2fabb4d/Ek27-sKGopUggD9oAAAAAAABhAJxoEGCvv-SUNno17kEgA?e=TJzQxf", "Bundle_A_EX-001_to_EX-005.zip"),
  ("https://YOUR_PUBLIC_LINK/Bundle_B_EX-006_to_EX-011.zip", "Bundle_B_EX-006_to_EX-011.zip"),
]

EXHIBITS = [
  ("https://YOUR_PUBLIC_LINK/EX-001__CPS_Investigation_Report_5.23.20__BATES.pdf", "EX-001__CPS Investigation Report 5.23.20__BATES.pdf"),
  ("https://YOUR_PUBLIC_LINK/EX-002__CPS_Investigation_Report_9.5.19__BATES.pdf", "EX-002__CPS Investigation Report 9.5.19__BATES.pdf"),
  # EX-003 skipped (docx)
  ("https://YOUR_PUBLIC_LINK/EX-004__CPS_Complaint_12.30.19__BATES.pdf", "EX-004__CPS Complaint 12.30.19__BATES.pdf"),
  ("https://YOUR_PUBLIC_LINK/EX-005__CPS_Complaint_6.10.20__BATES.pdf", "EX-005__CPS Complaint 6.10.20__BATES.pdf"),
  ("https://YOUR_PUBLIC_LINK/EX-006__CPS_Complaint_6.26.20__BATES.pdf", "EX-006__CPS Complaint 6.26.20__BATES.pdf"),
  ("https://YOUR_PUBLIC_LINK/EX-007__CPS_Complaint_7.12.20__BATES.pdf", "EX-007__CPS Complaint 7.12.20__BATES.pdf"),
  ("https://YOUR_PUBLIC_LINK/EX-008__CPS_Complaint_7.23.20__BATES.pdf", "EX-008__CPS Complaint 7.23.20__BATES.pdf"),
  ("https://YOUR_PUBLIC_LINK/EX-009__CPS_Complaint_8.12.20__BATES.pdf", "EX-009__CPS Complaint 8.12.20__BATES.pdf"),
  ("https://YOUR_PUBLIC_LINK/EX-010__CPS_Complaint_9.9.20__BATES.pdf", "EX-010__CPS Complaint 9.9.20__BATES.pdf"),
  ("https://YOUR_PUBLIC_LINK/EX-011__Battle_Creek_Counseling_Psychological_Eval_8.31.20__BATES.pdf", "EX-011__Battle Creek Counseling Psychological Eval 8.31.20__BATES.pdf"),
]
# ===========================================

def dl(url, name):
    print("→", name)
    urlretrieve(url, OUT / name)

for url, name in BUNDLES:
    if url:
        dl(url, name)
for url, name in EXHIBITS:
    if url:
        dl(url, name)

# Evidence marker
(OUT / 'EVIDENCE.txt').write_text('THIS IS EVIDENCE', encoding='utf-8')

print("Done. Files are in:", OUT.resolve())
