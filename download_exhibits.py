#!/usr/bin/env python3
"""
download_exhibits.py
- Robust downloader with retries, HTML sniffing, and OneDrive direct-download retry.
- Creates ./downloads and writes EVIDENCE.txt with "THIS IS EVIDENCE".
"""

import argparse
import os
import re
import sys
import time
from pathlib import Path
from urllib.parse import urlparse, urlencode, parse_qsl, urlunparse

import requests
from urllib3.util.retry import Retry
from requests.adapters import HTTPAdapter

DEFAULT_UA = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/124.0 Safari/537.36"
)

# 🔁 configure a retrying session
def make_session():
    sess = requests.Session()
    retries = Retry(
        total=5,
        connect=5,
        read=5,
        backoff_factor=0.8,
        status_forcelist=(429, 500, 502, 503, 504),
        allowed_methods=frozenset(["GET", "HEAD"]),
        raise_on_status=False,
    )
    adapter = HTTPAdapter(max_retries=retries, pool_connections=10, pool_maxsize=10)
    sess.mount("http://", adapter)
    sess.mount("https://", adapter)
    sess.headers.update({"User-Agent": DEFAULT_UA})
    return sess


def ensure_download_dir(path: Path) -> Path:
    path.mkdir(parents=True, exist_ok=True)
    # Evidence marker
    (path / "EVIDENCE.txt").write_text("THIS IS EVIDENCE\n", encoding="utf-8")
    return path


def is_probably_html(content_type: str, first_bytes: bytes) -> bool:
    ct = (content_type or "").lower()
    if "text/html" in ct:
        return True
    sniff = (first_bytes or b"")[:512].lower()
    return b"<html" in sniff or b"<!doctype html" in sniff


def filename_from_cd(cd: str) -> str | None:
    # content-disposition: attachment; filename="foo.zip"
    if not cd:
        return None
    m = re.search(r'filename\*?=(?:UTF-8\'\')?"?([^\";]+)"?', cd, flags=re.I)
    if m:
        return os.path.basename(m.group(1))
    return None


def safe_name_from_url(url: str) -> str:
    parsed = urlparse(url)
    base = os.path.basename(parsed.path) or "download"
    base = base.split("?")[0]  # strip weird suffixes
    return re.sub(r"[^\w.\-]", "_", base)


def maybe_add_onedrive_download(url: str) -> str:
    host = urlparse(url).netloc.lower()
    if any(h in host for h in ("onedrive.live.com", "1drv.ms", "sharepoint.com")):
        p = urlparse(url)
        q = dict(parse_qsl(p.query, keep_blank_values=True))
        if "download" not in q:
            q["download"] = "1"
            p = p._replace(query=urlencode(q, doseq=True))
            return urlunparse(p)
    return url


def try_download(sess: requests.Session, url: str, outdir: Path) -> Path:
    # HEAD first (best-effort)
    try:
        h = sess.head(url, allow_redirects=True, timeout=20)
        h.raise_for_status()
    except requests.RequestException:
        # Non-fatal; proceed with GET
        pass

    # First GET
    r = sess.get(url, stream=True, allow_redirects=True, timeout=60)
    ct = r.headers.get("Content-Type", "")
    # Peek a bit to sniff
    try:
        first = next(r.iter_content(chunk_size=1024)) or b""
    except StopIteration:
        first = b""

    if is_probably_html(ct, first):
        # OneDrive/SharePoint often needs ?download=1
        alt = maybe_add_onedrive_download(r.url)
        if alt != r.url:
            r.close()
            r = sess.get(alt, stream=True, allow_redirects=True, timeout=60)
            ct = r.headers.get("Content-Type", "")
            try:
                first = next(r.iter_content(chunk_size=1024)) or b""
            except StopIteration:
                first = b""

    if is_probably_html(ct, first):
        r.close()
        raise RuntimeError(
            "Server returned HTML (likely a folder/share page or login). "
            "Please replace with a DIRECT FILE link."
        )

    # Determine filename
    cd = r.headers.get("Content-Disposition", "")
    name = filename_from_cd(cd) or safe_name_from_url(r.url)
    # Fallback extension by content-type
    if not os.path.splitext(name)[1]:
        if "zip" in ct:
            name += ".zip"
        elif "pdf" in ct:
            name += ".pdf"

    outpath = outdir / name
    with open(outpath, "wb") as f:
        # Write the peeked bytes (if any) then the rest
        if first:
            f.write(first)
        for chunk in r.iter_content(chunk_size=1024 * 1024):
            if chunk:
                f.write(chunk)
    r.close()
    return outpath


def main():
    parser = argparse.ArgumentParser(description="Robust exhibit downloader")
    parser.add_argument(
        "--urls",
        nargs="*",
        help="One or more direct-file URLs to download. If omitted, uses the hard-coded bundle list.",
    )
    args = parser.parse_args()

    # 🔗 Replace these placeholders with your direct-file links (not folder links)
    BUNDLE_URLS = [
        # "https://onedrive.live.com/...?download=1",
        # "https://your-other-direct-file-link.zip",
    ]

    urls = args.urls if args.urls else BUNDLE_URLS
    if not urls:
        print("No URLs provided. Use --urls or set BUNDLE_URLS.", file=sys.stderr)
        sys.exit(2)

    outdir = ensure_download_dir(Path("downloads"))
    sess = make_session()

    failures = []
    for i, url in enumerate(urls, 1):
        print(f"[{i}/{len(urls)}] Downloading: {url}")
        try:
            path = try_download(sess, url, outdir)
            size_mb = path.stat().st_size / (1024 * 1024)
            print(f"  -> saved to {path} ({size_mb:.2f} MB)")
        except Exception as e:
            print(f"  !! ERROR: {e}", file=sys.stderr)
            failures.append((url, str(e)))
        time.sleep(0.2)

    if failures:
        print("\nSome downloads failed:")
        for u, err in failures:
            print(f" - {u}\n   {err}")
        sys.exit(1)
    else:
        print("\nAll downloads completed successfully.")


if __name__ == "__main__":
    main()
