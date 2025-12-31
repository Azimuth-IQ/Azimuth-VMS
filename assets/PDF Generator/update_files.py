import os

models_content = r'''from sqlalchemy import Column, Integer, String
from .database import Base

class Volunteer(Base):
    __tablename__ = "volunteers"

    id = Column(Integer, primary_key=True, index=True)
    text1 = Column(String, nullable=True)
    text2 = Column(String, nullable=True)
    
    # Name fields (replacing text3)
    first_name = Column(String, nullable=True)
    father_name = Column(String, nullable=True)
    grandfather_name = Column(String, nullable=True)
    great_grandfather_name = Column(String, nullable=True)
    surname = Column(String, nullable=True)
    
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
'''

form_content = r'''{% extends "base.html" %}

{% block content %}
<style>
    .step-indicator {
        display: flex;
        justify-content: space-between;
        margin-bottom: 30px;
        position: relative;
    }
    .step-indicator::before {
        content: '';
        position: absolute;
        top: 15px;
        left: 0;
        right: 0;
        height: 2px;
        background: #e9ecef;
        z-index: 0;
    }
    .step {
        width: 35px;
        height: 35px;
        background: #e9ecef;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
        color: #6c757d;
        position: relative;
        z-index: 1;
        cursor: pointer;
    }
    .step.active {
        background: #3498db;
        color: white;
    }
    .step.completed {
        background: #2ecc71;
        color: white;
    }
    .step-label {
        position: absolute;
        top: 40px;
        left: 50%;
        transform: translateX(-50%);
        white-space: nowrap;
        font-size: 0.8rem;
        color: #6c757d;
    }
    .step.active .step-label { color: #3498db; font-weight: bold; }
    
    .form-section { display: none; animation: fadeIn 0.3s; }
    .form-section.active { display: block; }
    
    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

    .camera-preview {
        width: 100%;
        max-width: 300px;
        height: 225px;
        background: #000;
        margin: 10px auto;
        display: none;
    }
    .photo-preview {
        width: 150px;
        height: 150px;
        object-fit: cover;
        border-radius: 10px;
        border: 2px solid #ddd;
        margin-top: 10px;
    }
</style>

<div class="card shadow">
    <div class="card-header bg-white">
        <h4 class="mb-0">{{ "تعديل استمارة" if volunteer else "إضافة استمارة جديدة" }}</h4>
    </div>
    <div class="card-body">
        
        <!-- Stepper Header -->
        <div class="step-indicator px-4">
            <div class="step active" onclick="showStep(1)">1<span class="step-label">المعلومات الشخصية</span></div>
            <div class="step" onclick="showStep(2)">2<span class="step-label">السكن والاتصال</span></div>
            <div class="step" onclick="showStep(3)">3<span class="step-label">التعليم والعمل</span></div>
            <div class="step" onclick="showStep(4)">4<span class="step-label">المستمسكات</span></div>
            <div class="step" onclick="showStep(5)">5<span class="step-label">التطوع</span></div>
            <div class="step" onclick="showStep(6)">6<span class="step-label">الصورة</span></div>
        </div>

        <form method="post" enctype="multipart/form-data" id="volunteerForm">
            
            <!-- Step 1: Personal Info -->
            <div class="form-section active" id="step1">
                <h5 class="mb-3 border-bottom pb-2">المعلومات الشخصية</h5>
                <div class="row">
                    <div class="col-md-4 mb-3">
                        <label class="form-label">رقم الاستمارة</label>
                        <input type="text" name="text1" class="form-control" value="{{ volunteer['text1'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label">اسم المجموعة والرمز</label>
                        <input type="text" name="text2" class="form-control" value="{{ volunteer['text2'] if volunteer else '' }}">
                    </div>
                </div>
                
                <h6 class="mt-3 mb-2 text-primary">الاسم الكامل</h6>
                <div class="row">
                    <div class="col-md-2 mb-3">
                        <label class="form-label">الاسم الأول</label>
                        <input type="text" name="first_name" class="form-control" value="{{ volunteer['first_name'] if volunteer else '' }}" required>
                    </div>
                    <div class="col-md-2 mb-3">
                        <label class="form-label">اسم الأب</label>
                        <input type="text" name="father_name" class="form-control" value="{{ volunteer['father_name'] if volunteer else '' }}" required>
                    </div>
                    <div class="col-md-2 mb-3">
                        <label class="form-label">اسم الجد</label>
                        <input type="text" name="grandfather_name" class="form-control" value="{{ volunteer['grandfather_name'] if volunteer else '' }}" required>
                    </div>
                    <div class="col-md-3 mb-3">
                        <label class="form-label">اسم أب الجد</label>
                        <input type="text" name="great_grandfather_name" class="form-control" value="{{ volunteer['great_grandfather_name'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-3 mb-3">
                        <label class="form-label">اللقب</label>
                        <input type="text" name="surname" class="form-control" value="{{ volunteer['surname'] if volunteer else '' }}" required>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-4 mb-3">
                        <label class="form-label">المواليد</label>
                        <input type="text" name="text5" class="form-control" value="{{ volunteer['text5'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label">الحالة الاجتماعية</label>
                        <input type="text" name="text6" class="form-control" value="{{ volunteer['text6'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label">عدد الابناء</label>
                        <input type="text" name="text7" class="form-control" value="{{ volunteer['text7'] if volunteer else '' }}">
                    </div>
                </div>
                <div class="text-end mt-3">
                    <button type="button" class="btn btn-primary" onclick="nextStep(2)">التالي <i class="bi bi-arrow-left"></i></button>
                </div>
            </div>

            <!-- Step 2: Contact & Address -->
            <div class="form-section" id="step2">
                <h5 class="mb-3 border-bottom pb-2">السكن والاتصال</h5>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">رقم الموبايل</label>
                        <input type="text" name="text9" class="form-control" value="{{ volunteer['text9'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">العنوان الحالي</label>
                        <input type="text" name="text10" class="form-control" value="{{ volunteer['text10'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">العنوان السابق</label>
                        <input type="text" name="text14" class="form-control" value="{{ volunteer['text14'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">رقم بطاقة السكن</label>
                        <input type="text" name="text28" class="form-control" value="{{ volunteer['text28'] if volunteer else '' }}">
                    </div>
                </div>
                <div class="d-flex justify-content-between mt-3">
                    <button type="button" class="btn btn-secondary" onclick="prevStep(1)"><i class="bi bi-arrow-right"></i> السابق</button>
                    <button type="button" class="btn btn-primary" onclick="nextStep(3)">التالي <i class="bi bi-arrow-left"></i></button>
                </div>
            </div>

            <!-- Step 3: Education & Work -->
            <div class="form-section" id="step3">
                <h5 class="mb-3 border-bottom pb-2">التعليم والعمل</h5>
                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label">التحصيل الدراسي</label>
                        <input type="text" name="text4" class="form-control" value="{{ volunteer['text4'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">العنوان الوظيفي</label>
                        <input type="text" name="text17" class="form-control" value="{{ volunteer['text17'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">أسم الدائرة</label>
                        <input type="text" name="text18" class="form-control" value="{{ volunteer['text18'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">الموهبة او الخبرة</label>
                        <input type="text" name="text20" class="form-control" value="{{ volunteer['text20'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">اللغات التي يجيدها</label>
                        <input type="text" name="text21" class="form-control" value="{{ volunteer['text21'] if volunteer else '' }}">
                    </div>
                </div>
                <div class="d-flex justify-content-between mt-3">
                    <button type="button" class="btn btn-secondary" onclick="prevStep(2)"><i class="bi bi-arrow-right"></i> السابق</button>
                    <button type="button" class="btn btn-primary" onclick="nextStep(4)">التالي <i class="bi bi-arrow-left"></i></button>
                </div>
            </div>

            <!-- Step 4: Official Documents -->
            <div class="form-section" id="step4">
                <h5 class="mb-3 border-bottom pb-2">المستمسكات الرسمية</h5>
                <div class="row">
                    <div class="col-md-4 mb-3">
                        <label class="form-label">دائرة الاحوال</label>
                        <input type="text" name="text13" class="form-control" value="{{ volunteer['text13'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label">السجل</label>
                        <input type="text" name="text23" class="form-control" value="{{ volunteer['text23'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label">الصحيفة</label>
                        <input type="text" name="text24" class="form-control" value="{{ volunteer['text24'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">رقم البطاقة التموينية</label>
                        <input type="text" name="text25" class="form-control" value="{{ volunteer['text25'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label">رقم مركز التموين</label>
                        <input type="text" name="text27" class="form-control" value="{{ volunteer['text27'] if volunteer else '' }}">
                    </div>
                </div>
                <div class="d-flex justify-content-between mt-3">
                    <button type="button" class="btn btn-secondary" onclick="prevStep(3)"><i class="bi bi-arrow-right"></i> السابق</button>
                    <button type="button" class="btn btn-primary" onclick="nextStep(5)">التالي <i class="bi bi-arrow-left"></i></button>
                </div>
            </div>

            <!-- Step 5: Volunteer Info -->
            <div class="form-section" id="step5">
                <h5 class="mb-3 border-bottom pb-2">معلومات التطوع</h5>
                <div class="row">
                    <div class="col-md-4 mb-3">
                        <label class="form-label">عدد المشاركات</label>
                        <input type="text" name="text15" class="form-control" value="{{ volunteer['text15'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label">الانتماء السياسي</label>
                        <input type="text" name="text19" class="form-control" value="{{ volunteer['text19'] if volunteer else '' }}">
                    </div>
                    <div class="col-md-4 mb-3">
                        <label class="form-label">أصحاب الحسين</label>
                        <input type="text" name="text30" class="form-control" value="{{ volunteer['text30'] if volunteer else '' }}">
                    </div>
                </div>
                <div class="d-flex justify-content-between mt-3">
                    <button type="button" class="btn btn-secondary" onclick="prevStep(4)"><i class="bi bi-arrow-right"></i> السابق</button>
                    <button type="button" class="btn btn-primary" onclick="nextStep(6)">التالي <i class="bi bi-arrow-left"></i></button>
                </div>
            </div>

            <!-- Step 6: Photo -->
            <div class="form-section" id="step6">
                <h5 class="mb-3 border-bottom pb-2">الصورة الشخصية</h5>
                <div class="text-center">
                    {% if volunteer and volunteer.photo_path %}
                        <img src="/{{ volunteer.photo_path }}" class="photo-preview mb-3" id="currentPhoto">
                    {% else %}
                        <img src="https://via.placeholder.com/150" class="photo-preview mb-3" id="currentPhoto">
                    {% endif %}
                    
                    <div class="mb-3">
                        <label class="form-label">رفع صورة</label>
                        <input type="file" name="photo" class="form-control" accept="image/*" onchange="previewImage(this)">
                    </div>
                    
                    <div class="mb-3">
                        <p>أو التقاط صورة</p>
                        <button type="button" class="btn btn-outline-primary" onclick="startCamera()">
                            <i class="bi bi-camera"></i> فتح الكاميرا
                        </button>
                        <video id="camera" class="camera-preview" autoplay playsinline></video>
                        <canvas id="canvas" style="display:none;"></canvas>
                        <button type="button" id="captureBtn" class="btn btn-success mt-2" style="display:none;" onclick="capturePhoto()">
                            <i class="bi bi-camera-fill"></i> التقاط
                        </button>
                        <input type="hidden" name="camera_image" id="cameraInput">
                    </div>
                </div>

                <div class="d-flex justify-content-between mt-4">
                    <button type="button" class="btn btn-secondary" onclick="prevStep(5)"><i class="bi bi-arrow-right"></i> السابق</button>
                    <button type="submit" class="btn btn-success btn-lg">حفظ الاستمارة <i class="bi bi-check-circle"></i></button>
                </div>
            </div>

        </form>
    </div>
</div>

<script>
    let currentStep = 1;
    const totalSteps = 6;

    function showStep(step) {
        document.querySelectorAll('.form-section').forEach(el => el.classList.remove('active'));
        document.getElementById('step' + step).classList.add('active');
        
        document.querySelectorAll('.step').forEach((el, index) => {
            if (index + 1 < step) {
                el.classList.add('completed');
                el.classList.remove('active');
            } else if (index + 1 === step) {
                el.classList.add('active');
                el.classList.remove('completed');
            } else {
                el.classList.remove('active', 'completed');
            }
        });
        currentStep = step;
    }

    function nextStep(step) {
        showStep(step);
    }

    function prevStep(step) {
        showStep(step);
    }

    function previewImage(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function(e) {
                document.getElementById('currentPhoto').src = e.target.result;
            }
            reader.readAsDataURL(input.files[0]);
        }
    }

    // Camera Logic
    let stream;
    async function startCamera() {
        try {
            stream = await navigator.mediaDevices.getUserMedia({ video: true });
            const video = document.getElementById('camera');
            video.srcObject = stream;
            video.style.display = 'block';
            document.getElementById('captureBtn').style.display = 'inline-block';
        } catch (err) {
            alert("Could not access camera: " + err);
        }
    }

    function capturePhoto() {
        const video = document.getElementById('camera');
        const canvas = document.getElementById('canvas');
        const context = canvas.getContext('2d');
        
        canvas.width = video.videoWidth;
        canvas.height = video.videoHeight;
        context.drawImage(video, 0, 0, canvas.width, canvas.height);
        
        const dataURL = canvas.toDataURL('image/jpeg');
        document.getElementById('currentPhoto').src = dataURL;
        document.getElementById('cameraInput').value = dataURL;
        
        // Stop camera
        stream.getTracks().forEach(track => track.stop());
        video.style.display = 'none';
        document.getElementById('captureBtn').style.display = 'none';
    }
</script>
{% endblock %}
'''

main_content = r'''from fastapi import FastAPI, Request, Depends, Form, UploadFile, File, HTTPException
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
                models.Volunteer.first_name.contains(q),
                models.Volunteer.surname.contains(q)
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
    
    # Handle standard text fields
    for i in range(1, 31):
        if i == 3: continue # Skip text3 as it's replaced by name fields
        key = f"text{i}"
        data[key] = form_data.get(key, "")
    
    # Handle Name Fields
    data["first_name"] = form_data.get("first_name", "")
    data["father_name"] = form_data.get("father_name", "")
    data["grandfather_name"] = form_data.get("grandfather_name", "")
    data["great_grandfather_name"] = form_data.get("great_grandfather_name", "")
    data["surname"] = form_data.get("surname", "")
    
    # Handle Image
    camera_image = form_data.get("camera_image")
    photo_path = save_image(file=photo, base64_str=camera_image)
    if photo_path:
        data["photo_path"] = photo_path.replace("\\", "/")

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
    
    # Update standard fields
    for i in range(1, 31):
        if i == 3: continue
        key = f"text{i}"
        setattr(volunteer, key, form_data.get(key, ""))
    
    # Update Name Fields
    volunteer.first_name = form_data.get("first_name", "")
    volunteer.father_name = form_data.get("father_name", "")
    volunteer.grandfather_name = form_data.get("grandfather_name", "")
    volunteer.great_grandfather_name = form_data.get("great_grandfather_name", "")
    volunteer.surname = form_data.get("surname", "")
    
    # Handle Image
    camera_image = form_data.get("camera_image")
    new_photo_path = save_image(file=photo, base64_str=camera_image)
    if new_photo_path:
        volunteer.photo_path = new_photo_path.replace("\\", "/")
    
    db.commit()
    return RedirectResponse(url="/", status_code=303)

@app.get("/pdf/{id}")
def generate_pdf(id: int, db: Session = Depends(get_db)):
    volunteer = db.query(models.Volunteer).filter(models.Volunteer.id == id).first()
    if not volunteer:
        raise HTTPException(status_code=404, detail="Not found")
    
    data = {}
    for i in range(1, 31):
        if i == 3:
            # Construct Full Name for Text3
            parts = [
                volunteer.first_name,
                volunteer.father_name,
                volunteer.grandfather_name,
                volunteer.great_grandfather_name,
                volunteer.surname
            ]
            # Filter out None or empty strings and join
            full_name = " ".join([p for p in parts if p])
            data["Text3"] = full_name
        else:
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
'''

with open("app/models.py", "w", encoding="utf-8") as f:
    f.write(models_content)

with open("app/templates/form.html", "w", encoding="utf-8") as f:
    f.write(form_content)

with open("app/main.py", "w", encoding="utf-8") as f:
    f.write(main_content)

print("Files updated successfully.")
