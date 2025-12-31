import fitz

pdf_path = r"assets/الاستمارة الجديدة الدائمية.pdf"
try:
    doc = fitz.open(pdf_path)
    page = doc[0]
    print("Widgets found in PDF:")
    for widget in page.widgets():
        print(f"Field Name: '{widget.field_name}', Rect: {widget.rect}")
except Exception as e:
    print(f"Error: {e}")
