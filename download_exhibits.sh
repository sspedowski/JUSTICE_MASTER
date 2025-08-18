#!/usr/bin/env bash
set -euo pipefail

# =====  Your links =====
BUNDLE_URLS=(
  "https://www.dropbox.com/scl/fi/1o8m6jb4nxrvolkbdnpyd/zip-ai-1.zip?rlkey=s76d7mkf9g1e07vqucjb8ghy6&st=5iun9q7k&dl=1|Exhibits_20250818-0321.zip"
)
EXHIBIT_URLS=(
  "https://www.dropbox.com/scl/fi/1o8m6jb4nxrvolkbdnpyd/zip-ai-1.zip?rlkey=s76d7mkf9g1e07vqucjb8ghy6&st=5iun9q7k&dl=1|zip-ai-1.zip"
)
# =======================

mkdir -p downloads
cd downloads

_download() {
  local url="$1"; local name="$2"
  [[ -z "$url" ]] && return 0
  # Auto-convert Dropbox preview links (dl=0) to direct-download dl=1
  if echo "$url" | grep -qi "dropbox.com"; then
    if echo "$url" | grep -q "[?&]dl=0"; then
      url=$(echo "$url" | sed -E 's/([?&])dl=0/\1dl=1/')
    elif ! echo "$url" | grep -q "[?&]dl="; then
      url="$url&dl=1"
    fi
  fi
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
