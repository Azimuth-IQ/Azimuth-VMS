import json
import os

def generate_project_files():
    mapping_path = "field_mapping.json"
    if not os.path.exists(mapping_path):
        print("Mapping file not found.")
        return

    with open(mapping_path, "r", encoding="utf-8") as f:
        mapping = json.load(f)

    # 1. Generate models.py
    models_content = """from sqlalchemy import Column, Integer, String
from .database import Base

class Volunteer(Base):
    __tablename__ = "volunteers"

    id = Column(Integer, primary_key=True, index=True)
"""
    for field_name in mapping.keys():
        # Sanitize field name for python variable (lowercase)
        var_name = field_name.lower()
        models_content += f"    {var_name} = Column(String, nullable=True)\n"
    
    models_content += """    
    # Metadata
    created_at = Column(String, nullable=True)
"""
    
    with open("app/models.py", "w", encoding="utf-8") as f:
        f.write(models_content)
    print("Updated app/models.py")

    # 2. Generate form.html
    form_content = """{% extends "base.html" %}

{% block content %}
<div class="card shadow">
    <div class="card-header bg-white">
        <h4 class="mb-0">{{ "تعديل استمارة" if volunteer else "إضافة استمارة جديدة" }}</h4>
    </div>
    <div class="card-body">
        <form method="post">
            <div class="row">
"""
    for field_name, label in mapping.items():
        var_name = field_name.lower()
        form_content += f"""                <div class="col-md-4 mb-3">
                    <label class="form-label">{label}</label>
                    <input type="text" name="{var_name}" class="form-control" 
                           value="{{{{ volunteer['{var_name}'] if volunteer else '' }}}}">
                </div>
"""
    form_content += """            </div>
            <div class="mt-4">
                <button type="submit" class="btn btn-primary btn-lg">حفظ</button>
                <a href="/" class="btn btn-secondary btn-lg">إلغاء</a>
            </div>
        </form>
    </div>
</div>
{% endblock %}
"""
    with open("app/templates/form.html", "w", encoding="utf-8") as f:
        f.write(form_content)
    print("Updated app/templates/form.html")

    # 3. Generate list.html
    # We'll show the first 4 fields in the list
    first_fields = list(mapping.items())[:4]
    
    list_content = """{% extends "base.html" %}

{% block content %}
<div class="card shadow">
    <div class="card-header bg-white">
        <div class="row align-items-center">
            <div class="col">
                <h4 class="mb-0">قائمة الاستمارات</h4>
            </div>
            <div class="col-auto">
                <a href="/new" class="btn btn-primary">إضافة استمارة</a>
            </div>
        </div>
    </div>
    <div class="card-body">
        <form method="get" action="/" class="row g-3 mb-4">
            <div class="col-md-10">
                <input type="text" name="q" class="form-control" placeholder="بحث..." value="{{ query }}">
            </div>
            <div class="col-md-2">
                <button type="submit" class="btn btn-secondary w-100">بحث</button>
            </div>
        </form>

        <div class="table-responsive">
            <table class="table table-hover table-bordered">
                <thead class="table-light">
                    <tr>
                        <th>ID</th>
"""
    for _, label in first_fields:
        list_content += f"                        <th>{label}</th>\n"
    
    list_content += """                        <th>إجراءات</th>
                    </tr>
                </thead>
                <tbody>
                    {% for v in volunteers %}
                    <tr>
                        <td>{{ v.id }}</td>
"""
    for field_name, _ in first_fields:
        var_name = field_name.lower()
        list_content += f"                        <td>{{{{ v.{var_name} }}}}</td>\n"

    list_content += """                        <td>
                            <a href="/edit/{{ v.id }}" class="btn btn-sm btn-warning">تعديل</a>
                            <a href="/pdf/{{ v.id }}" class="btn btn-sm btn-success" target="_blank">طباعة PDF</a>
                        </td>
                    </tr>
                    {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
</div>
{% endblock %}
"""
    with open("app/templates/list.html", "w", encoding="utf-8") as f:
        f.write(list_content)
    print("Updated app/templates/list.html")

    # 4. Generate batch.html (Update instructions)
    batch_content = """{% extends "base.html" %}

{% block content %}
<div class="card shadow" style="max-width: 800px; margin: 0 auto;">
    <div class="card-header bg-white">
        <h4 class="mb-0">إدخال متعدد (Batch Upload)</h4>
    </div>
    <div class="card-body">
        <p class="text-muted">
            قم برفع ملف Excel (.xlsx) يحتوي على الأعمدة التالية (بالترتيب أو بالاسم):
            <br>
            <small>
"""
    labels = [label for _, label in mapping.items()]
    batch_content += ", ".join(labels)
    
    batch_content += """
            </small>
            <br><br>
            <a href="/download-template" class="btn btn-sm btn-outline-primary">تحميل ملف القالب</a>
        </p>
        <form method="post" enctype="multipart/form-data">
            <div class="mb-3">
                <label class="form-label">ملف Excel</label>
                <input type="file" name="file" class="form-control" accept=".xlsx, .xls" required>
            </div>
            <button type="submit" class="btn btn-success w-100">رفع ومعالجة</button>
        </form>
    </div>
</div>
{% endblock %}
"""
    with open("app/templates/batch.html", "w", encoding="utf-8") as f:
        f.write(batch_content)
    print("Updated app/templates/batch.html")

    # 5. Update main.py to handle dynamic fields in batch upload?
    # Actually main.py uses `text{i}` which matches `models.py` `text{i}`.
    # But wait, `models.py` uses `text1`, `text2`...
    # The mapping keys are `Text1`, `Text2`...
    # So `var_name = field_name.lower()` works perfectly.
    # However, the batch upload logic in `main.py` expects columns named `Text1`...
    # If the user changes the Excel headers to Arabic, we need to map them back.
    # For now, let's assume the Excel template still uses `Text1`... as headers (internal IDs), 
    # but we can update the template generator to use the Labels if we want.
    # Let's stick to `Text1` headers for simplicity in the backend, but show Labels in the UI.

if __name__ == "__main__":
    generate_project_files()
