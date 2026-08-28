import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/leaderboard_entry.dart';
import '../models/student.dart';
import '../widgets/questly_background.dart';
import '../widgets/vector_asset_helper.dart';
import '../services/localization_service.dart';

class LeaderboardScreen extends StatelessWidget {
  final bool isTab;

  const LeaderboardScreen({
    Key? key,
    this.isTab = false,
  }) : super(key: key);

  List<LeaderboardEntry> _getLeaderboardEntries(Student student) {
    return [
      LeaderboardEntry(name: 'Ananya', xp: 1240),
      LeaderboardEntry(name: 'Rahul', xp: 1180),
      LeaderboardEntry(name: student.displayName, xp: student.xp, isMe: true),
      LeaderboardEntry(name: 'Meena', xp: 990),
      LeaderboardEntry(name: 'Arjun', xp: 920),
      LeaderboardEntry(name: 'Priya', xp: 880),
      LeaderboardEntry(name: 'Karthik', xp: 850),
    ]..sort((a, b) => b.xp.compareTo(a.xp));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Locator.studentRepository,
      builder: (context, _) {
        final Student? student = Locator.studentRepository.getCurrentStudent();
        if (student == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final entries = _getLeaderboardEntries(student);

        final Widget listContent = Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ColorSystem.plum, width: 2),
          ),
          child: Column(
            children: [
              // Table Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l('rank_student_header'),
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ColorSystem.plum.withOpacity(0.55),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      l('total_score_header'),
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ColorSystem.plum.withOpacity(0.55),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: ColorSystem.plum, thickness: 1.5),
              // Scrollable list
              Expanded(
                child: ListView.separated(
                  itemCount: entries.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    final isMe = entry.isMe;

                    Widget rankWidget;
                    if (index < 3) {
                      rankWidget = VectorAssetHelper.badgeIcon('trophy', size: 22);
                    } else {
                      rankWidget = Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontFamily: 'Fredoka',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ColorSystem.plum,
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe ? ColorSystem.lavender.withOpacity(0.35) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Center(child: rankWidget),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                entry.name,
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 13,
                                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                  color: ColorSystem.plum,
                                ),
                              ),
                              if (isMe) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: ColorSystem.purple,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    l('current').toUpperCase(),
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              VectorAssetHelper.xpStarIcon(size: 14),
                              const SizedBox(width: 4),
                              Text(
                                '${entry.xp} XP',
                                style: TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 13,
                                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                                  color: ColorSystem.plum,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );

        if (isTab) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l('leaderboard').toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Fredoka',
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: ColorSystem.purple,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(child: listContent),
              ],
            ),
          );
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
                    // Header (Back button + title)
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 24),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l('leaderboard'),
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
                    Expanded(child: listContent),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
