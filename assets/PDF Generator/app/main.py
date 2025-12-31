from fastapi import FastAPI, Request, Depends, Form, UploadFile, File, HTTPException
from fastapi.responses import HTMLResponse, FileResponse, RedirectResponse, Response, StreamingResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from sqlalchemy.orm import Session
from sqlalchemy import or_
from starlette.middleware.sessions import SessionMiddleware
import hashlib
import shutil
import os
import pandas as pd
from typing import Optional, List
import uuid
import base64
import qrcode
from io import BytesIO
import json
import zipfile

from . import models, database, pdf_service

# Password hashing using SHA256 (simple and reliable)
def verify_password(plain_password, hashed_password):
    return hashlib.sha256(plain_password.encode()).hexdigest() == hashed_password

def get_password_hash(password):
    return hashlib.sha256(password.encode()).hexdigest()

# Use DATA_DIR from environment for persistent storage (Cloud Storage mount)
DATA_DIR = os.environ.get("DATA_DIR", ".")
UPLOADS_DIR = os.path.join(DATA_DIR, "uploads")
os.makedirs(UPLOADS_DIR, exist_ok=True)

# Create DB tables
models.Base.metadata.create_all(bind=database.engine)

# Create root user if not exists
def create_root_user():
    db = database.SessionLocal()
    try:
        existing = db.query(models.User).filter(models.User.phone == "07705371953").first()
        if not existing:
            root_user = models.User(
                phone="07705371953",
                password_hash=get_password_hash("root"),
                is_admin=True
            )
            db.add(root_user)
            db.commit()
            print("Root user created: 07705371953 / root")
    except Exception as e:
        print(f"Warning: Could not create root user: {e}")
    finally:
        db.close()

create_root_user()

app = FastAPI()

# Add session middleware (secret key for signing cookies)
app.add_middleware(SessionMiddleware, secret_key="volunteer-pdf-generator-secret-key-2024")

# Mount static files - serve from persistent storage
app.mount("/uploads", StaticFiles(directory=UPLOADS_DIR), name="uploads")

templates = Jinja2Templates(directory="app/templates")

# Dependency
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Authentication dependency
def get_current_user(request: Request, db: Session = Depends(get_db)):
    user_id = request.session.get("user_id")
    if not user_id:
        return None
    return db.query(models.User).filter(models.User.id == user_id).first()

def require_auth(request: Request, db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user:
        raise HTTPException(status_code=303, headers={"Location": "/login"})
    return user

def require_admin(request: Request, db: Session = Depends(get_db)):
    user = require_auth(request, db)
    if not user.is_admin:
        raise HTTPException(status_code=403, detail="Admin access required")
    return user

PDF_TEMPLATE_PATH = "assets/الاستمارة الجديدة الدائمية.pdf"

def get_volunteer_folder(volunteer_id: int) -> str:
    """Get or create volunteer-specific folder."""
    folder = os.path.join(UPLOADS_DIR, f"volunteer_{volunteer_id}")
    os.makedirs(folder, exist_ok=True)
    return folder

def save_image(file: UploadFile = None, base64_str: str = None, volunteer_id: int = None) -> Optional[str]:
    if not file and not base64_str:
        return None
    
    # Use volunteer-specific folder if volunteer_id is provided
    if volunteer_id:
        folder = get_volunteer_folder(volunteer_id)
    else:
        folder = UPLOADS_DIR
    
    filename = f"photo_{uuid.uuid4()}.jpg"
    filepath = os.path.join(folder, filename)
    
    if file and file.filename:
        # Read entire content first, then write in single operation (required for GCS FUSE)
        content = file.file.read()
        print(f"[SAVE_IMAGE] Read {len(content)} bytes from uploaded file: {file.filename}")
        with open(filepath, "wb") as buffer:
            buffer.write(content)
        # Verify file was written
        if os.path.exists(filepath):
            actual_size = os.path.getsize(filepath)
            print(f"[SAVE_IMAGE] Saved to {filepath}, file size: {actual_size} bytes")
        else:
            print(f"[SAVE_IMAGE] ERROR: File not found after write: {filepath}")
        return os.path.relpath(filepath, UPLOADS_DIR).replace("\\", "/")
    elif base64_str:
        # Remove header if present (data:image/jpeg;base64,...)
        if "base64," in base64_str:
            base64_str = base64_str.split("base64,")[1]
        
        try:
            img_data = base64.b64decode(base64_str)
            print(f"[SAVE_IMAGE] Decoded {len(img_data)} bytes from base64")
            with open(filepath, "wb") as f:
                f.write(img_data)
            # Verify file was written
            if os.path.exists(filepath):
                actual_size = os.path.getsize(filepath)
                print(f"[SAVE_IMAGE] Saved to {filepath}, file size: {actual_size} bytes")
            else:
                print(f"[SAVE_IMAGE] ERROR: File not found after write: {filepath}")
            return os.path.relpath(filepath, UPLOADS_DIR).replace("\\", "/")
        except Exception as e:
            print(f"[SAVE_IMAGE] ERROR decoding base64: {e}")
            return None
    return None

def save_attachment(file: UploadFile, volunteer_id: int) -> Optional[str]:
    """Save an attachment file (image or PDF) to volunteer's folder."""
    if not file or not file.filename:
        return None
    
    folder = get_volunteer_folder(volunteer_id)
    ext = os.path.splitext(file.filename)[1].lower()
    filename = f"attachment_{uuid.uuid4()}{ext}"
    filepath = os.path.join(folder, filename)
    
    # Read entire content first, then write in single operation (required for GCS FUSE)
    content = file.file.read()
    print(f"[SAVE_ATTACHMENT] Read {len(content)} bytes from uploaded file: {file.filename}")
    with open(filepath, "wb") as buffer:
        buffer.write(content)
    
    # Verify file was written
    if os.path.exists(filepath):
        actual_size = os.path.getsize(filepath)
        print(f"[SAVE_ATTACHMENT] Saved to {filepath}, file size: {actual_size} bytes")
    else:
        print(f"[SAVE_ATTACHMENT] ERROR: File not found after write: {filepath}")
    
    return os.path.relpath(filepath, UPLOADS_DIR).replace("\\", "/")

def get_attachments_for_pdf(volunteer) -> List[dict]:
    """Get list of attachments with name and file_path for PDF generation."""
    attachments = []
    for att in volunteer.attachment_list:
        file_path = att.file_path
        # Convert relative path to absolute for PDF generation
        if file_path and not os.path.isabs(file_path):
            file_path = os.path.join(UPLOADS_DIR, file_path)
        attachments.append({"name": att.name, "file_path": file_path})
    
    print(f"Found {len(attachments)} attachments for volunteer {volunteer.id}: {attachments}")
    return attachments

def migrate_volunteer_files(volunteer, db: Session):
    """Migrate existing photo to volunteer-specific folder."""
    if not volunteer.photo_path:
        return
    
    old_path = volunteer.photo_path
    if not os.path.exists(old_path):
        return
    
    # Check if already in volunteer folder
    volunteer_folder = get_volunteer_folder(volunteer.id)
    if volunteer_folder.replace("\\", "/") in old_path:
        return
    
    # Move file to volunteer folder
    filename = os.path.basename(old_path)
    new_path = os.path.join(volunteer_folder, filename)
    try:
        shutil.move(old_path, new_path)
        volunteer.photo_path = os.path.relpath(new_path, UPLOADS_DIR).replace("\\", "/")
        db.commit()
    except Exception as e:
        print(f"Error migrating file: {e}")

# ============== AUTH ROUTES ==============

@app.get("/login", response_class=HTMLResponse)
def login_page(request: Request):
    # If already logged in, redirect to home
    if request.session.get("user_id"):
        return RedirectResponse(url="/", status_code=303)
    return templates.TemplateResponse("login.html", {"request": request, "error": None})

@app.post("/login")
def login(request: Request, phone: str = Form(...), password: str = Form(...), db: Session = Depends(get_db)):
    user = db.query(models.User).filter(models.User.phone == phone).first()
    if not user or not verify_password(password, user.password_hash):
        return templates.TemplateResponse("login.html", {"request": request, "error": "رقم الهاتف أو كلمة المرور غير صحيحة"})
    
    request.session["user_id"] = user.id
    return RedirectResponse(url="/", status_code=303)

@app.get("/logout")
def logout(request: Request):
    request.session.clear()
    return RedirectResponse(url="/login", status_code=303)

@app.get("/users", response_class=HTMLResponse)
def users_page(request: Request, db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    if not user.is_admin:
        raise HTTPException(status_code=403, detail="Admin access required")
    
    users = db.query(models.User).all()
    return templates.TemplateResponse("users.html", {"request": request, "users": users, "current_user": user})

@app.post("/users/add")
def add_user(request: Request, phone: str = Form(...), password: str = Form(...), is_admin: bool = Form(False), db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user or not user.is_admin:
        raise HTTPException(status_code=403, detail="Admin access required")
    
    existing = db.query(models.User).filter(models.User.phone == phone).first()
    if existing:
        return RedirectResponse(url="/users?error=exists", status_code=303)
    
    new_user = models.User(
        phone=phone,
        password_hash=get_password_hash(password),
        is_admin=is_admin
    )
    db.add(new_user)
    db.commit()
    return RedirectResponse(url="/users", status_code=303)

@app.post("/users/delete/{user_id}")
def delete_user(request: Request, user_id: int, db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user or not user.is_admin:
        raise HTTPException(status_code=403, detail="Admin access required")
    
    # Don't allow deleting yourself
    if user_id == user.id:
        return RedirectResponse(url="/users?error=self", status_code=303)
    
    target = db.query(models.User).filter(models.User.id == user_id).first()
    if target:
        db.delete(target)
        db.commit()
    return RedirectResponse(url="/users", status_code=303)

# ============== PROTECTED ROUTES ==============

@app.get("/", response_class=HTMLResponse)
def read_root(request: Request, q: Optional[str] = None, db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    
    query = db.query(models.Volunteer)
    if q:
        query = query.filter(
            or_(
                models.Volunteer.text1.contains(q),
                models.Volunteer.text3.contains(q),
                models.Volunteer.text9.contains(q),
                models.Volunteer.text10.contains(q)
            )
        )
    volunteers = query.all()
    return templates.TemplateResponse("list.html", {"request": request, "volunteers": volunteers, "query": q or "", "current_user": user})

@app.get("/new", response_class=HTMLResponse)
def new_form(request: Request, db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    return templates.TemplateResponse("form.html", {"request": request, "volunteer": None, "current_user": user})

@app.post("/new")
async def create_volunteer(
    request: Request, 
    photo: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db)
):
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    
    form_data = await request.form()
    data = {}
    
    # Handle all 30 text fields directly
    for i in range(1, 31):
        key = f"text{i}"
        data[key] = form_data.get(key, "")
    
    # Create volunteer first to get ID
    db_volunteer = models.Volunteer(**data)
    db.add(db_volunteer)
    db.commit()
    db.refresh(db_volunteer)
    
    # Handle Image with volunteer-specific folder
    camera_image = form_data.get("camera_image")
    photo_path = save_image(file=photo, base64_str=camera_image, volunteer_id=db_volunteer.id)
    if photo_path:
        db_volunteer.photo_path = photo_path
        db.commit()

    return RedirectResponse(url=f"/edit/{db_volunteer.id}", status_code=303)

@app.get("/edit/{id}", response_class=HTMLResponse)
def edit_form(request: Request, id: int, db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    
    volunteer = db.query(models.Volunteer).filter(models.Volunteer.id == id).first()
    if not volunteer:
        raise HTTPException(status_code=404, detail="Not found")
    
    return templates.TemplateResponse("form.html", {
        "request": request, 
        "volunteer": volunteer, 
        "current_user": user,
        "attachments": volunteer.attachment_list
    })

@app.post("/edit/{id}")
async def update_volunteer(
    request: Request, 
    id: int, 
    photo: Optional[UploadFile] = File(None),
    db: Session = Depends(get_db)
):
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    
    volunteer = db.query(models.Volunteer).filter(models.Volunteer.id == id).first()
    if not volunteer:
        raise HTTPException(status_code=404, detail="Not found")
    
    form_data = await request.form()
    
    # Update all 30 text fields directly
    for i in range(1, 31):
        key = f"text{i}"
        setattr(volunteer, key, form_data.get(key, ""))
    
    # Handle Image with volunteer-specific folder
    camera_image = form_data.get("camera_image")
    new_photo_path = save_image(file=photo, base64_str=camera_image, volunteer_id=volunteer.id)
    if new_photo_path:
        # Delete old photo if exists
        if volunteer.photo_path and os.path.exists(volunteer.photo_path):
            try:
                os.remove(volunteer.photo_path)
            except:
                pass
        volunteer.photo_path = new_photo_path
    
    db.commit()
    return RedirectResponse(url=f"/edit/{id}", status_code=303)

@app.post("/delete/{id}")
def delete_volunteer(request: Request, id: int, db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    
    volunteer = db.query(models.Volunteer).filter(models.Volunteer.id == id).first()
    if not volunteer:
        raise HTTPException(status_code=404, detail="Not found")
    
    # Delete volunteer folder and all files
    volunteer_folder = get_volunteer_folder(volunteer.id)
    if os.path.exists(volunteer_folder):
        try:
            shutil.rmtree(volunteer_folder)
        except Exception as e:
            print(f"Error deleting volunteer folder: {e}")
    
    # Also delete old-style photo if exists outside folder
    if volunteer.photo_path and os.path.exists(volunteer.photo_path):
        try:
            os.remove(volunteer.photo_path)
        except:
            pass
    
    db.delete(volunteer)
    db.commit()
    return RedirectResponse(url="/", status_code=303)

# ============== ATTACHMENT ROUTES ==============

@app.post("/upload-attachment/{id}")
async def upload_attachment(
    request: Request, 
    id: int, 
    db: Session = Depends(get_db)
):
    """Upload an attachment (image or PDF) for a volunteer with a name."""
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    
    volunteer = db.query(models.Volunteer).filter(models.Volunteer.id == id).first()
    if not volunteer:
        raise HTTPException(status_code=404, detail="Not found")
    
    form_data = await request.form()
    attachment_name = form_data.get("attachment_name", "").strip()
    attachment_file = form_data.get("attachment")
    
    if not attachment_name:
        raise HTTPException(status_code=400, detail="اسم المرفق مطلوب")
    
    if not attachment_file or not hasattr(attachment_file, 'filename') or not attachment_file.filename:
        raise HTTPException(status_code=400, detail="الملف مطلوب")
    
    # Check file type
    allowed_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.pdf']
    ext = os.path.splitext(attachment_file.filename)[1].lower()
    if ext not in allowed_extensions:
        raise HTTPException(status_code=400, detail="نوع الملف غير مدعوم. المسموح: صور و PDF")
    
    # Save attachment file
    attachment_path = save_attachment(attachment_file, volunteer.id)
    if attachment_path:
        # Create new attachment record
        new_attachment = models.Attachment(
            volunteer_id=volunteer.id,
            name=attachment_name,
            file_path=attachment_path
        )
        db.add(new_attachment)
        db.commit()
    
    return RedirectResponse(url=f"/edit/{id}", status_code=303)

@app.post("/delete-attachment/{id}/{attachment_id}")
async def delete_attachment(
    request: Request, 
    id: int,
    attachment_id: int,
    db: Session = Depends(get_db)
):
    """Delete a specific attachment from a volunteer."""
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    
    volunteer = db.query(models.Volunteer).filter(models.Volunteer.id == id).first()
    if not volunteer:
        raise HTTPException(status_code=404, detail="Not found")
    
    attachment = db.query(models.Attachment).filter(
        models.Attachment.id == attachment_id,
        models.Attachment.volunteer_id == id
    ).first()
    
    if attachment:
        # Delete file
        if os.path.exists(attachment.file_path):
            try:
                os.remove(attachment.file_path)
            except Exception as e:
                print(f"Error deleting attachment file: {e}")
        
        # Delete record
        db.delete(attachment)
        db.commit()
    
    return RedirectResponse(url=f"/edit/{id}", status_code=303)

@app.get("/download-folder/{id}")
def download_folder(id: int, request: Request, db: Session = Depends(get_db)):
    """Download volunteer's folder as a ZIP file."""
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    
    volunteer = db.query(models.Volunteer).filter(models.Volunteer.id == id).first()
    if not volunteer:
        raise HTTPException(status_code=404, detail="Not found")
    
    volunteer_folder = get_volunteer_folder(volunteer.id)
    
    # Generate the PDF first to include it in the download
    name = volunteer.text3 or f"volunteer_{id}"
    safe_name = name.replace(" ", "_").replace("/", "_").replace("\\", "_").replace(":", "_")
    output_filename = f"{safe_name}.pdf"
    output_path = os.path.join(volunteer_folder, output_filename)
    
    # Generate PDF
    data = {}
    for i in range(1, 31):
        val = getattr(volunteer, f"text{i}")
        data[f"Text{i}"] = val if val else ""
    
    attachments = get_attachments_for_pdf(volunteer)
    try:
        photo_path = volunteer.photo_path
        if photo_path and not os.path.isabs(photo_path):
            photo_path = os.path.join(UPLOADS_DIR, photo_path)
        pdf_service.fill_pdf(PDF_TEMPLATE_PATH, output_path, data, photo_path, attachments)
    except Exception as e:
        print(f"Error generating PDF for download: {e}")
    
    # Create ZIP file in memory
    zip_buffer = BytesIO()
    with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zip_file:
        for root, dirs, files in os.walk(volunteer_folder):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, volunteer_folder)
                zip_file.write(file_path, arcname)
    
    zip_buffer.seek(0)
    zip_filename = f"{safe_name}_files.zip"
    
    return StreamingResponse(
        zip_buffer,
        media_type="application/zip",
        headers={"Content-Disposition": f"attachment; filename={zip_filename}"}
    )

@app.post("/delete-folder/{id}")
def delete_folder(request: Request, id: int, db: Session = Depends(get_db)):
    """Delete volunteer's folder but keep the database record."""
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    
    volunteer = db.query(models.Volunteer).filter(models.Volunteer.id == id).first()
    if not volunteer:
        raise HTTPException(status_code=404, detail="Not found")
    
    # Delete folder
    volunteer_folder = get_volunteer_folder(volunteer.id)
    if os.path.exists(volunteer_folder):
        try:
            shutil.rmtree(volunteer_folder)
        except Exception as e:
            print(f"Error deleting volunteer folder: {e}")
    
    # Clear file references
    volunteer.photo_path = None
    # Delete all attachment records
    for att in volunteer.attachment_list:
        db.delete(att)
    db.commit()
    
    return RedirectResponse(url=f"/edit/{id}", status_code=303)

@app.get("/pdf/{id}")
def generate_pdf(id: int, request: Request, db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    
    volunteer = db.query(models.Volunteer).filter(models.Volunteer.id == id).first()
    if not volunteer:
        raise HTTPException(status_code=404, detail="Not found")
    
    # Map all 30 text fields to PDF fields (Text1 to Text30)
    data = {}
    for i in range(1, 31):
        val = getattr(volunteer, f"text{i}")
        data[f"Text{i}"] = val if val else ""
    
    # Generate filename from volunteer name (text3 contains the full name)
    name = volunteer.text3 or f"volunteer_{id}"
    # Replace spaces with underscores and remove any problematic characters
    safe_name = name.replace(" ", "_").replace("/", "_").replace("\\", "_").replace(":", "_")
    
    # Save PDF to volunteer's folder
    volunteer_folder = get_volunteer_folder(volunteer.id)
    output_filename = f"{safe_name}.pdf"
    output_path = os.path.join(volunteer_folder, output_filename)
    
    # Get attachments
    attachments = get_attachments_for_pdf(volunteer)
    
    try:
        photo_path = volunteer.photo_path
        if photo_path and not os.path.isabs(photo_path):
            photo_path = os.path.join(UPLOADS_DIR, photo_path)
        pdf_service.fill_pdf(PDF_TEMPLATE_PATH, output_path, data, photo_path, attachments)
        return FileResponse(output_path, filename=output_filename)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/qr/{id}")
def get_qr(id: int, request: Request, db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    
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
def scan_page(request: Request, db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    return templates.TemplateResponse("scan.html", {"request": request, "current_user": user})

@app.get("/download-template")
def download_template(request: Request, db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    
    path = "assets/batch_template.xlsx"
    if os.path.exists(path):
        return FileResponse(path, filename="batch_template.xlsx")
    return HTMLResponse("Template not found", status_code=404)

@app.get("/batch", response_class=HTMLResponse)
def batch_page(request: Request, db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    return templates.TemplateResponse("batch.html", {"request": request, "current_user": user})

@app.post("/batch")
async def batch_upload(request: Request, file: UploadFile = File(...), db: Session = Depends(get_db)):
    user = get_current_user(request, db)
    if not user:
        return RedirectResponse(url="/login", status_code=303)
    
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
            # Handle standard fields
            for i in range(1, 31):
                if i == 3: continue
                col_name = f"Text{i}"
                if col_name in df.columns:
                    val = row[col_name]
                    data[f"text{i}"] = str(val) if pd.notna(val) else ""
            
            # Handle Name Fields from Excel
            if "First Name" in df.columns:
                data["first_name"] = str(row["First Name"]) if pd.notna(row["First Name"]) else ""
                data["father_name"] = str(row["Father Name"]) if pd.notna(row["Father Name"]) else ""
                data["grandfather_name"] = str(row["Grandfather Name"]) if pd.notna(row["Grandfather Name"]) else ""
                data["great_grandfather_name"] = str(row["Great Grandfather Name"]) if pd.notna(row["Great Grandfather Name"]) else ""
                data["surname"] = str(row["Surname"]) if pd.notna(row["Surname"]) else ""
            elif "Text3" in df.columns:
                 # Fallback: put everything in first_name
                 data["first_name"] = str(row["Text3"]) if pd.notna(row["Text3"]) else ""
            
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
