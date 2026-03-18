import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @createList.
  ///
  /// In en, this message translates to:
  /// **'Create List'**
  String get createList;

  /// No description provided for @listName.
  ///
  /// In en, this message translates to:
  /// **'LIST NAME'**
  String get listName;

  /// No description provided for @listNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter list name (e.g., Weekly Groceries)'**
  String get listNameHint;

  /// No description provided for @listNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a list name'**
  String get listNameRequired;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'SELECT CATEGORY'**
  String get selectCategory;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'PRIORITY'**
  String get priority;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get normal;

  /// No description provided for @dueDateOptional.
  ///
  /// In en, this message translates to:
  /// **'DUE DATE (optional)'**
  String get dueDateOptional;

  /// No description provided for @createListButton.
  ///
  /// In en, this message translates to:
  /// **'CREATE LIST'**
  String get createListButton;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to Listfy'**
  String get signInToContinue;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signedIn.
  ///
  /// In en, this message translates to:
  /// **'Signed in'**
  String get signedIn;

  /// No description provided for @activeLists.
  ///
  /// In en, this message translates to:
  /// **'Active Lists'**
  String get activeLists;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @changeLanguageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguageTooltip;

  /// No description provided for @failedToLoadMarketing.
  ///
  /// In en, this message translates to:
  /// **'Failed to load marketing'**
  String get failedToLoadMarketing;

  /// No description provided for @noMarketing.
  ///
  /// In en, this message translates to:
  /// **'No marketing available'**
  String get noMarketing;

  /// No description provided for @failedToLoadLists.
  ///
  /// In en, this message translates to:
  /// **'Failed to load lists'**
  String get failedToLoadLists;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items'**
  String get noItems;

  /// No description provided for @createNewList.
  ///
  /// In en, this message translates to:
  /// **'Create\nNew List'**
  String get createNewList;

  /// No description provided for @deleteList.
  ///
  /// In en, this message translates to:
  /// **'Delete List'**
  String get deleteList;

  /// No description provided for @deleteListConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this list? This action cannot be undone.'**
  String get deleteListConfirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @deleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\" from the list?'**
  String deleteItemConfirm(String name);

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted.'**
  String get itemDeleted;

  /// No description provided for @listDeleted.
  ///
  /// In en, this message translates to:
  /// **'List deleted successfully.'**
  String get listDeleted;

  /// No description provided for @failedToDeleteList.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete list: {error}'**
  String failedToDeleteList(Object error);

  /// No description provided for @shareList.
  ///
  /// In en, this message translates to:
  /// **'Here is the list of {listName}\n{itemsText}\n\nThank you for using the app'**
  String shareList(Object itemsText, Object listName);

  /// No description provided for @noItemsInList.
  ///
  /// In en, this message translates to:
  /// **'No items in the list.'**
  String get noItemsInList;

  /// No description provided for @listCreated.
  ///
  /// In en, this message translates to:
  /// **'List \"{name}\" created successfully!'**
  String listCreated(Object name);

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @failedToLoadCategories.
  ///
  /// In en, this message translates to:
  /// **'Failed to load categories.'**
  String get failedToLoadCategories;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get items;

  /// No description provided for @enterCustomItem.
  ///
  /// In en, this message translates to:
  /// **'Enter custom item'**
  String get enterCustomItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @photo.
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get photo;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'(optional)'**
  String get optional;

  /// No description provided for @addToList.
  ///
  /// In en, this message translates to:
  /// **'Add to list'**
  String get addToList;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Grovia'**
  String get appTitle;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @aboutUsContent.
  ///
  /// In en, this message translates to:
  /// **'Grovia is a smart grocery list app that helps you organize your shopping and collaborate with family or friends in real time. Create lists, share them instantly, and never forget an item again.'**
  String get aboutUsContent;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share the app with a friend'**
  String get shareApp;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get theme;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'John Doe'**
  String get nameHint;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Please enter your full name'**
  String get enterFullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'email@example.com'**
  String get emailHint;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get enterEmail;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get enterValidEmail;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get passwordHint;

  /// No description provided for @password6chars.
  ///
  /// In en, this message translates to:
  /// **'Password must be 6+ chars'**
  String get password6chars;

  /// No description provided for @orJoinWith.
  ///
  /// In en, this message translates to:
  /// **'OR JOIN WITH'**
  String get orJoinWith;

  /// No description provided for @google.
  ///
  /// In en, this message translates to:
  /// **'Google'**
  String get google;

  /// No description provided for @apple.
  ///
  /// In en, this message translates to:
  /// **'Apple'**
  String get apple;

  /// No description provided for @accountCreated.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully'**
  String get accountCreated;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @terms.
  ///
  /// In en, this message translates to:
  /// **'By signing up, you agree to our Terms of Service and Privacy Policy'**
  String get terms;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @favorite.
  ///
  /// In en, this message translates to:
  /// **'Favorite'**
  String get favorite;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @noSuggestions.
  ///
  /// In en, this message translates to:
  /// **'No suggestions found.'**
  String get noSuggestions;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @selectDueDate.
  ///
  /// In en, this message translates to:
  /// **'Select due date'**
  String get selectDueDate;

  /// No description provided for @activeSection.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeSection;

  /// No description provided for @checkedSection.
  ///
  /// In en, this message translates to:
  /// **'Checked'**
  String get checkedSection;

  /// No description provided for @searchOrAddItems.
  ///
  /// In en, this message translates to:
  /// **'Search or add items...'**
  String get searchOrAddItems;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @cantFindItem.
  ///
  /// In en, this message translates to:
  /// **'Can\'t find your item?'**
  String get cantFindItem;

  /// No description provided for @tapToAddManually.
  ///
  /// In en, this message translates to:
  /// **'Tap here to add it manually'**
  String get tapToAddManually;

  /// No description provided for @itemAlreadyInList.
  ///
  /// In en, this message translates to:
  /// **'Item already in list'**
  String get itemAlreadyInList;

  /// No description provided for @itemAlreadyChecked.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is already in your list and has been checked off.'**
  String itemAlreadyChecked(Object name);

  /// No description provided for @itemAlreadyActiveQty.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" is already in your list (qty: {qty}). Would you like to increase the quantity?'**
  String itemAlreadyActiveQty(Object name, Object qty);

  /// No description provided for @increase.
  ///
  /// In en, this message translates to:
  /// **'Increase'**
  String get increase;

  /// No description provided for @increasedQty.
  ///
  /// In en, this message translates to:
  /// **'Increased \"{name}\" quantity to {qty}.'**
  String increasedQty(Object name, Object qty);

  /// No description provided for @viewItem.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get viewItem;

  /// No description provided for @checkItem.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get checkItem;

  /// No description provided for @uncheckItem.
  ///
  /// In en, this message translates to:
  /// **'Uncheck'**
  String get uncheckItem;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get enterPassword;

  /// No description provided for @notSignedIn.
  ///
  /// In en, this message translates to:
  /// **'You\'re not signed in'**
  String get notSignedIn;

  /// No description provided for @logInOrCreate.
  ///
  /// In en, this message translates to:
  /// **'Log in or create an account to manage your grocery lists.'**
  String get logInOrCreate;

  /// No description provided for @welcomeToProfile.
  ///
  /// In en, this message translates to:
  /// **'Welcome to your profile'**
  String get welcomeToProfile;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @inviteToList.
  ///
  /// In en, this message translates to:
  /// **'Invite to list'**
  String get inviteToList;

  /// No description provided for @shareInviteLink.
  ///
  /// In en, this message translates to:
  /// **'Share invite link'**
  String get shareInviteLink;

  /// No description provided for @generatingLink.
  ///
  /// In en, this message translates to:
  /// **'Generating link…'**
  String get generatingLink;

  /// No description provided for @inviteLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite link copied!'**
  String get inviteLinkCopied;

  /// No description provided for @acceptInvite.
  ///
  /// In en, this message translates to:
  /// **'Accept Invite'**
  String get acceptInvite;

  /// No description provided for @rejectInvite.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get rejectInvite;

  /// No description provided for @inviteTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ve been invited!'**
  String get inviteTitle;

  /// No description provided for @inviteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{name} invited you to collaborate on a list.'**
  String inviteSubtitle(String name);

  /// No description provided for @inviteListName.
  ///
  /// In en, this message translates to:
  /// **'List: {listName}'**
  String inviteListName(String listName);

  /// No description provided for @inviteItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String inviteItemCount(int count);

  /// No description provided for @inviteAccepted.
  ///
  /// In en, this message translates to:
  /// **'You\'ve joined the list!'**
  String get inviteAccepted;

  /// No description provided for @inviteDeclined.
  ///
  /// In en, this message translates to:
  /// **'Invite declined.'**
  String get inviteDeclined;

  /// No description provided for @inviteInvalid.
  ///
  /// In en, this message translates to:
  /// **'This invite link is invalid or has expired.'**
  String get inviteInvalid;

  /// No description provided for @mustBeLoggedInToAccept.
  ///
  /// In en, this message translates to:
  /// **'Please log in first to accept this invite.'**
  String get mustBeLoggedInToAccept;

  /// No description provided for @accepting.
  ///
  /// In en, this message translates to:
  /// **'Accepting…'**
  String get accepting;

  /// No description provided for @declining.
  ///
  /// In en, this message translates to:
  /// **'Declining…'**
  String get declining;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
