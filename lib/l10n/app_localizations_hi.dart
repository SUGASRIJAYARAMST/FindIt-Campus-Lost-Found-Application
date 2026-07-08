// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'FindIt';

  @override
  String get tagline => 'कुछ खो गया? इसे स्मार्ट तरीके से खोजें।';

  @override
  String get lostFoundCampus => 'कैंपस लाइफ के लिए खोया और पाया';

  @override
  String get welcomeBack => 'वापसी पर स्वागत है';

  @override
  String get signInToAccount => 'अपने खाते में साइन इन करें';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get joinCampus => 'अपने कैंपस समुदाय में शामिल हों';

  @override
  String get createYourAccount => 'अपना खाता बनाएं';

  @override
  String get emailAddress => 'ईमेल पता';

  @override
  String get emailHint => 'you@university.edu';

  @override
  String get password => 'पासवर्ड';

  @override
  String get enterPassword => 'अपना पासवर्ड दर्ज करें';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get nameHint => 'John Doe';

  @override
  String get department => 'विभाग';

  @override
  String get deptHint => 'कंप्यूटर विज्ञान';

  @override
  String get phoneNumber => 'फ़ोन नंबर';

  @override
  String get phoneHint => '+1 234 567 890';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get reenterPassword => 'पासवर्ड फिर से दर्ज करें';

  @override
  String get createStrongPassword => 'मजबूत पासवर्ड बनाएं';

  @override
  String get agreeTerms => 'मैं नियम और शर्तों और गोपनीयता नीति से सहमत हूं';

  @override
  String get signIn => 'साइन इन';

  @override
  String get signUp => 'साइन अप';

  @override
  String get dontHaveAccount => 'खाता नहीं है? ';

  @override
  String get alreadyHaveAccount => 'पहले से खाता है? ';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get enterValidEmail => 'पहले मान्य ईमेल पता दर्ज करें।';

  @override
  String get passwordResetSent =>
      'पासवर्ड रीसेट ईमेल भेजा गया। अपना इनबॉक्स देखें।';

  @override
  String get acceptTerms => 'कृपया नियम और शर्तों को स्वीकार करें।';

  @override
  String helloName(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get findLostReport =>
      'अपनी खोई हुई वस्तुओं को खोजें या पाई गई वस्तुओं की रिपोर्ट करें';

  @override
  String get goodMorning => 'शुभ प्रभात';

  @override
  String get goodAfternoon => 'शुभ दोपहर';

  @override
  String get goodEvening => 'शुभ संध्या';

  @override
  String get report => 'रिपोर्ट';

  @override
  String get home => 'होम';

  @override
  String get items => 'वस्तुएं';

  @override
  String get rewards => 'पुरस्कार';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get searchHint => 'खोई या पाई गई वस्तुओं की खोज करें...';

  @override
  String get quickActions => 'त्वरित क्रियाएं';

  @override
  String get reportLost => 'खोई रिपोर्ट करें';

  @override
  String get reportFound => 'पाई रिपोर्ट करें';

  @override
  String get myReports => 'मेरी रिपोर्ट';

  @override
  String get recentLostItems => 'हाल की खोई हुई वस्तुएं';

  @override
  String get recentFoundItems => 'हाल की पाई गई वस्तुएं';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String get lost => 'खोई';

  @override
  String get found => 'पाई';

  @override
  String get student => 'छात्र';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get account => 'खाता';

  @override
  String get editProfile => 'प्रोफ़ाइल संपादित करें';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get app => 'ऐप';

  @override
  String get theme => 'थीम';

  @override
  String get language => 'भाषा';

  @override
  String get about => 'के बारे में';

  @override
  String get support => 'सहायता';

  @override
  String get helpCenter => 'सहायता केंद्र';

  @override
  String get sendFeedback => 'प्रतिक्रिया भेजें';

  @override
  String get termsOfService => 'सेवा की शर्तें';

  @override
  String get privacyPolicy => 'गोपनीयता नीति';

  @override
  String get chooseTheme => 'थीम चुनें';

  @override
  String get light => 'लाइट';

  @override
  String get dark => 'डार्क';

  @override
  String get system => 'सिस्टम';

  @override
  String get chooseLanguage => 'भाषा चुनें';

  @override
  String get english => 'अंग्रेज़ी';

  @override
  String get tamil => 'तमिल';

  @override
  String get hindi => 'हिन्दी';

  @override
  String get malayalam => 'मलयालम';

  @override
  String get telugu => 'तेलुगु';

  @override
  String languageSetTo(String lang, Object name) {
    return 'भाषा $lang पर सेट की गई';
  }

  @override
  String get aboutSubtitle => 'कैंपस खोया और पाया ऐप';

  @override
  String get version => 'संस्करण 1.0.0';

  @override
  String get aboutDesc =>
      'FindIt आपको कैंपस में खोई हुई वस्तुओं की रिपोर्ट करने और खोजने में मदद करता है। AI-संचालित मैचिंग का उपयोग करके अपनी वस्तुओं से फिर से जुड़ें।';

  @override
  String get builtWith => 'Flutter & Firebase के साथ बनाया गया';

  @override
  String get close => 'बंद करें';

  @override
  String get feedbackPrompt =>
      'हमें बेहतर बनाने में मदद करें! हमें बताएं आप क्या सोचते हैं।';

  @override
  String get feedbackHint => 'आपकी प्रतिक्रिया...';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get submit => 'जमा करें';

  @override
  String get thankFeedback => 'आपकी प्रतिक्रिया के लिए धन्यवाद!';

  @override
  String get enterFeedback => 'कृपया अपनी प्रतिक्रिया दर्ज करें।';

  @override
  String get passwordResetContent =>
      'हम आपके ईमेल पर पासवर्ड रीसेट लिंक भेजेंगे।';

  @override
  String get email => 'ईमेल';

  @override
  String get emailHint2 => 'your@email.com';

  @override
  String get sendLink => 'लिंक भेजें';

  @override
  String get enterEmail => 'कृपया ईमेल दर्ज करें।';

  @override
  String get logout => 'लॉगआउट';

  @override
  String get signOut => 'साइन आउट';

  @override
  String get areYouSureSignOut => 'क्या आप वाकई साइन आउट करना चाहते हैं?';

  @override
  String get notSet => 'सेट नहीं';

  @override
  String get role => 'भूमिका';

  @override
  String get phone => 'फ़ोन';

  @override
  String get points => 'अंक';

  @override
  String get badge => 'बैज';

  @override
  String get rookie => 'रूकी';

  @override
  String get updateInfo => 'अपनी व्यक्तिगत जानकारी अपडेट करें';

  @override
  String get changePhoto => 'फ़ोटो बदलें';

  @override
  String get uploadPhoto => 'नई प्रोफ़ाइल फ़ोटो अपलोड करें';

  @override
  String get appPrefs => 'ऐप प्राथमिकताएं और खाता';

  @override
  String get logOutAccount => 'अपने खाते से लॉग आउट करें';

  @override
  String get camera => 'कैमरा';

  @override
  String get gallery => 'गैलरी';

  @override
  String get removePhoto => 'फ़ोटो हटाएं';

  @override
  String get profileRemoved => 'प्रोफ़ाइल फ़ोटो हटा दी गई।';

  @override
  String get profileUpdated => 'प्रोफ़ाइल फ़ोटो अपडेट की गई!';

  @override
  String get saveChanges => 'परिवर्तन सहेजें';

  @override
  String get profileUpdateSuccess => 'प्रोफ़ाइल अपडेट की गई!';

  @override
  String get profileUpdateFail => 'प्रोफ़ाइल अपडेट करने में विफल';

  @override
  String get reportLostItem => 'खोई हुई वस्तु की रिपोर्ट करें';

  @override
  String get reportFoundItem => 'पाई गई वस्तु की रिपोर्ट करें';

  @override
  String get reportingLost => 'खोई हुई वस्तु की रिपोर्ट कर रहे हैं';

  @override
  String get reportingFound => 'पाई गई वस्तु की रिपोर्ट कर रहे हैं';

  @override
  String get tapToAddPhoto => 'फ़ोटो जोड़ने के लिए टैप करें';

  @override
  String get optionalRecommended => 'वैकल्पिक लेकिन अनुशंसित';

  @override
  String get itemName => 'वस्तु का नाम';

  @override
  String get itemHint => 'वस्तु क्या है?';

  @override
  String get enterItemName => 'कृपया वस्तु का नाम दर्ज करें';

  @override
  String get category => 'श्रेणी';

  @override
  String get electronics => 'इलेक्ट्रॉनिक्स';

  @override
  String get documents => 'दस्तावेज़';

  @override
  String get clothing => 'कपड़े';

  @override
  String get accessories => 'सहायक उपकरण';

  @override
  String get bags => 'बैग';

  @override
  String get keys => 'चाबियाँ';

  @override
  String get idCards => 'आईडी कार्ड';

  @override
  String get books => 'किताबें';

  @override
  String get other => 'अन्य';

  @override
  String get description => 'विवरण';

  @override
  String get describeItem => 'वस्तु का वर्णन करें (रंग, आकार, आदि)';

  @override
  String get enterDescription => 'कृपया विवरण दर्ज करें';

  @override
  String get lostLocation => 'खोने का स्थान';

  @override
  String get foundLocation => 'पाने का स्थान';

  @override
  String get whereLost => 'यह कहाँ खो गई?';

  @override
  String get whereFound => 'यह कहाँ पाई गई?';

  @override
  String get enterLocation => 'कृपया स्थान दर्ज करें';

  @override
  String get lostDate => 'खोने की तारीख';

  @override
  String get foundDate => 'पाने की तारीख';

  @override
  String get selectDate => 'तारीख चुनें';

  @override
  String get contactNumber => 'संपर्क नंबर';

  @override
  String get yourPhone => 'आपका फ़ोन नंबर';

  @override
  String get enterContact => 'कृपया संपर्क नंबर दर्ज करें';

  @override
  String get submitLostReport => 'खोई रिपोर्ट जमा करें';

  @override
  String get submitFoundReport => 'पाई रिपोर्ट जमा करें';

  @override
  String get lostReportSubmitted => 'खोई रिपोर्ट जमा की गई!';

  @override
  String get foundReportSubmitted => 'पाई रिपोर्ट जमा की गई!';

  @override
  String get all => 'सभी';

  @override
  String get filters => 'फ़िल्टर';

  @override
  String get newest => 'नवीनतम';

  @override
  String get oldest => 'पुराना';

  @override
  String get sortBy => 'क्रमबद्ध करें';

  @override
  String get newestFirst => 'नवीनतम पहले';

  @override
  String get oldestFirst => 'पुराना पहले';

  @override
  String get noLostItems => 'कोई खोई हुई वस्तु नहीं';

  @override
  String get noFoundItems => 'कोई पाई गई वस्तु नहीं';

  @override
  String get noItemsYet => 'अभी तक कोई वस्तु नहीं';

  @override
  String get noLostReported =>
      'अभी तक कोई खोई हुई वस्तु की रिपोर्ट नहीं की गई।';

  @override
  String get noFoundReported =>
      'अभी तक कोई पाई गई वस्तु की रिपोर्ट नहीं की गई।';

  @override
  String get tapToReport =>
      'खोई या पाई गई वस्तु की रिपोर्ट करने के लिए + टैप करें।';

  @override
  String get unknown => 'अज्ञात';

  @override
  String get searchItems => 'वस्तुएं खोजें...';

  @override
  String get lostItems => 'खोई हुई वस्तुएं';

  @override
  String get foundItems => 'पाई गई वस्तुएं';

  @override
  String get noLostItemsHere =>
      'खोई हुई रिपोर्ट की गई वस्तुएं यहाँ दिखाई देंगी';

  @override
  String get noFoundItemsHere =>
      'पाई गई रिपोर्ट की गई वस्तुएं यहाँ दिखाई देंगी';

  @override
  String get edit => 'संपादित करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get editReport => 'रिपोर्ट संपादित करें';

  @override
  String get location => 'स्थान';

  @override
  String get contact => 'संपर्क';

  @override
  String get reportUpdated => 'रिपोर्ट अपडेट की गई!';

  @override
  String get deleteReport => 'रिपोर्ट हटाएं';

  @override
  String get deleteReportConfirm =>
      'क्या आप वाकई यह रिपोर्ट हटाना चाहते हैं? यह क्रिया पूर्ववत नहीं की जा सकती।';

  @override
  String get reportDeleted => 'रिपोर्ट हटा दी गई';

  @override
  String get open => 'खुला';

  @override
  String get available => 'उपलब्ध';

  @override
  String get matched => 'मैच किया';

  @override
  String get claimed => 'दावा किया';

  @override
  String get recovered => 'वसूल किया';

  @override
  String get returned => 'वापस किया';

  @override
  String get itemNotFound => 'वस्तु नहीं मिली';

  @override
  String get reportedBy => 'द्वारा रिपोर्ट किया';

  @override
  String get posted => 'पोस्ट किया';

  @override
  String get noDescription => 'कोई विवरण प्रदान नहीं किया गया।';

  @override
  String get noContact => 'कोई संपर्क प्रदान नहीं किया गया';

  @override
  String get markAsRecovered => 'वसूल के रूप में चिह्नित करें';

  @override
  String get markRecoveredConfirm =>
      'इस वस्तु को वसूल के रूप में चिह्नित करें?';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get statusUpdated => 'स्थिति अपडेट की गई!';

  @override
  String get markAsReturned => 'वापस के रूप में चिह्नित करें';

  @override
  String get deleteReportQuestion => 'क्या आप वाकई यह रिपोर्ट हटाना चाहते हैं?';

  @override
  String get iFoundThis => 'मैंने यह वस्तु पाई';

  @override
  String get thisIsMyItem => 'यह मेरी वस्तु है';

  @override
  String get claimItem => 'वस्तु का दावा करें';

  @override
  String get confirmOwnership => 'स्वामित्व की पुष्टि करें';

  @override
  String get claimConfirmFound =>
      'क्या आपने यह वस्तु पाई है? मालिक को सूचित किया जाएगा।';

  @override
  String get claimConfirmOwner =>
      'क्या यह आपकी वस्तु है? पाने वाले को सूचित किया जाएगा।';

  @override
  String get itemClaimed => 'वस्तु का सफलतापूर्वक दावा किया गया!';

  @override
  String get timeline => 'समयरेखा';

  @override
  String get noEvents => 'अभी तक कोई घटना नहीं';

  @override
  String get shareSoon => 'शेयर सुविधा जल्द आ रही है!';

  @override
  String get favorites => 'पसंदीदा';

  @override
  String get noFavorites => 'अभी तक कोई पसंदीदा नहीं';

  @override
  String get tapHeartAdd =>
      'पसंदीदा में जोड़ने के लिए किसी भी वस्तु पर दिल आइकन पर टैप करें';

  @override
  String get reportHistory => 'रिपोर्ट इतिहास';

  @override
  String get searchReports => 'रिपोर्ट खोजें...';

  @override
  String get noReportsFound => 'कोई रिपोर्ट नहीं मिली';

  @override
  String get archivedItems => 'संग्रहीत वस्तुएं';

  @override
  String get noArchived => 'कोई संग्रहीत वस्तु नहीं';

  @override
  String get autoArchived =>
      'वसूली के बाद वस्तुएं स्वचालित रूप से संग्रहीत हो जाती हैं';

  @override
  String get deleteArchived => 'संग्रहीत वस्तु हटाएं';

  @override
  String get actionUndone => 'यह क्रिया पूर्ववत नहीं की जा सकती।';

  @override
  String get restore => 'पुनर्स्थापित करें';

  @override
  String get rewardPoints => 'पुरस्कार अंक';

  @override
  String currentBadge(String badge) {
    return 'वर्तमान बैज: $badge';
  }

  @override
  String get badgeProgress => 'बैज प्रगति';

  @override
  String get current => 'वर्तमान';

  @override
  String pointsRequired(int n) {
    return '$n अंक आवश्यक';
  }

  @override
  String get howToEarn => 'अंक कैसे कमाएं';

  @override
  String get reportLostItemBadge => 'खोई हुई वस्तु की रिपोर्ट करें';

  @override
  String get plus10pts => '+10 अंक';

  @override
  String get reportFoundItemBadge => 'पाई गई वस्तु की रिपोर्ट करें';

  @override
  String get plus15pts => '+15 अंक';

  @override
  String get itemRecovered => 'वस्तु वसूल';

  @override
  String get plus25pts => '+25 अंक';

  @override
  String get dailyCheckin => 'दैनिक चेक-इन';

  @override
  String get plus5pts => '+5 अंक';

  @override
  String get smartMatches => 'स्मार्ट मैच';

  @override
  String get analyzingMatches => 'मैच का विश्लेषण हो रहा है...';

  @override
  String get comparingItems => 'खोई और पाई गई वस्तुओं की तुलना कर रहे हैं';

  @override
  String get noMatches => 'कोई मैच नहीं मिला';

  @override
  String get noMatchesDesc =>
      'अभी कोई संभावित मैच नहीं मिला। वस्तुओं की रिपोर्ट करने पर नए मैच स्वचालित रूप से दिखाई देंगे।';

  @override
  String potentialMatches(int n) {
    return '$n संभावित मैच';
  }

  @override
  String get aiResults => 'AI-संचालित मैचिंग परिणाम';

  @override
  String get name => 'नाम';

  @override
  String get excellentMatch => 'उत्कृष्ट मैच';

  @override
  String get goodMatch => 'अच्छा मैच';

  @override
  String get possibleMatch => 'संभावित मैच';

  @override
  String get weakMatch => 'कमज़ोर मैच';

  @override
  String get adminDashboard => 'एडमिन डैशबोर्ड';

  @override
  String get overview => 'अवलोकन';

  @override
  String get totalUsers => 'कुल उपयोगकर्ता';

  @override
  String get lostItemsCount => 'खोई हुई वस्तुएं';

  @override
  String get foundItemsCount => 'पाई गई वस्तुएं';

  @override
  String get recoveryRate => 'वसूली दर';

  @override
  String get ofItemsRecovered => 'रिपोर्ट की गई वस्तुओं में से वसूल';

  @override
  String get management => 'प्रबंधन';

  @override
  String get users => 'उपयोगकर्ता';

  @override
  String get manageUsers => 'उपयोगकर्ता प्रबंधित करें';

  @override
  String get manageItems => 'वस्तुएं प्रबंधित करें';

  @override
  String get analytics => 'विश्लेषण';

  @override
  String get categories => 'श्रेणियां';

  @override
  String get topLocations => 'शीर्ष स्थान';

  @override
  String get itemManagement => 'वस्तु प्रबंधन';

  @override
  String get noItemsFound => 'कोई वस्तु नहीं मिली';

  @override
  String get markReturnedConfirm => 'वापस के रूप में चिह्नित करें?';

  @override
  String get markRecoveredConfirmAdmin => 'वसूल के रूप में चिह्नित करें?';

  @override
  String get deleteItemConfirm =>
      'यह वस्तु हटाएं? यह पूर्ववत नहीं किया जा सकता।';

  @override
  String get statusUpdated2 => 'स्थिति अपडेट की गई';

  @override
  String get failedToUpdate => 'अपडेट करने में विफल';

  @override
  String get itemDeleted => 'वस्तु हटा दी गई';

  @override
  String get failedToDelete => 'हटाने में विफल';

  @override
  String get userManagement => 'उपयोगकर्ता प्रबंधन';

  @override
  String get searchUsers => 'उपयोगकर्ता खोजें...';

  @override
  String get noUsersFound => 'कोई उपयोगकर्ता नहीं मिला';

  @override
  String get admin => 'एडमिन';

  @override
  String get blocked => 'ब्लॉक किया';

  @override
  String get active => 'सक्रिय';

  @override
  String get blockUser => 'उपयोगकर्ता को ब्लॉक करें';

  @override
  String get unblockUser => 'उपयोगकर्ता को अनब्लॉक करें';

  @override
  String get deleteUser => 'उपयोगकर्ता हटाएं';

  @override
  String blockUserConfirm(String name) {
    return '$name को ब्लॉक करें?';
  }

  @override
  String unblockUserConfirm(String name) {
    return '$name को अनब्लॉक करें?';
  }

  @override
  String deleteUserConfirm(String name) {
    return '$name को हटाएं? यह पूर्ववत नहीं किया जा सकता।';
  }

  @override
  String userBlocked(String name) {
    return '$name को ब्लॉक कर दिया गया';
  }

  @override
  String userUnblocked(String name) {
    return '$name को अनब्लॉक कर दिया गया';
  }

  @override
  String get userDeleted => 'उपयोगकर्ता हटा दिया गया';

  @override
  String get failedDeleteUser => 'उपयोगकर्ता हटाने में विफल';

  @override
  String get allItems => 'सभी वस्तुएं';

  @override
  String get archive => 'संग्रह';

  @override
  String get reportItem => 'वस्तु की रिपोर्ट करें';

  @override
  String pts(int n) {
    return '$n अंक';
  }

  @override
  String get january => 'जनवरी';

  @override
  String get february => 'फरवरी';

  @override
  String get march => 'मार्च';

  @override
  String get april => 'अप्रैल';

  @override
  String get may => 'मई';

  @override
  String get june => 'जून';

  @override
  String get july => 'जुलाई';

  @override
  String get august => 'अगस्त';

  @override
  String get september => 'सितंबर';

  @override
  String get october => 'अक्टूबर';

  @override
  String get november => 'नवंबर';

  @override
  String get december => 'दिसंबर';

  @override
  String get referralCode => 'रेफरल कोड (वैकल्पिक)';

  @override
  String get referralCodeHint => 'रेफरल कोड दर्ज करें';

  @override
  String get referralCodeOptional => 'रेफरल कोड है? बोनस अंक के लिए दर्ज करें!';

  @override
  String get yourReferralCode => 'आपका रेफरल कोड';

  @override
  String get shareReferralCode =>
      'अपना कोड दोस्तों के साथ साझा करें और बोनस अंक कमाएं';

  @override
  String get referralStats => 'रेफरल आंकड़े';

  @override
  String get friendsReferred => 'रेफर किए गए दोस्त';

  @override
  String get shareCode => 'कोड साझा करें';

  @override
  String get copiedToClipboard => 'रेफरल कोड क्लिपबोर्ड पर कॉपी किया गया';

  @override
  String get referralBonus => 'रेफरल बोनस';
}
