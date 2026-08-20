import 'package:flutter/foundation.dart';
import '../core/locator.dart';
import 'storage_service.dart';

class LocalizationService {
  static String _currentLanguage = 'en';
  static final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');

  static String get currentLanguage => _currentLanguage;

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Navigation & Dashboard
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
      'home': 'Home',
      'back': 'BACK',
      'close': 'Close',

      // Missions
      'missions': 'Missions',
      'daily_missions': 'DAILY MISSIONS',
      'weekly_missions': 'WEEKLY MISSIONS',
      'daily': 'DAILY',
      'weekly': 'WEEKLY',
      'resets_daily': 'Resets daily at midnight',
      'resets_weekly': 'Resets every Monday',
      'claim_reward_btn': 'CLAIM REWARD!',
      'claimed_btn': 'CLAIMED',
      'complete_2_lessons': 'Complete 2 Lessons',
      'earn_100_xp': 'Earn 100 XP',
      'finish_1_simulation_lab': 'Finish 1 Simulation Lab',
      'master_1_full_module': 'Master 1 Full Module',
      'earn_500_weekly_xp': 'Earn 500 Weekly XP',
      'complete_any_2_curiosity_or_lab_lessons': 'Complete any 2 curiosity or lab lessons',
      'gain_100_xp_from_quests_and_activities': 'Gain 100 XP from quests and activities',
      'conduct_any_phet_or_titration_lab_experiment': 'Conduct any PhET or titration lab experiment',
      'finish_all_5_interactive_lessons_in_a_topic': 'Finish all 5 interactive lessons in a topic',
      'gather_500_total_xp_across_the_entire_week': 'Gather 500 total XP across the entire week',

      // Daily Rewards
      'daily_login_reward': 'DAILY LOGIN REWARD',
      'day_streak': '{day}-Day Streak',
      'streak_day': 'Day {day}',
      'claim_reward': 'CLAIM REWARD',
      'mystery_chest': 'MYSTERY CHEST',
      'reward_claimed': 'REWARD CLAIMED!',
      'come_back_tomorrow': 'Come back tomorrow for Day {day} reward!',
      'streak_complete': '7-day streak complete! Next cycle begins tomorrow.',
      'claimed': 'CLAIMED',

      // Ask Dendy
      'ask_dendy': 'ASK DENDY',
      'dendy_companion': 'Dendy AI Companion',
      'ask_me_anything': 'Ask me anything about science or math!',
      'listening': 'Listening...',
      'tap_to_speak': 'Tap mic to speak or type below',
      'type_question': 'Type your question...',
      'suggested_questions': 'Suggested Questions:',
      'why_wood_float': 'Why does wood float in water?',
      'how_steel_ships_float': 'How do steel ships float?',
      'why_ice_float': 'Why does ice float?',
      'what_is_density': 'What is density?',
      'what_is_titration': 'What is titration in chemistry?',
      'dendy_learning_fallback': "I'm still learning! My offline AI will answer this in a future version. Try asking me about density, floating, buoyancy, titration, or fractions!",

      // Dendy Dialogues & Mascots
      'ready_next_quest': 'Ready for your next quest?',
      'almost_done_lesson': 'You are almost done with this lesson!',
      'all_science_quests_complete': 'Excellent! You completed all the physical science lab quests!',
      'start_first_quest_desc': "Start your first quest! Let's find something new to explore!",
      'investigate_reasons_lab': 'We will investigate the exact reasons and measurements in the next experiment lab!',
      'discovery_complete': 'DISCOVERY COMPLETE!',
      'predictions_tested': 'You made your predictions and tested them.',
      'carefully_check_parameters': 'Carefully check the parameters before selecting your answer!',
      'keep_trying_density_formula': 'Keep trying! Think about the density formula.',
      'lab_description': 'LAB DESCRIPTION',
      'titration_objectives': 'TITRATION OBJECTIVES',
      'apparatus_selection': '1. Apparatus Selection',
      'level_up': 'LEVEL UP!',
      'reached_level': 'YOU REACHED LEVEL {level}!',
      'continue_adventure': 'CONTINUE ADVENTURE',
      'bonus_xp': 'Bonus XP',
      'rank_promoted': 'Promoted',
      'fantastic_job_mastered': 'Fantastic job! You mastered this challenge and earned rewards.',
      'continue_next_lesson': 'CONTINUE TO NEXT LESSON',

      // Scientific Concepts
      'steel_ship_explanation': 'A hollow steel ship floats because the air trapped inside its massive hull lowers its total average density below 1.00 kg/L.',
      'ice_expands_title': 'Ice Expands & Defies Normal Solids',
      'ice_expands_body': 'Water expands when freezing, giving ice a density of 0.92 kg/L. That is why ice floats and supports Arctic life.',
      'liquids_layer_title': 'Liquids Naturally Layer by Density',
      'liquids_layer_body': 'When immiscible fluids meet, lighter fluids (like oil at ~0.92 kg/L) float on top of denser fluids (like water at 1.00 kg/L).',
      'complete_and_unlock': 'COMPLETE & UNLOCK CHALLENGE',
    },
    'ta': {
      // Navigation & Dashboard
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
      'home': 'முகப்பு',
      'back': 'பின்செல்',
      'close': 'மூடு',

      // Missions
      'missions': 'பணிகள்',
      'daily_missions': 'தினசரி பணிகள்',
      'weekly_missions': 'வாராந்திர பணிகள்',
      'daily': 'தினசரி',
      'weekly': 'வாராந்திரம்',
      'resets_daily': 'தினமும் நள்ளிரவில் புதுப்பிக்கப்படும்',
      'resets_weekly': 'ஒவ்வொரு திங்கட்கிழமையும் புதுப்பிக்கப்படும்',
      'claim_reward_btn': 'பரிசைப் பெறு!',
      'claimed_btn': 'பெறப்பட்டது',
      'complete_2_lessons': '2 பாடங்களை முடிக்கவும்',
      'earn_100_xp': '100 XP சம்பாதிக்கவும்',
      'finish_1_simulation_lab': '1 ஆய்வக பரிசோதனையை முடிக்கவும்',
      'master_1_full_module': '1 முழு பாடப்பிரிவில் தேர்ச்சி பெறவும்',
      'earn_500_weekly_xp': '500 வாராந்திர XP சம்பாதிக்கவும்',
      'complete_any_2_curiosity_or_lab_lessons': 'ஏதேனும் 2 ஆய்வக அல்லது தேடல் பாடங்களை முடிக்கவும்',
      'gain_100_xp_from_quests_and_activities': 'பாடங்கள் மற்றும் செயல்களில் இருந்து 100 XP பெறவும்',
      'conduct_any_phet_or_titration_lab_experiment': 'ஏதேனும் ஒரு PhET அல்லது டைட்ரேஷன் பரிசோதனையைச் செய்யவும்',
      'finish_all_5_interactive_lessons_in_a_topic': 'ஒரு தலைப்பில் உள்ள அனைத்து 5 பாடங்களையும் முடிக்கவும்',
      'gather_500_total_xp_across_the_entire_week': 'வாரம் முழுவதும் மொத்தம் 500 XP பெறவும்',

      // Daily Rewards
      'daily_login_reward': 'தினசரி உள்நுழைவு பரிசு',
      'day_streak': '{day}-நாள் தொடர்',
      'streak_day': 'நாள் {day}',
      'claim_reward': 'பரிசைப் பெறு',
      'mystery_chest': 'மர்மப் பெட்டி',
      'reward_claimed': 'பரிசு பெறப்பட்டது!',
      'come_back_tomorrow': 'நாள் {day} பரிசுக்காக நாளை மீண்டும் வாருங்கள்!',
      'streak_complete': '7-நாள் தொடர் முடிந்தது! அடுத்த சுழற்சி நாளை தொடங்கும்.',
      'claimed': 'பெறப்பட்டது',

      // Ask Dendy
      'ask_dendy': 'டெண்டியிடம் கேள்',
      'dendy_companion': 'டெண்டி AI தோழன்',
      'ask_me_anything': 'அறிவியல் அல்லது கணிதம் பற்றி என்னிடம் எதையும் கேளுங்கள்!',
      'listening': 'கேட்கிறது...',
      'tap_to_speak': 'பேச மைக்-ஐ அழுத்தவும் அல்லது கீழே தட்டச்சு செய்யவும்',
      'type_question': 'உங்கள் கேள்வியைத் தட்டச்சு செய்க...',
      'suggested_questions': 'பரிந்துரைக்கப்பட்ட கேள்விகள்:',
      'why_wood_float': 'மரம் ஏன் தண்ணீரில் மிதக்கிறது?',
      'how_steel_ships_float': 'எஃகு கப்பல்கள் எவ்வாறு மிதக்கின்றன?',
      'why_ice_float': 'பனிக்கட்டி ஏன் மிதக்கிறது?',
      'what_is_density': 'அடர்த்தி என்றால் என்ன?',
      'what_is_titration': 'வேதியியலில் டைட்ரேஷன் என்றால் என்ன?',
      'dendy_learning_fallback': 'நான் இன்னும் கற்றுக்கொண்டு வருகிறேன்! எனது ஆஃப்லைன் AI எதிர்கால பதிப்பில் இதற்குப் பதிலளிக்கும். அடர்த்தி, மிதத்தல், மிதப்பு விசை, அல்லது பின்னங்கள் பற்றி என்னிடம் கேளுங்கள்!',

      // Dendy Dialogues & Mascots
      'ready_next_quest': 'உங்களது அடுத்த தேடலுக்குத் தயாரா?',
      'almost_done_lesson': 'நீங்கள் இந்த பாடத்தை கிட்டத்தட்ட முடித்துவிட்டீர்கள்!',
      'all_science_quests_complete': 'அற்புதம்! அனைத்து இயற்பியல் அறிவியல் ஆய்வக தேடல்களையும் முடித்துவிட்டீர்கள்!',
      'start_first_quest_desc': 'உங்கள் முதல் தேடலைத் தொடங்குங்கள்! புதியதைக் கற்றுக்கொள்வோம்!',
      'investigate_reasons_lab': 'அடுத்த ஆய்வகத்தில் இதற்கான சரியான காரணங்களையும் அளவீடுகளையும் நாம் ஆராய்வோம்!',
      'discovery_complete': 'கண்டுபிடிப்பு முடிந்தது!',
      'predictions_tested': 'நீங்கள் உங்களது கணிப்புகளைச் செய்து அவற்றை சோதித்தீர்கள்.',
      'carefully_check_parameters': 'பதிலைத் தேர்ந்தெடுப்பதற்கு முன் அளவுருக்களை கவனமாகச் சரிபார்க்கவும்!',
      'keep_trying_density_formula': 'தொடர்ந்து முயற்சிக்கவும்! அடர்த்தி சூத்திரத்தை நினைவில் கொள்ளுங்கள்.',
      'lab_description': 'ஆய்வக விளக்கம்',
      'titration_objectives': 'டைட்ரேஷன் நோக்கங்கள்',
      'apparatus_selection': '1. கருவிகள் தேர்வு',
      'level_up': 'புதிய நிலை!',
      'reached_level': 'நீங்கள் நிலை {level}-ஐ அடைந்துவிட்டீர்கள்!',
      'continue_adventure': 'பயணத்தைத் தொடரவும்',
      'bonus_xp': 'கூடுதல் XP',
      'rank_promoted': 'பதவி உயர்வு',
      'fantastic_job_mastered': 'அருமையான வேலை! நீங்கள் இந்த சவாலில் தேர்ச்சி பெற்று பரிசுகளைப் பெற்றுள்ளீர்கள்.',
      'continue_next_lesson': 'அடுத்த பாடத்திற்குச் செல்லவும்',

      // Scientific Concepts
      'steel_ship_explanation': 'ஒரு வெற்று எஃகு கப்பல் மிதக்கிறது, ஏனெனில் அதன் உள்ளே உள்ள காற்று அதன் மொத்த சராசரி அடர்த்தியைக் குறைக்கிறது.',
      'ice_expands_title': 'பனிக்கட்டி விரிவடைகிறது மற்றும் சாதாரண திடப்பொருட்களை விட மாறுபடுகிறது',
      'ice_expands_body': 'நீர் உறையும் போது விரிவடைந்து 0.92 kg/L அடர்த்தியைப் பெறுகிறது. அதனால்தான் பனிக்கட்டி மிதக்கிறது.',
      'liquids_layer_title': 'திரவங்கள் அடர்த்தியின் அடிப்படையில் இயல்பாக அடுக்குகளாக அமைகின்றன',
      'liquids_layer_body': 'கலக்காத திரவங்கள் சேரும்போது, குறைந்த அடர்த்தி கொண்ட திரவங்கள் (எண்ணெய் போன்றவை) அதிக அடர்த்தி கொண்ட திரவங்களின் மேல் மிதக்கின்றன.',
      'complete_and_unlock': 'முடிக்கப்பட்டு சவாலைத் திறக்கவும்',
    },
    'hi': {
      // Navigation & Dashboard
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
      'home': 'होम',
      'back': 'पीछे',
      'close': 'बंद करें',

      // Missions
      'missions': 'मिशन',
      'daily_missions': 'दैनिक मिशन',
      'weekly_missions': 'साप्ताहिक मिशन',
      'daily': 'दैनिक',
      'weekly': 'साप्ताहिक',
      'resets_daily': 'प्रतिदिन मध्यरात्रि को रीसेट होता है',
      'resets_weekly': 'हर सोमवार को रीसेट होता है',
      'claim_reward_btn': 'इनाम प्राप्त करें!',
      'claimed_btn': 'प्राप्त किया',
      'complete_2_lessons': '2 पाठ पूरे करें',
      'earn_100_xp': '100 XP अर्जित करें',
      'finish_1_simulation_lab': '1 प्रयोगशाला सिमुलेशन पूरा करें',
      'master_1_full_module': '1 पूरा मॉड्यूल पूरा करें',
      'earn_500_weekly_xp': '500 साप्ताहिक XP अर्जित करें',
      'complete_any_2_curiosity_or_lab_lessons': 'कोई भी 2 पाठ या प्रयोगशाला सत्र पूरे करें',
      'gain_100_xp_from_quests_and_activities': 'खोजों और गतिविधियों से 100 XP प्राप्त करें',
      'conduct_any_phet_or_titration_lab_experiment': 'कोई भी PhET या अनुमापन प्रयोग करें',
      'finish_all_5_interactive_lessons_in_a_topic': 'एक विषय में सभी 5 पाठ पूरे करें',
      'gather_500_total_xp_across_the_entire_week': 'पूरे सप्ताह में कुल 500 XP एकत्र करें',

      // Daily Rewards
      'daily_login_reward': 'दैनिक लॉगिन इनाम',
      'day_streak': '{day}-दिन की लकीर',
      'streak_day': 'दिन {day}',
      'claim_reward': 'इनाम प्राप्त करें',
      'mystery_chest': 'रहस्यमय संदूक',
      'reward_claimed': 'इनाम प्राप्त हुआ!',
      'come_back_tomorrow': 'दिन {day} के इनाम के लिए कल वापस आएं!',
      'streak_complete': '7-दिन की लकीर पूरी हुई! अगला चक्र कल शुरू होगा।',
      'claimed': 'प्राप्त किया',

      // Ask Dendy
      'ask_dendy': 'डेंडी से पूछें',
      'dendy_companion': 'डेंडी एआई साथी',
      'ask_me_anything': 'विज्ञान या गणित के बारे में मुझसे कुछ भी पूछें!',
      'listening': 'सुन रहा है...',
      'tap_to_speak': 'बोलने के लिए माइक दबाएं या नीचे टाइप करें',
      'type_question': 'अपना प्रश्न टाइप करें...',
      'suggested_questions': 'सुझाए गए प्रश्न:',
      'why_wood_float': 'लकड़ी पानी में क्यों तैरती है?',
      'how_steel_ships_float': 'स्टील के जहाज कैसे तैरते हैं?',
      'why_ice_float': 'बर्फ क्यों तैरती है?',
      'what_is_density': 'घनत्व क्या है?',
      'what_is_titration': 'रसायन विज्ञान में अनुमापन क्या है?',
      'dendy_learning_fallback': 'मैं अभी सीख रहा हूँ! मेरा ऑफ़लाइन एआई भविष्य के संस्करण में इसका उत्तर देगा। मुझसे घनत्व, तैरना, उत्प्लावन या भिन्नों के बारे में पूछें!',

      // Dendy Dialogues & Mascots
      'ready_next_quest': 'अपनी अगली खोज के लिए तैयार हैं?',
      'almost_done_lesson': 'आप इस पाठ को लगभग पूरा कर चुके हैं!',
      'all_science_quests_complete': 'उत्कृष्ट! आपने सभी भौतिक विज्ञान प्रयोगशाला खोजों को पूरा कर लिया है!',
      'start_first_quest_desc': 'अपनी पहली खोज शुरू करें! आइए कुछ नया सीखें!',
      'investigate_reasons_lab': 'हम अगली प्रयोग प्रयोगशाला में सटीक कारणों और मापों की जांच करेंगे!',
      'discovery_complete': 'खोज पूरी हुई!',
      'predictions_tested': 'आपने अपने अनुमान लगाए और उनका परीक्षण किया।',
      'carefully_check_parameters': 'अपना उत्तर चुनने से पहले मापदंडों की सावधानीपूर्वक जांच करें!',
      'keep_trying_density_formula': 'प्रयास जारी रखें! घनत्व सूत्र के बारे में सोचें।',
      'lab_description': 'प्रयोगशाला विवरण',
      'titration_objectives': 'अनुमापन उद्देश्य',
      'apparatus_selection': '1. उपकरण चयन',
      'level_up': 'स्तर बढ़ा!',
      'reached_level': 'आप स्तर {level} पर पहुँच गए हैं!',
      'continue_adventure': 'साहसिक कार्य जारी रखें',
      'bonus_xp': 'बोनस XP',
      'rank_promoted': 'रैंक पदोन्नत',
      'fantastic_job_mastered': 'शानदार काम! आपने इस चुनौती में महारत हासिल की और पुरस्कार अर्जित किए।',
      'continue_next_lesson': 'अगले पाठ पर आगे बढ़ें',

      // Scientific Concepts
      'steel_ship_explanation': 'एक खोखला स्टील का जहाज तैरता है क्योंकि उसके अंदर फंसी हवा उसके कुल औसत घनत्व को कम कर देती है।',
      'ice_expands_title': 'बर्फ फैलती है और सामान्य ठोस पदार्थों से भिन्न होती है',
      'ice_expands_body': 'जमने पर पानी फैलता है, जिससे बर्फ का घनत्व 0.92 kg/L हो जाता है। इसीलिए बर्फ तैरती है।',
      'liquids_layer_title': 'तरल पदार्थ घनत्व के आधार पर स्वाभाविक रूप से परत बनाते हैं',
      'liquids_layer_body': 'जब अमिश्रणीय तरल पदार्थ मिलते हैं, तो हल्के तरल पदार्थ भारी तरल पदार्थों के ऊपर तैरते हैं।',
      'complete_and_unlock': 'पूरा करें और चुनौती अनलॉक करें',
    }
  };

  // Bidirectional English-phrase to Translation mapping dictionary
  static final Map<String, String> _phraseToKey = {
    'Continue Learning': 'continue_learning',
    'YOUR QUEST': 'your_quest',
    'CONTINUE QUEST': 'continue_quest',
    'START QUEST': 'start_quest',
    'QUICK REVISION': 'quick_revision',
    'My Modules': 'my_modules',
    'VIEW ALL': 'view_all',
    'VIEW ALL MODULES': 'view_all_modules',
    'Leaderboard': 'leaderboard',
    'YOUR CLASS': 'your_class',
    'VIEW LEADERBOARD': 'view_leaderboard',
    'Collection': 'collection',
    'Shop': 'shop',
    'Settings': 'settings',
    'Profile': 'profile',
    'Badges': 'badges',
    'Collectibles': 'collectibles',
    'Account': 'account',
    'Log Out': 'logout',
    'LOG OUT': 'logout',
    'Language': 'language',
    'Sound Effects': 'sound',
    'Student ID': 'student_id',
    'Notifications': 'notifications',
    'Quest Coins': 'quest_coins',
    'Level': 'level',
    'Roadmap': 'roadmap',
    'EXPLORE MODULES': 'explore_modules',
    'START YOUR FIRST QUEST': 'start_first_quest',
    'QUEST COMPLETE!': 'quest_complete',
    'Change Language': 'change_language',
    'DAILY MISSIONS': 'daily_missions',
    'WEEKLY MISSIONS': 'weekly_missions',
    'DAILY': 'daily',
    'WEEKLY': 'weekly',
    'CLAIM REWARD!': 'claim_reward_btn',
    'CLAIMED': 'claimed_btn',
    'Complete 2 Lessons': 'complete_2_lessons',
    'Earn 100 XP': 'earn_100_xp',
    'Finish 1 Simulation Lab': 'finish_1_simulation_lab',
    'Master 1 Full Module': 'master_1_full_module',
    'Earn 500 Weekly XP': 'earn_500_weekly_xp',
    'DAILY LOGIN REWARD': 'daily_login_reward',
    'CLAIM REWARD': 'claim_reward',
    'MYSTERY CHEST': 'mystery_chest',
    'REWARD CLAIMED!': 'reward_claimed',
    'ASK DENDY': 'ask_dendy',
    'Ask Dendy': 'ask_dendy',
    'Dendy AI Companion': 'dendy_companion',
    'Ask me anything about science or math!': 'ask_me_anything',
    'Listening...': 'listening',
    'Type your question...': 'type_question',
    'Ready for your next quest?': 'ready_next_quest',
    'You are almost done with this lesson!': 'almost_done_lesson',
    'Excellent! You completed all the physical science lab quests!': 'all_science_quests_complete',
    "Start your first quest! Let's find something new to explore!": 'start_first_quest_desc',
    'We will investigate the exact reasons and measurements in the next experiment lab!': 'investigate_reasons_lab',
    'DISCOVERY COMPLETE!': 'discovery_complete',
    'You made your predictions and tested them.': 'predictions_tested',
    'Carefully check the parameters before selecting your answer!': 'carefully_check_parameters',
    'Keep trying! Think about the density formula.': 'keep_trying_density_formula',
    'LAB DESCRIPTION': 'lab_description',
    'TITRATION OBJECTIVES': 'titration_objectives',
    'LEVEL UP!': 'level_up',
    'CONTINUE ADVENTURE': 'continue_adventure',
    'Bonus XP': 'bonus_xp',
    'Fantastic job! You mastered this challenge and earned rewards.': 'fantastic_job_mastered',
    'CONTINUE TO NEXT LESSON': 'continue_next_lesson',
    'A hollow steel ship floats because the air trapped inside its massive hull lowers its total average density below 1.00 kg/L.': 'steel_ship_explanation',
    'Ice Expands & Defies Normal Solids': 'ice_expands_title',
    'Water expands when freezing, giving ice a density of 0.92 kg/L. That is why ice floats and supports Arctic life.': 'ice_expands_body',
    'Liquids Naturally Layer by Density': 'liquids_layer_title',
    'When immiscible fluids meet, lighter fluids (like oil at ~0.92 kg/L) float on top of denser fluids (like water at 1.00 kg/L).': 'liquids_layer_body',
  };

  static void init(StorageService storage) {
    _currentLanguage = storage.getLanguage();
    languageNotifier.value = _currentLanguage;
  }

  static Future<void> setLanguage(StorageService storage, String langCode) async {
    if (_localizedValues.containsKey(langCode)) {
      _currentLanguage = langCode;
      languageNotifier.value = langCode;
      await storage.saveLanguage(langCode);

      final currentStudent = Locator.studentRepository.getCurrentStudent();
      if (currentStudent != null) {
        final updated = currentStudent.copyWith(language: langCode);
        await Locator.studentRepository.updateStudentProfile(updated);
      }
    }
  }

  static String translate(String keyOrText, {String? targetLanguage, Map<String, String>? args}) {
    final lang = targetLanguage ?? _currentLanguage;
    final dict = _localizedValues[lang] ?? _localizedValues['en']!;

    // 1. Direct key match
    if (dict.containsKey(keyOrText)) {
      String val = dict[keyOrText]!;
      if (args != null) {
        args.forEach((k, v) => val = val.replaceAll('{$k}', v));
      }
      return val;
    }

    // 2. Direct English phrase match from dictionary
    final mappedKey = _phraseToKey[keyOrText.trim()];
    if (mappedKey != null && dict.containsKey(mappedKey)) {
      String val = dict[mappedKey]!;
      if (args != null) {
        args.forEach((k, v) => val = val.replaceAll('{$k}', v));
      }
      return val;
    }

    // 3. Fallback to English dictionary lookup
    final enDict = _localizedValues['en']!;
    if (enDict.containsKey(keyOrText)) {
      String val = enDict[keyOrText]!;
      if (args != null) {
        args.forEach((k, v) => val = val.replaceAll('{$k}', v));
      }
      return val;
    }

    // Return original string if untranslated
    String result = keyOrText;
    if (args != null) {
      args.forEach((k, v) => result = result.replaceAll('{$k}', v));
    }
    return result;
  }
}

// Global short translation helper function
String l(String key, {Map<String, String>? args}) {
  return LocalizationService.translate(key, args: args);
}
