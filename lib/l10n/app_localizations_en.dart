// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToContinue => 'Sign in to continue to ShopSmart';

  @override
  String get signIn => 'Sign In';

  @override
  String get signedIn => 'Signed in';

  @override
  String get activeLists => 'Active Lists';

  @override
  String get refresh => 'Refresh';

  @override
  String get notifications => 'Notifications';

  @override
  String get changeLanguageTooltip => 'Change Language';

  @override
  String get failedToLoadMarketing => 'Failed to load marketing';

  @override
  String get noMarketing => 'No marketing available';

  @override
  String get failedToLoadLists => 'Failed to load lists';

  @override
  String get retry => 'Retry';

  @override
  String get noItems => 'No items';

  @override
  String get createNewList => 'Create\nNew List';

  @override
  String get deleteList => 'Delete List';

  @override
  String get deleteListConfirm => 'Are you sure you want to delete this list? This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get listDeleted => 'List deleted successfully.';

  @override
  String failedToDeleteList(Object error) {
    return 'Failed to delete list: $error';
  }

  @override
  String shareList(Object itemsText, Object listName) {
    return 'Here is the list of $listName\n$itemsText\n\nThank you for using the app';
  }

  @override
  String get noItemsInList => 'No items in the list.';

  @override
  String listCreated(Object name) {
    return 'List \"$name\" created successfully!';
  }

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get categories => 'Categories';

  @override
  String get failedToLoadCategories => 'Failed to load categories.';

  @override
  String get items => 'items';

  @override
  String get enterCustomItem => 'Enter custom item';

  @override
  String get itemName => 'Item name';

  @override
  String get add => 'Add';

  @override
  String get appTitle => 'ShopSmart';

  @override
  String get settings => 'Settings';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get aboutUs => 'About Us';

  @override
  String get aboutUsContent => 'ShopSmart helps you elevate your grocery experience.';

  @override
  String get shareApp => 'Share the app with a friend';

  @override
  String get theme => 'Dark Mode';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get ok => 'OK';

  @override
  String get createAccount => 'Create Account';

  @override
  String get fullName => 'Full Name';

  @override
  String get nameHint => 'John Doe';

  @override
  String get enterFullName => 'Please enter your full name';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get emailHint => 'email@example.com';

  @override
  String get enterEmail => 'Please enter your email';

  @override
  String get enterValidEmail => 'Please enter a valid email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'At least 6 characters';

  @override
  String get password6chars => 'Password must be 6+ chars';

  @override
  String get orJoinWith => 'OR JOIN WITH';

  @override
  String get google => 'Google';

  @override
  String get apple => 'Apple';

  @override
  String get accountCreated => 'Account created successfully';

  @override
  String get signUp => 'Sign Up';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get logIn => 'Log In';

  @override
  String get terms => 'By signing up, you agree to our Terms of Service and Privacy Policy';
}
