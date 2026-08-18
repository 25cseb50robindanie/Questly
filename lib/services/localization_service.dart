import '../core/locator.dart';
import 'storage_service.dart';

class LocalizationService {
  static String _currentLanguage = 'en';

  static String get currentLanguage => _currentLanguage;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'continue_learning': 'Continue Learning',
      'your_quest': 'YOUR QUEST',
      'lesson_progress': 'Lesson {current} of {total}',
      'continue_quest': 'CONTINUE QUEST',
      'start_quest': 'START QUEST',
      'revision': 'Revision',
      'quick_revision': 'QUICK REVISION',
      'concepts_ready': '{count} concepts ready for review',
      'start_revision': 'START REVISION',
      'my_modules': 'My Modules',
      'view_all': 'VIEW ALL',
      'view_all_modules': 'VIEW ALL MODULES',
      'leaderboard': 'Leaderboard',
      'your_class': 'YOUR CLASS',
      'view_leaderboard': 'VIEW LEADERBOARD',
      'collection': 'Collection',
      'shop': 'Shop',
      'settings': 'Settings',
      'profile': 'Profile',
      'badges': 'Badges',
      'collectibles': 'Collectibles',
      'account': 'Account',
      'logout': 'Log Out',
      'language': 'Language',
      'sound': 'Sound Effects',
      'student_id': 'Student ID',
      'notifications': 'Notifications',
      'quest_coins': 'Quest Coins',
      'level': 'Level',
      'completed': 'Completed',
      'current': 'Current',
      'locked': 'Locked',
      'insufficient_coins': 'Not enough Quest Coins! Keep learning to earn more.',
      'purchase_success': 'Successfully purchased!',
      'already_owned': 'You already own this item!',
      'start_module': 'START MODULE',
      'continue_module': 'CONTINUE MODULE',
      'roadmap': 'Roadmap',
      'explore_modules': 'EXPLORE MODULES',
      'start_first_quest': 'START YOUR FIRST QUEST',
      'quest_complete': 'QUEST COMPLETE!',
      'all_caught_up': "You're all caught up!",
      'change_language': 'Change Language',
    },
    'ta': {
      'continue_learning': 'தொடர்ந்து கற்கவும்',
      'your_quest': 'உங்களது தேடல்',
      'lesson_progress': 'பாடம் {current} இல் {total}',
      'continue_quest': 'தேடலைத் தொடரவும்',
      'start_quest': 'தேடலைத் தொடங்கு',
      'revision': 'திருப்புதல்',
      'quick_revision': 'விரைவு திருப்புதல்',
      'concepts_ready': '{count} கருத்துக்கள் திருப்புதலுக்குத் தயார்',
      'start_revision': 'திருப்புதலைத் தொடங்கு',
      'my_modules': 'எனது பாடங்கள்',
      'view_all': 'அனைத்தையும் பார்',
      'view_all_modules': 'அனைத்து பாடங்களையும் பார்',
      'leaderboard': 'மதிப்பெண் பட்டியல்',
      'your_class': 'உங்களது வகுப்பு',
      'view_leaderboard': 'மதிப்பெண் பட்டியலை பார்',
      'collection': 'சேகரிப்புகள்',
      'shop': 'கடை',
      'settings': 'அமைப்புகள்',
      'profile': 'சுயவிவரம்',
      'badges': 'சின்னங்கள்',
      'collectibles': 'சேகரிக்கப்பட்டவை',
      'account': 'கணக்கு',
      'logout': 'வெளியேறு',
      'language': 'மொழி',
      'sound': 'ஒலி விளைவுகள்',
      'student_id': 'மாணவர் ஐடி',
      'notifications': 'அறிவிப்புகள்',
      'quest_coins': 'தேடல் நாணயங்கள்',
      'level': 'நிலை',
      'completed': 'முடிக்கப்பட்டது',
      'current': 'தற்போதைய',
      'locked': 'பூட்டப்பட்டது',
      'insufficient_coins': 'தேவையான நாணயங்கள் இல்லை! மேலும் நாணயங்கள் பெற தொடர்ந்து கற்கவும்.',
      'purchase_success': 'வெற்றிகரமாக வாங்கப்பட்டது!',
      'already_owned': 'நீங்கள் ஏற்கனவே இதை வாங்கியுள்ளீர்கள்!',
      'start_module': 'பாடத்தைத் தொடங்கு',
      'continue_module': 'பாடத்தைத் தொடரவும்',
      'roadmap': 'பயண வழி',
      'explore_modules': 'பாடங்களை ஆராய்',
      'start_first_quest': 'முதல் தேடலைத் தொடங்கு',
      'quest_complete': 'தேடல் முடிந்தது!',
      'all_caught_up': 'அனைத்தும் படித்து முடிக்கப்பட்டது!',
      'change_language': 'மொழியை மாற்று',
    },
    'hi': {
      'continue_learning': 'सीखना जारी रखें',
      'your_quest': 'आपकी खोज',
      'lesson_progress': 'पाठ {current} का {total}',
      'continue_quest': 'खोज जारी रखें',
      'start_quest': 'खोज शुरू करें',
      'revision': 'दोहराव',
      'quick_revision': 'त्वरित दोहराव',
      'concepts_ready': '{count} अवधारणाएं दोहराव के लिए तैयार',
      'start_revision': 'दोहराव शुरू करें',
      'my_modules': 'मेरे मॉड्यूल',
      'view_all': 'सभी देखें',
      'view_all_modules': 'सभी मॉड्यूल देखें',
      'leaderboard': 'लीडरबोर्ड',
      'your_class': 'आपकी कक्षा',
      'view_leaderboard': 'लीडरबोर्ड देखें',
      'collection': 'संग्रह',
      'shop': 'दुकान',
      'settings': 'सेटिंग्स',
      'profile': 'प्रोफाइल',
      'badges': 'बैज',
      'collectibles': 'संग्रहणीय वस्तुएं',
      'account': 'खाता',
      'logout': 'लॉग आउट',
      'language': 'भाषा',
      'sound': 'ध्वनि प्रभाव',
      'student_id': 'छात्र आईडी',
      'notifications': 'सूचनाएं',
      'quest_coins': 'क्वेस्ट सिक्के',
      'level': 'स्तर',
      'completed': 'पूरा हुआ',
      'current': 'वर्तमान',
      'locked': 'तालाबंद',
      'insufficient_coins': 'पर्याप्त सिक्के नहीं हैं! अधिक सिक्के कमाने के लिए सीखना जारी रखें।',
      'purchase_success': 'सफलतापूर्वक खरीदा गया!',
      'already_owned': 'आप पहले से ही इस वस्तु के मालिक हैं!',
      'start_module': 'मॉड्यूल शुरू करें',
      'continue_module': 'मॉड्यूल जारी रखें',
      'roadmap': 'मार्गदर्शन',
      'explore_modules': 'मॉड्यूल खोजें',
      'start_first_quest': 'अपनी पहली खोज शुरू करें',
      'quest_complete': 'खोज पूरी हुई!',
      'all_caught_up': 'सब कुछ पढ़ लिया गया है!',
      'change_language': 'भाषा बदलें',
    }
  };

  static void init(StorageService storage) {
    _currentLanguage = storage.getLanguage();
  }

  static Future<void> setLanguage(StorageService storage, String langCode) async {
    if (_localizedValues.containsKey(langCode)) {
      _currentLanguage = langCode;
      await storage.saveLanguage(langCode);
    }
  }

  static String translate(String key, {Map<String, String>? args}) {
    String val = _localizedValues[_currentLanguage]?[key] ?? _localizedValues['en']?[key] ?? key;
    if (args != null) {
      args.forEach((k, v) {
        val = val.replaceAll('{$k}', v);
      });
    }
    return val;
  }
}

// Global short translation helper function
String l(String key, {Map<String, String>? args}) {
  return LocalizationService.translate(key, args: args);
}
