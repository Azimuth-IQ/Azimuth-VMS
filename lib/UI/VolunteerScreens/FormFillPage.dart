import 'package:azimuth_vms/Helpers/VolunteerFormHelperFirebase.dart';
import 'package:azimuth_vms/Models/VolunteerForm.dart';
import 'package:azimuth_vms/UI/Theme/Breakpoints.dart';
import 'package:azimuth_vms/UI/Widgets/ImageOptimizationDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:azimuth_vms/l10n/app_localizations.dart';
import 'dart:html' as html;

class FormFillPage extends StatefulWidget {
  const FormFillPage({super.key});

  @override
  State<FormFillPage> createState() => _FormFillPageState();
}

class _FormFillPageState extends State<FormFillPage> {
  bool _isLoading = false;

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
    super.dispose();
  }

  Future<void> _saveAndReturn() async {
    await _saveFormToDatabase();
    if (mounted && !_isLoading) {
      Navigator.of(context).pop();
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

      // If image is larger than 500KB, open optimization dialog
      if (imageData.lengthInBytes > 500 * 1024) {
        if (!mounted) return;

        final optimizedImageData = await showDialog<Uint8List>(
          context: context,
          barrierDismissible: false,
          builder: (context) => ImageOptimizationDialog(originalImageData: imageData, imageName: files[0].name),
        );

        if (optimizedImageData != null) {
          onImagePicked(optimizedImageData);
        }
      } else {
        // Image is already under 500KB, use it directly
        onImagePicked(imageData);
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
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
      await formHelper.CreateForm(_formData!);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Volunteer Form / تعديل استمارة المتطوع' : 'Volunteer Form / استمارة المتطوع')),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) : _buildStepperForm(),
    );
  }

  Widget _buildStepperForm() {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Stepper(
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 4) {
            setState(() => _currentStep++);
          } else {
            _saveAndReturn();
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
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
                  child: Text(_currentStep == 4 ? 'Save Form / حفظ الاستمارة' : 'Next / التالي'),
                ),
                const SizedBox(width: 12),
                if (_currentStep > 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
                    child: const Text('Back / السابق'),
                  ),
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
        _buildResponsiveRow([_buildTextField('formNumber', 'Form Number / رقم الاستمارة'), _buildTextField('groupNameAndCode', 'Group Name & Code / اسم المجموعة والرمز')]),
        _buildTextField('fullName', 'Full Name / الاسم الرباعي واللقب', required: true),
        _buildResponsiveRow([_buildTextField('education', 'Education / التحصيل الدراسي'), _buildTextField('birthDate', 'Birth Date / المواليد')]),
        _buildResponsiveRow([_buildTextField('maritalStatus', 'Marital Status / الحالة الاجتماعية'), _buildTextField('numberOfChildren', 'Number of Children / عدد الابناء')]),
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
        _buildResponsiveRow([
          _buildTextField('civilStatusDirectorate', 'Civil Status Directorate / دائرة الاحوال'),
          _buildTextField('previousAddress', 'Previous Address / العنوان السابق'),
        ]),
      ],
    );
  }

  Widget _buildProfessionalInfoStep() {
    return Column(
      children: [
        _buildTextField('volunteerParticipationCount', 'Volunteer Participation Count / عدد المشاركات في الخدمة التطوعية'),
        _buildResponsiveRow([_buildTextField('profession', 'Profession / المهنة'), _buildTextField('jobTitle', 'Job Title / العنوان الوظيفي')]),
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
        _buildResponsiveRow([_buildTextField('idCardNumber', 'ID Card Number / رقم الهوية او البطاقة الوطنية'), _buildTextField('recordNumber', 'Record / السجل')]),
        _buildResponsiveRow([_buildTextField('pageNumber', 'Page / الصحيفة'), _buildTextField('rationCardNumber', 'Ration Card Number / رقم البطاقة التموينية')]),
        _buildResponsiveRow([_buildTextField('agentName', 'Agent Name / اسم الوكيل'), _buildTextField('supplyCenterNumber', 'Supply Center Number / رقم مركز التموين')]),
        _buildResponsiveRow([_buildTextField('residenceCardNumber', 'Residence Card Number / رقم بطاقة السكن'), _buildTextField('issuer', 'Issuer / جهة اصدارها')]),
        _buildTextField('no', 'NO'),
      ],
    );
  }

  Widget _buildAttachmentsStep() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildImageUploadCard(
          'User Photo / الصورة الشخصية',
          _userPhoto,
          () => _pickImage((image) => setState(() => _userPhoto = image)),
          Icons.person,
          hint: l10n.personalPhotoHint,
        ),
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

  // ignore: unused_element
  Widget _buildForm() {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('الصور والمستندات'),
          _buildImageUploadCard('الصورة الشخصية', _userPhoto, () => _pickImage((image) => setState(() => _userPhoto = image)), Icons.person, hint: l10n.personalPhotoHint),
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
        style: TextStyle(fontSize: Breakpoints.isMobile(context) ? 11 : 20, fontWeight: FontWeight.bold, color: Colors.blue),
      ),
    );
  }

  // Helper method to build responsive rows that stack on mobile
  Widget _buildResponsiveRow(List<Widget> children) {
    return Breakpoints.isMobile(context)
        ? Column(children: children)
        : Row(
            children: children
                .map((child) => Expanded(child: child))
                .expand((widget) => [widget, if (widget != children.last) const SizedBox(width: 16)])
                .where((widget) => widget is! bool)
                .toList(),
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

  Widget _buildImageUploadCard(String label, Uint8List? imageData, VoidCallback onTap, IconData icon, {String? hint}) {
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
                if (hint != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    hint,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                  ),
                ],
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
