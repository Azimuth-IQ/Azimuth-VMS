// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'نظام إدارة المتطوعين';

  @override
  String get welcome => 'مرحباً';

  @override
  String get search => 'بحث';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get edit => 'تعديل';

  @override
  String get add => 'إضافة';

  @override
  String get update => 'تحديث';

  @override
  String get submit => 'إرسال';

  @override
  String get close => 'إغلاق';

  @override
  String get confirm => 'تأكيد';

  @override
  String get back => 'رجوع';

  @override
  String get next => 'التالي';

  @override
  String get previous => 'السابق';

  @override
  String get loading => 'جاري التحميل...';

  @override
  String get error => 'خطأ';

  @override
  String get success => 'نجح';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get changePassword => 'تغيير كلمة المرور';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get ok => 'موافق';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get upload => 'رفع';

  @override
  String get uploaded => 'تم الرفع';

  @override
  String get download => 'تحميل';

  @override
  String get print => 'طباعة';

  @override
  String get select => 'اختيار';

  @override
  String get selected => 'محدد';

  @override
  String get assign => 'تعيين';

  @override
  String get approve => 'موافقة';

  @override
  String get reject => 'رفض';

  @override
  String get pending => 'قيد الانتظار';

  @override
  String get approved => 'مقبول';

  @override
  String get rejected => 'مرفوض';

  @override
  String get completed => 'مكتمل';

  @override
  String get active => 'نشط';

  @override
  String get inactive => 'غير نشط';

  @override
  String get send => 'إرسال';

  @override
  String get view => 'عرض';

  @override
  String get refresh => 'تحديث';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get home => 'الرئيسية';

  @override
  String get events => 'الفعاليات';

  @override
  String get volunteers => 'المتطوعون';

  @override
  String get leaders => 'القادة';

  @override
  String get teamLeaders => 'قادة الفرق';

  @override
  String get teams => 'الفرق';

  @override
  String get locations => 'المواقع';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get sendNotif => 'إرسال إشعار';

  @override
  String get sendNotification => 'إرسال إشعار';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String welcomeBack(String userPhone) {
    return 'مرحباً بك، $userPhone';
  }

  @override
  String get analytics => 'التحليلات';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get workflowScenarios => 'سيناريوهات سير العمل';

  @override
  String get activeEvents => 'الفعاليات النشطة';

  @override
  String get volunteersPerTeam => 'المتطوعون لكل فريق (أفضل 5)';

  @override
  String get noActiveEvents => 'لا توجد فعاليات نشطة';

  @override
  String get activity => 'النشاط';

  @override
  String get actions => 'الإجراءات';

  @override
  String get activityOverview => 'نظرة عامة على النشاط';

  @override
  String get shiftsCompletedLast6Months => 'الورديات المكتملة في آخر 6 أشهر';

  @override
  String get activeEventsCount => 'الفعاليات النشطة';

  @override
  String get volunteersCount => 'المتطوعون';

  @override
  String get teamLeadersCount => 'قادة الفرق';

  @override
  String get notificationsCount => 'الإشعارات';

  @override
  String get shiftAssignment => 'تعيين الورديات';

  @override
  String get presenceCheck => 'تسجيل الحضور';

  @override
  String get formsMgmt => 'إدارة النماذج';

  @override
  String get carouselMgmt => 'إدارة العروض';

  @override
  String get ratings => 'التقييمات';

  @override
  String get leaveRequests => 'طلبات الإجازة';

  @override
  String get systemFeedback => 'ملاحظات النظام';

  @override
  String get eventFeedback => 'ملاحظات الفعالية';

  @override
  String get volunteerRegistration => 'تسجيل المتطوعين';

  @override
  String get volunteerRegistrationDescription =>
      'سير عمل كامل لتأهيل المتطوعين الجدد بما في ذلك تقديم النموذج والمراجعة والموافقة';

  @override
  String get eventManagement => 'إدارة الفعاليات';

  @override
  String get eventManagementDescription =>
      'إنشاء الفعاليات مع التكرار، تعيين الفرق، إدارة الورديات، وتتبع الحضور';

  @override
  String get volunteerWorkflow => 'سير عمل المتطوع';

  @override
  String statusUpdatedTo(String status) {
    return 'تم تحديث الحالة إلى $status';
  }

  @override
  String get sent => 'تم الإرسال';

  @override
  String get waitingForVolunteerToFillData => 'في انتظار المتطوع لملء البيانات';

  @override
  String get formLinkSent => 'تم إرسال رابط النموذج إلى المتطوع.';

  @override
  String get pendingReview => 'قيد المراجعة';

  @override
  String get adminChecksForm => 'المسؤول يراجع النموذج والمرفقات';

  @override
  String get pleaseReviewForm => 'يرجى مراجعة بيانات النموذج والمرفقات.';

  @override
  String get viewForm => 'عرض النموذج';

  @override
  String get generatingPdf => 'جاري إنشاء ملف PDF...';

  @override
  String get pdfDownloaded => 'تم تحميل ملف PDF';

  @override
  String get initialApproval => 'الموافقة الأولية';

  @override
  String get firstLevelApproval => 'الموافقة من المستوى الأول';

  @override
  String get formPassedInitialReview => 'اجتاز النموذج المراجعة الأولية.';

  @override
  String get approveL1 => 'موافقة (م1)';

  @override
  String get finalApproval => 'الموافقة النهائية';

  @override
  String get secondLevelApproval => 'الموافقة من المستوى الثاني';

  @override
  String get formPassedFinalReview => 'اجتاز النموذج المراجعة النهائية.';

  @override
  String get approveL2 => 'موافقة (م2)';

  @override
  String get processFinished => 'انتهت العملية';

  @override
  String get volunteerRegistrationComplete => 'اكتمل تسجيل المتطوع.';

  @override
  String get complete => 'إكمال';

  @override
  String get reEvaluate => 'إعادة التقييم';

  @override
  String get volunteerDashboard => 'لوحة تحكم المتطوع';

  @override
  String get redirectingToForm => 'جاري التوجيه إلى النموذج...';

  @override
  String get myAssignments => 'تعييناتي';

  @override
  String get upcomingShift => 'الوردية القادمة';

  @override
  String get noUpcomingShifts => 'لا توجد ورديات قادمة معينة.';

  @override
  String get eventsManagement => 'إدارة الفعاليات';

  @override
  String get createEvent => 'إنشاء فعالية';

  @override
  String get editEvent => 'تعديل الفعالية';

  @override
  String get deleteEvent => 'حذف الفعالية';

  @override
  String get eventName => 'اسم الفعالية';

  @override
  String get eventDescription => 'وصف الفعالية';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get eventCreated => 'تم إنشاء الفعالية بنجاح';

  @override
  String get eventUpdated => 'تم تحديث الفعالية بنجاح';

  @override
  String get eventDeleted => 'تم حذف الفعالية بنجاح';

  @override
  String get noEvents => 'لا توجد فعاليات';

  @override
  String get selectEvent => 'اختر فعالية';

  @override
  String get shifts => 'الورديات';

  @override
  String get shiftTime => 'وقت الوردية';

  @override
  String get startTime => 'وقت البدء';

  @override
  String get endTime => 'وقت الانتهاء';

  @override
  String get shift => 'الوردية';

  @override
  String get noShifts => 'لا توجد ورديات متاحة';

  @override
  String get selectShift => 'اختر وردية';

  @override
  String get teamLeadersManagement => 'إدارة قادة الفرق';

  @override
  String get addTeamLeader => 'إضافة قائد فريق';

  @override
  String get editTeamLeader => 'تعديل قائد الفريق';

  @override
  String get deleteTeamLeader => 'حذف قائد الفريق';

  @override
  String get noTeamLeaders => 'لا يوجد قادة فرق';

  @override
  String get tapPlusToAddTeamLeader => 'اضغط + لإضافة قائد فريق جديد';

  @override
  String teamLeaderArchived(String name) {
    return 'تم أرشفة $name';
  }

  @override
  String teamLeaderRestored(String name) {
    return 'تم استعادة $name';
  }

  @override
  String teamLeaderDeleted(String name) {
    return 'تم حذف $name';
  }

  @override
  String get teamsManagement => 'إدارة الفرق';

  @override
  String get addTeam => 'إضافة فريق';

  @override
  String get editTeam => 'تعديل الفريق';

  @override
  String get deleteTeam => 'حذف الفريق';

  @override
  String get teamName => 'اسم الفريق';

  @override
  String get noTeams => 'لا توجد فرق';

  @override
  String get locationsManagement => 'إدارة المواقع';

  @override
  String get addLocation => 'إضافة موقع';

  @override
  String get editLocation => 'تعديل الموقع';

  @override
  String get deleteLocation => 'حذف الموقع';

  @override
  String get locationName => 'اسم الموقع';

  @override
  String get mainLocation => 'الموقع الرئيسي';

  @override
  String get subLocation => 'الموقع الفرعي';

  @override
  String get noLocations => 'لا توجد مواقع';

  @override
  String get selectLocation => 'اختر موقعاً';

  @override
  String get location => 'الموقع';

  @override
  String get assignMyTeam => 'تعيين فريقي';

  @override
  String get unableToIdentifyCurrentUser =>
      'غير قادر على تحديد المستخدم الحالي';

  @override
  String get noEventsAssignedToYourTeams => 'لا توجد فعاليات معينة لفرقك';

  @override
  String get contactAdminToAssignYourTeam =>
      'اتصل بالمسؤول لتعيين فريقك للفعاليات';

  @override
  String get selectEventAndShift => 'اختر وردية لتعيين المتطوعين';

  @override
  String get myEvents => 'فعالياتي';

  @override
  String get eventsWhereYourTeamIsAssigned =>
      'الفعاليات التي تم تعيين فريقك لها';

  @override
  String get selectLocationToAssign => 'اختر موقعاً للتعيين';

  @override
  String get chooseLocationToAssignTeam =>
      'اختر الموقع الذي تريد تعيين أعضاء فريقك له:';

  @override
  String get assignVolunteers => 'تعيين المتطوعين';

  @override
  String get currentAssignments => 'التعيينات الحالية';

  @override
  String by(String assignedBy) {
    return 'بواسطة: $assignedBy';
  }

  @override
  String get selectVolunteers => 'اختر المتطوعين';

  @override
  String get pleaseSelectEventShiftLocation =>
      'يرجى اختيار فعالية ووردية وموقع أولاً';

  @override
  String get noTeamAssignedToLocation => 'لا يوجد فريق معين لهذا الموقع';

  @override
  String get noApprovedVolunteersInTeam =>
      'لا يوجد متطوعون موافق عليهم في فريقك';

  @override
  String assignedVolunteersSuccessfully(int count) {
    return 'تم تعيين $count متطوع بنجاح';
  }

  @override
  String get leaveRequestsManagement => 'طلبات الإجازة';

  @override
  String get leaveRequestApproved => 'تمت الموافقة على طلب الإجازة';

  @override
  String get leaveRequestRejected => 'تم رفض طلب الإجازة';

  @override
  String get selectAnEventToViewRequests => 'اختر فعالية لعرض طلبات الإجازة';

  @override
  String get pendingLeaveRequests => 'طلبات الإجازة المعلقة';

  @override
  String get noPendingLeaveRequests => 'لا توجد طلبات إجازة معلقة';

  @override
  String get reason => 'السبب:';

  @override
  String requested(String date) {
    return 'تم الطلب: $date';
  }

  @override
  String get volunteerForm => 'استمارة المتطوع';

  @override
  String get editVolunteerForm => 'تعديل استمارة المتطوع';

  @override
  String get basicInformation => 'المعلومات الأساسية';

  @override
  String get contactInformation => 'معلومات الاتصال';

  @override
  String get professionalInformation => 'المعلومات المهنية';

  @override
  String get documentInformation => 'معلومات الوثائق';

  @override
  String get attachments => 'المرفقات';

  @override
  String get createPdf => 'إنشاء PDF';

  @override
  String get formCreatedSuccessfully =>
      'تم إنشاء النموذج بنجاح! يمكن للمتطوع الآن تسجيل الدخول.';

  @override
  String get formUpdatedSuccessfully => 'تم تحديث النموذج بنجاح!';

  @override
  String get imageSizeExceeds500KB => 'يجب ألا يتجاوز حجم الصورة 500 كيلوبايت.';

  @override
  String errorPickingImage(String error) {
    return 'خطأ في اختيار الصورة: $error';
  }

  @override
  String get uploadingImages => 'جاري رفع الصور...';

  @override
  String imageUploaded(String name) {
    return 'تم رفع الصورة: $name';
  }

  @override
  String errorUploadingImage(String name, String error) {
    return 'خطأ في رفع $name: $error';
  }

  @override
  String get pdfDownloadedSuccessfully => 'تم تحميل ملف PDF بنجاح!';

  @override
  String errorDownloading(String error) {
    return 'خطأ في التحميل: $error';
  }

  @override
  String errorPrinting(String error) {
    return 'خطأ في الطباعة: $error';
  }

  @override
  String get existingImage => 'صورة موجودة';

  @override
  String get rateVolunteers => 'تقييم المتطوعين';

  @override
  String get noVolunteersFound => 'لم يتم العثور على متطوعين';

  @override
  String get rate => 'تقييم';

  @override
  String get notRated => 'لم يتم التقييم';

  @override
  String lastRated(String date) {
    return 'آخر تقييم: $date';
  }

  @override
  String get pleaseConfigureCriteriaFirst => 'يرجى تكوين معايير التقييم أولاً';

  @override
  String get ratingCriteria => 'معايير التقييم';

  @override
  String get notesOptional => 'ملاحظات (اختياري)';

  @override
  String get addNote => 'أضف ملاحظة...';

  @override
  String get saveRating => 'حفظ التقييم';

  @override
  String ratingSaved(String name) {
    return 'تم حفظ التقييم لـ $name';
  }

  @override
  String errorSavingRating(String error) {
    return 'خطأ في حفظ التقييم: $error';
  }

  @override
  String averageRating(String rating) {
    return 'المتوسط: $rating/5';
  }

  @override
  String get manageRatingCriteria => 'إدارة معايير التقييم';

  @override
  String get noCriteriaDefined => 'لم يتم تحديد معايير';

  @override
  String get clickPlusToAddCriteria => 'انقر فوق الزر + لإضافة معايير';

  @override
  String get addNewCriterion => 'إضافة معيار جديد';

  @override
  String get criterionName => 'اسم المعيار';

  @override
  String get criterionPlaceholder => 'مثل: مهارات الاتصال';

  @override
  String get criterionAdded => 'تمت إضافة المعيار. لا تنسَ الحفظ!';

  @override
  String get editCriterion => 'تعديل المعيار';

  @override
  String get criterionUpdated => 'تم تحديث المعيار. لا تنسَ الحفظ!';

  @override
  String get deleteCriterion => 'حذف المعيار';

  @override
  String confirmDeleteCriterion(String name) {
    return 'هل أنت متأكد من حذف \"$name\"؟';
  }

  @override
  String get criterionDeleted => 'تم حذف المعيار. لا تنسَ الحفظ!';

  @override
  String get cannotSaveEmptyCriteria => 'لا يمكن حفظ قائمة معايير فارغة';

  @override
  String get ratingCriteriaSaved => 'تم حفظ معايير التقييم بنجاح';

  @override
  String errorSavingCriteria(String error) {
    return 'خطأ في حفظ المعايير: $error';
  }

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get confirmPassword => 'تأكيد كلمة المرور';

  @override
  String get passwordChangedSuccessfully => 'تم تغيير كلمة المرور بنجاح!';

  @override
  String get passwordMismatch => 'كلمات المرور غير متطابقة';

  @override
  String get passwordTooShort => 'يجب أن تكون كلمة المرور 6 أحرف على الأقل';

  @override
  String get wrongCurrentPassword => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get passwordSecurityTips => 'نصائح أمان كلمة المرور:';

  @override
  String get volunteerManagementSystem => 'نظام إدارة المتطوعين';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get password => 'كلمة المرور';

  @override
  String get enterPhoneNumber => 'أدخل رقم هاتفك';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get seedDevelopmentData => 'بيانات التطوير الأولية';

  @override
  String get manageSystemFeedback => 'إدارة ملاحظات النظام';

  @override
  String get allFeedback => 'جميع الملاحظات';

  @override
  String get inProgress => 'قيد التنفيذ';

  @override
  String get resolved => 'تم الحل';

  @override
  String get feedbackType => 'نوع الملاحظة';

  @override
  String get bugReport => 'تقرير خطأ';

  @override
  String get featureRequest => 'طلب ميزة';

  @override
  String get improvement => 'تحسين';

  @override
  String get unknownError => 'حدث خطأ غير معروف';

  @override
  String get networkError => 'خطأ في الشبكة. يرجى التحقق من اتصالك.';

  @override
  String get permissionDenied => 'تم رفض الإذن';

  @override
  String get notFound => 'لم يتم العثور عليه';

  @override
  String get somethingWentWrong => 'حدث خطأ ما';

  @override
  String get language => 'اللغة';

  @override
  String get english => 'English';

  @override
  String get arabic => 'العربية';

  @override
  String get switchLanguage => 'تبديل اللغة';

  @override
  String get languageChanged => 'تم تغيير اللغة بنجاح';

  @override
  String get name => 'الاسم';

  @override
  String get phone => 'الهاتف';

  @override
  String get email => 'البريد الإلكتروني';

  @override
  String get address => 'العنوان';

  @override
  String get date => 'التاريخ';

  @override
  String get time => 'الوقت';

  @override
  String get status => 'الحالة';

  @override
  String get description => 'الوصف';

  @override
  String get notes => 'ملاحظات';

  @override
  String get from => 'من';

  @override
  String get to => 'إلى';

  @override
  String get volunteer => 'متطوع';

  @override
  String get teamLeader => 'قائد الفريق';

  @override
  String get admin => 'مسؤول';

  @override
  String get all => 'الكل';

  @override
  String get none => 'لا شيء';

  @override
  String get unknown => 'غير معروف';

  @override
  String get unknownName => 'اسم غير معروف';

  @override
  String get noPhone => 'لا يوجد هاتف';
}
