#!/usr/bin/env bash
set -euo pipefail

# =====  Paste your PUBLIC links below  =====
# Two bundle ZIPs (optional if you prefer individual PDFs)
BUNDLE_URLS=(
  "https://YOUR_PUBLIC_LINK/Bundle_A_EX-001_to_EX-005.zip|Bundle_A_EX-001_to_EX-005.zip"
  "https://YOUR_PUBLIC_LINK/Bundle_B_EX-006_to_EX-011.zip|Bundle_B_EX-006_to_EX-011.zip"
)

# Individual Bates‑stamped PDFs (fill any you want)
EXHIBIT_URLS=(
  "https://YOUR_PUBLIC_LINK/EX-001__CPS_Investigation_Report_5.23.20__BATES.pdf|EX-001__CPS Investigation Report 5.23.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-002__CPS_Investigation_Report_9.5.19__BATES.pdf|EX-002__CPS Investigation Report 9.5.19__BATES.pdf"
  # EX-003 is a .docx in this set (skip or add your own PDF if you made one)
  "https://YOUR_PUBLIC_LINK/EX-004__CPS_Complaint_12.30.19__BATES.pdf|EX-004__CPS Complaint 12.30.19__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-005__CPS_Complaint_6.10.20__BATES.pdf|EX-005__CPS Complaint 6.10.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-006__CPS_Complaint_6.26.20__BATES.pdf|EX-006__CPS Complaint 6.26.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-007__CPS_Complaint_7.12.20__BATES.pdf|EX-007__CPS Complaint 7.12.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-008__CPS_Complaint_7.23.20__BATES.pdf|EX-008__CPS Complaint 7.23.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-009__CPS_Complaint_8.12.20__BATES.pdf|EX-009__CPS Complaint 8.12.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-010__CPS_Complaint_9.9.20__BATES.pdf|EX-010__CPS Complaint 9.9.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-011__Battle_Creek_Counseling_Psychological_Eval_8.31.20__BATES.pdf|EX-011__Battle Creek Counseling Psychological Eval 8.31.20__BATES.pdf"
)
# ===========================================

mkdir -p downloads
cd downloads

_download() {
  local url="$1"; shift
  local name="$1"; shift
  echo "→ $name"
  curl -L --retry 3 --fail --output "$name" "$url"
}

for pair in "${BUNDLE_URLS[@]}"; do
  IFS="|" read -r url name <<<"$pair"; [[ -n "$url" ]] && _download "$url" "$name"
done

for pair in "${EXHIBIT_URLS[@]}"; do
  IFS="|" read -r url name <<<"$pair"; [[ -n "$url" ]] && _download "$url" "$name"
done

# Evidence marker
printf '%s\n' "THIS IS EVIDENCE" > EVIDENCE.txt

echo "Done. Files are in: $(pwd)"
