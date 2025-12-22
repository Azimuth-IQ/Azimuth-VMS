import 'package:firebase_database/firebase_database.dart';

class VolunteerForm {
  //1- Variables
  int? id;
  String? formNumber; // رقم الاستمارة
  String? groupNameAndCode; // اسم المجموعة والرمز
  String? fullName; // الاسم الرباعي واللقب
  String? education; // التحصيل الدراسي
  String? birthDate; // المواليد
  String? maritalStatus; // الحالة الاجتماعية
  String? numberOfChildren; // عدد الابناء
  String? motherName; // اسم الام الثلاثي واللقب
  String? mobileNumber; // رقم الموبايل
  String? currentAddress; // العنوان الحالي
  String? nearestLandmark; // اقرب نقطة دالة
  String? mukhtarName; // اسم المختار ومسؤول المجلس البلدي
  String? civilStatusDirectorate; // دائرة الاحوال
  String? previousAddress; // العنوان السابق
  String? volunteerParticipationCount; // عدد المشاركات في الخدمة التطوعية في العتبة
  String? profession; // المهنة
  String? jobTitle; // العنوان الوظيفي
  String? departmentName; // اسم الدائرة
  String? politicalAffiliation; // الانتماء السياسي
  String? talentAndExperience; // الموهبة والخبرة
  String? languages; // اللغات التي يجيدها
  String? idCardNumber; // رقم الهوية او البطاقة الوطنية
  String? recordNumber; // السجل
  String? pageNumber; // الصحيفة
  String? rationCardNumber; // رقم البطاقة التموينية
  String? agentName; // اسم الوكيل
  String? supplyCenterNumber; // رقم مركز التموين
  String? residenceCardNumber; // رقم بطاقة السكن
  String? issuer; // جهة اصدارها
  String? no; // NO
  String? photoPath; // User profile image path
  String? idFrontPath; // National ID front image path
  String? idBackPath; // National ID back image path
  String? residenceFrontPath; // Residency card front image path
  String? residenceBackPath; // Residency card back image path
  VolunteerFormStatus? status;

  //2- Constructor
  VolunteerForm({
    this.id,
    this.formNumber,
    this.groupNameAndCode,
    this.fullName,
    this.education,
    this.birthDate,
    this.maritalStatus,
    this.numberOfChildren,
    this.motherName,
    this.mobileNumber,
    this.currentAddress,
    this.nearestLandmark,
    this.mukhtarName,
    this.civilStatusDirectorate,
    this.previousAddress,
    this.volunteerParticipationCount,
    this.profession,
    this.jobTitle,
    this.departmentName,
    this.politicalAffiliation,
    this.talentAndExperience,
    this.languages,
    this.idCardNumber,
    this.recordNumber,
    this.pageNumber,
    this.rationCardNumber,
    this.agentName,
    this.supplyCenterNumber,
    this.residenceCardNumber,
    this.issuer,
    this.no,
    this.photoPath,
    this.idFrontPath,
    this.idBackPath,
    this.residenceFrontPath,
    this.residenceBackPath,
    this.status,
  });

  //3- From DataSnapshot
  factory VolunteerForm.fromDataSnapshot(DataSnapshot snapshot) {
    // Helper function to safely get string value
    String? getStringValue(String key) {
      final value = snapshot.child(key).value;
      return value?.toString();
    }

    // Helper function to get status enum from string
    VolunteerFormStatus? getStatus() {
      final statusValue = snapshot.child('status').value?.toString();
      if (statusValue == null) return null;
      try {
        return VolunteerFormStatus.values.firstWhere((e) => e.toString().split('.').last == statusValue, orElse: () => VolunteerFormStatus.Pending);
      } catch (e) {
        return null;
      }
    }

    return VolunteerForm(
      id: snapshot.child('id').value as int?,
      formNumber: getStringValue('formNumber'),
      groupNameAndCode: getStringValue('groupNameAndCode'),
      fullName: getStringValue('fullName'),
      education: getStringValue('education'),
      birthDate: getStringValue('birthDate'),
      maritalStatus: getStringValue('maritalStatus'),
      numberOfChildren: getStringValue('numberOfChildren'),
      motherName: getStringValue('motherName'),
      mobileNumber: getStringValue('mobileNumber'),
      currentAddress: getStringValue('currentAddress'),
      nearestLandmark: getStringValue('nearestLandmark'),
      mukhtarName: getStringValue('mukhtarName'),
      civilStatusDirectorate: getStringValue('civilStatusDirectorate'),
      previousAddress: getStringValue('previousAddress'),
      volunteerParticipationCount: getStringValue('volunteerParticipationCount'),
      profession: getStringValue('profession'),
      jobTitle: getStringValue('jobTitle'),
      departmentName: getStringValue('departmentName'),
      politicalAffiliation: getStringValue('politicalAffiliation'),
      talentAndExperience: getStringValue('talentAndExperience'),
      languages: getStringValue('languages'),
      idCardNumber: getStringValue('idCardNumber'),
      recordNumber: getStringValue('recordNumber'),
      pageNumber: getStringValue('pageNumber'),
      rationCardNumber: getStringValue('rationCardNumber'),
      agentName: getStringValue('agentName'),
      supplyCenterNumber: getStringValue('supplyCenterNumber'),
      residenceCardNumber: getStringValue('residenceCardNumber'),
      issuer: getStringValue('issuer'),
      no: getStringValue('no'),
      photoPath: getStringValue('photoPath'),
      idFrontPath: getStringValue('idFrontPath'),
      idBackPath: getStringValue('idBackPath'),
      residenceFrontPath: getStringValue('residenceFrontPath'),
      residenceBackPath: getStringValue('residenceBackPath'),
      status: getStatus(),
    );
  }

  //4- To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'formNumber': formNumber,
      'groupNameAndCode': groupNameAndCode,
      'fullName': fullName,
      'education': education,
      'birthDate': birthDate,
      'maritalStatus': maritalStatus,
      'numberOfChildren': numberOfChildren,
      'motherName': motherName,
      'mobileNumber': mobileNumber,
      'currentAddress': currentAddress,
      'nearestLandmark': nearestLandmark,
      'mukhtarName': mukhtarName,
      'civilStatusDirectorate': civilStatusDirectorate,
      'previousAddress': previousAddress,
      'volunteerParticipationCount': volunteerParticipationCount,
      'profession': profession,
      'jobTitle': jobTitle,
      'departmentName': departmentName,
      'politicalAffiliation': politicalAffiliation,
      'talentAndExperience': talentAndExperience,
      'languages': languages,
      'idCardNumber': idCardNumber,
      'recordNumber': recordNumber,
      'pageNumber': pageNumber,
      'rationCardNumber': rationCardNumber,
      'agentName': agentName,
      'supplyCenterNumber': supplyCenterNumber,
      'residenceCardNumber': residenceCardNumber,
      'issuer': issuer,
      'no': no,
      'photoPath': photoPath,
      'idFrontPath': idFrontPath,
      'idBackPath': idBackPath,
      'residenceFrontPath': residenceFrontPath,
      'residenceBackPath': residenceBackPath,
      'status': status?.toString().split('.').last,
    };
  }
}

enum VolunteerFormStatus { Sent, Pending, Approved1, Rejected1, Approved2, Rejected2, Completed }
