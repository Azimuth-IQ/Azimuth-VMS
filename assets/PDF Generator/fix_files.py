
import os

models_content = """from sqlalchemy import Column, Integer, String
from .database import Base

class Volunteer(Base):
    __tablename__ = "volunteers"

    id = Column(Integer, primary_key=True, index=True)
    text1 = Column(String, nullable=True)
    text2 = Column(String, nullable=True)
    text3 = Column(String, nullable=True)
    text4 = Column(String, nullable=True)
    text5 = Column(String, nullable=True)
    text6 = Column(String, nullable=True)
    text7 = Column(String, nullable=True)
    text8 = Column(String, nullable=True)
    text9 = Column(String, nullable=True)
    text10 = Column(String, nullable=True)
    text11 = Column(String, nullable=True)
    text12 = Column(String, nullable=True)
    text13 = Column(String, nullable=True)
    text14 = Column(String, nullable=True)
    text15 = Column(String, nullable=True)
    text16 = Column(String, nullable=True)
    text17 = Column(String, nullable=True)
    text18 = Column(String, nullable=True)
    text19 = Column(String, nullable=True)
    text20 = Column(String, nullable=True)
    text21 = Column(String, nullable=True)
    text22 = Column(String, nullable=True)
    text23 = Column(String, nullable=True)
    text24 = Column(String, nullable=True)
    text25 = Column(String, nullable=True)
    text26 = Column(String, nullable=True)
    text27 = Column(String, nullable=True)
    text28 = Column(String, nullable=True)
    text29 = Column(String, nullable=True)
    text30 = Column(String, nullable=True)
    
    photo_path = Column(String, nullable=True)
    
    # Metadata
    created_at = Column(String, nullable=True)
"""

main_content = """from fastapi import FastAPI, Request, Depends, Form, UploadFile, File, HTTPException
from fastapi.responses import HTMLResponse, FileResponse, RedirectResponse, Response
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session
from sqlalchemy import or_
import shutil
import os
import pandas as pd
from typing import Optional
import uuid
import base64
import qrcode
from io import BytesIO

from . import models, database, pdf_service

# Create DB tables
models.Base.metadata.create_all(bind=database.engine)

app = FastAPI()

# Mount static files
os.makedirs("uploads", exist_ok=True)
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

templates = Jinja2Templates(directory="app/templates")

# Dependency
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

PDF_TEMPLATE_PATH = r"assets/الاستمارة الجديدة الدائمية.pdf"
OUTPUT_DIR = "generated_pdfs"
os.makedirs(OUTPUT_DIR, exist_ok=True)

def save_image(file: UploadFile = None, base64_str: str = None) -> Optional[str]:
    if not file and not base64_str:
        return None
    
    filename = f"photo_{uuid.uuid4()}.jpg"
    filepath = os.path.join("uploads", filename)
    
    if file and file.filename:
        with open(filepath, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        return filepath
    elif base64_str:
        # Remove header if present (data:image/jpeg;base64,...)
        if "base64," in base64_str:
            base64_str = base64_str.split("base64,")[1]
        
        try:
            img_data = base64.b64decode(base64_str)
            with open(filepath, "wb") as f:
                f.write(img_data)
            return filepath
        except:
            return None
    return None

@app.get("/", response_class=HTMLResponse)
def read_root(request: Request, q: Optional[str] = None, db: Session = Depends(get_db)):
    query = db.query(models.Volunteer)
    if q:
        query = query.filter(
            or_(
                models.Volunteer.text1.contains(q),
                models.Volunteer.text2.contains(q),
                models.Volunteer.text3.contains(q)
            )
        )
    volunteers = query.all()
    return templates.TemplateResponse("list.html", {"request": request, "volunteers": volunteers, "query": q or ""})

@app.get("/new", response_class=HTMLResponse)
def new_form(request: Request):
    return templates.TemplateResponse("form.html", {"request": request, "volunteer": None})

@app.post("/new")
async def create_volunteer(
    request: Request, 
    photo: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db)
):
    form_data = await request.form()
    data = {}
    for i in range(1, 31):
        key = f"text{i}"
        data[key] = form_data.get(key, "")
    
    # Handle Image
    camera_image = form_data.get("camera_image")
    photo_path = save_image(file=photo, base64_str=camera_image)
    if photo_path:
        data["photo_path"] = photo_path.replace("\\\\", "/")

    db_volunteer = models.Volunteer(**data)
    db.add(db_volunteer)
    db.commit()
    db.refresh(db_volunteer)
    return RedirectResponse(url="/", status_code=303)

@app.get("/edit/{id}", response_class=HTMLResponse)
def edit_form(request: Request, id: int, db: Session = Depends(get_db)):
    volunteer = db.query(models.Volunteer).filter(models.Volunteer.id == id).first()
    if not volunteer:
        raise HTTPException(status_code=404, detail="Not found")
    return templates.TemplateResponse("form.html", {"request": request, "volunteer": volunteer})

@app.post("/edit/{id}")
async def update_volunteer(
    request: Request, 
    id: int, 
    photo: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db)
):
    volunteer = db.query(models.Volunteer).filter(models.Volunteer.id == id).first()
    if not volunteer:
        raise HTTPException(status_code=404, detail="Not found")
    
    form_data = await request.form()
    for i in range(1, 31):
        key = f"text{i}"
        setattr(volunteer, key, form_data.get(key, ""))
    
    # Handle Image
    camera_image = form_data.get("camera_image")
    new_photo_path = save_image(file=photo, base64_str=camera_image)
    if new_photo_path:
        volunteer.photo_path = new_photo_path.replace("\\\\", "/")
    
    db.commit()
    return RedirectResponse(url="/", status_code=303)

@app.get("/pdf/{id}")
def generate_pdf(id: int, db: Session = Depends(get_db)):
    volunteer = db.query(models.Volunteer).filter(models.Volunteer.id == id).first()
    if not volunteer:
        raise HTTPException(status_code=404, detail="Not found")
    
    data = {}
    for i in range(1, 31):
        val = getattr(volunteer, f"text{i}")
        data[f"Text{i}"] = val if val else ""
    
    output_filename = f"volunteer_{id}_{uuid.uuid4().hex[:8]}.pdf"
    output_path = os.path.join(OUTPUT_DIR, output_filename)
    
    try:
        pdf_service.fill_pdf(PDF_TEMPLATE_PATH, output_path, data, volunteer.photo_path)
        return FileResponse(output_path, filename=output_filename)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/qr/{id}")
def get_qr(id: int):
    # Generate QR code pointing to the edit page
    data = f"http://127.0.0.1:8000/edit/{id}"
    qr = qrcode.QRCode(version=1, box_size=10, border=5)
    qr.add_data(data)
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    
    buf = BytesIO()
    img.save(buf)
    buf.seek(0)
    return Response(content=buf.getvalue(), media_type="image/png")

@app.get("/scan", response_class=HTMLResponse)
def scan_page(request: Request):
    return templates.TemplateResponse("scan.html", {"request": request})

@app.get("/download-template")
def download_template():
    path = "assets/batch_template.xlsx"
    if os.path.exists(path):
        return FileResponse(path, filename="batch_template.xlsx")
    return HTMLResponse("Template not found", status_code=404)

@app.get("/batch", response_class=HTMLResponse)
def batch_page(request: Request):
    return templates.TemplateResponse("batch.html", {"request": request})

@app.post("/batch")
async def batch_upload(request: Request, file: UploadFile = File(...), db: Session = Depends(get_db)):
    if not file.filename.endswith(('.xlsx', '.xls')):
        return HTMLResponse("Invalid file type", status_code=400)
    
    contents = await file.read()
    temp_path = f"temp_{uuid.uuid4()}.xlsx"
    with open(temp_path, "wb") as f:
        f.write(contents)
    
    try:
        df = pd.read_excel(temp_path)
        count = 0
        for _, row in df.iterrows():
            data = {}
            for i in range(1, 31):
                col_name = f"Text{i}"
                if col_name in df.columns:
                    val = row[col_name]
                    data[f"text{i}"] = str(val) if pd.notna(val) else ""
            
            if data:
                db_volunteer = models.Volunteer(**data)
                db.add(db_volunteer)
                count += 1
        
        db.commit()
        os.remove(temp_path)
        return RedirectResponse(url="/", status_code=303)
        
    except Exception as e:
        if os.path.exists(temp_path):
            os.remove(temp_path)
        return HTMLResponse(f"Error processing file: {str(e)}", status_code=500)
"""

pdf_service_content = """import fitz
import os

def fill_pdf(template_path: str, output_path: str, data: dict, photo_path: str = None):
    \"\"\"
    Fills the PDF form fields with data and inserts photo.
    \"\"\"
    if not os.path.exists(template_path):
        raise FileNotFoundError(f"Template not found: {template_path}")

    doc = fitz.open(template_path)
    page = doc[0] 

    # Fill Form Fields
    for field_name, field_value in data.items():
        widgets = [w for w in page.widgets() if w.field_name == field_name]
        if widgets:
            for widget in widgets:
                widget.field_value = str(field_value) if field_value else ""
                widget.update()
    
    # Insert Photo
    if photo_path and os.path.exists(photo_path):
        # Coordinates for Image1_af_image from previous analysis:
        # Rect(11.5, 115.0, 103.2, 220.8)
        rect = fitz.Rect(11.5, 115.0, 103.2, 220.8)
        page.insert_image(rect, filename=photo_path)

    doc.save(output_path)
    doc.close()
"""

with open("app/models.py", "w", encoding="utf-8") as f:
    f.write(models_content)

with open("app/main.py", "w", encoding="utf-8") as f:
    f.write(main_content)

with open("app/pdf_service.py", "w", encoding="utf-8") as f:
    f.write(pdf_service_content)

print("Files created successfully.")
