"""
Debug script to test PDF filling with all 30 fields
"""
import fitz
import os

PDF_TEMPLATE_PATH = r"assets/الاستمارة الجديدة الدائمية.pdf"
OUTPUT_PATH = r"generated_pdfs/debug_test.pdf"

# Test data for all 30 fields
test_data = {
    "Text1": "رقم 001",           # رقم الاستمارة
    "Text2": "مجموعة أ-123",       # اسم المجموعة والرمز
    "Text3": "احمد محمد علي حسين الموسوي",  # الاسم الرباعي واللقب
    "Text4": "بكالوريوس",          # التحصيل الدراسي
    "Text5": "1990/01/15",         # المواليد
    "Text6": "متزوج",              # الحالة الاجتماعية
    "Text7": "3",                  # عدد الابناء
    "Text8": "فاطمة علي حسن الكاظمي",  # اسم الام الثلاثي واللقب
    "Text9": "07701234567",        # رقم الموبايل
    "Text10": "بغداد - الكرادة",   # العنوان الحالي
    "Text11": "قرب جامع الرحمن",   # اقرب نقطة دالة
    "Text12": "محمد الجبوري",      # اسم المختار ومسؤول المجلس البلدي
    "Text13": "الرصافة",           # دائرة الاحوال
    "Text14": "بغداد - الاعظمية",  # العنوان السابق
    "Text15": "5",                 # عدد المشاركات
    "Text16": "مهندس",             # المهنة
    "Text17": "مهندس اقدم",        # العنوان الوظيفي
    "Text18": "وزارة الكهرباء",    # اسم الدائرة
    "Text19": "لا يوجد",           # الانتماء السياسي
    "Text20": "برمجة",             # الموهبة والخبرة
    "Text21": "العربية والانكليزية",  # اللغات
    "Text22": "20001234567890",    # رقم الهوية
    "Text23": "15",                # السجل
    "Text24": "230",               # الصحيفة
    "Text25": "12345678",          # رقم البطاقة التموينية
    "Text26": "علي محمد",          # اسم الوكيل
    "Text27": "مركز 45",           # رقم مركز التموين
    "Text28": "سكن-12345",         # رقم بطاقة السكن
    "Text29": "امانة بغداد",       # جهة اصدارها
    "Text30": "NO-2024-001",       # NO
}

def test_fill_pdf():
    print("Opening PDF template...")
    doc = fitz.open(PDF_TEMPLATE_PATH)
    page = doc[0]
    
    print("\n=== PDF Form Fields Found ===")
    widgets_found = []
    for widget in page.widgets():
        widgets_found.append(widget.field_name)
        print(f"  {widget.field_name}: {widget.rect}")
    
    print(f"\nTotal widgets in PDF: {len(widgets_found)}")
    
    print("\n=== Test Data to Fill ===")
    for key, value in test_data.items():
        status = "✓" if key in widgets_found else "✗ MISSING IN PDF"
        print(f"  {key}: {value} {status}")
    
    # Check for any PDF fields not in our data
    print("\n=== PDF Fields NOT in Test Data ===")
    for field in widgets_found:
        if field not in test_data:
            print(f"  {field} - NOT BEING FILLED!")
    
    doc.close()
    
    # Now actually fill the PDF
    print("\n=== Filling PDF ===")
    from app.pdf_service import fill_pdf
    
    os.makedirs("generated_pdfs", exist_ok=True)
    fill_pdf(PDF_TEMPLATE_PATH, OUTPUT_PATH, test_data, None)
    print(f"PDF saved to: {OUTPUT_PATH}")
    print("\nPlease open the PDF and check if all fields are filled correctly!")

if __name__ == "__main__":
    test_fill_pdf()
