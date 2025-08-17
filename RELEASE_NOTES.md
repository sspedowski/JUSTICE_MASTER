# Release notes — Batch 03 pipeline (2025-08-16)

Summary

- Implemented an Excel-free ingest and PDF generation pipeline for Batch 03 Top‑10 items.
- Hardened DOCX extractor and PDF generator to reduce runtime KeyErrors and missing-column issues.
- Imported Top‑10 rows from `Top_10_Failures_Marsh_Case_Summary.xlsx` into `99_Master_Index.csv` and built `02_Batches/Batch_03/MasterFile_Batch_03.pdf`.

Key commits

- a6337c3 feat(batch03): import top10 rows from user spreadsheet
- 7647790 chore(batch03): remove sample DOCX imports and clean master index
- 2334791 chore(ci): add PR description + CI smoke workflow for Batch 03

Notes

- The pipeline is driven by `top10_pipeline.ps1`. It prefers an XLSX at repo root (`Top_10_Failures_Marsh_Case_Summary.xlsx`) or DOCX sources under `02_Batches/Batch_03/Top10`.
- `99_Master_Index.csv` is authoritative. Backups were created during imports and then cleaned locally; a pre-import backup is available in the repo history if needed.

Next steps

- Add CI badge to `README.md` (done in this release as a follow-up step).
- Consider automated tests to prevent regressions in parsing.
