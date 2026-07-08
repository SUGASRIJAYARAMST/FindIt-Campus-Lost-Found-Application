import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('ml'),
    Locale('ta'),
    Locale('te'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'FindIt'**
  String get appTitle;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Lost Something? Find It Smarter.'**
  String get tagline;

  /// No description provided for @lostFoundCampus.
  ///
  /// In en, this message translates to:
  /// **'Lost & Found for Campus Life'**
  String get lostFoundCampus;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back'**
  String get welcomeBack;

  /// No description provided for @signInToAccount.
  ///
  /// In en, this message translates to:
  /// **'Sign in to your account'**
  String get signInToAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinCampus.
  ///
  /// In en, this message translates to:
  /// **'Join your campus community'**
  String get joinCampus;

  /// No description provided for @createYourAccount.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get createYourAccount;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@university.edu'**
  String get emailHint;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enterPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterPassword;

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

  /// No description provided for @department.
  ///
  /// In en, this message translates to:
  /// **'Department'**
  String get department;

  /// No description provided for @deptHint.
  ///
  /// In en, this message translates to:
  /// **'Computer Science'**
  String get deptHint;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @phoneHint.
  ///
  /// In en, this message translates to:
  /// **'+1 234 567 890'**
  String get phoneHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @reenterPassword.
  ///
  /// In en, this message translates to:
  /// **'Re-enter your password'**
  String get reenterPassword;

  /// No description provided for @createStrongPassword.
  ///
  /// In en, this message translates to:
  /// **'Create a strong password'**
  String get createStrongPassword;

  /// No description provided for @agreeTerms.
  ///
  /// In en, this message translates to:
  /// **'I agree to the Terms & Conditions and Privacy Policy'**
  String get agreeTerms;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? '**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? '**
  String get alreadyHaveAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address first.'**
  String get enterValidEmail;

  /// No description provided for @passwordResetSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent. Check your inbox.'**
  String get passwordResetSent;

  /// No description provided for @acceptTerms.
  ///
  /// In en, this message translates to:
  /// **'Please accept the terms and conditions.'**
  String get acceptTerms;

  /// No description provided for @helloName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloName(String name);

  /// No description provided for @findLostReport.
  ///
  /// In en, this message translates to:
  /// **'Find your lost items or report found ones'**
  String get findLostReport;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @rewards.
  ///
  /// In en, this message translates to:
  /// **'Rewards'**
  String get rewards;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search lost or found items...'**
  String get searchHint;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @reportLost.
  ///
  /// In en, this message translates to:
  /// **'Report Lost'**
  String get reportLost;

  /// No description provided for @reportFound.
  ///
  /// In en, this message translates to:
  /// **'Report Found'**
  String get reportFound;

  /// No description provided for @myReports.
  ///
  /// In en, this message translates to:
  /// **'My Reports'**
  String get myReports;

  /// No description provided for @recentLostItems.
  ///
  /// In en, this message translates to:
  /// **'Recent Lost Items'**
  String get recentLostItems;

  /// No description provided for @recentFoundItems.
  ///
  /// In en, this message translates to:
  /// **'Recent Found Items'**
  String get recentFoundItems;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get lost;

  /// No description provided for @found.
  ///
  /// In en, this message translates to:
  /// **'Found'**
  String get found;

  /// No description provided for @student.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get student;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @app.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get app;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @chooseTheme.
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @tamil.
  ///
  /// In en, this message translates to:
  /// **'Tamil'**
  String get tamil;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @malayalam.
  ///
  /// In en, this message translates to:
  /// **'Malayalam'**
  String get malayalam;

  /// No description provided for @telugu.
  ///
  /// In en, this message translates to:
  /// **'Telugu'**
  String get telugu;

  /// No description provided for @languageSetTo.
  ///
  /// In en, this message translates to:
  /// **'Language set to {lang}'**
  String languageSetTo(String lang, Object name);

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Campus Lost & Found App'**
  String get aboutSubtitle;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0'**
  String get version;

  /// No description provided for @aboutDesc.
  ///
  /// In en, this message translates to:
  /// **'FindIt helps you report and find lost items on campus. Use AI-powered matching to reconnect with your belongings.'**
  String get aboutDesc;

  /// No description provided for @builtWith.
  ///
  /// In en, this message translates to:
  /// **'Built with Flutter & Firebase'**
  String get builtWith;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @feedbackPrompt.
  ///
  /// In en, this message translates to:
  /// **'Help us improve! Tell us what you think.'**
  String get feedbackPrompt;

  /// No description provided for @feedbackHint.
  ///
  /// In en, this message translates to:
  /// **'Your feedback...'**
  String get feedbackHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @thankFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankFeedback;

  /// No description provided for @enterFeedback.
  ///
  /// In en, this message translates to:
  /// **'Please enter your feedback.'**
  String get enterFeedback;

  /// No description provided for @passwordResetContent.
  ///
  /// In en, this message translates to:
  /// **'We\'ll send a password reset link to your email.'**
  String get passwordResetContent;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailHint2.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get emailHint2;

  /// No description provided for @sendLink.
  ///
  /// In en, this message translates to:
  /// **'Send Link'**
  String get sendLink;

  /// No description provided for @enterEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter your email.'**
  String get enterEmail;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @areYouSureSignOut.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get areYouSureSignOut;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @points.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get points;

  /// No description provided for @badge.
  ///
  /// In en, this message translates to:
  /// **'Badge'**
  String get badge;

  /// No description provided for @rookie.
  ///
  /// In en, this message translates to:
  /// **'Rookie'**
  String get rookie;

  /// No description provided for @updateInfo.
  ///
  /// In en, this message translates to:
  /// **'Update your personal information'**
  String get updateInfo;

  /// No description provided for @changePhoto.
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// No description provided for @uploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload a new profile picture'**
  String get uploadPhoto;

  /// No description provided for @appPrefs.
  ///
  /// In en, this message translates to:
  /// **'App preferences and account'**
  String get appPrefs;

  /// No description provided for @logOutAccount.
  ///
  /// In en, this message translates to:
  /// **'Log out of your account'**
  String get logOutAccount;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @profileRemoved.
  ///
  /// In en, this message translates to:
  /// **'Profile picture removed.'**
  String get profileRemoved;

  /// No description provided for @profileUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated!'**
  String get profileUpdated;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @profileUpdateSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile updated!'**
  String get profileUpdateSuccess;

  /// No description provided for @profileUpdateFail.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get profileUpdateFail;

  /// No description provided for @reportLostItem.
  ///
  /// In en, this message translates to:
  /// **'Report Lost Item'**
  String get reportLostItem;

  /// No description provided for @reportFoundItem.
  ///
  /// In en, this message translates to:
  /// **'Report Found Item'**
  String get reportFoundItem;

  /// No description provided for @reportingLost.
  ///
  /// In en, this message translates to:
  /// **'Reporting a Lost Item'**
  String get reportingLost;

  /// No description provided for @reportingFound.
  ///
  /// In en, this message translates to:
  /// **'Reporting a Found Item'**
  String get reportingFound;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @optionalRecommended.
  ///
  /// In en, this message translates to:
  /// **'Optional but recommended'**
  String get optionalRecommended;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @itemHint.
  ///
  /// In en, this message translates to:
  /// **'What is the item?'**
  String get itemHint;

  /// No description provided for @enterItemName.
  ///
  /// In en, this message translates to:
  /// **'Please enter item name'**
  String get enterItemName;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @electronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get electronics;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @clothing.
  ///
  /// In en, this message translates to:
  /// **'Clothing'**
  String get clothing;

  /// No description provided for @accessories.
  ///
  /// In en, this message translates to:
  /// **'Accessories'**
  String get accessories;

  /// No description provided for @bags.
  ///
  /// In en, this message translates to:
  /// **'Bags'**
  String get bags;

  /// No description provided for @keys.
  ///
  /// In en, this message translates to:
  /// **'Keys'**
  String get keys;

  /// No description provided for @idCards.
  ///
  /// In en, this message translates to:
  /// **'ID Cards'**
  String get idCards;

  /// No description provided for @books.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @describeItem.
  ///
  /// In en, this message translates to:
  /// **'Describe the item (color, size, etc.)'**
  String get describeItem;

  /// No description provided for @enterDescription.
  ///
  /// In en, this message translates to:
  /// **'Please enter description'**
  String get enterDescription;

  /// No description provided for @lostLocation.
  ///
  /// In en, this message translates to:
  /// **'Lost Location'**
  String get lostLocation;

  /// No description provided for @foundLocation.
  ///
  /// In en, this message translates to:
  /// **'Found Location'**
  String get foundLocation;

  /// No description provided for @whereLost.
  ///
  /// In en, this message translates to:
  /// **'Where did you lose it?'**
  String get whereLost;

  /// No description provided for @whereFound.
  ///
  /// In en, this message translates to:
  /// **'Where did you find it?'**
  String get whereFound;

  /// No description provided for @enterLocation.
  ///
  /// In en, this message translates to:
  /// **'Please enter location'**
  String get enterLocation;

  /// No description provided for @lostDate.
  ///
  /// In en, this message translates to:
  /// **'Lost Date'**
  String get lostDate;

  /// No description provided for @foundDate.
  ///
  /// In en, this message translates to:
  /// **'Found Date'**
  String get foundDate;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select date'**
  String get selectDate;

  /// No description provided for @contactNumber.
  ///
  /// In en, this message translates to:
  /// **'Contact Number'**
  String get contactNumber;

  /// No description provided for @yourPhone.
  ///
  /// In en, this message translates to:
  /// **'Your phone number'**
  String get yourPhone;

  /// No description provided for @enterContact.
  ///
  /// In en, this message translates to:
  /// **'Please enter contact number'**
  String get enterContact;

  /// No description provided for @submitLostReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Lost Report'**
  String get submitLostReport;

  /// No description provided for @submitFoundReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Found Report'**
  String get submitFoundReport;

  /// No description provided for @lostReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Lost report submitted!'**
  String get lostReportSubmitted;

  /// No description provided for @foundReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Found report submitted!'**
  String get foundReportSubmitted;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @newest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get newest;

  /// No description provided for @oldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get oldest;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @newestFirst.
  ///
  /// In en, this message translates to:
  /// **'Newest First'**
  String get newestFirst;

  /// No description provided for @oldestFirst.
  ///
  /// In en, this message translates to:
  /// **'Oldest First'**
  String get oldestFirst;

  /// No description provided for @noLostItems.
  ///
  /// In en, this message translates to:
  /// **'No lost items'**
  String get noLostItems;

  /// No description provided for @noFoundItems.
  ///
  /// In en, this message translates to:
  /// **'No found items'**
  String get noFoundItems;

  /// No description provided for @noItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No items yet'**
  String get noItemsYet;

  /// No description provided for @noLostReported.
  ///
  /// In en, this message translates to:
  /// **'No lost items have been reported yet.'**
  String get noLostReported;

  /// No description provided for @noFoundReported.
  ///
  /// In en, this message translates to:
  /// **'No found items have been reported yet.'**
  String get noFoundReported;

  /// No description provided for @tapToReport.
  ///
  /// In en, this message translates to:
  /// **'Tap + to report a lost or found item.'**
  String get tapToReport;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @searchItems.
  ///
  /// In en, this message translates to:
  /// **'Search items...'**
  String get searchItems;

  /// No description provided for @lostItems.
  ///
  /// In en, this message translates to:
  /// **'Lost Items'**
  String get lostItems;

  /// No description provided for @foundItems.
  ///
  /// In en, this message translates to:
  /// **'Found Items'**
  String get foundItems;

  /// No description provided for @noLostItemsHere.
  ///
  /// In en, this message translates to:
  /// **'Items you report as lost will appear here'**
  String get noLostItemsHere;

  /// No description provided for @noFoundItemsHere.
  ///
  /// In en, this message translates to:
  /// **'Items you report as found will appear here'**
  String get noFoundItemsHere;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editReport.
  ///
  /// In en, this message translates to:
  /// **'Edit Report'**
  String get editReport;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @reportUpdated.
  ///
  /// In en, this message translates to:
  /// **'Report updated!'**
  String get reportUpdated;

  /// No description provided for @deleteReport.
  ///
  /// In en, this message translates to:
  /// **'Delete Report'**
  String get deleteReport;

  /// No description provided for @deleteReportConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this report? This action cannot be undone.'**
  String get deleteReportConfirm;

  /// No description provided for @reportDeleted.
  ///
  /// In en, this message translates to:
  /// **'Report deleted'**
  String get reportDeleted;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @matched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get matched;

  /// No description provided for @claimed.
  ///
  /// In en, this message translates to:
  /// **'Claimed'**
  String get claimed;

  /// No description provided for @recovered.
  ///
  /// In en, this message translates to:
  /// **'Recovered'**
  String get recovered;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returned;

  /// No description provided for @itemNotFound.
  ///
  /// In en, this message translates to:
  /// **'Item not found'**
  String get itemNotFound;

  /// No description provided for @reportedBy.
  ///
  /// In en, this message translates to:
  /// **'Reported by'**
  String get reportedBy;

  /// No description provided for @posted.
  ///
  /// In en, this message translates to:
  /// **'Posted'**
  String get posted;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description provided.'**
  String get noDescription;

  /// No description provided for @noContact.
  ///
  /// In en, this message translates to:
  /// **'No contact provided'**
  String get noContact;

  /// No description provided for @markAsRecovered.
  ///
  /// In en, this message translates to:
  /// **'Mark as Recovered'**
  String get markAsRecovered;

  /// No description provided for @markRecoveredConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark this item as recovered?'**
  String get markRecoveredConfirm;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @statusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated!'**
  String get statusUpdated;

  /// No description provided for @markAsReturned.
  ///
  /// In en, this message translates to:
  /// **'Mark as Returned'**
  String get markAsReturned;

  /// No description provided for @deleteReportQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this report?'**
  String get deleteReportQuestion;

  /// No description provided for @iFoundThis.
  ///
  /// In en, this message translates to:
  /// **'I Found This Item'**
  String get iFoundThis;

  /// No description provided for @thisIsMyItem.
  ///
  /// In en, this message translates to:
  /// **'This Is My Item'**
  String get thisIsMyItem;

  /// No description provided for @claimItem.
  ///
  /// In en, this message translates to:
  /// **'Claim Item'**
  String get claimItem;

  /// No description provided for @confirmOwnership.
  ///
  /// In en, this message translates to:
  /// **'Confirm Ownership'**
  String get confirmOwnership;

  /// No description provided for @claimConfirmFound.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you found this item? The owner will be notified.'**
  String get claimConfirmFound;

  /// No description provided for @claimConfirmOwner.
  ///
  /// In en, this message translates to:
  /// **'Are you sure this is your item? The finder will be notified.'**
  String get claimConfirmOwner;

  /// No description provided for @itemClaimed.
  ///
  /// In en, this message translates to:
  /// **'Item claimed successfully!'**
  String get itemClaimed;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @noEvents.
  ///
  /// In en, this message translates to:
  /// **'No events yet'**
  String get noEvents;

  /// No description provided for @shareSoon.
  ///
  /// In en, this message translates to:
  /// **'Share feature coming soon!'**
  String get shareSoon;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @tapHeartAdd.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any item to add it to favorites'**
  String get tapHeartAdd;

  /// No description provided for @reportHistory.
  ///
  /// In en, this message translates to:
  /// **'Report History'**
  String get reportHistory;

  /// No description provided for @searchReports.
  ///
  /// In en, this message translates to:
  /// **'Search reports...'**
  String get searchReports;

  /// No description provided for @noReportsFound.
  ///
  /// In en, this message translates to:
  /// **'No reports found'**
  String get noReportsFound;

  /// No description provided for @archivedItems.
  ///
  /// In en, this message translates to:
  /// **'Archived Items'**
  String get archivedItems;

  /// No description provided for @noArchived.
  ///
  /// In en, this message translates to:
  /// **'No archived items'**
  String get noArchived;

  /// No description provided for @autoArchived.
  ///
  /// In en, this message translates to:
  /// **'Items are automatically archived after recovery'**
  String get autoArchived;

  /// No description provided for @deleteArchived.
  ///
  /// In en, this message translates to:
  /// **'Delete Archived Item'**
  String get deleteArchived;

  /// No description provided for @actionUndone.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone.'**
  String get actionUndone;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @rewardPoints.
  ///
  /// In en, this message translates to:
  /// **'Reward Points'**
  String get rewardPoints;

  /// No description provided for @currentBadge.
  ///
  /// In en, this message translates to:
  /// **'Current Badge: {badge}'**
  String currentBadge(String badge);

  /// No description provided for @badgeProgress.
  ///
  /// In en, this message translates to:
  /// **'Badge Progress'**
  String get badgeProgress;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @pointsRequired.
  ///
  /// In en, this message translates to:
  /// **'{n} points required'**
  String pointsRequired(int n);

  /// No description provided for @howToEarn.
  ///
  /// In en, this message translates to:
  /// **'How to Earn Points'**
  String get howToEarn;

  /// No description provided for @reportLostItemBadge.
  ///
  /// In en, this message translates to:
  /// **'Report Lost Item'**
  String get reportLostItemBadge;

  /// No description provided for @plus10pts.
  ///
  /// In en, this message translates to:
  /// **'+10 pts'**
  String get plus10pts;

  /// No description provided for @reportFoundItemBadge.
  ///
  /// In en, this message translates to:
  /// **'Report Found Item'**
  String get reportFoundItemBadge;

  /// No description provided for @plus15pts.
  ///
  /// In en, this message translates to:
  /// **'+15 pts'**
  String get plus15pts;

  /// No description provided for @itemRecovered.
  ///
  /// In en, this message translates to:
  /// **'Item Recovered'**
  String get itemRecovered;

  /// No description provided for @plus25pts.
  ///
  /// In en, this message translates to:
  /// **'+25 pts'**
  String get plus25pts;

  /// No description provided for @dailyCheckin.
  ///
  /// In en, this message translates to:
  /// **'Daily Check-in'**
  String get dailyCheckin;

  /// No description provided for @plus5pts.
  ///
  /// In en, this message translates to:
  /// **'+5 pts'**
  String get plus5pts;

  /// No description provided for @smartMatches.
  ///
  /// In en, this message translates to:
  /// **'Smart Matches'**
  String get smartMatches;

  /// No description provided for @analyzingMatches.
  ///
  /// In en, this message translates to:
  /// **'Analyzing matches...'**
  String get analyzingMatches;

  /// No description provided for @comparingItems.
  ///
  /// In en, this message translates to:
  /// **'Comparing lost and found items'**
  String get comparingItems;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'No Matches Found'**
  String get noMatches;

  /// No description provided for @noMatchesDesc.
  ///
  /// In en, this message translates to:
  /// **'No potential matches found right now. New matches will appear automatically when items are reported.'**
  String get noMatchesDesc;

  /// No description provided for @potentialMatches.
  ///
  /// In en, this message translates to:
  /// **'{n} Potential Matches'**
  String potentialMatches(int n);

  /// No description provided for @aiResults.
  ///
  /// In en, this message translates to:
  /// **'AI-powered matching results'**
  String get aiResults;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @excellentMatch.
  ///
  /// In en, this message translates to:
  /// **'Excellent Match'**
  String get excellentMatch;

  /// No description provided for @goodMatch.
  ///
  /// In en, this message translates to:
  /// **'Good Match'**
  String get goodMatch;

  /// No description provided for @possibleMatch.
  ///
  /// In en, this message translates to:
  /// **'Possible Match'**
  String get possibleMatch;

  /// No description provided for @weakMatch.
  ///
  /// In en, this message translates to:
  /// **'Weak Match'**
  String get weakMatch;

  /// No description provided for @adminDashboard.
  ///
  /// In en, this message translates to:
  /// **'Admin Dashboard'**
  String get adminDashboard;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @lostItemsCount.
  ///
  /// In en, this message translates to:
  /// **'Lost Items'**
  String get lostItemsCount;

  /// No description provided for @foundItemsCount.
  ///
  /// In en, this message translates to:
  /// **'Found Items'**
  String get foundItemsCount;

  /// No description provided for @recoveryRate.
  ///
  /// In en, this message translates to:
  /// **'Recovery Rate'**
  String get recoveryRate;

  /// No description provided for @ofItemsRecovered.
  ///
  /// In en, this message translates to:
  /// **'of reported items recovered'**
  String get ofItemsRecovered;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage users'**
  String get manageUsers;

  /// No description provided for @manageItems.
  ///
  /// In en, this message translates to:
  /// **'Manage items'**
  String get manageItems;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @topLocations.
  ///
  /// In en, this message translates to:
  /// **'Top Locations'**
  String get topLocations;

  /// No description provided for @itemManagement.
  ///
  /// In en, this message translates to:
  /// **'Item Management'**
  String get itemManagement;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @markReturnedConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark as Returned?'**
  String get markReturnedConfirm;

  /// No description provided for @markRecoveredConfirmAdmin.
  ///
  /// In en, this message translates to:
  /// **'Mark as Recovered?'**
  String get markRecoveredConfirmAdmin;

  /// No description provided for @deleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this item? This cannot be undone.'**
  String get deleteItemConfirm;

  /// No description provided for @statusUpdated2.
  ///
  /// In en, this message translates to:
  /// **'Status updated'**
  String get statusUpdated2;

  /// No description provided for @failedToUpdate.
  ///
  /// In en, this message translates to:
  /// **'Failed to update'**
  String get failedToUpdate;

  /// No description provided for @itemDeleted.
  ///
  /// In en, this message translates to:
  /// **'Item deleted'**
  String get itemDeleted;

  /// No description provided for @failedToDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete'**
  String get failedToDelete;

  /// No description provided for @userManagement.
  ///
  /// In en, this message translates to:
  /// **'User Management'**
  String get userManagement;

  /// No description provided for @searchUsers.
  ///
  /// In en, this message translates to:
  /// **'Search users...'**
  String get searchUsers;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @blocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked'**
  String get blocked;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @blockUser.
  ///
  /// In en, this message translates to:
  /// **'Block User'**
  String get blockUser;

  /// No description provided for @unblockUser.
  ///
  /// In en, this message translates to:
  /// **'Unblock User'**
  String get unblockUser;

  /// No description provided for @deleteUser.
  ///
  /// In en, this message translates to:
  /// **'Delete User'**
  String get deleteUser;

  /// No description provided for @blockUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Block {name}?'**
  String blockUserConfirm(String name);

  /// No description provided for @unblockUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Unblock {name}?'**
  String unblockUserConfirm(String name);

  /// No description provided for @deleteUserConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? This cannot be undone.'**
  String deleteUserConfirm(String name);

  /// No description provided for @userBlocked.
  ///
  /// In en, this message translates to:
  /// **'{name} has been blocked'**
  String userBlocked(String name);

  /// No description provided for @userUnblocked.
  ///
  /// In en, this message translates to:
  /// **'{name} has been unblocked'**
  String userUnblocked(String name);

  /// No description provided for @userDeleted.
  ///
  /// In en, this message translates to:
  /// **'User deleted'**
  String get userDeleted;

  /// No description provided for @failedDeleteUser.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete user'**
  String get failedDeleteUser;

  /// No description provided for @allItems.
  ///
  /// In en, this message translates to:
  /// **'All Items'**
  String get allItems;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @reportItem.
  ///
  /// In en, this message translates to:
  /// **'Report Item'**
  String get reportItem;

  /// No description provided for @pts.
  ///
  /// In en, this message translates to:
  /// **'{n} pts'**
  String pts(int n);

  /// No description provided for @january.
  ///
  /// In en, this message translates to:
  /// **'January'**
  String get january;

  /// No description provided for @february.
  ///
  /// In en, this message translates to:
  /// **'February'**
  String get february;

  /// No description provided for @march.
  ///
  /// In en, this message translates to:
  /// **'March'**
  String get march;

  /// No description provided for @april.
  ///
  /// In en, this message translates to:
  /// **'April'**
  String get april;

  /// No description provided for @may.
  ///
  /// In en, this message translates to:
  /// **'May'**
  String get may;

  /// No description provided for @june.
  ///
  /// In en, this message translates to:
  /// **'June'**
  String get june;

  /// No description provided for @july.
  ///
  /// In en, this message translates to:
  /// **'July'**
  String get july;

  /// No description provided for @august.
  ///
  /// In en, this message translates to:
  /// **'August'**
  String get august;

  /// No description provided for @september.
  ///
  /// In en, this message translates to:
  /// **'September'**
  String get september;

  /// No description provided for @october.
  ///
  /// In en, this message translates to:
  /// **'October'**
  String get october;

  /// No description provided for @november.
  ///
  /// In en, this message translates to:
  /// **'November'**
  String get november;

  /// No description provided for @december.
  ///
  /// In en, this message translates to:
  /// **'December'**
  String get december;

  /// No description provided for @referralCode.
  ///
  /// In en, this message translates to:
  /// **'Referral Code (Optional)'**
  String get referralCode;

  /// No description provided for @referralCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Enter referral code'**
  String get referralCodeHint;

  /// No description provided for @referralCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Have a referral code? Enter it for bonus points!'**
  String get referralCodeOptional;

  /// No description provided for @yourReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Your Referral Code'**
  String get yourReferralCode;

  /// No description provided for @shareReferralCode.
  ///
  /// In en, this message translates to:
  /// **'Share your code with friends and earn bonus points'**
  String get shareReferralCode;

  /// No description provided for @referralStats.
  ///
  /// In en, this message translates to:
  /// **'Referral Stats'**
  String get referralStats;

  /// No description provided for @friendsReferred.
  ///
  /// In en, this message translates to:
  /// **'Friends Referred'**
  String get friendsReferred;

  /// No description provided for @shareCode.
  ///
  /// In en, this message translates to:
  /// **'Share Code'**
  String get shareCode;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Referral code copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @referralBonus.
  ///
  /// In en, this message translates to:
  /// **'Referral Bonus'**
  String get referralBonus;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'ml', 'ta', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'ml':
      return AppLocalizationsMl();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
