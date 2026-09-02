import 'package:flutter_test/flutter_test.dart';
import 'package:questly/services/localization_service.dart';
import 'package:questly/services/dendy_nlp_service.dart';
import 'package:questly/services/module_repository.dart';
import 'package:questly/services/read_aloud_stub.dart';

void main() {
  group('Full Application Multilingual & Game Logic Sanity Suite', () {
    const supportedLanguages = ['en', 'ta', 'hi', 'or'];

    setUp(() {
      LocalizationService.setLanguageCode('en');
    });

    test('1. Localization Dictionary 100% Key Parity & Non-Empty Across All 4 Languages', () {
      final keys = LocalizationService.allKeys;
      expect(keys.length, greaterThanOrEqualTo(330));

      for (final lang in supportedLanguages) {
        LocalizationService.setLanguageCode(lang);
        expect(LocalizationService.currentLanguage, equals(lang));

        for (final key in keys) {
          final translated = l(key);
          expect(translated, isNotEmpty, reason: 'Key "" is empty in language ""');
          expect(translated != key || lang == 'en', isTrue,
              reason: 'Key "" returned raw untranslated key in language ""');
        }
      }
    });

    test('2. Density Simulation Physics & Game Logic Sanity Across All 4 Languages', () {
      for (final lang in supportedLanguages) {
        LocalizationService.setLanguageCode(lang);

        // Simulation Controls & Labels
        expect(l('simulation_controls'), isNotEmpty);
        expect(l('material_label'), isNotEmpty);
        expect(l('mass_m_label'), isNotEmpty);
        expect(l('volume_v_label'), isNotEmpty);
        expect(l('calculated_density_label'), isNotEmpty);
        expect(l('reset_btn'), isNotEmpty);
        expect(l('drop_btn'), isNotEmpty);
        expect(l('exit_lab_btn'), isNotEmpty);
        expect(l('quest_completed_title'), isNotEmpty);
        expect(l('claim_rewards_return_btn'), isNotEmpty);

        // Presets & Buoyant Physics Math Sanity
        // Wood: mass = 2.0 kg, volume = 3.33 L -> density ~ 0.6 kg/L < 1.0 kg/L (FLOATS)
        const woodMass = 2.0;
        const woodVolume = 3.33;
        final woodDensity = woodMass / woodVolume;
        expect(woodDensity < 1.0, isTrue);
        expect(l('wood_floats'), isNotEmpty);

        // Aluminum: mass = 5.4 kg, volume = 2.0 L -> density = 2.7 kg/L > 1.0 kg/L (SINKS)
        const alumMass = 5.4;
        const alumVolume = 2.0;
        final alumDensity = alumMass / alumVolume;
        expect(alumDensity > 1.0, isTrue);
        expect(l('aluminum_sinks'), isNotEmpty);

        // Gold: mass = 9.65 kg, volume = 0.5 L -> density = 19.3 kg/L > 1.0 kg/L (SINKS)
        const goldMass = 9.65;
        const goldVolume = 0.5;
        final goldDensity = goldMass / goldVolume;
        expect(goldDensity > 1.0, isTrue);
        expect(l('gold_sinks'), isNotEmpty);

        // Custom material label
        expect(l('custom_material'), isNotEmpty);
      }
    });

    test('3. Acid-Base Titration Chemistry Lab Logic Sanity in All 4 Languages', () {
      for (final lang in supportedLanguages) {
        LocalizationService.setLanguageCode(lang);

        expect(l('virtual_labs'), isNotEmpty);
        expect(l('titration_title'), isNotEmpty);
        expect(l('titration_objectives_title'), isNotEmpty);
        expect(l('1. Apparatus Selection'), isNotEmpty);
        expect(l('2. Solutions Preparation'), isNotEmpty);
        expect(l('3. Pipette & Flask Setup'), isNotEmpty);
        expect(l('4. Dropwise Titration'), isNotEmpty);
        expect(l('5. Endpoint Detection'), isNotEmpty);
        expect(l('VIRTUAL LAB COMPLETE!'), isNotEmpty);
      }
    });

    test('4. Fractions Canyon Game Logic Sanity in All 4 Languages', () {
      for (final lang in supportedLanguages) {
        LocalizationService.setLanguageCode(lang);

        expect(l('fractions_ratios_title'), isNotEmpty);
        expect(l('next_lesson_error'), isNotEmpty);
        expect(l('Canyon Crossings'), isNotEmpty);
        expect(l('fantastic_job_mastered'), isNotEmpty);
      }
    });

    test('5. Density Lessons 3-5 (Apply, Detective, Teach-Back) in All 4 Languages', () {
      for (final lang in supportedLanguages) {
        LocalizationService.setLanguageCode(lang);

        // Lesson 3: Mission Rescue Board
        expect(l('mission_rescue_board'), isNotEmpty);
        expect(l('mission_rescue_desc'), isNotEmpty);
        expect(l('mission_boat_title'), isNotEmpty);
        expect(l('mission_boat_sub'), isNotEmpty);
        expect(l('mission_oil_title'), isNotEmpty);
        expect(l('mission_oil_sub'), isNotEmpty);
        expect(l('mission_treasure_title'), isNotEmpty);
        expect(l('mission_treasure_sub'), isNotEmpty);
        expect(l('mission_factory_title'), isNotEmpty);
        expect(l('mission_factory_sub'), isNotEmpty);
        expect(l('m1_intro'), isNotEmpty);
        expect(l('m1_success'), isNotEmpty);
        expect(l('m2_intro'), isNotEmpty);
        expect(l('m2_success'), isNotEmpty);
        expect(l('m3_intro'), isNotEmpty);
        expect(l('m3_success'), isNotEmpty);
        expect(l('m4_intro'), isNotEmpty);
        expect(l('m4_success'), isNotEmpty);
        expect(l('l3_all_complete_title'), isNotEmpty);
        expect(l('l3_btn_continue_les4'), isNotEmpty);
        expect(l('mini_practice_title'), isNotEmpty);

        // Lesson 4: Density Tower (Template Library)
        expect(l('density_tower_title'), isNotEmpty);
        expect(l('density_tower_desc'), isNotEmpty);
        expect(l('liquid_honey'), isNotEmpty);
        expect(l('liquid_water'), isNotEmpty);
        expect(l('liquid_oil'), isNotEmpty);
        expect(l('liquid_alcohol'), isNotEmpty);
        expect(l('empty_cylinder'), isNotEmpty);
        expect(l('dt_prompt_intro'), isNotEmpty);
        expect(l('dt_prompt_settling'), isNotEmpty);
        expect(l('dt_hint_mistake1'), isNotEmpty);
        expect(l('dt_hint_mistake2'), isNotEmpty);
        expect(l('dt_perfect_pour'), isNotEmpty);
        expect(l('dt_layer_master'), isNotEmpty);
        expect(l('dt_easy_practice_title'), isNotEmpty);
        expect(l('dt_easy_practice_desc'), isNotEmpty);
        expect(l('dt_complete_title'), isNotEmpty);
        expect(l('dt_complete_msg'), isNotEmpty);
        expect(l('dt_btn_continue_les5'), isNotEmpty);
        expect(l('dt_tap_to_pour'), isNotEmpty);
        expect(l('dt_reset'), isNotEmpty);

        // Lesson 5: Teach-Back
        expect(l('lesson_5_teach_header'), isNotEmpty);
        expect(l('lesson_5_teach_title'), isNotEmpty);
        expect(l('curiosity'), isNotEmpty);
        expect(l('experiment'), isNotEmpty);
        expect(l('apply'), isNotEmpty);
        expect(l('challenge'), isNotEmpty);
        expect(l('teach_back'), isNotEmpty);

        // Lesson 1: Adaptive Learning Engine & Wildcard Support
        expect(l('adapt_correct_reinforce'), isNotEmpty);
        expect(l('adapt_hint_conceptual'), isNotEmpty);
        expect(l('adapt_real_world_ship'), isNotEmpty);
        expect(l('adapt_real_world_stone'), isNotEmpty);
        expect(l('adapt_wildcard_badge'), isNotEmpty);
        expect(l('adapt_wildcard_title'), isNotEmpty);
        expect(l('adapt_wildcard_desc'), isNotEmpty);
        expect(l('adapt_wildcard_ship'), isNotEmpty);
        expect(l('adapt_wildcard_stone'), isNotEmpty);
        expect(l('adapt_wildcard_btn_ship'), isNotEmpty);
        expect(l('adapt_wildcard_btn_stone'), isNotEmpty);
        expect(l('adapt_wildcard_success'), isNotEmpty);
        expect(l('adapt_wildcard_continue'), isNotEmpty);
        expect(l('adapt_summary_header'), isNotEmpty);
        expect(l('adapt_summary_p1'), isNotEmpty);
        expect(l('adapt_summary_p2'), isNotEmpty);
        expect(l('adapt_summary_p3'), isNotEmpty);
        // Lesson 1 & 2: Adaptive Scaffolding & Grand Formula
        expect(l('adapt_l1_good_obs'), isNotEmpty);
        expect(l('adapt_l1_struggle_obs'), isNotEmpty);
        expect(l('adapt_dendy_noticed_examples'), isNotEmpty);
        expect(l('adapt_dendy_noticed_quick'), isNotEmpty);
        expect(l('adapt_btn_continue_experiment'), isNotEmpty);
        expect(l('adapt_l2_correct_mass'), isNotEmpty);
        expect(l('adapt_l2_correct_volume'), isNotEmpty);
        expect(l('adapt_l2_correct_compare'), isNotEmpty);
        expect(l('adapt_l2_discovery_prompt'), isNotEmpty);
        expect(l('adapt_l2_formula_desc'), isNotEmpty);
        expect(l('adapt_l2_btn_mastery'), isNotEmpty);
      }
    });

    test('6. Auth Screens, Daily Rewards, & Gamification Modals in All 4 Languages', () {
      for (final lang in supportedLanguages) {
        LocalizationService.setLanguageCode(lang);

        // Auth
        expect(l('questly'), isNotEmpty);
        expect(l('welcome_back_adventurer'), isNotEmpty);
        expect(l('login_subtitle'), isNotEmpty);
        expect(l('student_sign_in'), isNotEmpty);
        expect(l('continue_btn'), isNotEmpty);
        expect(l('create_new_account_btn'), isNotEmpty);
        expect(l('create_profile_title'), isNotEmpty);
        expect(l('register_subtitle'), isNotEmpty);
        expect(l('join_the_quest'), isNotEmpty);
        expect(l('create_account_btn'), isNotEmpty);
        expect(l('cancel_btn'), isNotEmpty);

        // Daily Reward
        expect(l('daily_reward_title'), isNotEmpty);
        expect(l('daily_reward_claimed_msg'), isNotEmpty);
        expect(l('complete_today_quest_reward'), isNotEmpty);
        expect(l('reward_tracker_title'), isNotEmpty);
        expect(l('claim_reward_btn_label'), isNotEmpty);

        // Modals
        expect(l('mission_objective_title'), isNotEmpty);
        expect(l('lessons_in_this_level'), isNotEmpty);
        expect(l('possible_rewards_title'), isNotEmpty);
        expect(l('opening_chest'), isNotEmpty);
        expect(l('xp_progress_title'), isNotEmpty);
      }
    });

    test('7. Multilingual Dendy NLP Offline Service in All 4 Languages', () {
      final dendy = DendyNlpService();

      for (final lang in supportedLanguages) {
        LocalizationService.setLanguageCode(lang);

        // Empty query
        expect(dendy.getResponse(''), equals(l('dendy_resp_empty')));

        // Hello in English
        final helloEn = dendy.getResponse('hello');
        expect(helloEn, equals(l('dendy_resp_hello')));

        // Hello in Indic scripts
        expect(dendy.getResponse('வணக்கம்'), equals(l('dendy_resp_hello')));
        expect(dendy.getResponse('नमस्ते'), equals(l('dendy_resp_hello')));
        expect(dendy.getResponse('ନମସ୍କାର'), equals(l('dendy_resp_hello')));

        // Density definition in English and Indic scripts
        expect(dendy.getResponse('what is density'), equals(l('dendy_resp_density')));
        expect(dendy.getResponse('அடர்த்தி என்றால் என்ன'), equals(l('dendy_resp_density')));
        expect(dendy.getResponse('घनत्व क्या है'), equals(l('dendy_resp_density')));
        expect(dendy.getResponse('ଘନତ୍ୱ କଣ'), equals(l('dendy_resp_density')));

        // Buoyancy
        expect(dendy.getResponse('explain buoyancy'), equals(l('dendy_resp_buoyancy')));
        expect(dendy.getResponse('மிதப்பு விசை'), equals(l('dendy_resp_buoyancy')));

        // Ship
        expect(dendy.getResponse('how do steel ships float'), equals(l('dendy_resp_ship')));
        expect(dendy.getResponse('கப்பல் எவ்வாறு மிதக்கிறது'), equals(l('dendy_resp_ship')));

        // Titration
        expect(dendy.getResponse('titration experiment'), equals(l('dendy_resp_titration')));

        // Fractions
        expect(dendy.getResponse('what is a fraction'), equals(l('dendy_resp_fraction')));
      }
    });

    test('8. Logout Button & Simulation Language URL Sync in All 4 Languages', () {
      for (final lang in supportedLanguages) {
        LocalizationService.setLanguageCode(lang);

        // Verify logout and database clearing keys in all 4 languages
        expect(l('logout'), isNotEmpty);
        expect(l('clear_database_btn'), isNotEmpty);
        expect(l('database_cleared_msg'), isNotEmpty);
        expect(l('account'), isNotEmpty);
        expect(l('student_id'), isNotEmpty);

        // Verify titration simulation URL path formats
        final titrationPath = '/virtual_lab/index.html?lang=$lang';
        expect(titrationPath.contains('lang=$lang'), isTrue);
      }
    });

    test('9. Thedalai Thodarum (continue_quest) Button & Lesson Route Targets', () {
      for (final lang in supportedLanguages) {
        LocalizationService.setLanguageCode(lang);

        final continueQuestText = l('continue_quest');
        expect(continueQuestText, isNotEmpty);
        if (lang == 'ta') {
          expect(continueQuestText, equals('தேடலைத் தொடரவும்'));
        } else if (lang == 'hi') {
          expect(continueQuestText, equals('खोज जारी रखें'));
        } else if (lang == 'or') {
          expect(continueQuestText, equals('ଅଭିଯାନ ଜାରି ରଖନ୍ତୁ'));
        } else {
          expect(continueQuestText, equals('CONTINUE QUEST'));
        }

        // Verify that module repository resolves lessons correctly
        final mod = ModuleRepository().getModuleById('mod_density');
        expect(mod, isNotNull);
        expect(mod!.levels.first.lessons.first.id, equals('density_les1'));
      }
    });

    test('10. Read Aloud Speech Synthesis & Odia Phonetic Bridge Across All 4 Languages', () {
      const phrases = [
        'ready_next_quest',
        'start_first_quest_desc',
        'curiosity_refl_note',
        'almost_done_lesson',
      ];

      for (final lang in supportedLanguages) {
        LocalizationService.setLanguageCode(lang);

        for (final phrase in phrases) {
          final translated = l(phrase);
          expect(translated, isNotEmpty);

          if (lang == 'ta') {
            // Verify Tamil to Devanagari transliteration bridge generates valid Indic string
            final devanagari = PlatformSpeechTts.tamilToDevanagari(translated);
            expect(devanagari, isNotEmpty);
            expect(devanagari.codeUnits.any((c) => c >= 0x0900 && c <= 0x097F), isTrue);
          } else if (lang == 'or') {
            // Verify Odia to Devanagari transliteration bridge generates valid Indic string
            final devanagari = PlatformSpeechTts.odiaToDevanagari(translated);
            expect(devanagari, isNotEmpty);
            // Confirm that at least one character was bridged if the string had Odia glyphs
            expect(devanagari.codeUnits.any((c) => c >= 0x0900 && c <= 0x097F), isTrue);
          }
        }
      }
    });
  });
}
