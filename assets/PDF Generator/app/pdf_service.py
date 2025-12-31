import fitz
import os
import arabic_reshaper
from bidi.algorithm import get_display
from PIL import Image
from typing import List, Optional


def fill_pdf(template_path: str, output_path: str, data: dict, photo_path: str = None, attachments: List[dict] = None):
    """
    Fills the PDF form fields with data and inserts photo.
    Replaces form fields with flat text to avoid appearance issues.
    Handles Arabic text reshaping and resizing.
    Appends attachments (images/PDFs) as additional pages with titles.
    
    Args:
        attachments: List of dicts with 'name' and 'file_path' keys
    """
    if not os.path.exists(template_path):
        raise FileNotFoundError(f"Template not found: {template_path}")

    doc = fitz.open(template_path)
    page = doc[0] 
    
    # Font Configuration - check multiple possible font paths
    font_paths = [
        "C:/Windows/Fonts/arial.ttf",  # Windows
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",  # Linux (Debian/Ubuntu)
        "/usr/share/fonts/TTF/DejaVuSans.ttf",  # Linux (Arch)
        "assets/arial.ttf",  # Bundled font (fallback)
    ]
    
    font_path = None
    for fp in font_paths:
        if os.path.exists(fp):
            font_path = fp
            break
    
    font_name = "Arial"
    
    # Register font for the page
    if font_path and os.path.exists(font_path):
        page.insert_font(fontname=font_name, fontfile=font_path)
        calc_font = fitz.Font(fontfile=font_path)
    else:
        calc_font = fitz.Font("helv") 
        font_name = "helv"

    # STEP 1: Collect ALL widget info FIRST (before any modifications)
    widgets_info = []
    for widget in page.widgets():
        field_name = widget.field_name
        rect = fitz.Rect(widget.rect)  # Make a copy of the rect
        if field_name in data:
            widgets_info.append({
                'name': field_name,
                'rect': rect,
                'value': data[field_name]
            })
    
    # STEP 2: Delete ALL widgets at once
    # We need to iterate again because deleting while iterating causes issues
    widgets_to_delete = list(page.widgets())
    for widget in widgets_to_delete:
        try:
            page.delete_widget(widget)
        except:
            pass  # Some widgets may fail to delete, that's ok
    
    # STEP 3: Insert text for each field using saved rect info
    for info in widgets_info:
        rect = info['rect']
        text_value = info['value']
        field_name = info['name']
        
        if not text_value:
            continue
            
        text = str(text_value)
        
        # Handle Arabic Text (Reshape & Bidi)
        try:
            reshaped_text = arabic_reshaper.reshape(text)
            bidi_text = get_display(reshaped_text)
        except Exception:
            bidi_text = text
        
        # Calculate Font Size to Fit Width
        fontsize = 12
        min_fontsize = 6
        max_width = rect.width - 2
        
        while fontsize > min_fontsize:
            text_width = calc_font.text_length(bidi_text, fontsize=fontsize)
            if text_width <= max_width:
                break
            fontsize -= 0.5
            
        # Insert Text with center alignment
        try:
            page.insert_textbox(
                rect, 
                bidi_text, 
                fontsize=fontsize, 
                fontname=font_name,
                align=1,  # Center
                color=(0, 0, 0)
            )
        except Exception as e:
            print(f"Error inserting text for {field_name}: {e}")
    
    # Insert Photo
    if photo_path and os.path.exists(photo_path):
        photo_size = os.path.getsize(photo_path)
        print(f"Inserting photo: {photo_path}, size: {photo_size} bytes")
        if photo_size == 0:
            print(f"WARNING: Photo file is empty, skipping")
        else:
            rect = fitz.Rect(11.5, 115.0, 103.2, 220.8)
            try:
                page.insert_image(rect, filename=photo_path)
            except Exception as e:
                print(f"Error inserting photo: {e}")
    elif photo_path:
        print(f"Photo path provided but file not found: {photo_path}")

    doc.save(output_path)
    doc.close()
    
    # Append attachments as additional pages
    if attachments:
        append_attachments_to_pdf(output_path, attachments)


def append_attachments_to_pdf(pdf_path: str, attachments: List[dict]):
    """
    Appends attachment files (images or PDFs) as additional pages to the PDF.
    Each attachment gets a title header with its name.
    
    Args:
        attachments: List of dicts with 'name' and 'file_path' keys
    """
    if not attachments:
        print("No attachments to append")
        return
    
    print(f"Appending {len(attachments)} attachments to PDF")
    
    doc = fitz.open(pdf_path)
    
    # Font Configuration for title
    font_paths = [
        "C:/Windows/Fonts/arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/TTF/DejaVuSans.ttf",
        "assets/arial.ttf",
    ]
    
    font_path = None
    for fp in font_paths:
        if os.path.exists(fp):
            font_path = fp
            break
    
    font_name = "Arial" if font_path else "helv"
    
    for attachment in attachments:
        attachment_name = attachment.get('name', 'مرفق')
        attachment_path = attachment.get('file_path', '')
        
        print(f"Processing attachment: {attachment_name} at {attachment_path}")
        
        if not os.path.exists(attachment_path):
            print(f"Attachment not found: {attachment_path}")
            continue
        
        # Check file size
        file_size = os.path.getsize(attachment_path)
        print(f"Attachment file size: {file_size} bytes")
        if file_size == 0:
            print(f"WARNING: Attachment file is empty: {attachment_path}")
            continue
        
        ext = os.path.splitext(attachment_path)[1].lower()
        
        try:
            if ext == '.pdf':
                # For PDFs, add a title page first, then merge PDF pages
                a4_width, a4_height = 595, 842
                title_page = doc.new_page(width=a4_width, height=a4_height)
                
                # Add title
                title_text = attachment_name
                try:
                    reshaped = arabic_reshaper.reshape(title_text)
                    title_text = get_display(reshaped)
                except:
                    pass
                
                if font_path:
                    title_page.insert_font(fontname=font_name, fontfile=font_path)
                
                title_page.insert_textbox(
                    fitz.Rect(36, 36, a4_width - 36, 80),
                    title_text,
                    fontsize=24,
                    fontname=font_name,
                    align=1,  # Center
                    color=(0.2, 0.2, 0.6)
                )
                
                # Merge PDF pages after title
                attachment_doc = fitz.open(attachment_path)
                doc.insert_pdf(attachment_doc)
                attachment_doc.close()
                
            elif ext in ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp']:
                # Convert image to PDF page with title
                img = Image.open(attachment_path)
                img_width, img_height = img.size
                
                # A4 size: 595 x 842 points
                a4_width, a4_height = 595, 842
                
                # Create new page
                new_page = doc.new_page(width=a4_width, height=a4_height)
                
                # Add title at top
                title_text = attachment_name
                try:
                    reshaped = arabic_reshaper.reshape(title_text)
                    title_text = get_display(reshaped)
                except:
                    pass
                
                if font_path:
                    new_page.insert_font(fontname=font_name, fontfile=font_path)
                
                new_page.insert_textbox(
                    fitz.Rect(36, 20, a4_width - 36, 60),
                    title_text,
                    fontsize=20,
                    fontname=font_name,
                    align=1,  # Center
                    color=(0.2, 0.2, 0.6)
                )
                
                # Calculate scaling to fit image on page with margins and title space
                margin = 36
                title_space = 70  # Space for title
                max_width = a4_width - 2 * margin
                max_height = a4_height - title_space - 2 * margin
                
                scale = min(max_width / img_width, max_height / img_height)
                new_width = img_width * scale
                new_height = img_height * scale
                
                # Center the image horizontally, place below title
                x_offset = (a4_width - new_width) / 2
                y_offset = title_space + margin
                
                rect = fitz.Rect(x_offset, y_offset, x_offset + new_width, y_offset + new_height)
                new_page.insert_image(rect, filename=attachment_path)
                
                img.close()
            else:
                print(f"Unsupported attachment format: {ext}")
        except Exception as e:
            print(f"Error processing attachment {attachment_path}: {e}")
    
    # Save to a temporary file first to avoid "save to original must be incremental" error
    temp_output = pdf_path + ".tmp"
    doc.save(temp_output)
    doc.close()
    
    # Replace original file
    if os.path.exists(pdf_path):
        os.remove(pdf_path)
    os.rename(temp_output, pdf_path)

