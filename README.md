# Justice_Master

[![CI](https://github.com/sspedowski/JUSTICE_MASTER/actions/workflows/ci.yml/badge.svg)](https://github.com/sspedowski/JUSTICE_MASTER/actions/workflows/ci.yml)

This is the single source of truth for Stephanie's Justice project (Jace & Josh).

## Project Structure
- `01_Instructions/` – Locked processing format (July 17, 2025) and master rules
	- Contains standardized templates and procedures
	- Defines document handling protocols
  
- `02_Batches/` – Each 10‑doc batch folder with originals and per‑doc outputs
	- Organized by batch number (Batch_1, Batch_2, etc.)
	- Contains original documents and processed outputs
	- Includes per-document analysis and summaries

- `03_Exhibits/` – Final exhibit bundles by category and recipient
	- Organized by recipient (Courts, DOJ, FBI, Media)
	- Contains finalized, reviewed documents
	- Includes submission-ready packages

- `04_Analysis/` – Side‑by‑side edits, timelines, whistleblower notes
	- Contains detailed comparative analysis
	- Includes chronological event tracking
	- Houses whistleblower documentation

- `05_Dashboard/` – App code (frontend, backend, tests) + CI
	- Frontend: React-based user interface
	- Backend: API and data management
	- Tests: Automated testing suite
	- CI: Continuous Integration configuration

- `06_Distribution/` – Cover letters, recipient variants, contact lists
	- Template cover letters
	- Recipient-specific document variants
	- Maintained contact database

- `07_Book_Project/` – Chapters and faith narrative
	- Manuscript drafts and outlines
	- Supporting documentation
	- Editorial notes

- `99_Master_Index.xlsx` – Master tracker
	- Document inclusion/removal status
	- Child document relationships
	- Misconduct categorization

## First‑time Setup
```bash
git lfs install
git lfs track "*.pdf" "*.docx" "*.xlsx" "*.pptx"
git add .gitattributes
git commit -m "chore: enable Git LFS"
```

## Workflow Instructions

### 1. Document Batch Processing
1. Create new batch folder in `02_Batches/Batch_##/`
2. Add original documents to batch folder
3. For each document:
	 - Create summary (MD/HTML format)
	 - Complete misconduct analysis table
	 - Generate processed output files
4. Update `99_Master_Index.xlsx` with new entries

### 2. Analysis and Review
1. Perform side-by-side comparison in `04_Analysis/SideBySide/`
2. Update timeline entries in `04_Analysis/Timelines/`
3. Add relevant whistleblower notes to `04_Analysis/Whistleblower/`
4. Review and validate all analysis documents

### 3. Exhibit Preparation
1. Sort processed documents by recipient
2. Create exhibit bundles in `03_Exhibits/By_Recipient/`
3. Generate necessary redactions or variations
4. Prepare submission packages

### 4. Distribution
1. Select appropriate cover letter template from `06_Distribution/`
2. Customize recipient-specific content
3. Prepare final distribution packages
4. Update contact tracking

### 5. Dashboard Updates
1. Update frontend displays as needed
2. Maintain backend data consistency
3. Run test suite before deployment
4. Monitor CI/CD pipeline

### Quality Control
- Regular validation of Master Index
- Cross-reference between batches and exhibits
- Maintain consistent formatting
- Regular backup procedures
- Version control compliance

## Contact
For project-related questions or concerns, refer to the contact information in `06_Distribution/`.
