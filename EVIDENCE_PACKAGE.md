# Evidence package: prepare & deliver

This file lists practical, low-risk steps to prepare a digital evidence package and how to submit it to federal law enforcement (FBI). This is guidance only — consider consulting an attorney for sensitive matters.

## Quick summary

- Preserve originals. Never modify original files. Work on copies.
- Produce a simple manifest (filename, size, SHA-256) and include it with the package.
- Compute cryptographic hashes and keep a chain-of-custody record.
- Deliver via the FBI tip line or your local FBI field office (links below). If immediate danger is present, call 911.

## Create a working folder

1. Make a new folder next to the originals, named clearly (e.g., `EVIDENCE_PACKAGE_YYYYMMDD`).
2. Copy files (do not move) into the folder. Keep originals unchanged and note their original paths.
3. If you must extract contents from archives or containers, keep a copy of the original archive as well.

## Manifest (required)

Create a manifest file `MANIFEST.csv` with these columns (comma-separated):

filename,size_bytes,sha256,notes

Example:

EX-001__CPS_Report.pdf,2534212,3b7f5f1a...,'copied from \\\\server\\share\\reports\\'

Notes:

- Use exact filenames as placed in the package.
- Write clear notes about source and any processing you applied.

## Compute hashes (verification)

Use SHA-256. Examples:

- macOS / Linux (bash):

  sha256sum "path/to/file" | awk '{print $1}'

- Windows PowerShell:

  Get-FileHash -Algorithm SHA256 -Path .\\path\\to\\file | Select-Object -ExpandProperty Hash

Add each file's hex hash to `MANIFEST.csv`.

## File sizes and timestamps

Record file sizes (in bytes) and the filesystem timestamp you see when copying files. Include this in the `notes` column or a separate `COC.md` (chain-of-custody) file.

## Chain-of-custody (COC)

Create `COC.md` with minimal fields for each handling step:

- date_utc, handler_name, action, notes

Example:

2025-08-17T14:21:00Z,Jane Doe,created copy,Copied original from C:\\Users\\Jane\\Downloads\\EX-001.pdf

Keep the COC with the package and keep a separate secure log (physical or digital) of who accessed the originals.

## Packaging

1. Once manifest and checksums are ready, create a compressed archive (ZIP) of the package folder; include `MANIFEST.csv` and `COC.md` at the top-level of the archive.
2. Sign the archive if you have a digital signing capability (GPG or equivalent). Otherwise, include the SHA-256 checksum of the archive in a separate text file.

Command examples:

- Create zip (Unix/macOS):

  zip -r "EVIDENCE_PACKAGE_YYYYMMDD.zip" "EVIDENCE_PACKAGE_YYYYMMDD/"

- Create zip (Windows PowerShell):

  Compress-Archive -Path .\\EVIDENCE_PACKAGE_YYYYMMDD\* -DestinationPath EVIDENCE_PACKAGE_YYYYMMDD.zip -Force

- Hash the archive (PowerShell):

  Get-FileHash -Algorithm SHA256 -Path .\\EVIDENCE_PACKAGE_YYYYMMDD.zip | Select-Object -ExpandProperty Hash

## Sample manifest template

filename,size_bytes,sha256,notes
EX-001__CPS_Report.pdf,2534212,3b7f5f1a...,"copied from C:\\Users\\Jane\\Downloads"
EX-002__Complaint.pdf,142334,abcd1234...,"copied from OneDrive link: https://..."

## How to deliver to the FBI

1. FBI Internet Crime Complaint Center (IC3) / Tip page (non-urgent):
   - <https://tips.fbi.gov/>

2. FBI field office directory (to contact a local office):
   - <https://www.fbi.gov/contact-us/field-offices>

3. If the matter is urgent or involves immediate danger, call 911 and follow law enforcement instructions.

4. For large files or secure delivery, contact your local FBI field office by phone (directory above) and ask for guidance on secure transfer (SFTP, AFT, or other channels). Do not publish or share links publicly.

5. When using the FBI web tip form, do NOT upload extremely large archives via the form — follow the office guidance for large files.

## Suggested message / email subject (short)

Subject: Potential evidence submission — [brief subject, e.g., "Exhibit package re: alleged misconduct"], date

Body (concise):

Hello,

I have collected digital files that I believe are relevant to a potential investigation. I have prepared an evidence package with `MANIFEST.csv` and `COC.md`. Please advise the best secure method to transfer a ZIP archive (~<estimated size> MB).

Thank you,
[Your name]
[Contact phone]
[Contact email]

If you prefer immediate contact, call the local FBI field office number found at the link above.

## Safety & privacy notes

- Do not post evidence files publicly or on social media.
- Remove/obscure unrelated private data from any draft messages.
- Consider consulting a lawyer if the materials relate to whistleblowing, legal claims, or sensitive personal data.

## Optional: sample command to create per-file checksums and a CSV manifest (bash)

for f in *; do echo "$(sha256sum "$f" | awk '{print $1}'),$(stat -c%s "$f"),$f"; done > MANIFEST.csv

Adjust the columns/ordering as needed.

## Minimal checklist

- [ ] Originals preserved (not modified)
- [ ] Manifest created (`MANIFEST.csv`)
- [ ] SHA-256 checksums recorded
- [ ] Chain-of-custody log (`COC.md`) created
- [ ] Archive created and hashed
- [ ] Contacted FBI tip/page or local field office and followed delivery instructions

---

If you want, I can now:

- Insert your OneDrive link into the scripts as you previously asked (second bundle slot),
- Or prepare a short email body tailored to the local field office (include which office if you want),
- Or create a small `pack_and_hash.ps1` script that produces `MANIFEST.csv`, `COC.md` and the zip archive automatically.

Tell me which of those you want next.
