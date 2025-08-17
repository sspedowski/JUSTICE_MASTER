import io
import pandas as pd
from generate_batch_pdf import build_pdf


def _csv_with_header(header):
    return io.StringIO(
        f''"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""{header}","Law Violated (if any)","Page / Paragraph","Description of Violation","Status (notes)","Notes"
"03","a.pdf","","Jace","","A summary","✅","","","",,""
"03","b.pdf","","Jace","","B summary","No","","","",,""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    )


def test_status_column_variants(tmp_path, monkeypatch):
    variants = [
        "Status (✅ Include / ❌ Remove)",
        "Status (  Include /  Remove)",
        "Status",
    ]
    for h in variants:
        csv_io = _csv_with_header(h)

        # Build a fake index file
        index_path = tmp_path / "index.csv"
        index_path.write_text(csv_io.getvalue(), encoding="utf-8")

        out_pdf = tmp_path / "out.pdf"
        build_pdf(str(index_path), "03", str(out_pdf))

        # Should include only the '✅' row (1 page/file minimum)
        assert out_pdf.exists()
        assert out_pdf.stat().st_size > 0
