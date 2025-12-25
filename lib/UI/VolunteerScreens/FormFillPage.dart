import 'package:azimuth_vms/Helpers/VolunteerFormHelperFirebase.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:html' as html;

class FormFillPage extends StatefulWidget {
  const FormFillPage({super.key});

  @override
  State<FormFillPage> createState() => _FormFillPageState();
}

class _FormFillPageState extends State<FormFillPage> {
  PdfDocument? _document;
  Uint8List? _pdfBytes;
  bool _isLoading = false;
  String? _errorMessage;

  // Stepper state
  int _currentStep = 0;

  // Form data model
  VolunteerForm? _formData;
  bool _isEditMode = false;

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the form argument if passed
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is VolunteerForm && _formData == null) {
      _formData = args;
      _isEditMode = true;
      _populateFormData();
    }
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

  void _populateFormData() {
    if (_formData == null) return;

    // Populate all text controllers with form data
    _controllers['formNumber']?.text = _formData!.formNumber ?? '';
    _controllers['groupNameAndCode']?.text = _formData!.groupNameAndCode ?? '';
    _controllers['fullName']?.text = _formData!.fullName ?? '';
    _controllers['education']?.text = _formData!.education ?? '';
    _controllers['birthDate']?.text = _formData!.birthDate ?? '';
    _controllers['maritalStatus']?.text = _formData!.maritalStatus ?? '';
    _controllers['numberOfChildren']?.text = _formData!.numberOfChildren ?? '';
    _controllers['motherName']?.text = _formData!.motherName ?? '';
    _controllers['mobileNumber']?.text = _formData!.mobileNumber ?? '';
    _controllers['currentAddress']?.text = _formData!.currentAddress ?? '';
    _controllers['nearestLandmark']?.text = _formData!.nearestLandmark ?? '';
    _controllers['mukhtarName']?.text = _formData!.mukhtarName ?? '';
    _controllers['civilStatusDirectorate']?.text = _formData!.civilStatusDirectorate ?? '';
    _controllers['previousAddress']?.text = _formData!.previousAddress ?? '';
    _controllers['volunteerParticipationCount']?.text = _formData!.volunteerParticipationCount ?? '';
    _controllers['profession']?.text = _formData!.profession ?? '';
    _controllers['jobTitle']?.text = _formData!.jobTitle ?? '';
    _controllers['departmentName']?.text = _formData!.departmentName ?? '';
    _controllers['politicalAffiliation']?.text = _formData!.politicalAffiliation ?? '';
    _controllers['talentAndExperience']?.text = _formData!.talentAndExperience ?? '';
    _controllers['languages']?.text = _formData!.languages ?? '';
    _controllers['idCardNumber']?.text = _formData!.idCardNumber ?? '';
    _controllers['recordNumber']?.text = _formData!.recordNumber ?? '';
    _controllers['pageNumber']?.text = _formData!.pageNumber ?? '';
    _controllers['rationCardNumber']?.text = _formData!.rationCardNumber ?? '';
    _controllers['agentName']?.text = _formData!.agentName ?? '';
    _controllers['supplyCenterNumber']?.text = _formData!.supplyCenterNumber ?? '';
    _controllers['residenceCardNumber']?.text = _formData!.residenceCardNumber ?? '';
    _controllers['issuer']?.text = _formData!.issuer ?? '';
    _controllers['no']?.text = _formData!.no ?? '';

    setState(() {});
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

      if (imageData.lengthInBytes > 500 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Image size should not exceed 500 KB.')));
        }
        return;
      }

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
      // Access the PDF form
      final PdfForm form = _document!.form;

      // Debug: Print all available fields in the PDF
      print('=== PDF Form Fields Debug ===');
      print('Total fields: ${form.fields.count}');
      for (int i = 0; i < form.fields.count; i++) {
        final field = form.fields[i];
        print('Field $i: Name="${field.name}", Type=${field.runtimeType}');
      }
      print('=========================');

      // Helper function to set field value by name
      void setFieldValue(String fieldName, String? value) {
        if (value != null && value.isNotEmpty) {
          try {
            PdfField? field;
            for (int i = 0; i < form.fields.count; i++) {
              if (form.fields[i].name == fieldName) {
                field = form.fields[i];
                break;
              }
            }
            if (field != null && field is PdfTextBoxField) {
              field.text = value;
              print('✓ Filled field: $fieldName = $value');
            } else if (field != null) {
              print('✗ Field found but not a text box: $fieldName (${field.runtimeType})');
            } else {
              print('✗ Field not found: $fieldName');
            }
          } catch (e) {
            print('✗ Error with field $fieldName: $e');
          }
        }
      }

      // Fill form fields - mapping controller keys to PDF field names (Text1-Text30)
      setFieldValue('Text1', _controllers['formNumber']?.text);
      setFieldValue('Text2', _controllers['groupNameAndCode']?.text);
      setFieldValue('Text3', _controllers['fullName']?.text);
      setFieldValue('Text4', _controllers['education']?.text);
      setFieldValue('Text5', _controllers['birthDate']?.text);
      setFieldValue('Text6', _controllers['maritalStatus']?.text);
      setFieldValue('Text7', _controllers['numberOfChildren']?.text);
      setFieldValue('Text8', _controllers['motherName']?.text);
      setFieldValue('Text9', _controllers['mobileNumber']?.text);
      setFieldValue('Text10', _controllers['currentAddress']?.text);
      setFieldValue('Text11', _controllers['nearestLandmark']?.text);
      setFieldValue('Text12', _controllers['mukhtarName']?.text);
      setFieldValue('Text13', _controllers['civilStatusDirectorate']?.text);
      setFieldValue('Text14', _controllers['previousAddress']?.text);
      setFieldValue('Text15', _controllers['volunteerParticipationCount']?.text);
      setFieldValue('Text16', _controllers['profession']?.text);
      setFieldValue('Text17', _controllers['jobTitle']?.text);
      setFieldValue('Text18', _controllers['departmentName']?.text);
      setFieldValue('Text19', _controllers['politicalAffiliation']?.text);
      setFieldValue('Text20', _controllers['talentAndExperience']?.text);
      setFieldValue('Text21', _controllers['languages']?.text);
      setFieldValue('Text22', _controllers['idCardNumber']?.text);
      setFieldValue('Text23', _controllers['recordNumber']?.text);
      setFieldValue('Text24', _controllers['pageNumber']?.text);
      setFieldValue('Text25', _controllers['rationCardNumber']?.text);
      setFieldValue('Text26', _controllers['agentName']?.text);
      setFieldValue('Text27', _controllers['supplyCenterNumber']?.text);
      setFieldValue('Text28', _controllers['residenceCardNumber']?.text);
      setFieldValue('Text29', _controllers['issuer']?.text);
      setFieldValue('Text30', _controllers['no']?.text);

      // Add user photo if provided (to Image1_af_image field)
      if (_userPhoto != null) {
        try {
          PdfField? imageField;
          for (int i = 0; i < form.fields.count; i++) {
            if (form.fields[i].name == 'Image1_af_image') {
              imageField = form.fields[i];
              break;
            }
          }
          if (imageField != null && imageField is PdfButtonField) {
            final PdfBitmap image = PdfBitmap(_userPhoto!);
            // Get the bounds of the button field
            final bounds = imageField.bounds;
            // Get the page where the field is located
            final page = imageField.page;
            if (page != null) {
              // Draw the image at the field's location
              page.graphics.drawImage(image, bounds);
              print('✓ Added user photo to Image1_af_image field at bounds: $bounds');
            }
          }
        } catch (e) {
          print('✗ Error adding image to field: $e');
        }
      }

      // Flatten the form to make it non-editable
      form.flattenAllFields();

      if (_nationalIdFront != null || _nationalIdBack != null || _residencyCardFront != null || _residencyCardBack != null) {
        final PdfPage docsPage = _document!.pages.add();
        final PdfGraphics docsGraphics = docsPage.graphics;
        final PdfFont boldFont = PdfStandardFont(PdfFontFamily.helvetica, 12, style: PdfFontStyle.bold);
        const double leftMargin = 50;
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

  Future<void> _saveFormToDatabase() async {
    if (!_formKey.currentState!.validate()) return;

    // Use existing form data or create new one
    _formData ??= VolunteerForm();

    // Populate _formData from controllers
    _formData!.formNumber = _controllers['formNumber']?.text;
    _formData!.groupNameAndCode = _controllers['groupNameAndCode']?.text;
    _formData!.fullName = _controllers['fullName']?.text;
    _formData!.education = _controllers['education']?.text;
    _formData!.birthDate = _controllers['birthDate']?.text;
    _formData!.maritalStatus = _controllers['maritalStatus']?.text;
    _formData!.numberOfChildren = _controllers['numberOfChildren']?.text;
    _formData!.motherName = _controllers['motherName']?.text;
    _formData!.mobileNumber = _controllers['mobileNumber']?.text;
    _formData!.currentAddress = _controllers['currentAddress']?.text;
    _formData!.nearestLandmark = _controllers['nearestLandmark']?.text;
    _formData!.mukhtarName = _controllers['mukhtarName']?.text;
    _formData!.civilStatusDirectorate = _controllers['civilStatusDirectorate']?.text;
    _formData!.previousAddress = _controllers['previousAddress']?.text;
    _formData!.volunteerParticipationCount = _controllers['volunteerParticipationCount']?.text;
    _formData!.profession = _controllers['profession']?.text;
    _formData!.jobTitle = _controllers['jobTitle']?.text;
    _formData!.departmentName = _controllers['departmentName']?.text;
    _formData!.politicalAffiliation = _controllers['politicalAffiliation']?.text;
    _formData!.talentAndExperience = _controllers['talentAndExperience']?.text;
    _formData!.languages = _controllers['languages']?.text;
    _formData!.idCardNumber = _controllers['idCardNumber']?.text;
    _formData!.recordNumber = _controllers['recordNumber']?.text;
    _formData!.pageNumber = _controllers['pageNumber']?.text;
    _formData!.rationCardNumber = _controllers['rationCardNumber']?.text;
    _formData!.agentName = _controllers['agentName']?.text;
    _formData!.supplyCenterNumber = _controllers['supplyCenterNumber']?.text;
    _formData!.residenceCardNumber = _controllers['residenceCardNumber']?.text;
    _formData!.issuer = _controllers['issuer']?.text;
    _formData!.no = _controllers['no']?.text;
    _formData!.photoPath ??= '';
    _formData!.idFrontPath ??= '';
    _formData!.idBackPath ??= '';
    _formData!.residenceFrontPath ??= '';
    _formData!.residenceBackPath ??= '';

    // Get phone number for storage path
    final phoneNumber = _formData!.mobileNumber ?? 'unknown';

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading images...'), duration: Duration(seconds: 2)));
    }

    // Upload images to Firebase Storage and get URLs
    if (_userPhoto != null) {
      final url = await _uploadImage(_userPhoto!, phoneNumber, 'photo.jpg');
      if (url != null) _formData!.photoPath = url;
    }
    if (_nationalIdFront != null) {
      final url = await _uploadImage(_nationalIdFront!, phoneNumber, 'id_front.jpg');
      if (url != null) _formData!.idFrontPath = url;
    }
    if (_nationalIdBack != null) {
      final url = await _uploadImage(_nationalIdBack!, phoneNumber, 'id_back.jpg');
      if (url != null) _formData!.idBackPath = url;
    }
    if (_residencyCardFront != null) {
      final url = await _uploadImage(_residencyCardFront!, phoneNumber, 'residence_front.jpg');
      if (url != null) _formData!.residenceFrontPath = url;
    }
    if (_residencyCardBack != null) {
      final url = await _uploadImage(_residencyCardBack!, phoneNumber, 'residence_back.jpg');
      if (url != null) _formData!.residenceBackPath = url;
    }

    // Save to database and update status
    final VolunteerFormHelperFirebase formHelper = VolunteerFormHelperFirebase();

    if (_isEditMode) {
      // Update existing form and set status to Pending
      _formData!.status = VolunteerFormStatus.Pending;
      formHelper.UpdateForm(_formData!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form submitted for review!')));
        // Navigate back to dashboard with success result
        Navigator.pop(context, true);
      }
    } else {
      // Create new form (status will be set to Sent by CreateForm)
      formHelper.CreateForm(_formData!);

      // Now update status to Pending
      _formData!.status = VolunteerFormStatus.Pending;
      formHelper.UpdateForm(_formData!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form submitted for review!')));
        // Navigate back to dashboard with success result
        Navigator.pop(context, true);
      }
    }
  }

  Future<String?> _uploadImage(Uint8List imageData, String phoneNumber, String imageName) async {
    try {
      // Create storage reference
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('ihs/volunteerForms/$phoneNumber/$imageName');

      // Upload the image
      final uploadTask = imageRef.putData(imageData, SettableMetadata(contentType: 'image/jpeg'));

      // Wait for upload to complete
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      print('✓ Image uploaded successfully: $imageName -> $downloadUrl');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image uploaded: $imageName')));

      return downloadUrl;
    } catch (e) {
      print('Error uploading image $imageName: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error uploading $imageName: $e')));
      }
      return null;
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
      // Don't revoke URL immediately to allow printing
      Future.delayed(const Duration(seconds: 5), () {
        html.Url.revokeObjectUrl(url);
      });
    } catch (e) {
      print('Error printing PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error printing: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Volunteer Form / تعديل استمارة المتطوع' : 'Volunteer Form / استمارة المتطوع'),
        actions: [
          if (_pdfBytes != null) ...[
            IconButton(icon: const Icon(Icons.download), tooltip: 'Download PDF / تحميل', onPressed: _downloadPdf),
            IconButton(icon: const Icon(Icons.print), tooltip: 'Print / طباعة', onPressed: _printPdf),
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
                  ElevatedButton(onPressed: _loadPdfForm, child: const Text('Retry')),
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
            _saveFormToDatabase();
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
            Expanded(child: _buildTextField('formNumber', 'Form Number / رقم الاستمارة')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('groupNameAndCode', 'Group Name & Code / اسم المجموعة والرمز')),
          ],
        ),
        _buildTextField('fullName', 'Full Name / الاسم الرباعي واللقب', required: true),
        Row(
          children: [
            Expanded(child: _buildTextField('education', 'Education / التحصيل الدراسي')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('birthDate', 'Birth Date / المواليد')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField('maritalStatus', 'Marital Status / الحالة الاجتماعية')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('numberOfChildren', 'Number of Children / عدد الابناء')),
          ],
        ),
        _buildTextField('motherName', 'Mother Name / اسم الام الثلاثي واللقب'),
      ],
    );
  }

  Widget _buildContactInfoStep() {
    return Column(
      children: [
        _buildTextField('mobileNumber', 'Mobile Number / رقم الموبايل', required: true),
        _buildTextField('currentAddress', 'Current Address / العنوان الحالي'),
        _buildTextField('nearestLandmark', 'Nearest Landmark / اقرب نقطة دالة'),
        _buildTextField('mukhtarName', 'Mukhtar Name / اسم المختار ومسؤول المجلس البلدي'),
        Row(
          children: [
            Expanded(child: _buildTextField('civilStatusDirectorate', 'Civil Status Directorate / دائرة الاحوال')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('previousAddress', 'Previous Address / العنوان السابق')),
          ],
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoStep() {
    return Column(
      children: [
        _buildTextField('volunteerParticipationCount', 'Volunteer Participation Count / عدد المشاركات في الخدمة التطوعية'),
        Row(
          children: [
            Expanded(child: _buildTextField('profession', 'Profession / المهنة')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('jobTitle', 'Job Title / العنوان الوظيفي')),
          ],
        ),
        _buildTextField('departmentName', 'Department Name / اسم الدائرة'),
        _buildTextField('politicalAffiliation', 'Political Affiliation / الانتماء السياسي'),
        _buildTextField('talentAndExperience', 'Talent & Experience / الموهبة والخبرة', maxLines: 2),
        _buildTextField('languages', 'Languages / اللغات التي يجيدها'),
      ],
    );
  }

  Widget _buildDocumentInfoStep() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField('idCardNumber', 'ID Card Number / رقم الهوية او البطاقة الوطنية')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('recordNumber', 'Record / السجل')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField('pageNumber', 'Page / الصحيفة')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('rationCardNumber', 'Ration Card Number / رقم البطاقة التموينية')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField('agentName', 'Agent Name / اسم الوكيل')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('supplyCenterNumber', 'Supply Center Number / رقم مركز التموين')),
          ],
        ),
        Row(
          children: [
            Expanded(child: _buildTextField('residenceCardNumber', 'Residence Card Number / رقم بطاقة السكن')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField('issuer', 'Issuer / جهة اصدارها')),
          ],
        ),
        _buildTextField('no', 'NO'),
      ],
    );
  }

  Widget _buildAttachmentsStep() {
    return Column(
      children: [
        _buildImageUploadCard('User Photo / الصورة الشخصية', _userPhoto, () => _pickImage((image) => setState(() => _userPhoto = image)), Icons.person),
        const SizedBox(height: 20),
        _buildImageUploadCard(
          'National ID - Front / الهوية الوطنية - الوجه الأمامي',
          _nationalIdFront,
          () => _pickImage((image) => setState(() => _nationalIdFront = image)),
          Icons.credit_card,
        ),
        const SizedBox(height: 20),
        _buildImageUploadCard(
          'National ID - Back / الهوية الوطنية - الوجه الخلفي',
          _nationalIdBack,
          () => _pickImage((image) => setState(() => _nationalIdBack = image)),
          Icons.credit_card,
        ),
        const SizedBox(height: 20),
        _buildImageUploadCard(
          'Residence Card - Front / بطاقة السكن - الوجه الأمامي',
          _residencyCardFront,
          () => _pickImage((image) => setState(() => _residencyCardFront = image)),
          Icons.home,
        ),
        const SizedBox(height: 20),
        _buildImageUploadCard(
          'Residence Card - Back / بطاقة السكن - الوجه الخلفي',
          _residencyCardBack,
          () => _pickImage((image) => setState(() => _residencyCardBack = image)),
          Icons.home,
        ),
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
                  return 'This field is required';
                }
                return null;
              }
            : null,
      ),
    );
  }

  Widget _buildImageUploadCard(String label, Uint8List? imageData, VoidCallback onTap, IconData icon) {
    // Check if we're in edit mode and have an image path for this field
    bool hasExistingImage = false;
    String? existingImageUrl;

    if (_isEditMode && _formData != null) {
      if (label.contains('User Photo') || label.contains('الصورة الشخصية')) {
        existingImageUrl = _formData!.photoPath;
      } else if (label.contains('ID - Front') || label.contains('الهوية الوطنية - الوجه الأمامي')) {
        existingImageUrl = _formData!.idFrontPath;
      } else if (label.contains('ID - Back') || label.contains('الهوية الوطنية - الوجه الخلفي')) {
        existingImageUrl = _formData!.idBackPath;
      } else if (label.contains('Residence Card - Front') || label.contains('بطاقة السكن - الوجه الأمامي')) {
        existingImageUrl = _formData!.residenceFrontPath;
      } else if (label.contains('Residence Card - Back') || label.contains('بطاقة السكن - الوجه الخلفي')) {
        existingImageUrl = _formData!.residenceBackPath;
      }

      hasExistingImage = existingImageUrl != null && existingImageUrl.isNotEmpty && existingImageUrl != 'null';
    }

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
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: onTap,
                      icon: Icon(imageData == null ? Icons.upload_file : Icons.check_circle, size: 18),
                      label: Text(imageData == null ? 'Upload' : 'Uploaded'),
                      style: ElevatedButton.styleFrom(backgroundColor: imageData == null ? null : Colors.green, foregroundColor: imageData == null ? null : Colors.white),
                    ),
                    if (hasExistingImage && imageData == null) ...[
                      const SizedBox(width: 8),
                      Chip(
                        avatar: const Icon(Icons.cloud_done, size: 16, color: Colors.blue),
                        label: const Text('Existing image', style: TextStyle(fontSize: 11)),
                        backgroundColor: Colors.blue.shade50,
                        padding: const EdgeInsets.all(4),
                      ),
                    ],
                  ],
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
          ] else if (hasExistingImage && existingImageUrl != null) ...[
            const SizedBox(width: 16),
            InkWell(
              onTap: () {
                // Open image in new tab
                html.window.open(existingImageUrl!, '_blank');
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue.shade200),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue.shade50,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    existingImageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, color: Colors.red.shade400, size: 24),
                          const SizedBox(height: 4),
                          Text('Error', style: TextStyle(fontSize: 8, color: Colors.red.shade700)),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
