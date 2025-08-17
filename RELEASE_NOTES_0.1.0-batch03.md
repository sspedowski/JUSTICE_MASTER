# Batch 03 Release

**Tag:** `v0.1.0-batch03`
**Date:** 2025-08-16

## What’s new

* ✅ Added a minimal **pytest** for the PDF generator (baseline green).
* ✅ Built **MasterFile_Batch_03.pdf** (Batch 03) and included as an asset.
* ✅ Hardened scripts:
  * `import_user_xlsx.py` (Top-10 rows import, dedupe)
  * `extract_top10_from_docx.py` (edge-case resilience)
  * `generate_batch_pdf.py` (stable build)
* ✅ CI badge + contributor guide / PR flow aligned with repo.

## Commits (recent)

* `2334791` 2025-08-16 COMMIT
* `875e492` 2025-08-16 COMMIT
* `33a701a` 2025-08-16 COMMIT
* `a6337c3` 2025-08-16 feat(batch03): import top10 rows from user spreadsheet
* `7647790` 2025-08-16 chore(batch03): remove sample DOCX imports and clean master index

## Verification

* Tests: **1 passed** (PDF generator smoke test).
* SHA256(MasterFile_Batch_03.pdf): `EB8EB43693BA80A36EB40240F1FCE41AE38EC35024B3CAE413AB9435E749A0B2`
* Branch: `main`
* Tag: `v0.1.0-batch03`

## Notes

* If the PDF exceeds GitHub asset limits (≈2 GB), store it via Git LFS or external storage and link here.
* Next up: expand extractor unit tests for odd PDFs (scanned/OCR, malformed outlines).
