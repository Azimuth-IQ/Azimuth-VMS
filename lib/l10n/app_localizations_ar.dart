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
  String get sending => 'جاري الإرسال...';

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
  String get management => 'الإدارة';

  @override
  String get manageShifts => 'إدارة الورديات';

  @override
  String get assignVolunteersToShifts => 'تعيين المتطوعين للورديات';

  @override
  String get presenceChecks => 'فحوصات الحضور';

  @override
  String get checkVolunteerAttendance => 'فحص حضور المتطوعين';

  @override
  String get reviewVolunteerLeaveRequests => 'مراجعة طلبات إجازة المتطوعين';

  @override
  String get reportBugsOrSuggestIdeas => 'الإبلاغ عن الأخطاء أو اقتراح أفكار';

  @override
  String get noEventsAssignedYet => 'لا توجد فعاليات معينة لفرقك بعد';

  @override
  String errorLoadingData(String error) {
    return 'خطأ في تحميل البيانات: $error';
  }

  @override
  String get teamLeaderDashboard => 'لوحة تحكم قائد الفريق';

  @override
  String get myEvents => 'فعالياتي';

  @override
  String shiftsAssigned(int count, String plural) {
    return '$count وردية$plural معينة';
  }

  @override
  String get noShiftsAssignedToYourTeams => 'لا توجد ورديات معينة لفرقك';

  @override
  String get mainShift => 'الوردية الرئيسية';

  @override
  String get subLocation => 'موقع فرعي';

  @override
  String membersAssigned(int assigned, int total) {
    return '$assigned/$total أعضاء معينين';
  }

  @override
  String get noTeamMembersAvailable => 'لا يوجد أعضاء فريق متاحون';

  @override
  String get memberAssigned => 'تم تعيين العضو';

  @override
  String get memberRemoved => 'تم إزالة العضو';

  @override
  String get memberAssignedToSublocation => 'تم تعيين العضو للموقع الفرعي';

  @override
  String get memberRemovedFromSublocation => 'تم إزالة العضو من الموقع الفرعي';

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
  String get eventManagement => 'إدارة الفعالية';

  @override
  String get eventManagementDescription =>
      'إنشاء الفعاليات، تعيين الورديات، وإدارة الحضور.';

  @override
  String get startWorkflow => 'بدء سير العمل';

  @override
  String get members => 'أعضاء';

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
  String get myAssignments => 'تكليفاتي';

  @override
  String get upcomingShift => 'المناوبة القادمة';

  @override
  String get noUpcomingShifts => 'لا توجد ورديات قادمة معينة.';

  @override
  String get applicationUnderReview => 'الطلب قيد المراجعة';

  @override
  String get applicationUnderReviewDesc =>
      'تم تقديم طلب التطوع الخاص بك وهو قيد المراجعة حاليًا. سيتم إعلامك بمجرد اتخاذ القرار.';

  @override
  String get firstLevelApprovalTitle => 'الموافقة من المستوى الأول';

  @override
  String get firstLevelApprovalDesc =>
      'تمت الموافقة على طلبك في المستوى الأول. في انتظار الموافقة النهائية.';

  @override
  String get fullyApproved => 'تمت الموافقة بالكامل';

  @override
  String get fullyApprovedDesc => 'تهانينا! تمت الموافقة على طلبك بالكامل.';

  @override
  String get activeVolunteer => 'متطوع نشط';

  @override
  String get activeVolunteerDesc => 'أنت متطوع نشط في النظام.';

  @override
  String get applicationRejected => 'تم رفض الطلب';

  @override
  String get applicationRejectedFirstStage =>
      'تم رفض طلبك في مرحلة المراجعة الأولى.';

  @override
  String get applicationRejectedFinalStage =>
      'تم رفض طلبك في مرحلة المراجعة النهائية.';

  @override
  String get errorLoadingInfo =>
      'حدث خطأ أثناء تحميل معلوماتك. يرجى المحاولة مرة أخرى.';

  @override
  String get noVolunteerFormFound =>
      'لم يتم العثور على نموذج متطوع. يرجى الاتصال بالدعم.';

  @override
  String get myScheduleLocations => 'جدولي والمواقع';

  @override
  String get viewUpcomingShifts => 'عرض المناوبات القادمة والأوقات والمواقع';

  @override
  String get myProfile => 'ملفي الشخصي';

  @override
  String get viewRatingAndInfo => 'عرض تقييمك ومعلوماتك الشخصية';

  @override
  String get submitFeedback => 'تقديم الملاحظات';

  @override
  String get reportBugsOrSuggest => 'الإبلاغ عن الأخطاء أو اقتراح تحسينات';

  @override
  String get welcomeBackName => 'مرحبًا بعودتك،';

  @override
  String get volunteer => 'متطوع';

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
  String get eventNameRequired => 'اسم الفعالية *';

  @override
  String get pleaseEnterEventName => 'يرجى إدخال اسم الفعالية';

  @override
  String get eventDescription => 'وصف الفعالية';

  @override
  String get description => 'الوصف';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get startDateRequired => 'تاريخ البدء *';

  @override
  String get endDate => 'تاريخ الانتهاء';

  @override
  String get endDateRequired => 'تاريخ الانتهاء *';

  @override
  String get required => 'مطلوب';

  @override
  String get dateFormatHint => 'يوم-شهر-سنة';

  @override
  String get eventCreated => 'تم إنشاء الفعالية بنجاح';

  @override
  String get eventUpdated => 'تم تحديث الفعالية بنجاح';

  @override
  String get eventDeleted => 'تم حذف الفعالية بنجاح';

  @override
  String get noEvents => 'لا توجد فعاليات';

  @override
  String get noArchivedEvents => 'لا توجد فعاليات مؤرشفة';

  @override
  String get noActiveEventsFound =>
      'لا توجد فعاليات نشطة.\nاضغط + لإضافة فعالية جديدة.';

  @override
  String get selectEvent => 'اختر الحدث';

  @override
  String get viewWorkflow => 'عرض سير العمل';

  @override
  String get archived => 'مؤرشف';

  @override
  String get restored => 'تم الاستعادة';

  @override
  String get deleted => 'تم الحذف';

  @override
  String get addNewEvent => 'إضافة فعالية جديدة';

  @override
  String get recurringEvent => 'فعالية متكررة';

  @override
  String get recurrenceType => 'نوع التكرار';

  @override
  String get recurrenceTypeRequired => 'نوع التكرار *';

  @override
  String get recurrenceEndDate => 'تاريخ انتهاء التكرار (اختياري)';

  @override
  String get recurrence => 'التكرار';

  @override
  String get presenceCheckPermissions => 'صلاحيات فحص الحضور';

  @override
  String get presenceCheckPermissionsRequired => 'صلاحيات فحص الحضور *';

  @override
  String get to => 'إلى';

  @override
  String get shifts => 'الورديات';

  @override
  String get shiftTime => 'وقت المناوبة';

  @override
  String get startTime => 'وقت البدء';

  @override
  String get endTime => 'وقت الانتهاء';

  @override
  String get shift => 'الوردية';

  @override
  String get noShifts => 'لا توجد ورديات متاحة';

  @override
  String get noShiftsAdded => 'لم تتم إضافة ورديات';

  @override
  String get selectShift => 'اختر وردية';

  @override
  String get addShift => 'إضافة وردية';

  @override
  String get location => 'الموقع';

  @override
  String get locationColon => 'الموقع:';

  @override
  String get subLocationRequired => 'الموقع الفرعي *';

  @override
  String get addSubLocation => 'إضافة موقع فرعي';

  @override
  String get editSubLocation => 'تعديل الموقع الفرعي';

  @override
  String get thisLocationHasNoSublocations => 'هذا الموقع ليس لديه مواقع فرعية';

  @override
  String get pleaseSelectSublocation => 'يرجى اختيار موقع فرعي';

  @override
  String get teamAssignment => 'تعيين الفريق';

  @override
  String get existing => 'موجود';

  @override
  String get temporary => 'مؤقت';

  @override
  String get teamOptional => 'الفريق (اختياري)';

  @override
  String get selectTeam => 'اختر الفريق';

  @override
  String get none => 'لا شيء';

  @override
  String get temporaryTeam => 'فريق مؤقت';

  @override
  String get create => 'إنشاء';

  @override
  String get createTeam => 'إنشاء فريق';

  @override
  String get createTemporaryTeam => 'إنشاء فريق مؤقت';

  @override
  String get leader => 'القائد';

  @override
  String leaderColon(String id) {
    return 'القائد: $id';
  }

  @override
  String get membersColon => 'الأعضاء:';

  @override
  String get teamMembers => 'أعضاء الفريق';

  @override
  String get teamMembersColon => 'أعضاء الفريق:';

  @override
  String get tapPlusToAddFirstTeamLeader => 'اضغط + لإضافة قائد فريق جديد';

  @override
  String get noMembers => 'لا يوجد أعضاء';

  @override
  String get noTemporaryTeamCreated => 'لم يتم إنشاء فريق مؤقت';

  @override
  String get selectTeamMember => 'اختر عضو الفريق';

  @override
  String get addMember => 'إضافة';

  @override
  String get selectDays => 'اختر الأيام:';

  @override
  String get dayOfMonth => 'يوم من الشهر';

  @override
  String get dayOfMonthRequired => 'يوم من الشهر *';

  @override
  String get selectDayHint => 'اختر اليوم (1-31)';

  @override
  String get day => 'اليوم';

  @override
  String get dayRequired => 'اليوم *';

  @override
  String dayNumber(int number) {
    return 'اليوم $number';
  }

  @override
  String get pleaseSelectDay => 'يرجى اختيار اليوم';

  @override
  String get month => 'الشهر';

  @override
  String get monthRequired => 'الشهر *';

  @override
  String get pleaseSelectMonth => 'يرجى اختيار الشهر';

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
  String get noLocations => 'لا توجد مواقع';

  @override
  String get selectLocation => 'اختر الموقع';

  @override
  String get assignMyTeam => 'تعيين فريقي';

  @override
  String get unableToIdentifyCurrentUser => 'تعذر تحديد المستخدم الحالي';

  @override
  String get noEventsAssignedToYourTeams => 'لا توجد أحداث معينة لفرقك';

  @override
  String get contactAdminToAssignYourTeam =>
      'اتصل بالمسؤول لتعيين فريقك للفعاليات';

  @override
  String get selectEventAndShift => 'اختر الحدث والوردية';

  @override
  String get eventsWhereYourTeamIsAssigned => 'الأحداث التي تم تعيين فريقك لها';

  @override
  String get selectLocationToAssign => 'اختر الموقع للتعيين';

  @override
  String get chooseLocationToAssignTeam =>
      'اختر الموقع الذي تريد تعيين أعضاء فريقك له:';

  @override
  String get assignVolunteers => 'تعيين المتطوعين';

  @override
  String get currentAssignments => 'التعيينات الحالية';

  @override
  String by(String assignedBy) {
    return 'بواسطة:';
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
  String get uploadingImages => 'جاري تحميل الصور...';

  @override
  String imageUploaded(String imageName) {
    return 'تم تحميل الصورة: $imageName';
  }

  @override
  String errorUploadingImage(String imageName, String error) {
    return 'خطأ في تحميل $imageName: $error';
  }

  @override
  String get pdfDownloadedSuccessfully => 'تم تنزيل ملف PDF بنجاح!';

  @override
  String errorDownloading(String error) {
    return 'خطأ في التنزيل: $error';
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
    return 'المتوسط التقييمي: $rating / 5';
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
  String get criterionPlaceholder => 'مثال: مهارات التواصل';

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
  String get allFeedback => 'جميع التعليقات';

  @override
  String get inProgress => 'قيد المعالجة';

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
  String get notes => 'ملاحظات';

  @override
  String get from => 'من';

  @override
  String get teamLeader => 'قائد الفريق';

  @override
  String get admin => 'مسؤول';

  @override
  String get all => 'الكل';

  @override
  String get unknown => 'غير معروف';

  @override
  String get unknownName => 'اسم غير معروف';

  @override
  String get noPhone => 'لا يوجد هاتف';

  @override
  String get volunteersManagement => 'إدارة المتطوعين';

  @override
  String get addVolunteer => 'إضافة متطوع';

  @override
  String get editVolunteer => 'تعديل متطوع';

  @override
  String get deleteVolunteer => 'حذف متطوع';

  @override
  String get archiveVolunteer => 'أرشفة متطوع';

  @override
  String get restoreVolunteer => 'استعادة متطوع';

  @override
  String get tapPlusToAddVolunteer => 'اضغط + لإضافة متطوع جديد';

  @override
  String get assignTeam => 'تعيين فريق';

  @override
  String selectTeamFor(String name) {
    return 'اختر فريقاً لـ $name:';
  }

  @override
  String get noTeam => 'بدون فريق';

  @override
  String assignedToTeam(String name, String teamName) {
    return 'تم تعيين $name إلى $teamName';
  }

  @override
  String archiveVolunteerConfirm(String name) {
    return 'أرشفة $name؟\n\nسيؤدي هذا إلى إخفاء المتطوع مع الاحتفاظ ببياناته.';
  }

  @override
  String get archive => 'أرشفة';

  @override
  String get restore => 'استعادة';

  @override
  String restoreVolunteerConfirm(String name) {
    return 'استعادة $name؟';
  }

  @override
  String deleteVolunteerConfirm(String name) {
    return 'حذف $name نهائياً؟\n\nلا يمكن التراجع عن هذا الإجراء!';
  }

  @override
  String get tapPlusToAddTeam => 'اضغط + لإضافة فريق جديد';

  @override
  String get noMembersAdded => 'لم تتم إضافة أعضاء';

  @override
  String get addTeamMember => 'إضافة عضو للفريق';

  @override
  String get noVolunteersAvailable => 'لا يوجد متطوعون متاحون';

  @override
  String get added => 'تمت الإضافة';

  @override
  String teamLeaderID(String id) {
    return 'معرف قائد الفريق: $id';
  }

  @override
  String get tapPlusToAddLocation => 'اضغط + لإضافة موقع جديد';

  @override
  String get noLocationsFound => 'لم يتم العثور على مواقع';

  @override
  String latLon(String lat, String lon) {
    return 'خط العرض: $lat، خط الطول: $lon';
  }

  @override
  String get subLocations => 'المواقع الفرعية:';

  @override
  String get subLocationsColon => 'المواقع الفرعية:';

  @override
  String get noSubLocationsAdded => 'لم تتم إضافة مواقع فرعية';

  @override
  String get pickLocationOnMap => 'اختر الموقع على الخريطة';

  @override
  String get pickLocation => 'اختيار الموقع';

  @override
  String get tapOnMapToSelectLocation =>
      'انقر على الخريطة أو اسحب العلامة لاختيار الموقع';

  @override
  String get confirmLocation => 'تأكيد الموقع';

  @override
  String get pickOnMap => 'اختر من الخريطة';

  @override
  String get pleaseSelectTeamLeader => 'الرجاء اختيار قائد فريق';

  @override
  String get team => 'الفريق';

  @override
  String teamColon(String name) {
    return 'الفريق: $name';
  }

  @override
  String get membersColonBold => 'الأعضاء:';

  @override
  String get leaderColon2 => 'القائد:';

  @override
  String teamLeaderIDColon(String id) {
    return 'معرّف قائد الفريق: $id';
  }

  @override
  String leaderColonWithId(String id) {
    return 'القائد: $id';
  }

  @override
  String latLonCoordinates(String lat, String lon) {
    return 'خط العرض: $lat، خط الطول: $lon';
  }

  @override
  String get subLocationsColon2 => 'المواقع الفرعية:';

  @override
  String get noSublocationsAdded => 'لم تتم إضافة مواقع فرعية';

  @override
  String get carouselManagement => 'إدارة الشرائح';

  @override
  String get noCarouselImagesYet => 'لا توجد صور شرائح حتى الآن';

  @override
  String get tapPlusToAddFirstImage => 'اضغط + لإضافة الصورة الأولى';

  @override
  String get deleteImage => 'حذف الصورة';

  @override
  String areYouSureDeleteImage(String title) {
    return 'هل أنت متأكد من حذف \"$title\"؟';
  }

  @override
  String get imageDeletedSuccessfully => 'تم حذف الصورة بنجاح';

  @override
  String get errorCouldNotReadFile => 'خطأ: تعذر قراءة الملف';

  @override
  String get imageUploadedSuccessfully => 'تم تحميل الصورة بنجاح!';

  @override
  String uploadFailed(String error) {
    return 'فشل التحميل: $error';
  }

  @override
  String get titleAndImageRequired => 'العنوان وعنوان URL للصورة مطلوبان';

  @override
  String get invalidImageURL => 'عنوان URL للصورة غير صالح';

  @override
  String get visibleToUsers => 'مرئي للمستخدمين';

  @override
  String get ratingCriteriaManagement => 'إدارة معايير التقييم';

  @override
  String get eventWorkflow => 'سير عمل الفعالية';

  @override
  String get planning => 'التخطيط';

  @override
  String get eventCreatedAndScheduled => 'تم إنشاء وجدولة الفعالية';

  @override
  String get eventInPlanningPhase =>
      'الفعالية في مرحلة التخطيط. يمكنك تعيين النوبات والمتطوعين.';

  @override
  String get eventIsCurrentlyRunning => 'الفعالية قيد التنفيذ حالياً';

  @override
  String get eventIsActive =>
      'الفعالية نشطة. يمكن للمتطوعين تسجيل الحضور والانصراف.';

  @override
  String get eventDateHasPassed => 'انتهى تاريخ الفعالية';

  @override
  String get eventHasEnded => 'انتهت الفعالية. يمكنك مراجعة الحضور والملاحظات.';

  @override
  String get eventIsArchived => 'الفعالية مؤرشفة';

  @override
  String get eventIsArchivedHidden =>
      'الفعالية مؤرشفة ومخفية عن القوائم الرئيسية.';

  @override
  String get closed => 'مغلق';

  @override
  String submittedDate(String date) {
    return 'تاريخ التقديم: $date';
  }

  @override
  String reviewedBy(String name) {
    return 'تمت المراجعة بواسطة: $name';
  }

  @override
  String get updateStatus => 'تحديث الحالة';

  @override
  String get updateFeedbackStatus => 'تحديث حالة التعليقات';

  @override
  String get statusColon => 'الحالة:';

  @override
  String get resolutionNotesOptional => 'ملاحظات الحل (اختياري):';

  @override
  String get feedbackUpdatedSuccessfully => 'تم تحديث التعليقات بنجاح';

  @override
  String get deleteFeedback => 'حذف التعليقات';

  @override
  String get deleteFeedbackConfirmation =>
      'هل أنت متأكد من حذف هذه التعليقات؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get feedbackDeletedSuccessfully => 'تم حذف التعليقات بنجاح';

  @override
  String get reassignLocation => 'إعادة تعيين الموقع';

  @override
  String eventColon(String name) {
    return 'الفعالية: $name';
  }

  @override
  String shiftTimeRange(String start, String end) {
    return 'النوبة: $start - $end';
  }

  @override
  String get selectNewLocation => 'اختر موقعاً جديداً:';

  @override
  String mainLocationColon(String name) {
    return 'الموقع الرئيسي: $name';
  }

  @override
  String get sublocationsColon => 'المواقع الفرعية:';

  @override
  String get reassign => 'إعادة التعيين';

  @override
  String get pleaseSelectARole => 'الرجاء اختيار دور';

  @override
  String get pleaseSelectATeam => 'الرجاء اختيار فريق';

  @override
  String get pleaseSelectAnEvent => 'الرجاء اختيار فعالية';

  @override
  String get noUsersFoundForAudience =>
      'لم يتم العثور على مستخدمين للجمهور المحدد';

  @override
  String notificationSentToUsers(int count) {
    return 'تم إرسال الإشعار إلى $count مستخدم';
  }

  @override
  String errorSendingNotifications(String error) {
    return 'خطأ في إرسال الإشعارات: $error';
  }

  @override
  String get notificationType => 'نوع الإشعار';

  @override
  String get title => 'العنوان';

  @override
  String get message => 'الرسالة';

  @override
  String get sendTo => 'إرسال إلى';

  @override
  String get allUsers => 'جميع المستخدمين';

  @override
  String get byRole => 'حسب الدور';

  @override
  String get byTeam => 'حسب الفريق';

  @override
  String get eventParticipants => 'المشاركون في الفعالية';

  @override
  String get selectRole => 'اختر الدور';

  @override
  String get chooseARole => 'اختر دوراً';

  @override
  String get chooseATeam => 'اختر فريقاً';

  @override
  String get chooseAnEvent => 'اختر فعالية';

  @override
  String get sendNotificationsToGroups =>
      'إرسال إشعارات إلى مجموعات محددة من المستخدمين في النظام';

  @override
  String get noEventsAvailable => 'لا توجد فعاليات متاحة';

  @override
  String get chooseEventToViewFeedback => 'اختر فعالية لعرض التعليقات';

  @override
  String get selectEventToViewFeedback => 'اختر فعالية لعرض التعليقات';

  @override
  String get noFeedbackReceivedYet => 'لم يتم استلام تعليقات لهذه الفعالية بعد';

  @override
  String errorLoadingAverages(String error) {
    return 'خطأ في تحميل المتوسطات: $error';
  }

  @override
  String individualFeedback(int count) {
    return 'تعليقات فردية ($count)';
  }

  @override
  String get overallRating => 'التقييم العام';

  @override
  String basedOnResponses(int count, String plural) {
    return 'بناءً على $count استجابة$plural';
  }

  @override
  String errorLoadingForms(String error) {
    return 'خطأ في تحميل النماذج: $error';
  }

  @override
  String syncedVolunteersWithForms(int count) {
    return 'تمت مزامنة $count متطوع مع نماذجهم';
  }

  @override
  String get volunteerFormsManagement => 'إدارة نماذج المتطوعين';

  @override
  String get newForm => 'نموذج جديد';

  @override
  String get filterByStatus => 'التصفية حسب الحالة:';

  @override
  String get allStatuses => 'جميع الحالات';

  @override
  String get createNewFormToGetStarted => 'أنشئ نموذجاً جديداً للبدء';

  @override
  String get documentsColon => 'المستندات:';

  @override
  String formNumber(String number) {
    return 'نموذج #$number';
  }

  @override
  String statusUpdatedButErrorCreatingAccount(String error) {
    return 'تم تحديث الحالة ولكن حدث خطأ في إنشاء الحساب: $error';
  }

  @override
  String get enterNotificationTitle => 'أدخل عنوان الإشعار';

  @override
  String get enterNotificationMessage => 'أدخل رسالة الإشعار';

  @override
  String archiveItem(String itemType) {
    return 'أرشفة $itemType؟';
  }

  @override
  String get unarchive => 'إلغاء الأرشفة';

  @override
  String unarchiveItem(String itemType) {
    return 'إلغاء أرشفة $itemType؟';
  }

  @override
  String deleteItem(String itemType) {
    return 'حذف $itemType؟';
  }

  @override
  String confirmArchiveItem(String itemName) {
    return 'هل أنت متأكد من أرشفة \"$itemName\"؟';
  }

  @override
  String confirmUnarchiveItem(String itemName) {
    return 'هل أنت متأكد من استعادة \"$itemName\" إلى الحالة النشطة؟';
  }

  @override
  String confirmDeleteItem(String itemName) {
    return 'هل أنت متأكد من حذف \"$itemName\" نهائياً؟';
  }

  @override
  String archiveWarning(String itemType) {
    return 'سيؤدي هذا إلى إخفاء $itemType من القوائم النشطة مع الاحتفاظ بجميع البيانات.';
  }

  @override
  String deleteWarning(String itemType) {
    return 'لا يمكن التراجع عن هذا الإجراء. سيتم إزالة جميع البيانات المرتبطة بـ $itemType نهائياً.';
  }

  @override
  String get deleteWarningGeneric =>
      'لا يمكن التراجع عن هذا الإجراء! سيتم حذف جميع البيانات المرتبطة نهائياً.';

  @override
  String get showArchived => 'عرض المؤرشف';

  @override
  String errorOccurred(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String get markAllRead => 'تعليم الكل كمقروء';

  @override
  String get errorLoadingNotifications => 'خطأ في تحميل الإشعارات';

  @override
  String get noNotificationsYet => 'لا توجد إشعارات حتى الآن';

  @override
  String get notificationsWillAppearHere => 'ستظهر الإشعارات هنا عند استلامها';

  @override
  String get notificationDeleted => 'تم حذف الإشعار';

  @override
  String get check1Departure => 'الفحص الأول: المغادرة';

  @override
  String get check2Arrival => 'الفحص الثاني: الوصول';

  @override
  String get selectAnEventToStartPresenceCheck => 'اختر حدثاً لبدء فحص الحضور';

  @override
  String get adminOnly => 'مدير فقط';

  @override
  String get tlOnly => 'قائد فقط';

  @override
  String get both => 'كلاهما';

  @override
  String get noVolunteersAssignedToThisEvent =>
      'لا توجد متطوعين مخصصين لهذا الحدث';

  @override
  String get departureCheckOnBus => 'فحص المغادرة (في الحافلة)';

  @override
  String get arrivalCheckOnLocation => 'فحص الوصول (في الموقع)';

  @override
  String get excusedLeaveApproved => 'معذور (تم الموافقة على الإجازة)';

  @override
  String get present => 'حاضر';

  @override
  String get presentUpper => 'حاضر';

  @override
  String get absent => 'غائب';

  @override
  String get absentUpper => 'غائب';

  @override
  String get markAbsent => 'تعليم كغائب';

  @override
  String get markPresent => 'تعليم كحاضر';

  @override
  String get notChecked => 'لم يتم الفحص';

  @override
  String get excused => 'معذور';

  @override
  String errorMarkingAttendance(String error) {
    return 'خطأ في تسجيل الحضور: $error';
  }

  @override
  String get selectAnEventAndShiftToAssignVolunteers =>
      'اختر حدثاً ووردية لتعيين المتطوعين';

  @override
  String get pleaseSelectEventShiftAndLocationFirst =>
      'يرجى اختيار حدث ووردية وموقع أولاً';

  @override
  String get noApprovedVolunteersAvailable => 'لا يوجد متطوعون معتمدون متاحون';

  @override
  String assignedVolunteersToSubLocation(int count) {
    return 'تم تعيين $count متطوع للموقع الفرعي بنجاح';
  }

  @override
  String errorCreatingAssignments(String error) {
    return 'خطأ في إنشاء التعيينات: $error';
  }

  @override
  String get chooseLocationToAssignVolunteers => 'اختر موقعاً لتعيين المتطوعين';

  @override
  String get selectALocation => 'اختر موقعاً';

  @override
  String get assignVolunteersToLocation => 'تعيين متطوعين للموقع';

  @override
  String get assigned => 'معين';

  @override
  String get noVolunteersAssignedYet => 'لم يتم تعيين متطوعين بعد';

  @override
  String get teamLeadersShouldAssignFirst => 'يجب على قادة الفرق التعيين أولاً';

  @override
  String get mainSuffix => '(رئيسي)';

  @override
  String get unknownSubLocation => 'موقع فرعي غير معروف';

  @override
  String selectedCount(int count) {
    return 'المحدد: $count';
  }

  @override
  String get event => 'الحدث';

  @override
  String errorReassigningLocation(String error) {
    return 'خطأ في إعادة تعيين الموقع: $error';
  }

  @override
  String get contactAdminToAssignYourTeamToEvents =>
      'اتصل بالمسؤول لتعيين فريقك للأحداث';

  @override
  String get selectAShiftToAssignVolunteers => 'اختر وردية لتعيين المتطوعين';

  @override
  String get noTeamAssignedToThisLocation => 'لا يوجد فريق معين لهذا الموقع';

  @override
  String get noApprovedVolunteersAvailableInYourTeam =>
      'لا يوجد متطوعون معتمدون متاحون في فريقك';

  @override
  String get chooseWhichLocationToAssignYourTeamMembersTo =>
      'اختر الموقع الذي تريد تعيين أعضاء فريقك له:';

  @override
  String get requestLeave => 'طلب إجازة';

  @override
  String get userNotAuthenticated => 'المستخدم غير مصادق عليه';

  @override
  String get leaveRequestSubmittedSuccessfully => 'تم تقديم طلب الإجازة بنجاح';

  @override
  String get reasonForLeaveRequest => 'سبب طلب الإجازة';

  @override
  String get provideDetailedReasonForLeave =>
      'يرجى تقديم سبب مفصل لطلب الإجازة. سيساعد هذا قائد فريقك على اتخاذ قرار مستنير.';

  @override
  String get enterYourReasonHere => 'أدخل سببك هنا...';

  @override
  String get pleaseProvideAReason => 'يرجى تقديم السبب';

  @override
  String get pleaseProvideMoreDetailedReason =>
      'يرجى تقديم سبب أكثر تفصيلاً (10 أحرف على الأقل)';

  @override
  String get teamLeaderWillReviewRequest =>
      'سيقوم قائد فريقك بمراجعة هذا الطلب. سيتم إخطارك بقرارهم.';

  @override
  String get submitting => 'جاري الإرسال...';

  @override
  String get submitRequest => 'تقديم الطلب';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get shiftTimeLabel => 'وقت المناوبة';

  @override
  String get noEventsAssignedToYou => 'لا توجد فعاليات مخصصة لك';

  @override
  String get contactTeamLeaderToBeAssignedToEvents =>
      'اتصل بقائد فريقك ليتم تعيينك للفعاليات';

  @override
  String get viewOnMap => 'عرض على الخريطة';

  @override
  String get submitEventFeedback => 'تقديم تقييم الحدث';

  @override
  String contactLabel(String phone) {
    return 'الاتصال: $phone';
  }

  @override
  String yourShift(String shiftId) {
    return 'مناوبتك: $shiftId';
  }

  @override
  String locationField(String location) {
    return 'الموقع: $location';
  }

  @override
  String get notAssigned => 'غير مخصص';

  @override
  String get rateYourExperience => 'قيّم تجربتك';

  @override
  String get rateEventManagementAspects =>
      'يرجى تقييم الجوانب التالية لإدارة الفعالية (1 = ضعيف، 5 = ممتاز)';

  @override
  String get additionalCommentsOptional => 'تعليقات إضافية (اختياري)';

  @override
  String get shareAnyAdditionalThoughts =>
      'شارك أي أفكار أو اقتراحات إضافية...';

  @override
  String get thankYouForFeedback => 'شكراً لملاحظاتك!';

  @override
  String get poor => 'ضعيف';

  @override
  String get fair => 'مقبول';

  @override
  String get good => 'جيد';

  @override
  String get veryGood => 'جيد جداً';

  @override
  String get excellent => 'ممتاز';

  @override
  String get imageSizeExceedsLimit => 'يجب ألا يتجاوز حجم الصورة 500 كيلوبايت.';

  @override
  String get formSubmittedForReview => 'تم تقديم النموذج للمراجعة!';

  @override
  String get downloadPdf => 'تحميل PDF';

  @override
  String get readyToPrint => 'جاهز للطباعة!';

  @override
  String get errorLabel => 'خطأ';

  @override
  String get sublocation => 'الموقع الفرعي';

  @override
  String get organizationPlanning => 'التنظيم والتخطيط';

  @override
  String get howWellWasEventOrganized => 'كيف كان مستوى تنظيم وتخطيط الفعالية؟';

  @override
  String get logisticsResources => 'اللوجستيات والموارد';

  @override
  String get wereResourcesAdequatelyProvided =>
      'هل تم توفير الموارد واللوجستيات بشكل كافٍ؟';

  @override
  String get communication => 'التواصل';

  @override
  String get howEffectiveWasCommunication =>
      'ما مدى فعالية التواصل قبل وأثناء الفعالية؟';

  @override
  String get howWellWasEventManaged => 'كيف كانت إدارة الفعالية بشكل عام؟';

  @override
  String get shareYourThoughts =>
      'شارك أفكارك أو اقتراحاتك أو أي مشاكل واجهتها...';

  @override
  String get mySchedule => 'جدولي';

  @override
  String errorLoadingSchedule(String error) {
    return 'خطأ في تحميل الجدول: $error';
  }

  @override
  String get selectDayToViewAssignments => 'اختر يوماً لعرض التكليفات';

  @override
  String noShiftsOn(String date) {
    return 'لا توجد مناوبات في $date';
  }

  @override
  String locationId(String id) {
    return 'معرف الموقع: $id';
  }

  @override
  String get performanceScore => 'درجة الأداء';

  @override
  String get basedOnIHSCriteria => 'بناءً على معايير IHS';

  @override
  String get personalInformation => 'المعلومات الشخصية';

  @override
  String get education => 'التعليم';

  @override
  String get birthDate => 'تاريخ الميلاد';

  @override
  String get profession => 'المهنة';

  @override
  String get jobTitle => 'المسمى الوظيفي';

  @override
  String get department => 'القسم';

  @override
  String get notApplicable => 'غير متوفر';

  @override
  String get nextShift => 'المناوبة القادمة';

  @override
  String get unknownLocation => 'موقع غير معروف';

  @override
  String get provideYourFeedback => 'قدم تقييمك حول هذا الحدث';

  @override
  String get howWasYourExperience => 'كيف كانت تجربتك؟';

  @override
  String get pleaseSelectRating => 'الرجاء اختيار التقييم';

  @override
  String get yourFeedback => 'تقييمك';

  @override
  String get shareFeedbackDetails => 'شارك تفاصيل تقييمك هنا...';

  @override
  String get pleaseProvideFeedback => 'الرجاء تقديم تقييمك';

  @override
  String get feedbackSubmittedSuccessfully => 'شكراً! تم تقديم تقييمك بنجاح.';

  @override
  String failedToSubmitFeedback(String error) {
    return 'فشل تقديم التقييم: $error';
  }

  @override
  String get eventDetails => 'تفاصيل الحدث';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get areYouSureSignOut => 'هل أنت متأكد من تسجيل الخروج؟';

  @override
  String get shareFeedbackPrompt =>
      'شارك ملاحظاتك، أبلغ عن الأخطاء، أو اقترح تحسينات لمساعدتنا في تحسين النظام.';

  @override
  String get describeFeedbackDetail =>
      'صف المشكلة أو الخطأ أو الاقتراح بالتفصيل...';

  @override
  String get pleaseEnterFeedback => 'الرجاء إدخال ملاحظاتك';

  @override
  String get provideMoreDetails =>
      'الرجاء تقديم المزيد من التفاصيل (10 أحرف على الأقل)';

  @override
  String get myPreviousFeedback => 'ملاحظاتي السابقة';

  @override
  String errorLoadingFeedback(String error) {
    return 'خطأ في تحميل الملاحظات: $error';
  }

  @override
  String get noFeedbackYet => 'لم تقدم أي ملاحظات بعد';

  @override
  String get adminResponse => 'رد المسؤول:';
}
