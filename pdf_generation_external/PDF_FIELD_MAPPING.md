# PDF Generation Field Mapping

**Purpose:** Documentation for external PDF generation software integration

**Template:** form1.pdf (included in this folder)

---

## Form1.pdf Field Mapping

The PDF template contains **30 text fields** and **1 image field** with the following mapping:

| PDF Field Name    | VolunteerForm Property        | Arabic Label                               | Description                         |
| ----------------- | ----------------------------- | ------------------------------------------ | ----------------------------------- |
| `Text1`           | `fullName`                    | الاسم الرباعي واللقب                       | Full name and surname               |
| `Text2`           | `education`                   | التحصيل الدراسي                            | Educational level                   |
| `Text3`           | `birthDate`                   | المواليد                                   | Birth date/year                     |
| `Text4`           | `maritalStatus`               | الحالة الاجتماعية                          | Marital status                      |
| `Text5`           | `numberOfChildren`            | عدد الابناء                                | Number of children                  |
| `Text6`           | `motherName`                  | اسم الام الثلاثي واللقب                    | Mother's full name                  |
| `Text7`           | `mobileNumber`                | رقم الموبايل                               | Mobile number                       |
| `Text8`           | `currentAddress`              | العنوان الحالي                             | Current address                     |
| `Text9`           | `nearestLandmark`             | اقرب نقطة دالة                             | Nearest landmark                    |
| `Text10`          | `mukhtarName`                 | اسم المختار ومسؤول المجلس البلدي           | Mukhtar/council representative name |
| `Text11`          | `civilStatusDirectorate`      | دائرة الاحوال                              | Civil status directorate            |
| `Text12`          | `previousAddress`             | العنوان السابق                             | Previous address                    |
| `Text13`          | `volunteerParticipationCount` | عدد المشاركات في الخدمة التطوعية في العتبة | Number of volunteer participations  |
| `Text14`          | `profession`                  | المهنة                                     | Profession                          |
| `Text15`          | `jobTitle`                    | العنوان الوظيفي                            | Job title                           |
| `Text16`          | `departmentName`              | اسم الدائرة                                | Department name                     |
| `Text17`          | `politicalAffiliation`        | الانتماء السياسي                           | Political affiliation               |
| `Text18`          | `talentAndExperience`         | الموهبة والخبرة                            | Talent and experience               |
| `Text19`          | `languages`                   | اللغات التي يجيدها                         | Languages spoken                    |
| `Text20`          | `idCardNumber`                | رقم الهوية او البطاقة الوطنية              | National ID card number             |
| `Text21`          | `recordNumber`                | السجل                                      | Record number                       |
| `Text22`          | `pageNumber`                  | الصحيفة                                    | Page number                         |
| `Text23`          | `formNumber`                  | رقم الاستمارة                              | Form number                         |
| `Text24`          | `groupNameAndCode`            | اسم المجموعة والرمز                        | Group name and code                 |
| `Text25`          | `rationCardNumber`            | رقم البطاقة التموينية                      | Ration card number                  |
| `Text26`          | `agentName`                   | اسم الوكيل                                 | Agent name                          |
| `Text27`          | `supplyCenterNumber`          | رقم مركز التموين                           | Supply center number                |
| `Text28`          | `residenceCardNumber`         | رقم بطاقة السكن                            | Residence card number               |
| `Text29`          | `issuer`                      | جهة اصدارها                                | Issuer                              |
| `Text30`          | `no`                          | NO                                         | Number/Sequence                     |
| `Image1_af_image` | `photoPath`                   | صورة شخصية                                 | Personal photo                      |

---

## VolunteerForm Model Structure

### Core Properties (All Optional Strings)

```dart
class VolunteerForm {
  // Form Identification
  String? formNumber;              // Text23
  String? groupNameAndCode;        // Text24

  // Personal Information
  String? fullName;                // Text1
  String? education;               // Text2
  String? birthDate;               // Text3
  String? maritalStatus;           // Text4
  String? numberOfChildren;        // Text5
  String? motherName;              // Text6
  String? mobileNumber;            // Text7

  // Address Information
  String? currentAddress;          // Text8
  String? nearestLandmark;         // Text9
  String? mukhtarName;             // Text10
  String? civilStatusDirectorate;  // Text11
  String? previousAddress;         // Text12

  // Volunteer Information
  String? volunteerParticipationCount; // Text13
  String? profession;              // Text14
  String? jobTitle;                // Text15
  String? departmentName;          // Text16
  String? politicalAffiliation;    // Text17
  String? talentAndExperience;     // Text18
  String? languages;               // Text19

  // Official Documents
  String? idCardNumber;            // Text20
  String? recordNumber;            // Text21
  String? pageNumber;              // Text22
  String? rationCardNumber;        // Text25
  String? agentName;               // Text26
  String? supplyCenterNumber;      // Text27
  String? residenceCardNumber;     // Text28
  String? issuer;                  // Text29
  String? no;                      // Text30

  // Image Paths (Firebase Storage URLs)
  String? photoPath;               // Image1_af_image
  String? idFrontPath;             // Not in PDF template
  String? idBackPath;              // Not in PDF template
  String? residenceFrontPath;      // Not in PDF template
  String? residenceBackPath;       // Not in PDF template

  // Status & Metadata
  VolunteerFormStatus? status;     // Enum: Pending/Approved/Rejected
  bool archived;                   // Default: false
}
```

### Status Enum

```dart
enum VolunteerFormStatus {
  Pending,
  Approved,
  Rejected
}
```

---

## JSON Request Format

### Request Structure

```json
{
  "formData": {
    "formNumber": "string",
    "groupNameAndCode": "string",
    "fullName": "string",
    "education": "string",
    "birthDate": "string",
    "maritalStatus": "string",
    "numberOfChildren": "string",
    "motherName": "string",
    "mobileNumber": "string",
    "currentAddress": "string",
    "nearestLandmark": "string",
    "mukhtarName": "string",
    "civilStatusDirectorate": "string",
    "previousAddress": "string",
    "volunteerParticipationCount": "string",
    "profession": "string",
    "jobTitle": "string",
    "departmentName": "string",
    "politicalAffiliation": "string",
    "talentAndExperience": "string",
    "languages": "string",
    "idCardNumber": "string",
    "recordNumber": "string",
    "pageNumber": "string",
    "rationCardNumber": "string",
    "agentName": "string",
    "supplyCenterNumber": "string",
    "residenceCardNumber": "string",
    "issuer": "string",
    "no": "string",
    "photoUrl": "string"
  },
  "templatePath": "form1.pdf",
  "outputFilename": "volunteer_fullName_mobileNumber.pdf"
}
```

### Example Request

```json
{
  "formData": {
    "formNumber": "1",
    "groupNameAndCode": "9",
    "fullName": "مهدي عدنان مهدي عدنان",
    "education": "بكلوريوس",
    "birthDate": "١٩٩٩",
    "maritalStatus": "متزوج",
    "numberOfChildren": "4",
    "motherName": "ميثاق عبد المجيد احمد شبيب",
    "mobileNumber": "07722627947",
    "currentAddress": "حي تونس افاق عربية",
    "nearestLandmark": "اسواق السيد",
    "mukhtarName": "ابو مريم",
    "civilStatusDirectorate": "دائرة احوال المعلومات",
    "previousAddress": "ماعندي",
    "volunteerParticipationCount": "٢٠٠٠",
    "profession": "كاسب",
    "jobTitle": "حمال",
    "departmentName": "محل الشديدي",
    "politicalAffiliation": "بلا",
    "talentAndExperience": "الحسابات",
    "languages": "١٠",
    "idCardNumber": "10009999777",
    "recordNumber": "15",
    "pageNumber": "11",
    "rationCardNumber": "07722627946",
    "agentName": "ابو حقي",
    "supplyCenterNumber": "محمد جاسم",
    "residenceCardNumber": "بنوك",
    "issuer": "صليخ",
    "no": "١",
    "photoUrl": "https://firebasestorage.googleapis.com/..."
  },
  "templatePath": "form1.pdf",
  "outputFilename": "volunteer_مهدي_عدنان_07722627947.pdf"
}
```

---

## API Integration Notes

### Expected Endpoint

```
POST /api/generate-pdf
Content-Type: application/json
```

### Expected Response

```json
{
  "success": true,
  "pdfUrl": "https://your-service.com/generated/volunteer_name_phone.pdf",
  "message": "PDF generated successfully"
}
```

### Error Response

```json
{
  "success": false,
  "error": "Error message",
  "details": "Detailed error description"
}
```

---

## Implementation Guidelines

### 1. Text Fields

- All text fields are **optional** (can be null/empty)
- Arabic text should be **RTL** (right-to-left)
- Preserve Arabic numerals (٠-٩) if provided
- Handle mixed English/Arabic content

### 2. Image Field (Image1_af_image)

- Accepts image URL from Firebase Storage
- Should download and embed image in PDF
- Recommended size: Fit to field boundaries
- Formats: JPEG, PNG

### 3. PDF Output

- **Flatten fields** after filling (make non-editable)
- Preserve template formatting and layout
- Generate filename: `volunteer_{fullName}_{mobileNumber}.pdf`
- Return downloadable URL

### 4. Font Handling

- **CRITICAL:** Use Arabic-compatible fonts
- Recommended fonts:
  - **Cairo** - Modern, clean
  - **Amiri** - Traditional, serif
  - **Noto Sans Arabic** - Universal fallback
- Ensure proper Arabic text shaping (connected letters)

### 5. Character Handling

- **Known Issue:** Character 1544 (؈ Arabic Ray) may not be supported by all fonts
- Recommendation: Strip unsupported characters or use font with full Arabic Unicode range (U+0600-U+06FF)

---

## Testing Checklist

- [ ] All 30 text fields populate correctly
- [ ] Arabic text renders properly (RTL, connected letters)
- [ ] Image embeds correctly from URL
- [ ] PDF is flattened (non-editable)
- [ ] Filename follows naming convention
- [ ] Empty/null fields handled gracefully
- [ ] Mixed Arabic/English content works
- [ ] Arabic numerals (٠-٩) preserved
- [ ] PDF opens correctly in Adobe Reader
- [ ] File size is reasonable (<2MB)

---

## Files in This Folder

1. **form1.pdf** - Original PDF template with 31 fields
2. **PDF_FIELD_MAPPING.md** - This documentation file

---

## Contact & Support

For questions about field mapping or data format, refer to:

- VolunteerForm model: `lib/Models/VolunteerForm.dart`
- Current PDF helper (deprecated): `lib/Helpers/PdfGeneratorHelper.dart`
- Firebase data structure: README.md → API Documentation

---

**Last Updated:** December 30, 2025
