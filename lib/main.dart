import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/locator.dart';
import 'core/theme/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/game_screen.dart';
import 'screens/module_overview_screen.dart';
import 'screens/roadmap_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/activity_renderer_screen.dart';
import 'screens/curiosity_discovery_screen.dart';
import 'screens/virtual_lab_screen.dart';
import 'screens/fraction_module_screen.dart';
import 'screens/density_experiment_screen.dart';
import 'screens/density_apply_screen.dart';
import 'screens/density_detective_screen.dart';
import 'screens/density_teach_back_screen.dart';
import 'screens/fraction_concept_screen.dart';
import 'screens/fraction_visual_screen.dart';
import 'screens/fraction_practice_screen.dart';
import 'screens/fraction_challenge_screen.dart';
import 'screens/fraction_teach_dendy_screen.dart';
import 'screens/developer_settings_screen.dart';
import 'services/localization_service.dart';

void main() async {
  // Ensure Flutter engine hooks are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce landscape orientation on native mobile platforms
  if (!kIsWeb) {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } catch (_) {}
  }

  // Guarantee all repositories & services are initialized before any route builds
  await Locator.setup();

  runApp(const QuestlyApp());
}

class QuestlyApp extends StatelessWidget {
  const QuestlyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocalizationService.languageNotifier,
      builder: (context, currentLanguage, _) {
        return MaterialApp(
          key: const ValueKey('questly_app'),
          title: 'Questly',
          debugShowCheckedModeBanner: false,
          theme: QuestlyTheme.lightTheme,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/login': (context) => const LoginScreen(),
            '/register': (context) => const RegisterScreen(),
            '/home': (context) => const HomeScreen(),
            '/game': (context) => const GameScreen(),
            '/module_overview': (context) => const ModuleOverviewScreen(),
            '/roadmap': (context) => const RoadmapScreen(),
            '/leaderboard': (context) => const LeaderboardScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/activity_renderer': (context) => const ActivityRendererScreen(),
            '/curiosity_discovery': (context) => const CuriosityDiscoveryScreen(),
            '/density_experiment': (context) => const DensityExperimentScreen(),
            '/density_apply': (context) => const DensityApplyScreen(),
            '/density_detective': (context) => const DensityDetectiveScreen(),
            '/density_teach_back': (context) => const DensityTeachBackScreen(),
            '/virtual_lab': (context) => const VirtualLabScreen(),
            '/fraction_module': (context) => const FractionModuleScreen(),
            '/fraction_concept': (context) => const FractionConceptScreen(),
            '/fraction_visual': (context) => const FractionVisualScreen(),
            '/fraction_practice': (context) => const FractionPracticeScreen(),
            '/fraction_challenge': (context) => const FractionChallengeScreen(),
            '/fraction_teach_dendy': (context) => const FractionTeachDendyScreen(),
            '/dev_settings': (context) => const DeveloperSettingsScreen(),
          },
        );
      },
    );
  }
}
