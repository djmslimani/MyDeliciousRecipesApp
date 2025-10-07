import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// The default language
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language;

  /// To find something
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  ///
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  ///
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  ///
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  ///
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  ///
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  ///
  ///
  /// In en, this message translates to:
  /// **'Search for a recipe'**
  String get searchfor;

  ///
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  ///
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  ///
  ///
  /// In en, this message translates to:
  /// **'This password is used to protect recipes from modification or deletion, from someone who is not familiar with the App, it can be modified or deleted at any time.'**
  String get passwordinfo;

  ///
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get enterpassword;

  ///
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  ///
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave?'**
  String get exitmessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Modification or deletion'**
  String get editordelete;

  /// delete
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  ///
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  ///
  ///
  /// In en, this message translates to:
  /// **'You have already added the password! If you want to change it, press Change or press Delete to delete it.'**
  String get modifyordeletepasswordinfo;

  ///
  ///
  /// In en, this message translates to:
  /// **'Old password'**
  String get oldpassword;

  ///
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newpassword;

  ///
  ///
  /// In en, this message translates to:
  /// **'Cannot be empty!'**
  String get cannotbeemty;

  ///
  ///
  /// In en, this message translates to:
  /// **'No results found!'**
  String get noresults;

  ///
  ///
  /// In en, this message translates to:
  /// **'Number of recipes found is:'**
  String get numberofresults;

  ///
  ///
  /// In en, this message translates to:
  /// **'Password added.'**
  String get passwordadded;

  ///
  ///
  /// In en, this message translates to:
  /// **'Password changed.'**
  String get passwordchanged;

  ///
  ///
  /// In en, this message translates to:
  /// **'The old password is wrong!'**
  String get wrongpassword;

  ///
  ///
  /// In en, this message translates to:
  /// **'Password deleted.'**
  String get passworddeleted;

  ///
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  ///
  ///
  /// In en, this message translates to:
  /// **'Desserts'**
  String get desserts;

  ///
  ///
  /// In en, this message translates to:
  /// **'My Delicious Recipes'**
  String get deliciousrecipes;

  ///
  ///
  /// In en, this message translates to:
  /// **'The purpose of this app is to save the prepared recipes and make them available in anytime and anywhere.'**
  String get apppurpose;

  ///
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  ///
  ///
  /// In en, this message translates to:
  /// **'Version: 1.0.0.'**
  String get versionnumber;

  ///
  ///
  /// In en, this message translates to:
  /// **'Release date: March, 2023.'**
  String get releasedate;

  ///
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  ///
  ///
  /// In en, this message translates to:
  /// **'If you require any further information, feel free to contact me:'**
  String get contactemail;

  ///
  ///
  /// In en, this message translates to:
  /// **'You have not chosen a picture!'**
  String get nopicture;

  ///
  ///
  /// In en, this message translates to:
  /// **'Recipe type'**
  String get chooserecipe;

  ///
  ///
  /// In en, this message translates to:
  /// **'This recipe exists!'**
  String get recipeexists;

  /// successfully added.
  ///
  /// In en, this message translates to:
  /// **'New recipe successfully added.'**
  String get successfullysaved;

  /// addarecipe
  ///
  /// In en, this message translates to:
  /// **'Recipe'**
  String get recipe;

  ///
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  ///
  ///
  /// In en, this message translates to:
  /// **'Method'**
  String get method;

  ///
  ///
  /// In en, this message translates to:
  /// **'Add a picture'**
  String get addapicture;

  ///
  ///
  /// In en, this message translates to:
  /// **'Select the image source'**
  String get imagesource;

  ///
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  ///
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// successfully changed.
  ///
  /// In en, this message translates to:
  /// **'Successfully changed.'**
  String get successfullychanged;

  ///
  ///
  /// In en, this message translates to:
  /// **'Change the picture'**
  String get changethepicture;

  ///
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete it?'**
  String get deletemessage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Do you want to preserve the existing recipes?'**
  String get preserverecipesmessage;

  /// Successfully deleted.
  ///
  /// In en, this message translates to:
  /// **'Successfully deleted.'**
  String get successfullyDeleted;

  ///
  ///
  /// In en, this message translates to:
  /// **'You have not chosen the recipe type!'**
  String get norecipetype;

  ///
  ///
  /// In en, this message translates to:
  /// **'Secuirity'**
  String get secuirity;

  ///
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get applanguage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  ///
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabiclanguage;

  ///
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishlanguage;

  ///
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get frenchlanguage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Internal storage'**
  String get internalstorage;

  ///
  ///
  /// In en, this message translates to:
  /// **'External storage'**
  String get externalstorage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Empty folder.'**
  String get emptyfolder;

  ///
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  ///
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  ///
  ///
  /// In en, this message translates to:
  /// **'Unsupported image type!'**
  String get unsupportedimagetype;

  ///
  ///
  /// In en, this message translates to:
  /// **'Unsupported file type!'**
  String get unsupportedfiletype;

  ///
  ///
  /// In en, this message translates to:
  /// **'This is not a valid file!'**
  String get notavalidfile;

  ///
  ///
  /// In en, this message translates to:
  /// **'Restore completed successfully'**
  String get restorecompletedsuccessfully;

  ///
  ///
  /// In en, this message translates to:
  /// **'Backup completed successfully'**
  String get backupcompletedsuccessfully;

  ///
  ///
  /// In en, this message translates to:
  /// **'Copying, please wait...'**
  String get copyingpleasewait;

  ///
  ///
  /// In en, this message translates to:
  /// **'Restoring, please wait...'**
  String get restoringpleasewait;

  ///
  ///
  /// In en, this message translates to:
  /// **'There is no recipe to backup!'**
  String get norecipetobackup;

  ///
  ///
  /// In en, this message translates to:
  /// **'Cloud storage'**
  String get cloudstorage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Local storage'**
  String get localstorage;

  ///
  ///
  /// In en, this message translates to:
  /// **'Local backup path:'**
  String get backupinfo;

  ///
  ///
  /// In en, this message translates to:
  /// **'- By clicking the restore button you will open the default backup folder, then choose the backup to be restored. You can also search for another backup on your device (local storage or SD card).\n- You can rename the backup file, but please keep the .MyDeliciousRecipesBackup part of the filename intact.'**
  String get restoreinfo;

  ///
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themes;

  ///
  ///
  /// In en, this message translates to:
  /// **'Voice typing'**
  String get voicetyping;

  ///
  ///
  /// In en, this message translates to:
  /// **'- This feature requires an internet connection.'**
  String get voicetypinginfo1;

  ///
  ///
  /// In en, this message translates to:
  /// **'- At the top of your keyboard, tap Microphone '**
  String get voicetypinginfo2;

  ///
  ///
  /// In en, this message translates to:
  /// **' Then, dictate your text.'**
  String get voicetypinginfo3;

  ///
  ///
  /// In en, this message translates to:
  /// **'- If the Microphone icon is missing from your Keyboard, tap Settings '**
  String get voicetypinginfo4;

  ///
  ///
  /// In en, this message translates to:
  /// **' Tap Voice typing, then turn Use voice typing on. The Microphone should now be available.'**
  String get voicetypinginfo5;

  ///
  ///
  /// In en, this message translates to:
  /// **'- If the Settings icon is missing from your Keyboard, touch and hold the comma \',\' in the bottom left of your keyboard, then drag your finger to the Settings icon.'**
  String get voicetypinginfo6;

  ///
  ///
  /// In en, this message translates to:
  /// **'Share (*.pdf)'**
  String get shareaspdf;

  ///
  ///
  /// In en, this message translates to:
  /// **'Share (*.MyDeliciousRecipesBackup)'**
  String get shareasappformat;

  ///
  ///
  /// In en, this message translates to:
  /// **'Operation completed'**
  String get operationcompleted;

  ///
  ///
  /// In en, this message translates to:
  /// **'This permission is required'**
  String get requiredpermission;

  ///
  ///
  /// In en, this message translates to:
  /// **'Grant the permission'**
  String get grantpermission;

  ///
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appsettings;

  ///
  ///
  /// In en, this message translates to:
  /// **'You need to give this permission from the App Settings.'**
  String get grantpermissionfromappsettings;

  ///
  ///
  /// In en, this message translates to:
  /// **'App Settings -> Permissions -> Storage -> Allow'**
  String get grantpermissionmethod;

  ///
  ///
  /// In en, this message translates to:
  /// **'This feature requires more than one recipe.'**
  String get recipesnumber;

  ///
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacypolicy;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
