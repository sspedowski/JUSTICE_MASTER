import os
import csv
import tempfile
from generate_batch_pdf import build_pdf


def test_build_pdf_creates_file():
    tmpdir = tempfile.mkdtemp()
    csv_path = os.path.join(tmpdir, 'test_index.csv')
    pdf_path = os.path.join(tmpdir, 'out.pdf')
    rows = [
        ['Batch #','Filename','Category','Children (Jace/Josh/Other)','Dates / Case #','Summary','Misconduct? (Yes/No)','Law Violated (if any)','Page / Paragraph','Description of Violation','Status (✅ Include / ❌ Remove)','Notes'],
        ['03','example.pdf','','Jace, Josh','','Test summary','Yes','','','Test violation','✅ Include','Test note']
    ]
    with open(csv_path,'w',newline='',encoding='utf-8') as fh:
        writer = csv.writer(fh)
        writer.writerows(rows)
    # call builder
    build_pdf(csv_path, 3, pdf_path)
    assert os.path.exists(pdf_path)
    assert os.path.getsize(pdf_path) > 0
