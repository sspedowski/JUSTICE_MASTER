#!/usr/bin/env bash
set -euo pipefail

# =====  Your links =====
BUNDLE_URLS=(
  "https://1drv.ms/f/c/3f95a286c2fabb4d/Ek27-sKGopUggD9oAAAAAAABhAJxoEGCvv-SUNno17kEgA?e=KizCPc&download=1|Bundle_A_EX-001_to_EX-005.zip"
  "https://1drv.ms/f/c/3f95a286c2fabb4d/Ek27-sKGopUggD9oAAAAAAABhAJxoEGCvv-SUNno17kEgA?e=KizCPc&download=1|Bundle_B_EX-006_to_EX-011.zip"
)
EXHIBIT_URLS=(
  "https://YOUR_PUBLIC_LINK/EX-001__CPS_Investigation_Report_5.23.20__BATES.pdf|EX-001__CPS Investigation Report 5.23.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-002__CPS_Investigation_Report_9.5.19__BATES.pdf|EX-002__CPS Investigation Report 9.5.19__BATES.pdf"
  # EX-003 is DOCX; skip unless you made a PDF
  "https://YOUR_PUBLIC_LINK/EX-004__CPS_Complaint_12.30.19__BATES.pdf|EX-004__CPS Complaint 12.30.19__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-005__CPS_Complaint_6.10.20__BATES.pdf|EX-005__CPS Complaint 6.10.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-006__CPS_Complaint_6.26.20__BATES.pdf|EX-006__CPS Complaint 6.26.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-007__CPS_Complaint_7.12.20__BATES.pdf|EX-007__CPS Complaint 7.12.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-008__CPS_Complaint_7.23.20__BATES.pdf|EX-008__CPS Complaint 7.23.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-009__CPS_Complaint_8.12.20__BATES.pdf|EX-009__CPS Complaint 8.12.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-010__CPS_Complaint_9.9.20__BATES.pdf|EX-010__CPS Complaint 9.9.20__BATES.pdf"
  "https://YOUR_PUBLIC_LINK/EX-011__Battle_Creek_Counseling_Psychological_Eval_8.31.20__BATES.pdf|EX-011__Battle Creek Counseling Psychological Eval 8.31.20__BATES.pdf"
)
# =======================

mkdir -p downloads
cd downloads

_download() {
  local url="$1"; local name="$2"
  [[ -z "$url" ]] && return 0
  echo "→ $name"
  curl -L --fail --retry 5 --retry-delay 2 --retry-connrefused \
       --connect-timeout 15 --max-time 0 \
       -H "User-Agent: Mozilla/5.0" \
       -o "$name" "$url"
  # Detect accidental HTML (login page, listing, error)
  if head -c 512 "$name" | LC_ALL=C tr -d '\000' | grep -qiE '^<!DOCTYPE|^<html|^\\{\\s*"error'; then
    echo "ERROR: $name looks like HTML (not the file). Check the link or provide a direct file link." >&2
    exit 1
  fi
}

for pair in "${BUNDLE_URLS[@]}"; do IFS="|" read -r u n <<<"$pair"; _download "$u" "$n"; done
for pair in "${EXHIBIT_URLS[@]}";  do IFS="|" read -r u n <<<"$pair"; _download "$u" "$n"; done

echo "Done. Files are in: $(pwd)"
printf '%s\n' "THIS IS EVIDENCE" > EVIDENCE.txt
