// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get createList => 'Create List';

  @override
  String get listName => 'LIST NAME';

  @override
  String get listNameHint => 'Enter list name (e.g., Weekly Groceries)';

  @override
  String get listNameRequired => 'Please enter a list name';

  @override
  String get selectCategory => 'SELECT CATEGORY';

  @override
  String get priority => 'PRIORITY';

  @override
  String get urgent => 'Urgent';

  @override
  String get normal => 'Normal';

  @override
  String get dueDateOptional => 'DUE DATE (optional)';

  @override
  String get createListButton => 'CREATE LIST';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get signInToContinue => 'Sign in to continue to Listfy';

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
  String get quantity => 'Quantity';

  @override
  String get photo => 'Photo';

  @override
  String get optional => '(optional)';

  @override
  String get addToList => 'Add to list';

  @override
  String get appTitle => 'Grovia';

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
  String get aboutUsContent => 'Grovia is a smart grocery list app that helps you organize your shopping and collaborate with family or friends in real time. Create lists, share them instantly, and never forget an item again.';

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

  @override
  String get share => 'Share';

  @override
  String get favorite => 'Favorite';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get noSuggestions => 'No suggestions found.';

  @override
  String get completed => 'Completed';

  @override
  String get selectDueDate => 'Select due date';

  @override
  String get activeSection => 'Active';

  @override
  String get checkedSection => 'Checked';

  @override
  String get searchOrAddItems => 'Search or add items...';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get cantFindItem => 'Can\'t find your item?';

  @override
  String get tapToAddManually => 'Tap here to add it manually';

  @override
  String get itemAlreadyInList => 'Item already in list';

  @override
  String itemAlreadyChecked(Object name) {
    return '\"$name\" is already in your list and has been checked off.';
  }

  @override
  String itemAlreadyActiveQty(Object name, Object qty) {
    return '\"$name\" is already in your list (qty: $qty). Would you like to increase the quantity?';
  }

  @override
  String get increase => 'Increase';

  @override
  String increasedQty(Object name, Object qty) {
    return 'Increased \"$name\" quantity to $qty.';
  }

  @override
  String get viewItem => 'View';

  @override
  String get checkItem => 'Check';

  @override
  String get uncheckItem => 'Uncheck';

  @override
  String get enterPassword => 'Please enter your password';

  @override
  String get notSignedIn => 'You\'re not signed in';

  @override
  String get logInOrCreate => 'Log in or create an account to manage your grocery lists.';

  @override
  String get welcomeToProfile => 'Welcome to your profile';

  @override
  String get signOut => 'Sign Out';

  @override
  String get inviteToList => 'Invite to list';

  @override
  String get shareInviteLink => 'Share invite link';

  @override
  String get generatingLink => 'Generating link…';

  @override
  String get inviteLinkCopied => 'Invite link copied!';

  @override
  String get acceptInvite => 'Accept Invite';

  @override
  String get rejectInvite => 'Decline';

  @override
  String get inviteTitle => 'You\'ve been invited!';

  @override
  String inviteSubtitle(String name) {
    return '$name invited you to collaborate on a list.';
  }

  @override
  String inviteListName(String listName) {
    return 'List: $listName';
  }

  @override
  String inviteItemCount(int count) {
    return '$count items';
  }

  @override
  String get inviteAccepted => 'You\'ve joined the list!';

  @override
  String get inviteDeclined => 'Invite declined.';

  @override
  String get inviteInvalid => 'This invite link is invalid or has expired.';

  @override
  String get mustBeLoggedInToAccept => 'Please log in first to accept this invite.';

  @override
  String get accepting => 'Accepting…';

  @override
  String get declining => 'Declining…';
}
