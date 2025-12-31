import fitz

def list_widgets(pdf_path):
    doc = fitz.open(pdf_path)
    page = doc[0]
    widgets = []
    for widget in page.widgets():
        widgets.append({
            "name": widget.field_name,
            "rect": [widget.rect.x0, widget.rect.y0, widget.rect.x1, widget.rect.y1],
            "value": widget.field_value
        })
    
    # Sort by Y then X to get a reading order
    widgets.sort(key=lambda w: (w['rect'][1], w['rect'][0]))
    
    for w in widgets:
        print(f"Field: {w['name']} | Rect: {w['rect']}")

if __name__ == "__main__":
    list_widgets(r"assets/الاستمارة الجديدة الدائمية.pdf")
