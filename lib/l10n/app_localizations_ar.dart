// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get createList => 'إنشاء قائمة';

  @override
  String get listName => 'اسم القائمة';

  @override
  String get listNameHint => 'أدخل اسم القائمة (مثال: مشتريات الأسبوع)';

  @override
  String get listNameRequired => 'يرجى إدخال اسم القائمة';

  @override
  String get selectCategory => 'اختر الفئة';

  @override
  String get priority => 'الأولوية';

  @override
  String get urgent => 'عاجل';

  @override
  String get normal => 'عادي';

  @override
  String get dueDateOptional => 'تاريخ الاستحقاق (اختياري)';

  @override
  String get createListButton => 'إنشاء القائمة';

  @override
  String get welcomeBack => 'مرحبًا بعودتك';

  @override
  String get signInToContinue => 'سجّل الدخول للمتابعة إلى Listfy';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signedIn => 'تم تسجيل الدخول';

  @override
  String get activeLists => 'القوائم النشطة';

  @override
  String get refresh => 'تحديث';

  @override
  String get notifications => 'الإشعارات';

  @override
  String get changeLanguageTooltip => 'تغيير اللغة';

  @override
  String get failedToLoadMarketing => 'فشل تحميل التسويق';

  @override
  String get noMarketing => 'لا يوجد تسويق متاح';

  @override
  String get failedToLoadLists => 'فشل تحميل القوائم';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noItems => 'لا توجد عناصر';

  @override
  String get createNewList => 'إنشاء\nقائمة جديدة';

  @override
  String get deleteList => 'حذف القائمة';

  @override
  String get deleteListConfirm => 'هل أنت متأكد أنك تريد حذف هذه القائمة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get delete => 'حذف';

  @override
  String get listDeleted => 'تم حذف القائمة بنجاح.';

  @override
  String failedToDeleteList(Object error) {
    return 'فشل حذف القائمة: $error';
  }

  @override
  String shareList(Object itemsText, Object listName) {
    return 'هذه قائمة $listName\n$itemsText\n\nشكرًا لاستخدامك التطبيق';
  }

  @override
  String get noItemsInList => 'لا توجد عناصر في القائمة.';

  @override
  String listCreated(Object name) {
    return 'تم إنشاء القائمة \"$name\" بنجاح!';
  }

  @override
  String get home => 'الرئيسية';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get categories => 'الفئات';

  @override
  String get failedToLoadCategories => 'فشل تحميل الفئات.';

  @override
  String get items => 'عنصر';

  @override
  String get enterCustomItem => 'أدخل عنصر مخصص';

  @override
  String get itemName => 'اسم العنصر';

  @override
  String get add => 'إضافة';

  @override
  String get quantity => 'الكمية';

  @override
  String get photo => 'صورة';

  @override
  String get optional => '(اختياري)';

  @override
  String get addToList => 'أضف إلى القائمة';

  @override
  String get appTitle => 'Grovia';

  @override
  String get settings => 'الإعدادات';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get arabic => 'العربية';

  @override
  String get aboutUs => 'معلومات عنا';

  @override
  String get aboutUsContent => 'Grovia تطبيق قوائم تسوق ذكي يساعدك على تنظيم مشترياتك والتعاون مع العائلة أو الأصدقاء في الوقت الفعلي. أنشئ قوائم، شاركها على الفور، ولا تنسَ أي عنصر.';

  @override
  String get shareApp => 'شارك التطبيق مع صديق';

  @override
  String get theme => 'الوضع الداكن';

  @override
  String get chooseLanguage => 'اختر اللغة';

  @override
  String get ok => 'موافق';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get fullName => 'الاسم الكامل';

  @override
  String get nameHint => 'محمد أحمد';

  @override
  String get enterFullName => 'يرجى إدخال الاسم الكامل';

  @override
  String get emailAddress => 'البريد الإلكتروني';

  @override
  String get emailHint => 'email@example.com';

  @override
  String get enterEmail => 'يرجى إدخال البريد الإلكتروني';

  @override
  String get enterValidEmail => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String get password => 'كلمة المرور';

  @override
  String get passwordHint => '6 أحرف على الأقل';

  @override
  String get password6chars => 'يجب أن تكون كلمة المرور 6 أحرف أو أكثر';

  @override
  String get orJoinWith => 'أو سجل بواسطة';

  @override
  String get google => 'جوجل';

  @override
  String get apple => 'آبل';

  @override
  String get accountCreated => 'تم إنشاء الحساب بنجاح';

  @override
  String get signUp => 'تسجيل';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟';

  @override
  String get logIn => 'تسجيل الدخول';

  @override
  String get terms => 'بالتسجيل، أنت توافق على شروط الخدمة وسياسة الخصوصية الخاصة بنا';

  @override
  String get share => 'مشاركة';

  @override
  String get favorite => 'مفضلة';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get noSuggestions => 'لا توجد اقتراحات.';

  @override
  String get completed => 'مكتمل';

  @override
  String get selectDueDate => 'اختر تاريخ الاستحقاق';

  @override
  String get activeSection => 'نشط';

  @override
  String get checkedSection => 'تم التحقق';

  @override
  String get searchOrAddItems => '...ابحث أو أضف عناصر';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get cantFindItem => 'لم تجد ما تبحث عنه؟';

  @override
  String get tapToAddManually => 'اضغط هنا لإضافته يدوياً';

  @override
  String get itemAlreadyInList => 'العنصر موجود في القائمة';

  @override
  String itemAlreadyChecked(Object name) {
    return '«$name» موجود بالفعل في قائمتك وتم تحديده.';
  }

  @override
  String itemAlreadyActiveQty(Object name, Object qty) {
    return '«$name» موجود بالفعل في قائمتك (الكمية: $qty). هل تريد زيادة الكمية؟';
  }

  @override
  String get increase => 'زيادة';

  @override
  String increasedQty(Object name, Object qty) {
    return 'تمت زيادة كمية «$name» إلى $qty.';
  }

  @override
  String get viewItem => 'عرض';

  @override
  String get checkItem => 'تحديد';

  @override
  String get uncheckItem => 'إلغاء التحديد';

  @override
  String get enterPassword => 'يرجى إدخال كلمة المرور';

  @override
  String get notSignedIn => 'أنت غير مسجّل الدخول';

  @override
  String get logInOrCreate => 'سجّل الدخول أو أنشئ حساباً لإدارة قوائم التسوق.';

  @override
  String get welcomeToProfile => 'مرحباً بك في ملفك الشخصي';

  @override
  String get signOut => 'تسجيل الخروج';
}
