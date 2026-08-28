import 'package:flutter/material.dart';
import '../locator.dart';
import 'color_system.dart';

class QuestlyThemeData {
  final String id;
  final String nameKey;
  final LinearGradient backgroundGradient;
  final Color cardBackground;
  final Color primaryColor;
  final Color accentColor;
  final Color borderColor;
  final Color surfaceColor;

  const QuestlyThemeData({
    required this.id,
    required this.nameKey,
    required this.backgroundGradient,
    required this.cardBackground,
    required this.primaryColor,
    required this.accentColor,
    required this.borderColor,
    required this.surfaceColor,
  });
}

class ThemeManager {
  static const QuestlyThemeData classic = QuestlyThemeData(
    id: 'theme_classic',
    nameKey: 'theme_classic',
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFFDF9), Color(0xFFF4EFE6)],
    ),
    cardBackground: Colors.white,
    primaryColor: ColorSystem.purple,
    accentColor: ColorSystem.gold,
    borderColor: ColorSystem.plum,
    surfaceColor: Color(0xFFF4EFE6),
  );

  static const QuestlyThemeData ocean = QuestlyThemeData(
    id: 'theme_ocean',
    nameKey: 'theme_ocean',
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF0FDF4), Color(0xFFE0F2FE)],
    ),
    cardBackground: Colors.white,
    primaryColor: Color(0xFF0284C7),
    accentColor: Color(0xFF06B6D4),
    borderColor: Color(0xFF0C4A6E),
    surfaceColor: Color(0xFFBAE6FD),
  );

  static const QuestlyThemeData forest = QuestlyThemeData(
    id: 'theme_forest',
    nameKey: 'theme_forest',
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
    ),
    cardBackground: Colors.white,
    primaryColor: Color(0xFF16A34A),
    accentColor: Color(0xFF84CC16),
    borderColor: Color(0xFF14532D),
    surfaceColor: Color(0xFFBBF7D0),
  );

  static const QuestlyThemeData sunset = QuestlyThemeData(
    id: 'theme_sunset',
    nameKey: 'theme_sunset',
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
    ),
    cardBackground: Colors.white,
    primaryColor: Color(0xFFEA580C),
    accentColor: Color(0xFFF59E0B),
    borderColor: Color(0xFF7C2D12),
    surfaceColor: Color(0xFFFED7AA),
  );

  static const QuestlyThemeData space = QuestlyThemeData(
    id: 'theme_space',
    nameKey: 'theme_space',
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFAF5FF), Color(0xFFEDE9FE)],
    ),
    cardBackground: Colors.white,
    primaryColor: Color(0xFF6366F1),
    accentColor: Color(0xFFA855F7),
    borderColor: Color(0xFF312E81),
    surfaceColor: Color(0xFFDDD6FE),
  );

  static const QuestlyThemeData aurora = QuestlyThemeData(
    id: 'theme_aurora',
    nameKey: 'theme_aurora',
    backgroundGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFECFDF5), Color(0xFFE0E7FF)],
    ),
    cardBackground: Colors.white,
    primaryColor: Color(0xFF0D9488),
    accentColor: Color(0xFF6366F1),
    borderColor: Color(0xFF134E4A),
    surfaceColor: Color(0xFF99F6E4),
  );

  static QuestlyThemeData getTheme(String? themeId) {
    switch (themeId) {
      case 'theme_ocean':
        return ocean;
      case 'theme_forest':
        return forest;
      case 'theme_sunset':
        return sunset;
      case 'theme_space':
        return space;
      case 'theme_aurora':
        return aurora;
      case 'theme_classic':
      default:
        return classic;
    }
  }

  static QuestlyThemeData currentTheme() {
    final student = Locator.studentRepository.getCurrentStudent();
    return getTheme(student?.equippedThemeId);
  }
}
