import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/student.dart';
import '../widgets/custom_button.dart';
import '../widgets/questly_background.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Student? _student;
  bool _soundEnabled = true;
  String _selectedLang = 'en';

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  void _loadState() {
    final s = Locator.studentRepository.getCurrentStudent();
    if (s != null) {
      setState(() {
        _student = s;
        _soundEnabled = SoundService.soundEnabled;
        _selectedLang = LocalizationService.currentLanguage;
      });
    }
  }

  Future<void> _changeLanguage(String langCode) async {
    await LocalizationService.setLanguage(Locator.storageService, langCode);
    if (_student != null) {
      final updated = _student!.copyWith(language: langCode);
      await Locator.studentRepository.updateStudentProfile(updated);
    }
    setState(() {
      _selectedLang = langCode;
    });
    SoundService.playClick();
  }

  Future<void> _handleLogout() async {
    await Locator.authService.logout();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    if (_student == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: ColorSystem.cream,
      body: QuestlyBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l('settings'),
                      style: const TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.plum,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Settings Box
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorSystem.plum, width: 2),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left: Account & Sound Toggle
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l('account').toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: ColorSystem.purple,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${l('student_id')}: ${_student!.questlyId}',
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: ColorSystem.plum,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Divider(color: ColorSystem.cream, thickness: 2),
                                const SizedBox(height: 10),

                                // Sound Switch
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l('sound'),
                                      style: const TextStyle(
                                        fontFamily: 'Fredoka',
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: ColorSystem.plum,
                                      ),
                                    ),
                                    Switch(
                                      value: _soundEnabled,
                                      activeColor: ColorSystem.purple,
                                      onChanged: (val) {
                                        setState(() {
                                          _soundEnabled = val;
                                          SoundService.soundEnabled = val;
                                        });
                                        SoundService.playSwitch();
                                      },
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),
                                CustomButton(
                                  text: l('clear_database_btn').toUpperCase(),
                                  backgroundColor: ColorSystem.pink.withOpacity(0.8),
                                  textColor: Colors.white,
                                  height: 38,
                                  onPressed: () async {
                                    final prefs = await SharedPreferences.getInstance();
                                    await prefs.clear();
                                    await Locator.authService.logout();
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l('database_cleared_msg')),
                                        backgroundColor: ColorSystem.purple,
                                      ),
                                    );
                                    Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil('/login', (route) => false);
                                  },
                                ),
                                const SizedBox(height: 12),
                                CustomButton(
                                  text: l('logout').toUpperCase(),
                                  backgroundColor: ColorSystem.purple,
                                  textColor: Colors.white,
                                  height: 38,
                                  onPressed: _handleLogout,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const VerticalDivider(width: 40, thickness: 1.5, color: ColorSystem.cream),
                        // Right: Language Selector
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l('language').toUpperCase(),
                                  style: const TextStyle(
                                    fontFamily: 'Fredoka',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: ColorSystem.purple,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                // Language selectors
                                _buildLangButton('en', 'English (English)'),
                                const SizedBox(height: 10),
                                _buildLangButton('ta', 'தமிழ் (Tamil)'),
                                const SizedBox(height: 10),
                                _buildLangButton('hi', 'हिन्दी (Hindi)'),
                                const SizedBox(height: 10),
                                _buildLangButton('or', 'ଓଡ଼ିଆ (Odia)'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton(String code, String displayName) {
    final isSelected = _selectedLang == code;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _changeLanguage(code),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? ColorSystem.lavender.withOpacity(0.4) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? ColorSystem.plum : ColorSystem.plum.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                displayName,
                style: TextStyle(
                  fontFamily: 'Fredoka',
                  fontFamilyFallback: const ['Noto Sans', 'Segoe UI', 'Roboto', 'sans-serif'],
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: ColorSystem.plum,
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: ColorSystem.purple, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
