import fitz

pdf_path = r"assets/الاستمارة الجديدة الدائمية.pdf"
output_path = r"assets/annotated_form_fields.pdf"

doc = fitz.open(pdf_path)
page = doc[0]

# Define colors for better visibility
RED = (1, 0, 0)
BLUE = (0, 0, 1)

for widget in page.widgets():
    rect = widget.rect
    field_name = widget.field_name
    
    # Draw a red rectangle around the field
    page.draw_rect(rect, color=RED, width=1.5)
    
    # Add the field name as a label above or inside the field
    # Position the label slightly above the field
    label_point = fitz.Point(rect.x0, rect.y0 - 2)
    
    # Insert the field name text
    page.insert_text(
        label_point,
        field_name,
        fontsize=8,
        color=BLUE,
        fontname="helv"
    )

# Save the annotated PDF
doc.save(output_path)
doc.close()

print(f"Annotated PDF saved to: {output_path}")
print("Open this file to see all field names marked on the form!")
