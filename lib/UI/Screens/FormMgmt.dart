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
          : _buildForm(),
      floatingActionButton: _document != null
          ? FloatingActionButton.extended(onPressed: _fillAndFlattenForm, icon: const Icon(Icons.picture_as_pdf), label: const Text('إنشاء PDF'))
          : null,
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('الصور والمستندات'),
          _buildImageUploadSection(),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: _controllers[key],
        decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), prefixIcon: const Icon(Icons.edit)),
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

  Widget _buildImageUploadSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageUploadCard(
              'الصورة الشخصية',
              _userPhoto,
              () => _pickImage((image) {
                setState(() => _userPhoto = image);
              }),
              Icons.person,
            ),
            const Divider(height: 32),

            _buildImageUploadCard(
              'الهوية الوطنية - الوجه الأمامي',
              _nationalIdFront,
              () => _pickImage((image) {
                setState(() => _nationalIdFront = image);
              }),
              Icons.credit_card,
            ),
            const SizedBox(height: 16),

            _buildImageUploadCard(
              'الهوية الوطنية - الوجه الخلفي',
              _nationalIdBack,
              () => _pickImage((image) {
                setState(() => _nationalIdBack = image);
              }),
              Icons.credit_card,
            ),
            const Divider(height: 32),

            _buildImageUploadCard(
              'بطاقة السكن - الوجه الأمامي',
              _residencyCardFront,
              () => _pickImage((image) {
                setState(() => _residencyCardFront = image);
              }),
              Icons.home,
            ),
            const SizedBox(height: 16),

            _buildImageUploadCard(
              'بطاقة السكن - الوجه الخلفي',
              _residencyCardBack,
              () => _pickImage((image) {
                setState(() => _residencyCardBack = image);
              }),
              Icons.home,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadCard(String label, Uint8List? imageData, VoidCallback onTap, IconData icon) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: onTap,
                icon: Icon(imageData == null ? Icons.upload : Icons.check),
                label: Text(imageData == null ? 'رفع الصورة' : 'تم الرفع'),
                style: ElevatedButton.styleFrom(backgroundColor: imageData == null ? null : Colors.green.shade100),
              ),
            ],
          ),
        ),
        if (imageData != null) ...[
          const SizedBox(width: 16),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(imageData, fit: BoxFit.cover),
            ),
          ),
        ],
      ],
    );
  }
}
