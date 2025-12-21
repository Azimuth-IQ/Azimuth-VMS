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
    return VolunteerForm(
      id: snapshot.child('id').value as int?,
      formNumber: snapshot.child('formNumber').value.toString(),
      groupNameAndCode: snapshot.child('groupNameAndCode').value.toString(),
      fullName: snapshot.child('fullName').value.toString(),
      education: snapshot.child('education').value.toString(),
      birthDate: snapshot.child('birthDate').value.toString(),
      maritalStatus: snapshot.child('maritalStatus').value.toString(),
      numberOfChildren: snapshot.child('numberOfChildren').value.toString(),
      motherName: snapshot.child('motherName').value.toString(),
      mobileNumber: snapshot.child('mobileNumber').value.toString(),
      currentAddress: snapshot.child('currentAddress').value.toString(),
      nearestLandmark: snapshot.child('nearestLandmark').value.toString(),
      mukhtarName: snapshot.child('mukhtarName').value.toString(),
      civilStatusDirectorate: snapshot.child('civilStatusDirectorate').value.toString(),
      previousAddress: snapshot.child('previousAddress').value.toString(),
      volunteerParticipationCount: snapshot.child('volunteerParticipationCount').value.toString(),
      profession: snapshot.child('profession').value.toString(),
      jobTitle: snapshot.child('jobTitle').value.toString(),
      departmentName: snapshot.child('departmentName').value.toString(),
      politicalAffiliation: snapshot.child('politicalAffiliation').value.toString(),
      talentAndExperience: snapshot.child('talentAndExperience').value.toString(),
      languages: snapshot.child('languages').value.toString(),
      idCardNumber: snapshot.child('idCardNumber').value.toString(),
      recordNumber: snapshot.child('recordNumber').value.toString(),
      pageNumber: snapshot.child('pageNumber').value.toString(),
      rationCardNumber: snapshot.child('rationCardNumber').value.toString(),
      agentName: snapshot.child('agentName').value.toString(),
      supplyCenterNumber: snapshot.child('supplyCenterNumber').value.toString(),
      residenceCardNumber: snapshot.child('residenceCardNumber').value.toString(),
      issuer: snapshot.child('issuer').value.toString(),
      no: snapshot.child('no').value.toString(),
      photoPath: snapshot.child('photoPath').value.toString(),
      idFrontPath: snapshot.child('idFrontPath').value.toString(),
      idBackPath: snapshot.child('idBackPath').value.toString(),
      residenceFrontPath: snapshot.child('residenceFrontPath').value.toString(),
      residenceBackPath: snapshot.child('residenceBackPath').value.toString(),
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
    };
  }
}

enum VolunteerFormStatus { Sent, Pending, Approved1, Rejected1, Approved2, Rejected2, Completed }
