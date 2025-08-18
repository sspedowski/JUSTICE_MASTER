import os, sys
from pathlib import Path
import shutil
import time

OUT = Path("downloads"); OUT.mkdir(exist_ok=True)

# =====  Paste your PUBLIC links below  =====
BUNDLES = [
  ("https://1drv.ms/f/c/3f95a286c2fabb4d/Ek27-sKGopUggD9oAAAAAAABhAJxoEGCvv-SUNno17kEgA?e=KizCPc&download=1", "Bundle_A_EX-001_to_EX-005.zip"),
  ("https://1drv.ms/f/c/3f95a286c2fabb4d/Ek27-sKGopUggD9oAAAAAAABhAJxoEGCvv-SUNno17kEgA?e=KizCPc&download=1", "Bundle_B_EX-006_to_EX-011.zip"),
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


def _sniff_html_prefix(b: bytes) -> bool:
    s = b.lstrip()[:16].lower()
    if not s:
        return False
    if s.startswith(b"<!doctype") or s.startswith(b"<html"):
        return True
    if s.startswith(b"{") and b"error" in s:
        return True
    return False


def download_requests(url: str, name: str, outdir: Path, attempts: int = 4, backoff: float = 1.5):
    try:
        import requests
    except Exception:
        raise

    headers = {"User-Agent": "Mozilla/5.0"}
    tmp = outdir / (name + ".part")
    target = outdir / name

    for attempt in range(1, attempts + 1):
        try:
            with requests.Session() as s:
                r = s.get(url, headers=headers, stream=True, allow_redirects=True, timeout=30)
                r.raise_for_status()
                # stream to temp file
                with open(tmp, "wb") as fh:
                    first_chunk = b""
                    for chunk in r.iter_content(chunk_size=8192):
                        if not chunk:
                            continue
                        if len(first_chunk) < 512:
                            need = 512 - len(first_chunk)
                            first_chunk += chunk[:need]
                        fh.write(chunk)
                # cheap HTML sniff on first bytes
                if _sniff_html_prefix(first_chunk):
                    tmp.unlink(missing_ok=True)
                    raise RuntimeError(f"Downloaded HTML (login/listing) instead of file: {name}. Provide a direct file link.")
                shutil.move(str(tmp), str(target))
                return
        except Exception as exc:
            if tmp.exists():
                try:
                    tmp.unlink()
                except Exception:
                    pass
            if attempt == attempts:
                raise
            time.sleep(backoff * attempt)


def download_urllib(url: str, name: str, outdir: Path):
    # fallback if requests unavailable
    try:
        from urllib.request import urlretrieve
    except Exception:
        raise
    target = outdir / name
    urlretrieve(url, target)
    # minimal sniff
    with open(target, "rb") as fh:
        head = fh.read(512)
        if _sniff_html_prefix(head):
            target.unlink(missing_ok=True)
            raise RuntimeError(f"Downloaded HTML (login/listing) instead of file: {name}. Provide a direct file link.")


def dl(url: str, name: str):
    if not url:
        return
    print("→", name)
    try:
        try:
            download_requests(url, name, OUT)
        except Exception as e:
            # if requests not installed or download_requests failed, try urllib fallback once
            try:
                download_urllib(url, name, OUT)
            except Exception:
                raise
    except Exception as exc:
        raise RuntimeError(f"Failed to download {name}: {exc}")


if __name__ == "__main__":
    for url, name in BUNDLES:
        if url:
            dl(url, name)
    for url, name in EXHIBITS:
        if url:
            dl(url, name)

    # Evidence marker
    (OUT / 'EVIDENCE.txt').write_text('THIS IS EVIDENCE', encoding='utf-8')

    print("Done. Files are in:", OUT.resolve())
