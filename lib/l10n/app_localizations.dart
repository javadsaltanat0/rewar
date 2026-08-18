import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// App localization for English, Kurdish (Sorani) and Arabic.
///
/// Hand-written (rather than generated) so it stays robust across Flutter
/// versions and gives full control over the Kurdish locale, which Flutter's
/// built-in localizations don't cover (handled via the fallback delegates
/// below — Kurdish reuses Arabic's Material/RTL localizations).
///
/// Access with `AppLocalizations.of(context)`.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ku'), // Kurdish (Sorani)
    Locale('ar'),
  ];

  /// The full delegate list for [MaterialApp] (and tests). Kurdish fallback
  /// delegates come first so they win for `ku`; everything else is handled by
  /// the standard global delegates.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        _KurdishMaterialDelegate(),
        _KurdishCupertinoDelegate(),
        _KurdishWidgetsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ];

  static const Map<String, Map<String, String>>
  _values = <String, Map<String, String>>{
    'en': <String, String>{
      'chooseYourLanguage': 'Choose Your Language',
      'selectLanguageToContinue': 'Select a language to continue',
      'logIn': 'Log In',
      'email': 'Email',
      'password': 'Password',
      'forgetPassword': 'Forget Password',
      'orLabel': 'Or',
      'dontHaveAccount': "Don't have an account? ",
      'registerNow': 'Register Now',
      'continueAsGuest': 'Continue as Guest',
      'emailRequired': 'Please enter your email',
      'emailInvalid': 'Enter a valid email address',
      'passwordRequired': 'Please enter your password',
      'forgetPasswordSubtitle':
          'Please select your contact details and we will send a '
          'verification code to reset your password.',
      'phoneNumber': 'Phone number',
      'emailAddress': 'Email address',
      'sendCode': 'Send Code',
      'selectContactMethod': 'Choose phone or email first',
      'verificationCode': 'Verification Code',
      // {dest} is replaced with the masked phone/email, rendered in bold.
      'verificationSubtitle':
          'Enter the 6-digit code we just sent to {dest} to reset your '
          'password.',
      'didntReceiveCode': "Didn't receive the code? ",
      'resendNow': 'Resend now',
      'resendIn': 'Resend in {seconds}s',
      'verify': 'Verify',
      'codeIncomplete': 'Enter all 6 digits of the code',
      'codeIncorrect': 'That code is not correct. Please try again.',
      'codeExpired': 'This code has expired. Request a new one.',
      'tooManyAttempts': 'Too many attempts. Please wait before trying again.',
      'codeResentPhone': 'A new code has been sent by SMS',
      'codeResentEmail': 'A new code has been sent to your email',
      'sendCodeFailed': "We couldn't send the code. Please try again.",
      'networkError': 'No connection. Check your network and try again.',
      'resetPassword': 'Reset Password',
      'resetPasswordSubtitle':
          'At least 8 characters, with uppercase, lowercase and special '
          'character.',
      'newPassword': 'New Password',
      'confirmPassword': 'Confirm Password',
      'updatePassword': 'Update Password',
      'passwordTooShort': 'Use at least 8 characters',
      'passwordNeedsUppercase': 'Add at least one uppercase letter',
      'passwordNeedsLowercase': 'Add at least one lowercase letter',
      'passwordNeedsSpecial': 'Add at least one special character',
      'confirmPasswordRequired': 'Please re-enter the new password',
      'passwordsDontMatch': 'The two passwords do not match',
      'passwordUpdated': 'Password updated. Please log in.',
      'passwordUpdateFailed':
          "We couldn't update your password. Please try again.",
      'passwordTooWeak': 'Please choose a stronger password',
      'sessionExpired': 'Your session expired. Please start again.',
      // --- Register screen ---
      'register': 'Register',
      'fullName': 'Full Name',
      'age': 'Age',
      'gender': 'Gender',
      'genderMale': 'Male',
      'genderFemale': 'Female',
      'genderOther': 'Other',
      'genderOptional': 'Gender (optional)',
      'alreadyHaveAccount': 'Already have an Account? ',
      'logInHere': 'Log In here',
      'passwordHint':
          'At least 8 characters, with uppercase, lowercase and special '
          'character.',
      'acceptTerms': 'I agree to the Terms of Service and Privacy Policy',
      'termsRequired': 'Please accept the Terms and Privacy Policy',
      'fullNameRequired': 'Please enter your full name',
      'fullNameTooShort': 'Please enter your full name',
      'dateOfBirthRequired': 'Please choose your date of birth',
      'mustBe18': 'You must be at least 18 to create an account',
      'phoneRequired': 'Please enter your phone number',
      'phoneInvalid': 'Enter a valid phone number',
      'selectCountryCode': 'Country code',
      'accountCreated': 'Account created. Please log in.',
      'registerFailed': "We couldn't create your account. Please try again.",
      'emailInUse': 'An account already exists with this email',
      'phoneInUse': 'An account already exists with this phone number',
      'verifyNumberSubtitle':
          'Enter the 6-digit code we just sent to {dest} to verify your '
          'number.',
      // --- Terms of Service screen ---
      'termsOfService': 'Terms of Service',
      'termsAgreeCheckbox':
          'I have read and agree to the Terms of Service and Privacy Policy.',
      'continueLabel': 'Continue',
      'lastUpdated': 'Last updated: {date}',
      'termsLoadFailed': "We couldn't load the Terms. Please try again.",
      'tryAgain': 'Try again',
      'termsNotReviewed':
          'Draft wording — pending legal review. Not for release.',
      // --- Account Setup screen ---
      'accountSetup': 'Account Setup',
      'accountSetupSubtitle':
          'Finish your account setup by uploading profile picture and set '
          'your username.',
      'username': 'Username',
      'createAccount': 'Create Account',
      'chooseFromGallery': 'Choose from gallery',
      'takePhoto': 'Take a photo',
      'removePhoto': 'Remove photo',
      'usernameRequired': 'Please enter a username',
      'usernameTooShort': 'Use at least 2 characters',
      'imageTooLarge': 'That picture is too large. Choose one under 5 MB.',
      'imagePickFailed': "We couldn't open that picture. Please try again.",
      'profileSaveFailed': "We couldn't save your profile. Please try again.",
      'cameraPermissionDenied':
          'Camera access is off. Turn it on in Settings to take a photo.',
      'galleryPermissionDenied':
          'Photo access is off. Turn it on in Settings to choose a picture.',
      // --- Register Complete screen ---
      'registerComplete': 'Register Complete!',
      'registerCompleteSubtitle':
          'You have successfully created your account. Welcome!',
      'explore': 'Explore',
      // --- Onboarding (3-slide intro) ---
      // The title is two separate lines because each uses a different font:
      // line 1 Corbel Regular, line 2 Unbounded Medium.
      'onboardingTitleLine1': 'Discover',
      'onboardingTitleLine2': 'Kurdistan',
      // The only hard line break is before the closing sentence; the rest is
      // left to wrap naturally so longer translations don't break the layout.
      'onboardingBody1':
          'Explore beautiful valleys, rivers, and mountain trails that few '
          'travelers ever reach.\nAll in one app.',
      // Slide 2. One sentence with no hard break — it wraps to two lines on
      // its own, as the reference shows.
      'onboardingTitle2Line1': 'Fly to',
      'onboardingTitle2Line2': 'Kurdistan',
      'onboardingBody2':
          'Compare flights, pick your dates and book your ticket in minutes.',
      // Slide 3.
      'onboardingTitle3Line1': 'Your Ride',
      'onboardingTitle3Line2': 'Is Ready !',
      'onboardingBody3':
          'Rent a car and reach every corner of Kurdistan on your own '
          'schedule.',
      'onboardingNext': 'Next',
      // --- Home screen ---
      'goodMorning': 'Good morning',
      'goodAfternoon': 'Good afternoon',
      'goodEvening': 'Good evening',
      'goodNight': 'Good night',
      'dearUser': 'Dear User',
      'whereWouldYouLikeToGo': 'Where would you like to go?',
      'planYourJourney': 'Plan your journey',
      'exploreNature': 'Explore Nature',
      'exploreNatureHint': 'Trails, lakes & breathtaking parks.',
      'whereToStay': 'Where to Stay',
      'whereToStayHint': 'Hotels, cabins & unique stays',
      'bestPrice': 'Best Price',
      'carRental': 'Car Rental',
      'carRentalHint': 'Find the perfect car for your adventure',
      'findACar': 'Find a Car',
      'flightTicketing': 'Flight Ticketing',
      'flightTicketingHint': 'Cheap flights, easy booking, secure payments',
      'findFlight': 'Find Flight',
      'exploreToursTitle': 'Explore Tours',
      'exploreToursHint': 'Local experiences, hidden gems & expert guides',
      'findTours': 'Find Tours',
      'placesCount': '{count}+ places',
      'navHome': 'Home',
      'navTrips': 'Trips',
      'navMap': 'Map',
      'navSaved': 'Saved',
      'featuredLoadFailed': "Couldn't load featured destinations",
      'featuredEmpty': 'Nothing is featured yet',
      'signInToSave': 'Sign in to save favourites',
      'signInToSaveBody':
          'Create an account or log in to keep your favourite places.',
      'notNow': 'Not now',
      'addedToFavorites': 'Added to your favourites',
      'removedFromFavorites': 'Removed from your favourites',
      'favoriteFailed': "Couldn't update your favourites",
      'comingSoon': 'Coming soon',
      'mapOpenFailed': "Couldn't open the maps app",
      'menu': 'Menu',
      'changeLanguage': 'Change language',
    },
    'ku': <String, String>{
      'chooseYourLanguage': 'زمانەکەت هەڵبژێرە',
      'selectLanguageToContinue': 'زمانێک هەڵبژێرە بۆ بەردەوامبوون',
      'logIn': 'چوونەژوورەوە',
      'email': 'ئیمەیڵ',
      'password': 'وشەی نهێنی',
      'forgetPassword': 'وشەی نهێنیت لەبیرچووە؟',
      'orLabel': 'یان',
      'dontHaveAccount': 'هەژمارت نییە؟ ',
      'registerNow': 'خۆت تۆمار بکە',
      'continueAsGuest': 'وەک میوان بەردەوام بە',
      'emailRequired': 'تکایە ئیمەیڵەکەت بنووسە',
      'emailInvalid': 'ئیمەیڵێکی دروست بنووسە',
      'passwordRequired': 'تکایە وشەی نهێنییەکەت بنووسە',
      'forgetPasswordSubtitle':
          'تکایە زانیارییەکانی پەیوەندیت هەڵبژێرە و ئێمە کۆدێکی '
          'پشتڕاستکردنەوەت بۆ دەنێرین بۆ ڕێکخستنەوەی وشەی نهێنی.',
      'phoneNumber': 'ژمارەی مۆبایل',
      'emailAddress': 'ناونیشانی ئیمەیڵ',
      'sendCode': 'کۆد بنێرە',
      'selectContactMethod': 'سەرەتا مۆبایل یان ئیمەیڵ هەڵبژێرە',
      'verificationCode': 'کۆدی پشتڕاستکردنەوە',
      'verificationSubtitle':
          'ئەو کۆدە ٦ ژمارەییە بنووسە کە ئێستا ناردمان بۆ {dest} بۆ '
          'ڕێکخستنەوەی وشەی نهێنییەکەت.',
      'didntReceiveCode': 'کۆدەکەت پێنەگەیشت؟ ',
      'resendNow': 'دووبارە بینێرە',
      'resendIn': 'دووبارە ناردن لە {seconds} چرکەدا',
      'verify': 'پشتڕاستکردنەوە',
      'codeIncomplete': 'هەر ٦ ژمارەکەی کۆدەکە بنووسە',
      'codeIncorrect': 'ئەم کۆدە دروست نییە. تکایە دووبارە هەوڵ بدەوە.',
      'codeExpired': 'ئەم کۆدە بەسەرچووە. کۆدێکی نوێ بخوازە.',
      'tooManyAttempts':
          'هەوڵی زۆر درا. تکایە پێش هەوڵدانەوە کەمێک چاوەڕێ بکە.',
      'codeResentPhone': 'کۆدێکی نوێ بە نامەی کورت نێردرا',
      'codeResentEmail': 'کۆدێکی نوێ بۆ ئیمەیڵەکەت نێردرا',
      'sendCodeFailed': 'نەمانتوانی کۆدەکە بنێرین. تکایە دووبارە هەوڵ بدەوە.',
      'networkError':
          'پەیوەندی نییە. تکایە ئینتەرنێتەکەت بپشکنە و دووبارە هەوڵ بدەوە.',
      'resetPassword': 'ڕێکخستنەوەی وشەی نهێنی',
      'resetPasswordSubtitle':
          'لانیکەم ٨ پیت، بە پیتی گەورە و پیتی بچووک و هێمایەکی تایبەت.',
      'newPassword': 'وشەی نهێنی نوێ',
      'confirmPassword': 'دووبارەکردنەوەی وشەی نهێنی',
      'updatePassword': 'نوێکردنەوەی وشەی نهێنی',
      'passwordTooShort': 'لانیکەم ٨ پیت بەکاربهێنە',
      'passwordNeedsUppercase': 'لانیکەم یەک پیتی گەورە زیاد بکە',
      'passwordNeedsLowercase': 'لانیکەم یەک پیتی بچووک زیاد بکە',
      'passwordNeedsSpecial': 'لانیکەم یەک هێمای تایبەت زیاد بکە',
      'confirmPasswordRequired': 'تکایە وشەی نهێنییە نوێیەکە دووبارە بنووسە',
      'passwordsDontMatch': 'هەردوو وشەی نهێنییەکە وەک یەک نین',
      'passwordUpdated': 'وشەی نهێنی نوێکرایەوە. تکایە بچۆرە ژوورەوە.',
      'passwordUpdateFailed':
          'نەمانتوانی وشەی نهێنییەکەت نوێ بکەینەوە. تکایە دووبارە هەوڵ بدەوە.',
      'passwordTooWeak': 'تکایە وشەیەکی نهێنی بەهێزتر هەڵبژێرە',
      'sessionExpired':
          'دانیشتنەکەت بەسەرچوو. تکایە لە سەرەتاوە دەست پێ بکەوە.',
      // --- Register screen ---
      'register': 'خۆتۆمارکردن',
      'fullName': 'ناوی تەواو',
      'age': 'تەمەن',
      'gender': 'ڕەگەز',
      'genderMale': 'نێر',
      'genderFemale': 'مێ',
      'genderOther': 'هیتر',
      'genderOptional': 'ڕەگەز (ئارەزوومەندانە)',
      'alreadyHaveAccount': 'پێشتر هەژمارت هەیە؟ ',
      'logInHere': 'لێرە بچۆرە ژوورەوە',
      'passwordHint':
          'لانیکەم ٨ پیت، بە پیتی گەورە و پیتی بچووک و هێمایەکی تایبەت.',
      'acceptTerms': 'ڕازیم بە مەرجەکانی بەکارهێنان و سیاسەتی تایبەتمەندی',
      'termsRequired': 'تکایە ڕەزامەندی بدە بە مەرجەکان و سیاسەتی تایبەتمەندی',
      'fullNameRequired': 'تکایە ناوی تەواوت بنووسە',
      'fullNameTooShort': 'تکایە ناوی تەواوت بنووسە',
      'dateOfBirthRequired': 'تکایە بەرواری لەدایکبوونت هەڵبژێرە',
      'mustBe18': 'دەبێت لانیکەم تەمەنت ١٨ ساڵ بێت بۆ دروستکردنی هەژمار',
      'phoneRequired': 'تکایە ژمارەی مۆبایلەکەت بنووسە',
      'phoneInvalid': 'ژمارەیەکی مۆبایلی دروست بنووسە',
      'selectCountryCode': 'کۆدی وڵات',
      'accountCreated': 'هەژمارەکە دروستکرا. تکایە بچۆرە ژوورەوە.',
      'registerFailed':
          'نەمانتوانی هەژمارەکەت دروست بکەین. تکایە دووبارە هەوڵ بدەوە.',
      'emailInUse': 'هەژمارێک بەم ئیمەیڵە هەیە',
      'phoneInUse': 'هەژمارێک بەم ژمارە مۆبایلە هەیە',
      'verifyNumberSubtitle':
          'ئەو کۆدە ٦ ژمارەییە بنووسە کە ئێستا ناردمان بۆ {dest} بۆ '
          'پشتڕاستکردنەوەی ژمارەکەت.',
      // --- Terms of Service screen ---
      'termsOfService': 'مەرجەکانی بەکارهێنان',
      'termsAgreeCheckbox':
          'خوێندمەوە و ڕازیم بە مەرجەکانی بەکارهێنان و سیاسەتی تایبەتمەندی.',
      'continueLabel': 'بەردەوامبوون',
      'lastUpdated': 'دوایین نوێکردنەوە: {date}',
      'termsLoadFailed':
          'نەمانتوانی مەرجەکان باربکەین. تکایە دووبارە هەوڵ بدەوە.',
      'tryAgain': 'دووبارە هەوڵ بدەوە',
      'termsNotReviewed':
          'دەقی سەرەتایی — چاوەڕوانی پێداچوونەوەی یاسایی. بۆ بڵاوکردنەوە نییە.',
      // --- Account Setup screen ---
      'accountSetup': 'ڕێکخستنی هەژمار',
      'accountSetupSubtitle':
          'ڕێکخستنی هەژمارەکەت تەواو بکە بە بارکردنی وێنەی پرۆفایل و '
          'دیارکردنی ناوی بەکارهێنەر.',
      'username': 'ناوی بەکارهێنەر',
      'createAccount': 'دروستکردنی هەژمار',
      'chooseFromGallery': 'لە گەلەری هەڵبژێرە',
      'takePhoto': 'وێنەیەک بگرە',
      'removePhoto': 'وێنەکە لاببە',
      'usernameRequired': 'تکایە ناوی بەکارهێنەر بنووسە',
      'usernameTooShort': 'لانیکەم ٢ پیت بەکاربهێنە',
      'imageTooLarge':
          'ئەم وێنەیە زۆر گەورەیە. یەکێک هەڵبژێرە کە لە ٥ مێگابایت کەمتر بێت.',
      'imagePickFailed':
          'نەمانتوانی ئەم وێنەیە بکەینەوە. تکایە دووبارە هەوڵ بدەوە.',
      'profileSaveFailed':
          'نەمانتوانی پرۆفایلەکەت پاشەکەوت بکەین. تکایە دووبارە هەوڵ بدەوە.',
      'cameraPermissionDenied':
          'دەستڕاگەیشتن بە کامێرا کوژاوەتەوە. لە ڕێکخستنەکان بیکەوە.',
      'galleryPermissionDenied':
          'دەستڕاگەیشتن بە وێنەکان کوژاوەتەوە. لە ڕێکخستنەکان بیکەوە.',
      // --- Register Complete screen ---
      'registerComplete': 'تۆمارکردن تەواو بوو!',
      'registerCompleteSubtitle':
          'بە سەرکەوتوویی هەژمارەکەت دروستکرا. بەخێربێیت!',
      'explore': 'گەڕان',
      // --- Onboarding (3-slide intro) ---
      'onboardingTitleLine1': 'بدۆزەرەوە',
      'onboardingTitleLine2': 'کوردستان',
      'onboardingBody1':
          'بگەڕێ بەناو دۆڵە جوانەکان و ڕووبارەکان و ڕێڕەوە شاخاوییەکاندا کە '
          'کەم گەشتیار پێیان دەگات.\nهەمووی لە یەک ئەپدا.',
      'onboardingTitle2Line1': 'بفڕە بۆ',
      'onboardingTitle2Line2': 'کوردستان',
      'onboardingBody2':
          'بەراوردی فڕینەکان بکە، بەرواری خۆت هەڵبژێرە و لە چەند خولەکێکدا '
          'بلیتەکەت تۆمار بکە.',
      'onboardingTitle3Line1': 'ئۆتۆمبێلەکەت',
      'onboardingTitle3Line2': 'ئامادەیە !',
      'onboardingBody3':
          'ئۆتۆمبێلێک بەکرێ بگرە و بەپێی پلانی خۆت بگە بە هەموو گۆشەیەکی '
          'کوردستان.',
      'onboardingNext': 'دواتر',
      // --- Home screen ---
      'goodMorning': 'بەیانیت باش',
      'goodAfternoon': 'نیوەڕۆت باش',
      'goodEvening': 'ئێوارەت باش',
      'goodNight': 'شەوت باش',
      'dearUser': 'بەکارهێنەری خۆشەویست',
      'whereWouldYouLikeToGo': 'دەتەوێت بۆ کوێ بچیت؟',
      'planYourJourney': 'گەشتەکەت پلان بکە',
      'exploreNature': 'گەڕان بە سروشتدا',
      'exploreNatureHint': 'ڕێڕەوەکان، دەریاچەکان و پارکە سەرنجڕاکێشەکان.',
      'whereToStay': 'شوێنی مانەوە',
      'whereToStayHint': 'هوتێل، کوخ و شوێنی مانەوەی تایبەت',
      'bestPrice': 'باشترین نرخ',
      'carRental': 'بەکرێدانی ئۆتۆمبێل',
      'carRentalHint': 'ئۆتۆمبێلی گونجاو بۆ سەرکێشییەکەت بدۆزەرەوە',
      'findACar': 'ئۆتۆمبێل بدۆزەرەوە',
      'flightTicketing': 'بلیتی فڕۆکە',
      'flightTicketingHint': 'فڕینی هەرزان، حیجزی ئاسان، پارەدانی پارێزراو',
      'findFlight': 'فڕین بدۆزەرەوە',
      'exploreToursTitle': 'گەڕان بە گەشتەکاندا',
      'exploreToursHint': 'ئەزموونی ناوخۆیی، شوێنە شاراوەکان و ڕێبەری شارەزا',
      'findTours': 'گەشت بدۆزەرەوە',
      'placesCount': '{count}+ شوێن',
      'navHome': 'ماڵەوە',
      'navTrips': 'گەشتەکان',
      'navMap': 'نەخشە',
      'navSaved': 'پاشەکەوتکراو',
      'featuredLoadFailed': 'نەتوانرا شوێنە هەڵبژێردراوەکان باربکرێن',
      'featuredEmpty': 'هێشتا هیچ شوێنێکی هەڵبژێردراو نییە',
      'signInToSave': 'بچۆ ژوورەوە بۆ پاشەکەوتکردن',
      'signInToSaveBody':
          'هەژمارێک دروست بکە یان بچۆ ژوورەوە بۆ هێشتنەوەی شوێنە '
          'دڵخوازەکانت.',
      'notNow': 'ئێستا نا',
      'addedToFavorites': 'زیادکرا بۆ دڵخوازەکانت',
      'removedFromFavorites': 'لابرا لە دڵخوازەکانت',
      'favoriteFailed': 'نەتوانرا دڵخوازەکانت نوێ بکرێنەوە',
      'comingSoon': 'بەم زووانە',
      'mapOpenFailed': 'نەتوانرا ئەپی نەخشە بکرێتەوە',
      'menu': 'لیستە',
      'changeLanguage': 'گۆڕینی زمان',
    },
    'ar': <String, String>{
      'chooseYourLanguage': 'اختر لغتك',
      'selectLanguageToContinue': 'اختر لغة للمتابعة',
      'logIn': 'تسجيل الدخول',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'forgetPassword': 'نسيت كلمة المرور؟',
      'orLabel': 'أو',
      'dontHaveAccount': 'ليس لديك حساب؟ ',
      'registerNow': 'سجّل الآن',
      'continueAsGuest': 'المتابعة كضيف',
      'emailRequired': 'الرجاء إدخال بريدك الإلكتروني',
      'emailInvalid': 'أدخل بريدًا إلكترونيًا صالحًا',
      'passwordRequired': 'الرجاء إدخال كلمة المرور',
      'forgetPasswordSubtitle':
          'يرجى اختيار بيانات الاتصال الخاصة بك وسنرسل إليك رمز تحقق '
          'لإعادة تعيين كلمة المرور.',
      'phoneNumber': 'رقم الهاتف',
      'emailAddress': 'البريد الإلكتروني',
      'sendCode': 'إرسال الرمز',
      'selectContactMethod': 'اختر الهاتف أو البريد الإلكتروني أولاً',
      'verificationCode': 'رمز التحقق',
      'verificationSubtitle':
          'أدخل الرمز المكوّن من ٦ أرقام الذي أرسلناه للتو إلى {dest} '
          'لإعادة تعيين كلمة المرور.',
      'didntReceiveCode': 'لم تستلم الرمز؟ ',
      'resendNow': 'إعادة الإرسال',
      'resendIn': 'إعادة الإرسال خلال {seconds} ثانية',
      'verify': 'تحقّق',
      'codeIncomplete': 'أدخل أرقام الرمز الستة كاملة',
      'codeIncorrect': 'هذا الرمز غير صحيح. يرجى المحاولة مرة أخرى.',
      'codeExpired': 'انتهت صلاحية هذا الرمز. اطلب رمزًا جديدًا.',
      'tooManyAttempts':
          'محاولات كثيرة جدًا. يرجى الانتظار قبل المحاولة مرة أخرى.',
      'codeResentPhone': 'تم إرسال رمز جديد عبر رسالة نصية',
      'codeResentEmail': 'تم إرسال رمز جديد إلى بريدك الإلكتروني',
      'sendCodeFailed': 'تعذّر إرسال الرمز. يرجى المحاولة مرة أخرى.',
      'networkError': 'لا يوجد اتصال. تحقّق من شبكتك ثم حاول مرة أخرى.',
      'resetPassword': 'إعادة تعيين كلمة المرور',
      'resetPasswordSubtitle':
          '٨ أحرف على الأقل، مع حرف كبير وحرف صغير ورمز خاص.',
      'newPassword': 'كلمة المرور الجديدة',
      'confirmPassword': 'تأكيد كلمة المرور',
      'updatePassword': 'تحديث كلمة المرور',
      'passwordTooShort': 'استخدم ٨ أحرف على الأقل',
      'passwordNeedsUppercase': 'أضف حرفًا كبيرًا واحدًا على الأقل',
      'passwordNeedsLowercase': 'أضف حرفًا صغيرًا واحدًا على الأقل',
      'passwordNeedsSpecial': 'أضف رمزًا خاصًا واحدًا على الأقل',
      'confirmPasswordRequired': 'يرجى إعادة إدخال كلمة المرور الجديدة',
      'passwordsDontMatch': 'كلمتا المرور غير متطابقتين',
      'passwordUpdated': 'تم تحديث كلمة المرور. يرجى تسجيل الدخول.',
      'passwordUpdateFailed':
          'تعذّر تحديث كلمة المرور. يرجى المحاولة مرة أخرى.',
      'passwordTooWeak': 'يرجى اختيار كلمة مرور أقوى',
      'sessionExpired': 'انتهت جلستك. يرجى البدء من جديد.',
      // --- Register screen ---
      'register': 'إنشاء حساب',
      'fullName': 'الاسم الكامل',
      'age': 'العمر',
      'gender': 'الجنس',
      'genderMale': 'ذكر',
      'genderFemale': 'أنثى',
      'genderOther': 'آخر',
      'genderOptional': 'الجنس (اختياري)',
      'alreadyHaveAccount': 'لديك حساب بالفعل؟ ',
      'logInHere': 'سجّل الدخول من هنا',
      'passwordHint': '٨ أحرف على الأقل، مع حرف كبير وحرف صغير ورمز خاص.',
      'acceptTerms': 'أوافق على شروط الخدمة وسياسة الخصوصية',
      'termsRequired': 'يرجى الموافقة على الشروط وسياسة الخصوصية',
      'fullNameRequired': 'يرجى إدخال اسمك الكامل',
      'fullNameTooShort': 'يرجى إدخال اسمك الكامل',
      'dateOfBirthRequired': 'يرجى اختيار تاريخ ميلادك',
      'mustBe18': 'يجب أن يكون عمرك ١٨ عامًا على الأقل لإنشاء حساب',
      'phoneRequired': 'يرجى إدخال رقم هاتفك',
      'phoneInvalid': 'أدخل رقم هاتف صالح',
      'selectCountryCode': 'رمز الدولة',
      'accountCreated': 'تم إنشاء الحساب. يرجى تسجيل الدخول.',
      'registerFailed': 'تعذّر إنشاء حسابك. يرجى المحاولة مرة أخرى.',
      'emailInUse': 'يوجد حساب بهذا البريد الإلكتروني بالفعل',
      'phoneInUse': 'يوجد حساب بهذا الرقم بالفعل',
      'verifyNumberSubtitle':
          'أدخل الرمز المكوّن من ٦ أرقام الذي أرسلناه للتو إلى {dest} '
          'للتحقق من رقمك.',
      // --- Terms of Service screen ---
      'termsOfService': 'شروط الخدمة',
      'termsAgreeCheckbox':
          'لقد قرأت شروط الخدمة وسياسة الخصوصية وأوافق عليها.',
      'continueLabel': 'متابعة',
      'lastUpdated': 'آخر تحديث: {date}',
      'termsLoadFailed': 'تعذّر تحميل الشروط. يرجى المحاولة مرة أخرى.',
      'tryAgain': 'حاول مرة أخرى',
      'termsNotReviewed':
          'صيغة مبدئية — بانتظار المراجعة القانونية. غير مخصّصة للإصدار.',
      // --- Account Setup screen ---
      'accountSetup': 'إعداد الحساب',
      'accountSetupSubtitle':
          'أكمل إعداد حسابك برفع صورة الملف الشخصي وتحديد اسم المستخدم.',
      'username': 'اسم المستخدم',
      'createAccount': 'إنشاء الحساب',
      'chooseFromGallery': 'اختر من المعرض',
      'takePhoto': 'التقط صورة',
      'removePhoto': 'إزالة الصورة',
      'usernameRequired': 'يرجى إدخال اسم المستخدم',
      'usernameTooShort': 'استخدم حرفين على الأقل',
      'imageTooLarge': 'هذه الصورة كبيرة جدًا. اختر صورة أقل من ٥ ميغابايت.',
      'imagePickFailed': 'تعذّر فتح هذه الصورة. يرجى المحاولة مرة أخرى.',
      'profileSaveFailed': 'تعذّر حفظ ملفك الشخصي. يرجى المحاولة مرة أخرى.',
      'cameraPermissionDenied':
          'الوصول إلى الكاميرا مُعطّل. فعّله من الإعدادات لالتقاط صورة.',
      'galleryPermissionDenied':
          'الوصول إلى الصور مُعطّل. فعّله من الإعدادات لاختيار صورة.',
      // --- Register Complete screen ---
      'registerComplete': 'اكتمل التسجيل!',
      'registerCompleteSubtitle': 'تم إنشاء حسابك بنجاح. أهلًا بك!',
      'explore': 'استكشف',
      // --- Onboarding (3-slide intro) ---
      'onboardingTitleLine1': 'اكتشف',
      'onboardingTitleLine2': 'كردستان',
      'onboardingBody1':
          'استكشف الوديان الجميلة والأنهار ودروب الجبال التي لا يصل إليها '
          'سوى قليل من المسافرين.\nكل ذلك في تطبيق واحد.',
      'onboardingTitle2Line1': 'طر إلى',
      'onboardingTitle2Line2': 'كردستان',
      'onboardingBody2': 'قارن الرحلات واختر تواريخك واحجز تذكرتك في دقائق.',
      'onboardingTitle3Line1': 'سيارتك',
      'onboardingTitle3Line2': 'جاهزة !',
      'onboardingBody3':
          'استأجر سيارة وتنقّل إلى كل ركن في كردستان وفق جدولك الخاص.',
      'onboardingNext': 'التالي',
      // --- Home screen ---
      'goodMorning': 'صباح الخير',
      'goodAfternoon': 'طاب نهارك',
      'goodEvening': 'مساء الخير',
      'goodNight': 'طابت ليلتك',
      'dearUser': 'عزيزي المستخدم',
      'whereWouldYouLikeToGo': 'إلى أين تودّ الذهاب؟',
      'planYourJourney': 'خطّط لرحلتك',
      'exploreNature': 'استكشف الطبيعة',
      'exploreNatureHint': 'مسارات وبحيرات وحدائق خلّابة.',
      'whereToStay': 'أين تقيم',
      'whereToStayHint': 'فنادق وأكواخ وأماكن إقامة مميّزة',
      'bestPrice': 'أفضل سعر',
      'carRental': 'تأجير السيارات',
      'carRentalHint': 'اعثر على السيارة المثالية لمغامرتك',
      'findACar': 'ابحث عن سيارة',
      'flightTicketing': 'حجز الطيران',
      'flightTicketingHint': 'رحلات رخيصة، حجز سهل، دفع آمن',
      'findFlight': 'ابحث عن رحلة',
      'exploreToursTitle': 'استكشف الجولات',
      'exploreToursHint': 'تجارب محلية وأماكن مخفية ومرشدون خبراء',
      'findTours': 'ابحث عن جولة',
      'placesCount': '{count}+ مكان',
      'navHome': 'الرئيسية',
      'navTrips': 'رحلاتي',
      'navMap': 'الخريطة',
      'navSaved': 'المحفوظات',
      'featuredLoadFailed': 'تعذّر تحميل الوجهات المميّزة',
      'featuredEmpty': 'لا توجد وجهات مميّزة بعد',
      'signInToSave': 'سجّل الدخول لحفظ المفضّلة',
      'signInToSaveBody':
          'أنشئ حسابًا أو سجّل الدخول للاحتفاظ بأماكنك المفضّلة.',
      'notNow': 'ليس الآن',
      'addedToFavorites': 'أُضيف إلى مفضّلتك',
      'removedFromFavorites': 'أُزيل من مفضّلتك',
      'favoriteFailed': 'تعذّر تحديث مفضّلتك',
      'comingSoon': 'قريبًا',
      'mapOpenFailed': 'تعذّر فتح تطبيق الخرائط',
      'menu': 'القائمة',
      'changeLanguage': 'تغيير اللغة',
    },
  };

  String _t(String key) =>
      _values[locale.languageCode]?[key] ?? _values['en']![key] ?? key;

  String get chooseYourLanguage => _t('chooseYourLanguage');
  String get selectLanguageToContinue => _t('selectLanguageToContinue');
  String get logIn => _t('logIn');
  String get email => _t('email');
  String get password => _t('password');
  String get forgetPassword => _t('forgetPassword');
  String get forgetPasswordSubtitle => _t('forgetPasswordSubtitle');
  String get phoneNumber => _t('phoneNumber');
  String get emailAddress => _t('emailAddress');
  String get sendCode => _t('sendCode');
  String get selectContactMethod => _t('selectContactMethod');
  String get orLabel => _t('orLabel');
  String get dontHaveAccount => _t('dontHaveAccount');
  String get registerNow => _t('registerNow');
  String get continueAsGuest => _t('continueAsGuest');
  String get emailRequired => _t('emailRequired');
  String get emailInvalid => _t('emailInvalid');
  String get passwordRequired => _t('passwordRequired');

  // --- Verification Code screen ---
  String get verificationCode => _t('verificationCode');
  String get didntReceiveCode => _t('didntReceiveCode');
  String get resendNow => _t('resendNow');
  String get verify => _t('verify');
  String get codeIncomplete => _t('codeIncomplete');
  String get codeIncorrect => _t('codeIncorrect');
  String get codeExpired => _t('codeExpired');
  String get tooManyAttempts => _t('tooManyAttempts');
  String get codeResentPhone => _t('codeResentPhone');
  String get codeResentEmail => _t('codeResentEmail');
  String get sendCodeFailed => _t('sendCodeFailed');
  String get networkError => _t('networkError');

  /// The raw subtitle template, still containing the literal `{dest}`
  /// placeholder. The screen splits on it so the destination can be drawn
  /// bold (and left-to-right) inside an otherwise right-to-left sentence.
  String get verificationSubtitleTemplate => _t('verificationSubtitle');

  /// Splits [verificationSubtitleTemplate] into the text before and after
  /// `{dest}`. Returns `(before, after)`.
  (String, String) verificationSubtitleParts() =>
      _splitOnDest(verificationSubtitleTemplate);

  String resendIn(int seconds) =>
      _t('resendIn').replaceAll('{seconds}', '$seconds');

  // --- Register screen ---
  String get register => _t('register');
  String get fullName => _t('fullName');
  String get age => _t('age');
  String get gender => _t('gender');
  String get genderMale => _t('genderMale');
  String get genderFemale => _t('genderFemale');
  String get genderOther => _t('genderOther');
  String get genderOptional => _t('genderOptional');
  String get alreadyHaveAccount => _t('alreadyHaveAccount');
  String get logInHere => _t('logInHere');
  String get passwordHint => _t('passwordHint');
  String get acceptTerms => _t('acceptTerms');
  String get termsRequired => _t('termsRequired');
  String get fullNameRequired => _t('fullNameRequired');
  String get fullNameTooShort => _t('fullNameTooShort');
  String get dateOfBirthRequired => _t('dateOfBirthRequired');
  String get mustBe18 => _t('mustBe18');
  String get phoneRequired => _t('phoneRequired');
  String get phoneInvalid => _t('phoneInvalid');
  String get selectCountryCode => _t('selectCountryCode');
  String get accountCreated => _t('accountCreated');
  String get registerFailed => _t('registerFailed');
  String get emailInUse => _t('emailInUse');
  String get phoneInUse => _t('phoneInUse');

  // --- Register Complete screen ---
  String get registerComplete => _t('registerComplete');
  String get registerCompleteSubtitle => _t('registerCompleteSubtitle');
  String get explore => _t('explore');
  String get onboardingTitleLine1 => _t('onboardingTitleLine1');
  String get onboardingTitleLine2 => _t('onboardingTitleLine2');
  String get onboardingBody1 => _t('onboardingBody1');
  String get onboardingTitle2Line1 => _t('onboardingTitle2Line1');
  String get onboardingTitle2Line2 => _t('onboardingTitle2Line2');
  String get onboardingBody2 => _t('onboardingBody2');
  String get onboardingTitle3Line1 => _t('onboardingTitle3Line1');
  String get onboardingTitle3Line2 => _t('onboardingTitle3Line2');
  String get onboardingBody3 => _t('onboardingBody3');
  String get onboardingNext => _t('onboardingNext');

  // --- Account Setup screen ---
  String get accountSetup => _t('accountSetup');
  String get accountSetupSubtitle => _t('accountSetupSubtitle');
  String get username => _t('username');
  String get createAccount => _t('createAccount');
  String get chooseFromGallery => _t('chooseFromGallery');
  String get takePhoto => _t('takePhoto');
  String get removePhoto => _t('removePhoto');
  String get usernameRequired => _t('usernameRequired');
  String get usernameTooShort => _t('usernameTooShort');
  String get imageTooLarge => _t('imageTooLarge');
  String get imagePickFailed => _t('imagePickFailed');
  String get profileSaveFailed => _t('profileSaveFailed');
  String get cameraPermissionDenied => _t('cameraPermissionDenied');
  String get galleryPermissionDenied => _t('galleryPermissionDenied');

  // --- Terms of Service screen ---
  String get termsOfService => _t('termsOfService');
  String get termsAgreeCheckbox => _t('termsAgreeCheckbox');
  String get continueLabel => _t('continueLabel');
  String get termsLoadFailed => _t('termsLoadFailed');
  String get tryAgain => _t('tryAgain');
  String get termsNotReviewed => _t('termsNotReviewed');

  String lastUpdated(String date) =>
      _t('lastUpdated').replaceAll('{date}', date);

  /// Subtitle for the Verification Code screen when it is verifying a phone
  /// number during registration, rather than resetting a password.
  String get verifyNumberSubtitleTemplate => _t('verifyNumberSubtitle');

  /// Splits [verifyNumberSubtitleTemplate] around `{dest}` — see
  /// [verificationSubtitleParts].
  (String, String) verifyNumberSubtitleParts() =>
      _splitOnDest(verifyNumberSubtitleTemplate);

  static (String, String) _splitOnDest(String template) {
    const marker = '{dest}';
    final index = template.indexOf(marker);
    if (index < 0) return (template, '');
    return (
      template.substring(0, index),
      template.substring(index + marker.length),
    );
  }

  // --- Reset Password screen ---
  String get resetPassword => _t('resetPassword');
  String get resetPasswordSubtitle => _t('resetPasswordSubtitle');
  String get newPassword => _t('newPassword');
  String get confirmPassword => _t('confirmPassword');
  String get updatePassword => _t('updatePassword');
  String get passwordTooShort => _t('passwordTooShort');
  String get passwordNeedsUppercase => _t('passwordNeedsUppercase');
  String get passwordNeedsLowercase => _t('passwordNeedsLowercase');
  String get passwordNeedsSpecial => _t('passwordNeedsSpecial');
  String get confirmPasswordRequired => _t('confirmPasswordRequired');
  String get passwordsDontMatch => _t('passwordsDontMatch');
  String get passwordUpdated => _t('passwordUpdated');
  String get passwordUpdateFailed => _t('passwordUpdateFailed');
  String get passwordTooWeak => _t('passwordTooWeak');
  String get sessionExpired => _t('sessionExpired');

  // --- Home screen ---
  String get dearUser => _t('dearUser');
  String get whereWouldYouLikeToGo => _t('whereWouldYouLikeToGo');
  String get planYourJourney => _t('planYourJourney');
  String get exploreNature => _t('exploreNature');
  String get exploreNatureHint => _t('exploreNatureHint');
  String get whereToStay => _t('whereToStay');
  String get whereToStayHint => _t('whereToStayHint');
  String get bestPrice => _t('bestPrice');
  String get carRental => _t('carRental');
  String get carRentalHint => _t('carRentalHint');
  String get findACar => _t('findACar');
  String get flightTicketing => _t('flightTicketing');
  String get flightTicketingHint => _t('flightTicketingHint');
  String get findFlight => _t('findFlight');
  String get exploreToursTitle => _t('exploreToursTitle');
  String get exploreToursHint => _t('exploreToursHint');
  String get findTours => _t('findTours');
  String get navHome => _t('navHome');
  String get navTrips => _t('navTrips');
  String get navMap => _t('navMap');
  String get navSaved => _t('navSaved');
  String get featuredLoadFailed => _t('featuredLoadFailed');
  String get featuredEmpty => _t('featuredEmpty');
  String get signInToSave => _t('signInToSave');
  String get signInToSaveBody => _t('signInToSaveBody');
  String get notNow => _t('notNow');
  String get addedToFavorites => _t('addedToFavorites');
  String get removedFromFavorites => _t('removedFromFavorites');
  String get favoriteFailed => _t('favoriteFailed');
  String get comingSoon => _t('comingSoon');
  String get mapOpenFailed => _t('mapOpenFailed');
  String get menu => _t('menu');
  String get changeLanguage => _t('changeLanguage');

  String placesCount(int count) =>
      _t('placesCount').replaceAll('{count}', '$count');

  /// Time-of-day greeting, e.g. "Good evening".
  ///
  /// Four buckets rather than the three named in the spec: without an
  /// afternoon band, 1pm would have to read either "Good morning" or "Good
  /// evening", both of which are wrong. Remove [goodAfternoon] and widen
  /// morning/evening if a three-way split is preferred.
  String greetingForHour(int hour) {
    if (hour >= 5 && hour < 12) return _t('goodMorning');
    if (hour >= 12 && hour < 17) return _t('goodAfternoon');
    if (hour >= 17 && hour < 21) return _t('goodEvening');
    return _t('goodNight');
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const <String>['en', 'ku', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// --- Kurdish fallback delegates -------------------------------------------
// Flutter's global localizations don't support `ku`, so for Kurdish we reuse
// Arabic's localizations. That also gives Kurdish right-to-left layout.

class _KurdishMaterialDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _KurdishMaterialDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(_KurdishMaterialDelegate old) => false;
}

class _KurdishCupertinoDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _KurdishCupertinoDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(_KurdishCupertinoDelegate old) => false;
}

class _KurdishWidgetsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _KurdishWidgetsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'ku';

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      GlobalWidgetsLocalizations.delegate.load(const Locale('ar'));

  @override
  bool shouldReload(_KurdishWidgetsDelegate old) => false;
}
