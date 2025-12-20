import 'dart:typed_data';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'dart:html' as html;

class FormMgmt extends StatefulWidget {
  const FormMgmt({super.key});

  @override
  State<FormMgmt> createState() => _FormMgmtState();
}

class _FormMgmtState extends State<FormMgmt> {
  PdfDocument? _document;
  Uint8List? _pdfBytes;
  bool _isLoading = false;
  String? _errorMessage;

  // Stepper state
  int _currentStep = 0;

  // Form data model
  final VolunteerForm _formData = VolunteerForm();

  // Form controllers
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  // Image data
  Uint8List? _userPhoto;
  Uint8List? _nationalIdFront;
  Uint8List? _nationalIdBack;
  Uint8List? _residencyCardFront;
  Uint8List? _residencyCardBack;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadPdfForm();
  }

  void _initializeControllers() {
    // Initialize all text controllers based on VolunteerForm model
    _controllers['formNumber'] = TextEditingController();
    _controllers['groupNameAndCode'] = TextEditingController();
    _controllers['fullName'] = TextEditingController();
    _controllers['education'] = TextEditingController();
    _controllers['birthDate'] = TextEditingController();
    _controllers['maritalStatus'] = TextEditingController();
    _controllers['numberOfChildren'] = TextEditingController();
    _controllers['motherName'] = TextEditingController();
    _controllers['mobileNumber'] = TextEditingController();
    _controllers['currentAddress'] = TextEditingController();
    _controllers['nearestLandmark'] = TextEditingController();
    _controllers['mukhtarName'] = TextEditingController();
    _controllers['civilStatusDirectorate'] = TextEditingController();
    _controllers['previousAddress'] = TextEditingController();
    _controllers['volunteerParticipationCount'] = TextEditingController();
    _controllers['profession'] = TextEditingController();
    _controllers['jobTitle'] = TextEditingController();
    _controllers['departmentName'] = TextEditingController();
    _controllers['politicalAffiliation'] = TextEditingController();
    _controllers['talentAndExperience'] = TextEditingController();
    _controllers['languages'] = TextEditingController();
    _controllers['idCardNumber'] = TextEditingController();
    _controllers['recordNumber'] = TextEditingController();
    _controllers['pageNumber'] = TextEditingController();
    _controllers['rationCardNumber'] = TextEditingController();
    _controllers['agentName'] = TextEditingController();
    _controllers['supplyCenterNumber'] = TextEditingController();
    _controllers['residenceCardNumber'] = TextEditingController();
    _controllers['issuer'] = TextEditingController();
    _controllers['no'] = TextEditingController();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _document?.dispose();
    super.dispose();
  }

  Future<void> _loadPdfForm() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ByteData data = await rootBundle.load('assets/pdfs/form1.pdf');
      final Uint8List bytes = data.buffer.asUint8List();
      _document = PdfDocument(inputBytes: bytes);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading PDF form: $e');
      setState(() {
        _errorMessage = 'Error loading PDF form: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(Function(Uint8List?) onImagePicked) async {
    try {
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      await uploadInput.onChange.first;
      final files = uploadInput.files;
      if (files!.isEmpty) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(files[0]);
      await reader.onLoad.first;

      final Uint8List imageData = reader.result as Uint8List;
      onImagePicked(imageData);
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _fillAndFlattenForm() async {
    if (_document == null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final PdfPage page = _document!.pages[0];
      final PdfGraphics graphics = page.graphics;

      final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 10);
      final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 10, style: PdfFontStyle.bold);

      double yPos = 50;
      final double leftMargin = 50;
      final double lineHeight = 20;

      void drawField(String label, String? value, {bool bold = false}) {
        if (value != null && value.isNotEmpty) {
          graphics.drawString('$label: $value', bold ? boldFont : font, bounds: Rect.fromLTWH(leftMargin, yPos, 500, lineHeight));
          yPos += lineHeight;
        }
      }

      if (_userPhoto != null) {
        final PdfBitmap image = PdfBitmap(_userPhoto!);
        graphics.drawImage(image, Rect.fromLTWH(450, 50, 100, 120));
      }

      drawField('رقم الاستمارة', _controllers['formNumber']?.text);
      drawField('اسم المجموعة والرمز', _controllers['groupNameAndCode']?.text);
      drawField('الاسم الرباعي واللقب', _controllers['fullName']?.text, bold: true);
      drawField('التحصيل الدراسي', _controllers['education']?.text);
      drawField('المواليد', _controllers['birthDate']?.text);
      drawField('الحالة الاجتماعية', _controllers['maritalStatus']?.text);
      drawField('عدد الابناء', _controllers['numberOfChildren']?.text);
      drawField('اسم الام الثلاثي واللقب', _controllers['motherName']?.text);
      drawField('رقم الموبايل', _controllers['mobileNumber']?.text);
      drawField('العنوان الحالي', _controllers['currentAddress']?.text);
      drawField('اقرب نقطة دالة', _controllers['nearestLandmark']?.text);
      drawField('اسم المختار ومسؤول المجلس البلدي', _controllers['mukhtarName']?.text);
      drawField('دائرة الاحوال', _controllers['civilStatusDirectorate']?.text);
      drawField('العنوان السابق', _controllers['previousAddress']?.text);
      drawField('عدد المشاركات في الخدمة التطوعية', _controllers['volunteerParticipationCount']?.text);
      drawField('المهنة', _controllers['profession']?.text);
      drawField('العنوان الوظيفي', _controllers['jobTitle']?.text);
      drawField('اسم الدائرة', _controllers['departmentName']?.text);
      drawField('الانتماء السياسي', _controllers['politicalAffiliation']?.text);
      drawField('الموهبة والخبرة', _controllers['talentAndExperience']?.text);
      drawField('اللغات التي يجيدها', _controllers['languages']?.text);
      drawField('رقم الهوية او البطاقة الوطنية', _controllers['idCardNumber']?.text);
      drawField('السجل', _controllers['recordNumber']?.text);
      drawField('الصحيفة', _controllers['pageNumber']?.text);
      drawField('رقم البطاقة التموينية', _controllers['rationCardNumber']?.text);
      drawField('اسم الوكيل', _controllers['agentName']?.text);
      drawField('رقم مركز التموين', _controllers['supplyCenterNumber']?.text);
      drawField('رقم بطاقة السكن', _controllers['residenceCardNumber']?.text);
      drawField('جهة اصدارها', _controllers['issuer']?.text);

      if (_nationalIdFront != null || _nationalIdBack != null || _residencyCardFront != null || _residencyCardBack != null) {
        final PdfPage docsPage = _document!.pages.add();
        final PdfGraphics docsGraphics = docsPage.graphics;
        double docYPos = 50;

        docsGraphics.drawString('المستندات المرفقة', PdfStandardFont(PdfFontFamily.helvetica, 16, style: PdfFontStyle.bold), bounds: Rect.fromLTWH(leftMargin, 20, 500, 30));

        if (_nationalIdFront != null) {
          docsGraphics.drawString('الهوية الوطنية - الوجه الأمامي', boldFont, bounds: Rect.fromLTWH(leftMargin, docYPos, 300, 20));
          final PdfBitmap img = PdfBitmap(_nationalIdFront!);
          docsGraphics.drawImage(img, Rect.fromLTWH(leftMargin, docYPos + 25, 250, 150));
          docYPos += 185;
        }

        if (_nationalIdBack != null) {
          docsGraphics.drawString('الهوية الوطنية - الوجه الخلفي', boldFont, bounds: Rect.fromLTWH(leftMargin, docYPos, 300, 20));
          final PdfBitmap img = PdfBitmap(_nationalIdBack!);
          docsGraphics.drawImage(img, Rect.fromLTWH(leftMargin, docYPos + 25, 250, 150));
          docYPos += 185;
        }

        if (_residencyCardFront != null) {
          docsGraphics.drawString('بطاقة السكن - الوجه الأمامي', boldFont, bounds: Rect.fromLTWH(leftMargin, docYPos, 300, 20));
          final PdfBitmap img = PdfBitmap(_residencyCardFront!);
          docsGraphics.drawImage(img, Rect.fromLTWH(leftMargin, docYPos + 25, 250, 150));
          docYPos += 185;
        }

        if (_residencyCardBack != null && docYPos < 600) {
          docsGraphics.drawString('بطاقة السكن - الوجه الخلفي', boldFont, bounds: Rect.fromLTWH(leftMargin, docYPos, 300, 20));
          final PdfBitmap img = PdfBitmap(_residencyCardBack!);
          docsGraphics.drawImage(img, Rect.fromLTWH(leftMargin, docYPos + 25, 250, 150));
        }
      }

      final List<int> bytes = await _document!.save();
      _pdfBytes = Uint8List.fromList(bytes);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم ملء وإنشاء النموذج بنجاح!')));
      }
    } catch (e) {
      print('Error filling form: $e');
      setState(() {
        _errorMessage = 'Error processing form: $e';
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _downloadPdf() {
    if (_pdfBytes == null) return;

    try {
      final blob = html.Blob([_pdfBytes!], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'volunteer_form_${DateTime.now().millisecondsSinceEpoch}.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحميل ملف PDF بنجاح!')));
    } catch (e) {
      print('Error downloading PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error downloading: $e')));
    }
  }

  void _printPdf() {
    if (_pdfBytes == null) return;

    try {
      final blob = html.Blob([_pdfBytes!], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Error printing PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error printing: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استمارة المتطوع'),
        actions: [
          if (_pdfBytes != null) ...[
            IconButton(icon: const Icon(Icons.download), tooltip: 'تحميل PDF', onPressed: _downloadPdf),
            IconButton(icon: const Icon(Icons.print), tooltip: 'طباعة', onPressed: _printPdf),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadPdfForm, child: const Text('إعادة المحاولة')),
                ],
              ),
            )
          : _buildStepperForm(),
    );
  }

  Widget _buildStepperForm() {
    return Form(
      key: _formKey,
      child: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 4) {
            setState(() => _currentStep++);
          } else {
            _fillAndFlattenForm();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                ElevatedButton(onPressed: details.onStepContinue, child: Text(_currentStep == 4 ? 'إنشاء PDF' : 'التالي')),
                const SizedBox(width: 12),
                if (_currentStep > 0) TextButton(onPressed: details.onStepCancel, child: const Text('السابق')),
              ],
            ),
          );
        },
        steps: [
          Step(
            title: const Text('المعلومات الأساسية'),
            content: _buildBasicInfoStep(),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('معلومات الاتصال'),
            content: _buildContactInfoStep(),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('المعلومات المهنية'),
            content: _buildProfessionalInfoStep(),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('معلومات الوثائق'),
            content: _buildDocumentInfoStep(),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          ),
          Step(title: const Text('المرفقات'), content: _buildAttachmentsStep(), isActive: _currentStep >= 4, state: _currentStep > 4 ? StepState.complete : StepState.indexed),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField('formNumber', 'رقم الاستمارة')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('groupNameAndCode', 'اسم المجموعة والرمز')),
          ],
        ),
        _buildTextField('fullName', 'الاسم الرباعي واللقب', required: true),
        Row(
          children: [
            Expanded(child: _buildTextField('education', 'التحصيل الدراسي')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('birthDate', 'المواليد')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField('maritalStatus', 'الحالة الاجتماعية')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('numberOfChildren', 'عدد الابناء')),
          ],
        ),
        _buildTextField('motherName', 'اسم الام الثلاثي واللقب'),
      ],
    );
  }

  Widget _buildContactInfoStep() {
    return Column(
      children: [
        _buildTextField('mobileNumber', 'رقم الموبايل', required: true),
        _buildTextField('currentAddress', 'العنوان الحالي'),
        _buildTextField('nearestLandmark', 'اقرب نقطة دالة'),
        _buildTextField('mukhtarName', 'اسم المختار ومسؤول المجلس البلدي'),
        Row(
          children: [
            Expanded(child: _buildTextField('civilStatusDirectorate', 'دائرة الاحوال')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('previousAddress', 'العنوان السابق')),
          ],
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoStep() {
    return Column(
      children: [
        _buildTextField('volunteerParticipationCount', 'عدد المشاركات في الخدمة التطوعية'),
        Row(
          children: [
            Expanded(child: _buildTextField('profession', 'المهنة')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('jobTitle', 'العنوان الوظيفي')),
          ],
        ),
        _buildTextField('departmentName', 'اسم الدائرة'),
        _buildTextField('politicalAffiliation', 'الانتماء السياسي'),
        _buildTextField('talentAndExperience', 'الموهبة والخبرة', maxLines: 2),
        _buildTextField('languages', 'اللغات التي يجيدها'),
      ],
    );
  }

  Widget _buildDocumentInfoStep() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField('idCardNumber', 'رقم الهوية او البطاقة الوطنية')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('recordNumber', 'السجل')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField('pageNumber', 'الصحيفة')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('rationCardNumber', 'رقم البطاقة التموينية')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField('agentName', 'اسم الوكيل')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('supplyCenterNumber', 'رقم مركز التموين')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField('residenceCardNumber', 'رقم بطاقة السكن')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('issuer', 'جهة اصدارها')),
          ],
        ),
        _buildTextField('no', 'NO'),
      ],
    );
  }

  Widget _buildAttachmentsStep() {
    return Column(
      children: [
        _buildImageUploadCard('الصورة الشخصية', _userPhoto, () => _pickImage((image) => setState(() => _userPhoto = image)), Icons.person),
        const SizedBox(height: 20),
        _buildImageUploadCard('الهوية الوطنية - الوجه الأمامي', _nationalIdFront, () => _pickImage((image) => setState(() => _nationalIdFront = image)), Icons.credit_card),
        const SizedBox(height: 20),
        _buildImageUploadCard('الهوية الوطنية - الوجه الخلفي', _nationalIdBack, () => _pickImage((image) => setState(() => _nationalIdBack = image)), Icons.credit_card),
        const SizedBox(height: 20),
        _buildImageUploadCard('بطاقة السكن - الوجه الأمامي', _residencyCardFront, () => _pickImage((image) => setState(() => _residencyCardFront = image)), Icons.home),
        const SizedBox(height: 20),
        _buildImageUploadCard('بطاقة السكن - الوجه الخلفي', _residencyCardBack, () => _pickImage((image) => setState(() => _residencyCardBack = image)), Icons.home),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('الصور والمستندات'),
          _buildImageUploadCard('الصورة الشخصية', _userPhoto, () => _pickImage((image) => setState(() => _userPhoto = image)), Icons.person),
          const SizedBox(height: 20),
          _buildImageUploadCard('الهوية الوطنية - الوجه الأمامي', _nationalIdFront, () => _pickImage((image) => setState(() => _nationalIdFront = image)), Icons.credit_card),
          const SizedBox(height: 20),
          _buildImageUploadCard('الهوية الوطنية - الوجه الخلفي', _nationalIdBack, () => _pickImage((image) => setState(() => _nationalIdBack = image)), Icons.credit_card),
          const SizedBox(height: 20),
          _buildImageUploadCard('بطاقة السكن - الوجه الأمامي', _residencyCardFront, () => _pickImage((image) => setState(() => _residencyCardFront = image)), Icons.home),
          const SizedBox(height: 20),
          _buildImageUploadCard('بطاقة السكن - الوجه الخلفي', _residencyCardBack, () => _pickImage((image) => setState(() => _residencyCardBack = image)), Icons.home),
          const SizedBox(height: 24),

          _buildSectionTitle('المعلومات الأساسية'),
          _buildTextField('formNumber', 'رقم الاستمارة'),
          _buildTextField('groupNameAndCode', 'اسم المجموعة والرمز'),
          _buildTextField('fullName', 'الاسم الرباعي واللقب', required: true),
          _buildTextField('education', 'التحصيل الدراسي'),
          _buildTextField('birthDate', 'المواليد'),
          _buildTextField('maritalStatus', 'الحالة الاجتماعية'),
          _buildTextField('numberOfChildren', 'عدد الابناء'),
          _buildTextField('motherName', 'اسم الام الثلاثي واللقب'),
          const SizedBox(height: 24),

          _buildSectionTitle('معلومات الاتصال'),
          _buildTextField('mobileNumber', 'رقم الموبايل', required: true),
          _buildTextField('currentAddress', 'العنوان الحالي'),
          _buildTextField('nearestLandmark', 'اقرب نقطة دالة'),
          _buildTextField('mukhtarName', 'اسم المختار ومسؤول المجلس البلدي'),
          _buildTextField('civilStatusDirectorate', 'دائرة الاحوال'),
          _buildTextField('previousAddress', 'العنوان السابق'),
          const SizedBox(height: 24),

          _buildSectionTitle('المعلومات المهنية'),
          _buildTextField('volunteerParticipationCount', 'عدد المشاركات في الخدمة التطوعية'),
          _buildTextField('profession', 'المهنة'),
          _buildTextField('jobTitle', 'العنوان الوظيفي'),
          _buildTextField('departmentName', 'اسم الدائرة'),
          _buildTextField('politicalAffiliation', 'الانتماء السياسي'),
          _buildTextField('talentAndExperience', 'الموهبة والخبرة', maxLines: 3),
          _buildTextField('languages', 'اللغات التي يجيدها'),
          const SizedBox(height: 24),

          _buildSectionTitle('معلومات الوثائق'),
          _buildTextField('idCardNumber', 'رقم الهوية او البطاقة الوطنية'),
          _buildTextField('recordNumber', 'السجل'),
          _buildTextField('pageNumber', 'الصحيفة'),
          _buildTextField('rationCardNumber', 'رقم البطاقة التموينية'),
          _buildTextField('agentName', 'اسم الوكيل'),
          _buildTextField('supplyCenterNumber', 'رقم مركز التموين'),
          _buildTextField('residenceCardNumber', 'رقم بطاقة السكن'),
          _buildTextField('issuer', 'جهة اصدارها'),
          _buildTextField('no', 'NO'),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  Widget _buildTextField(String key, String label, {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
        maxLines: maxLines,
        validator: required
            ? (value) {
                if (value == null || value.isEmpty) {
                  return 'هذا الحقل مطلوب';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildImageUploadCard(String label, Uint8List? imageData, VoidCallback onTap, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: onTap,
                  icon: Icon(imageData == null ? Icons.upload_file : Icons.check_circle, size: 18),
                  label: Text(imageData == null ? 'رفع الصورة' : 'تم الرفع'),
                  style: ElevatedButton.styleFrom(backgroundColor: imageData == null ? null : Colors.green, foregroundColor: imageData == null ? null : Colors.white),
                ),
              ],
            ),
          ),
          if (imageData != null) ...[
            const SizedBox(width: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(imageData, fit: BoxFit.cover),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
