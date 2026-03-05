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
  String get signInToContinue => 'سجّل الدخول للمتابعة إلى شوب سمارت';

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
  String get appTitle => 'شوب سمارت';

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
  String get aboutUsContent => 'شوب سمارت تساعدك على تحسين تجربة التسوق الخاصة بك.';

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
}
