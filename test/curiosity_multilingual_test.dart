import 'package:flutter_test/flutter_test.dart';
import 'package:questly/services/localization_service.dart';

void main() {
  group('Curiosity Section Multilingual Acceptance Tests', () {
    final allRequiredKeys = [
      // Intro View
      'curiosity_intro_step',
      'curiosity_intro_title',
      'curiosity_intro_q',
      'curiosity_intro_desc',
      'curiosity_start_btn',
      'curiosity_dendy_intro',
      // Water Tank Laboratory
      'curiosity_water_tank_lab',
      'curiosity_testing_object',
      'curiosity_result_match',
      'curiosity_result_diff',
      // Hypothesis Station
      'curiosity_hypothesis_station',
      'curiosity_predicted_counter',
      'curiosity_which_will_float',
      // 5 Test Objects
      'curiosity_obj_wood',
      'curiosity_desc_wood',
      'curiosity_obj_metal',
      'curiosity_desc_metal',
      'curiosity_obj_plastic',
      'curiosity_desc_plastic',
      'curiosity_obj_stone',
      'curiosity_desc_stone',
      'curiosity_obj_bottle',
      'curiosity_desc_bottle',
      // Badges and Statuses
      'curiosity_badge_floated',
      'curiosity_badge_sunk',
      'curiosity_badge_match',
      'curiosity_badge_diff',
      'curiosity_status_floats',
      'curiosity_status_sinks',
      // Toggle Buttons and Actions
      'curiosity_chip_float',
      'curiosity_chip_sink',
      'curiosity_btn_test',
      'curiosity_btn_testing',
      'curiosity_btn_select_all',
      // Reflection
      'curiosity_refl_header',
      'curiosity_refl_summary',
      'curiosity_refl_q',
      'curiosity_refl_opt0_title',
      'curiosity_refl_opt0_sub',
      'curiosity_refl_opt1_title',
      'curiosity_refl_opt1_sub',
      'curiosity_refl_opt2_title',
      'curiosity_refl_opt2_sub',
      'curiosity_refl_note',
      'curiosity_btn_complete',
      // Completion View
      'curiosity_done_title',
      'curiosity_done_sub',
      'curiosity_star_title',
      'curiosity_star_desc',
      'curiosity_reward_xp',
      'curiosity_reward_coins',
      'curiosity_btn_roadmap',
      'curiosity_btn_next_lesson',
    ];

    test('All 4 languages (en, ta, hi, or) have complete non-empty translations for every key', () {
      final languages = ['en', 'ta', 'hi', 'or'];

      for (final lang in languages) {
        for (final key in allRequiredKeys) {
          final translated = LocalizationService.translate(key, targetLanguage: lang);
          expect(
            translated.isNotEmpty,
            isTrue,
            reason: 'Key "$key" should not be empty in language "$lang"',
          );
          expect(
            translated,
            isNot(equals(key)),
            reason: 'Key "$key" should be translated and not return raw key in language "$lang"',
          );
        }
      }
    });

    test('English translations match expected terminology', () {
      expect(LocalizationService.translate('curiosity_water_tank_lab', targetLanguage: 'en'), 'WATER TANK LABORATORY');
      expect(LocalizationService.translate('curiosity_hypothesis_station', targetLanguage: 'en'), 'HYPOTHESIS STATION');
      expect(LocalizationService.translate('curiosity_obj_wood', targetLanguage: 'en'), 'WOODEN BLOCK');
      expect(LocalizationService.translate('curiosity_obj_metal', targetLanguage: 'en'), 'METAL CUBE');
      expect(LocalizationService.translate('curiosity_obj_plastic', targetLanguage: 'en'), 'PLASTIC BALL');
      expect(LocalizationService.translate('curiosity_obj_stone', targetLanguage: 'en'), 'RIVER STONE');
      expect(LocalizationService.translate('curiosity_obj_bottle', targetLanguage: 'en'), 'EMPTY BOTTLE');
      expect(LocalizationService.translate('curiosity_chip_float', targetLanguage: 'en'), 'FLOAT');
      expect(LocalizationService.translate('curiosity_chip_sink', targetLanguage: 'en'), 'SINK');
      expect(LocalizationService.translate('curiosity_badge_floated', targetLanguage: 'en'), 'FLOATED');
      expect(LocalizationService.translate('curiosity_badge_sunk', targetLanguage: 'en'), 'SUNK');
      expect(LocalizationService.translate('curiosity_btn_test', targetLanguage: 'en'), 'TEST PREDICTIONS');
      expect(LocalizationService.translate('curiosity_done_title', targetLanguage: 'en'), 'DISCOVERY COMPLETE!');
    });

    test('Tamil translations match expected terminology', () {
      expect(LocalizationService.translate('curiosity_water_tank_lab', targetLanguage: 'ta'), 'நீர் தொட்டி ஆய்வகம்');
      expect(LocalizationService.translate('curiosity_hypothesis_station', targetLanguage: 'ta'), 'கருதுகோள் நிலையம்');
      expect(LocalizationService.translate('curiosity_obj_wood', targetLanguage: 'ta'), 'மரக்கட்டை');
      expect(LocalizationService.translate('curiosity_obj_metal', targetLanguage: 'ta'), 'உலோகக் கட்டை');
      expect(LocalizationService.translate('curiosity_obj_plastic', targetLanguage: 'ta'), 'பிளாஸ்டிக் பந்து');
      expect(LocalizationService.translate('curiosity_obj_stone', targetLanguage: 'ta'), 'ஆற்றுக் கல்');
      expect(LocalizationService.translate('curiosity_obj_bottle', targetLanguage: 'ta'), 'வெற்று பாட்டில்');
      expect(LocalizationService.translate('curiosity_chip_float', targetLanguage: 'ta'), 'மிதக்கும்');
      expect(LocalizationService.translate('curiosity_chip_sink', targetLanguage: 'ta'), 'மூழ்கும்');
      expect(LocalizationService.translate('curiosity_badge_floated', targetLanguage: 'ta'), 'மிதந்தது');
      expect(LocalizationService.translate('curiosity_badge_sunk', targetLanguage: 'ta'), 'மூழ்கியது');
      expect(LocalizationService.translate('curiosity_btn_test', targetLanguage: 'ta'), 'கணிப்புகளைச் சோதிக்கவும்');
      expect(LocalizationService.translate('curiosity_done_title', targetLanguage: 'ta'), 'கண்டுபிடிப்பு முடிந்தது!');
    });

    test('Hindi translations match expected terminology', () {
      expect(LocalizationService.translate('curiosity_water_tank_lab', targetLanguage: 'hi'), 'जल टैंक प्रयोगशाला');
      expect(LocalizationService.translate('curiosity_hypothesis_station', targetLanguage: 'hi'), 'परिकल्पना स्टेशन');
      expect(LocalizationService.translate('curiosity_obj_wood', targetLanguage: 'hi'), 'लकड़ी का टुकड़ा');
      expect(LocalizationService.translate('curiosity_obj_metal', targetLanguage: 'hi'), 'धातु का घन');
      expect(LocalizationService.translate('curiosity_obj_plastic', targetLanguage: 'hi'), 'प्लास्टिक की गेंद');
      expect(LocalizationService.translate('curiosity_obj_stone', targetLanguage: 'hi'), 'नदी का पत्थर');
      expect(LocalizationService.translate('curiosity_obj_bottle', targetLanguage: 'hi'), 'खाली बोतल');
      expect(LocalizationService.translate('curiosity_chip_float', targetLanguage: 'hi'), 'तैरेगा');
      expect(LocalizationService.translate('curiosity_chip_sink', targetLanguage: 'hi'), 'डूब जाएगा');
      expect(LocalizationService.translate('curiosity_badge_floated', targetLanguage: 'hi'), 'तैरा');
      expect(LocalizationService.translate('curiosity_badge_sunk', targetLanguage: 'hi'), 'डूबा');
      expect(LocalizationService.translate('curiosity_btn_test', targetLanguage: 'hi'), 'अनुमानों का परीक्षण करें');
      expect(LocalizationService.translate('curiosity_done_title', targetLanguage: 'hi'), 'खोज पूरी हुई!');
    });

    test('Odia translations match expected terminology', () {
      expect(LocalizationService.translate('curiosity_water_tank_lab', targetLanguage: 'or'), 'ଜଳ ଟାଙ୍କି ପ୍ରୟୋଗଶାଳା');
      expect(LocalizationService.translate('curiosity_hypothesis_station', targetLanguage: 'or'), 'ଅନୁମାନ କେନ୍ଦ୍ର');
      expect(LocalizationService.translate('curiosity_obj_wood', targetLanguage: 'or'), 'କାଠ ଖଣ୍ଡ');
      expect(LocalizationService.translate('curiosity_obj_metal', targetLanguage: 'or'), 'ଧାତୁ ଘନ');
      expect(LocalizationService.translate('curiosity_obj_plastic', targetLanguage: 'or'), 'ପ୍ଲାଷ୍ଟିକ୍ ବଲ୍');
      expect(LocalizationService.translate('curiosity_obj_stone', targetLanguage: 'or'), 'ନଦୀ ପଥର');
      expect(LocalizationService.translate('curiosity_obj_bottle', targetLanguage: 'or'), 'ଖାଲି ବୋତଲ');
      expect(LocalizationService.translate('curiosity_chip_float', targetLanguage: 'or'), 'ଭାସିବ');
      expect(LocalizationService.translate('curiosity_chip_sink', targetLanguage: 'or'), 'ବୁଡ଼ିଯିବ');
      expect(LocalizationService.translate('curiosity_badge_floated', targetLanguage: 'or'), 'ଭାସିଲା');
      expect(LocalizationService.translate('curiosity_badge_sunk', targetLanguage: 'or'), 'ବୁଡ଼ିଲା');
      expect(LocalizationService.translate('curiosity_btn_test', targetLanguage: 'or'), 'ଅନୁମାନ ପରୀକ୍ଷା କରନ୍ତୁ');
      expect(LocalizationService.translate('curiosity_done_title', targetLanguage: 'or'), 'ଆବିଷ୍କାର ସମ୍ପୂର୍ଣ୍ଣ!');
    });

    test('Dynamic parameter interpolation works across all 4 languages', () {
      // Testing object
      expect(
        LocalizationService.translate('curiosity_testing_object', targetLanguage: 'en', args: {'name': 'WOODEN BLOCK'}),
        'Testing WOODEN BLOCK...',
      );
      expect(
        LocalizationService.translate('curiosity_testing_object', targetLanguage: 'ta', args: {'name': 'மரக்கட்டை'}),
        'மரக்கட்டை பரிசோதிக்கப்படுகிறது...',
      );
      expect(
        LocalizationService.translate('curiosity_testing_object', targetLanguage: 'hi', args: {'name': 'लकड़ी का टुकड़ा'}),
        'लकड़ी का टुकड़ा का परीक्षण किया जा रहा है...',
      );
      expect(
        LocalizationService.translate('curiosity_testing_object', targetLanguage: 'or', args: {'name': 'କାଠ ଖଣ୍ଡ'}),
        'କାଠ ଖଣ୍ଡ ପରୀକ୍ଷଣ ଚାଲିଛି...',
      );

      // Predicted counter
      expect(
        LocalizationService.translate('curiosity_predicted_counter', targetLanguage: 'en', args: {'count': '3', 'total': '5'}),
        '3 / 5 PREDICTED',
      );
      expect(
        LocalizationService.translate('curiosity_predicted_counter', targetLanguage: 'ta', args: {'count': '3', 'total': '5'}),
        '3 / 5 கணிக்கப்பட்டது',
      );
      expect(
        LocalizationService.translate('curiosity_predicted_counter', targetLanguage: 'hi', args: {'count': '3', 'total': '5'}),
        '3 / 5 अनुमानित',
      );
      expect(
        LocalizationService.translate('curiosity_predicted_counter', targetLanguage: 'or', args: {'count': '3', 'total': '5'}),
        '3 / 5 ଅନୁମାନିତ',
      );
    });
  });
}
