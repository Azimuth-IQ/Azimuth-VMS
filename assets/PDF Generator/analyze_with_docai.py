import os
from google.api_core.client_options import ClientOptions
from google.cloud import documentai
import fitz  # PyMuPDF

# --- Configuration ---
PROJECT_ID = "azimuth-menu"
LOCATION = "eu"
PROCESSOR_ID = "5fcf66c62b8cbc89"
PDF_PATH = r"assets/الاستمارة الجديدة الدائمية.pdf"

def get_docai_document():
    opts = ClientOptions(api_endpoint=f"{LOCATION}-documentai.googleapis.com")
    client = documentai.DocumentProcessorServiceClient(client_options=opts)
    name = client.processor_path(PROJECT_ID, LOCATION, PROCESSOR_ID)

    with open(PDF_PATH, "rb") as image:
        image_content = image.read()

    raw_document = documentai.RawDocument(content=image_content, mime_type="application/pdf")
    request = documentai.ProcessRequest(name=name, raw_document=raw_document)
    
    print(f"Sending request to Document AI (Processor: {PROCESSOR_ID})...")
    result = client.process_document(request=request)
    return result.document

import json

def update_mapping_file(mappings):
    mapping_path = "field_mapping.json"
    try:
        with open(mapping_path, "r", encoding="utf-8") as f:
            current_mapping = json.load(f)
    except FileNotFoundError:
        current_mapping = {}

    for field_name, label in mappings:
        if label:
            # Clean label
            label = label.replace("\n", " ").strip()
            current_mapping[field_name] = label
    
    with open(mapping_path, "w", encoding="utf-8") as f:
        json.dump(current_mapping, f, indent=4, ensure_ascii=False)
    
    print(f"\nUpdated {mapping_path} with new labels.")

def analyze_alignment(docai_doc):
    # 1. Get Form Fields from PyMuPDF
    pdf_doc = fitz.open(PDF_PATH)
    page = pdf_doc[0]
    height = page.rect.height
    width = page.rect.width
    
    widgets = []
    for w in page.widgets():
        widgets.append({
            "name": w.field_name,
            "rect": w.rect, # (x0, y0, x1, y1)
            "center": ((w.rect.x0 + w.rect.x1)/2, (w.rect.y0 + w.rect.y1)/2)
        })
    
    print(f"\nFound {len(widgets)} form fields in PDF.")

    # 2. Get Text Blocks from Document AI
    # DocAI coords are normalized (0-1). We need to scale them to PDF dimensions.
    print("\n--- Mapping Fields to Nearest Text ---")
    
    mappings = []

    for widget in widgets:
        wx, wy = widget["center"]
        
        # Find nearest text to the RIGHT or ABOVE the widget
        # Arabic labels are usually to the RIGHT.
        
        best_text = None
        min_dist = float('inf')
        
        for page_docai in docai_doc.pages:
            for block in page_docai.blocks:
                # Get text for this block
                start = block.layout.text_anchor.text_segments[0].start_index
                end = block.layout.text_anchor.text_segments[0].end_index
                text = docai_doc.text[start:end].strip()
                
                if not text: continue

                # Get bounding box
                vertices = block.layout.bounding_poly.normalized_vertices
                if not vertices: continue
                
                # Scale to PDF size
                bx0 = min(v.x for v in vertices) * width
                bx1 = max(v.x for v in vertices) * width
                by0 = min(v.y for v in vertices) * height
                by1 = max(v.y for v in vertices) * height
                
                b_center_x = (bx0 + bx1) / 2
                b_center_y = (by0 + by1) / 2
                
                # Calculate distance
                # We prioritize text that is to the RIGHT of the widget (larger X) and roughly same Y
                # Or ABOVE (smaller Y) and roughly same X
                
                # Check if text is "Right" (Arabic Label)
                # Text X should be > Widget X
                # Text Y should be close to Widget Y
                
                is_right = (bx0 > widget["rect"].x0) and (abs(b_center_y - wy) < 20)
                
                # Check if text is "Above"
                is_above = (by1 < widget["rect"].y0) and (abs(b_center_x - wx) < 50)
                
                if is_right or is_above:
                    dist = ((b_center_x - wx)**2 + (b_center_y - wy)**2)**0.5
                    if dist < min_dist:
                        min_dist = dist
                        best_text = text
        
        mappings.append((widget["name"], best_text))
        print(f"Widget '{widget['name']}' -> Label: '{best_text}'")

    update_mapping_file(mappings)
    return mappings

if __name__ == "__main__":
    if "GOOGLE_APPLICATION_CREDENTIALS" not in os.environ:
        print("ERROR: GOOGLE_APPLICATION_CREDENTIALS environment variable not set.")
        print("Please set it to the path of your JSON key file.")
    else:
        try:
            doc = get_docai_document()
            analyze_alignment(doc)
        except Exception as e:
            print(f"Error: {e}")
