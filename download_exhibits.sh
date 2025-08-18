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
  # Normalize known preview/folder links into direct-download links
  url="$(normalize_url "$url")"
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

normalize_url() {
  local u="$1"
  # Dropbox → dl=1
  if [[ "$u" == *"dropbox.com"* ]]; then
    if [[ "$u" == *"dl=0"* ]]; then
      u="${u//dl=0/dl=1}"
    elif [[ "$u" != *"dl="* ]]; then
      if [[ "$u" == *"?"* ]]; then u+="&dl=1"; else u+="?dl=1"; fi
    fi
  fi
  # OneDrive/SharePoint → download=1
  if [[ "$u" == *"onedrive.live.com"* || "$u" == *"1drv.ms"* || "$u" == *"sharepoint.com"* ]]; then
    if [[ "$u" != *"download=1"* ]]; then
      if [[ "$u" == *"?"* ]]; then u+="&download=1"; else u+="?download=1"; fi
    fi
  fi
  printf '%s' "$u"
}

for pair in "${BUNDLE_URLS[@]}"; do IFS="|" read -r u n <<<"$pair"; _download "$(normalize_url "$u")" "$n"; done
for pair in "${EXHIBIT_URLS[@]}";  do IFS="|" read -r u n <<<"$pair"; _download "$(normalize_url "$u")" "$n"; done

echo "Done. Files are in: $(pwd)"
printf '%s\n' "THIS IS EVIDENCE" > EVIDENCE.txt
