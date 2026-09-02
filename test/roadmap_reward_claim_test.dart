import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:questly/core/locator.dart';
import 'package:questly/models/student.dart';
import 'package:questly/models/roadmap_node.dart';
import 'package:questly/models/roadmap_enums.dart';
import 'package:questly/services/reward_service.dart';
import 'package:questly/services/roadmap_repository.dart';
import 'package:questly/services/progression_service.dart';
import 'package:questly/widgets/reward_reveal_dialog.dart';
import 'package:questly/widgets/custom_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late RoadmapRepository roadmapRepo;
  late ProgressionService progressionService;
  late RewardService rewardService;
  const String studentId = 'student_claim_test';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    Locator.resetForTest();
    await Locator.setup();

    roadmapRepo = Locator.roadmapRepository;
    progressionService = Locator.progressionService;
    rewardService = Locator.rewardService;

    // Create and save test student
    final student = Student(
      questlyId: studentId,
      displayName: 'Alex Explorer',
      xp: 100,
      level: 1,
      gold: 20,
    );
    await Locator.studentRepository.updateStudentProfile(student);
  });

  group('Roadmap Claim Reward Milestone Tests', () {
    test('1. Fractions roadmap contains 8 nodes with Two Claim Reward milestones like Density', () {
      final nodes = roadmapRepo.getRoadmap('mod_fractions');
      expect(nodes.length, equals(8));

      // Node 1: Quest 1
      expect(nodes[0].id, equals('fractions_node1'));
      expect(nodes[0].title, contains('Quest 1'));

      // Node 2: 1st Claim Reward
      expect(nodes[1].id, equals('fractions_node2'));
      expect(nodes[1].type, equals(RoadmapNodeType.milestone));
      expect(nodes[1].title, contains('Claim Reward'));
      expect(nodes[1].prerequisiteNodeIds, equals(['fractions_node1']));

      // Node 3: Quest 2
      expect(nodes[2].id, equals('fractions_node3'));
      expect(nodes[2].title, contains('Quest 2'));
      expect(nodes[2].prerequisiteNodeIds, equals(['fractions_node2']));

      // Node 4: Quest 3
      expect(nodes[3].id, equals('fractions_node4'));
      expect(nodes[3].title, contains('Quest 3'));
      expect(nodes[3].prerequisiteNodeIds, equals(['fractions_node3']));

      // Node 5: 2nd Claim Reward
      expect(nodes[4].id, equals('fractions_node5'));
      expect(nodes[4].type, equals(RoadmapNodeType.milestone));
      expect(nodes[4].title, contains('Claim Reward'));
      expect(nodes[4].prerequisiteNodeIds, equals(['fractions_node4']));

      // 2nd Milestone Rewards: 100 XP and 20 Coins
      final rewards2 = roadmapRepo.getRewardsForNode(nodes[4]);
      expect(rewards2.length, equals(2));
      final xpReward2 = rewards2.firstWhere((r) => r.type == RewardType.xp);
      final coinReward2 = rewards2.firstWhere((r) => r.type == RewardType.coins);
      expect(xpReward2.amount, equals(100));
      expect(coinReward2.amount, equals(20));

      // Node 6: Quest 4
      expect(nodes[5].id, equals('fractions_node6'));
      expect(nodes[5].title, contains('Quest 4'));
      expect(nodes[5].prerequisiteNodeIds, equals(['fractions_node5']));

      // Node 7: Quest 5
      expect(nodes[6].id, equals('fractions_node7'));
      expect(nodes[6].title, contains('Quest 5'));
      expect(nodes[6].prerequisiteNodeIds, equals(['fractions_node6']));

      // Node 8: Grand Master
      expect(nodes[7].id, equals('fractions_node8'));
      expect(nodes[7].type, equals(RoadmapNodeType.mastery));
    });

    test('2. Quest 2 remains locked until Quest 1 is complete AND Claim Reward 1 is claimed', () {
      final nodes = roadmapRepo.getRoadmap('mod_fractions');
      final node1 = nodes[0];
      final node2 = nodes[1];
      final node3 = nodes[2];

      expect(progressionService.getNodeStatus(studentId, node1, nodes), equals(RoadmapNodeStatus.current));
      expect(progressionService.getNodeStatus(studentId, node2, nodes), equals(RoadmapNodeStatus.locked));
      expect(progressionService.isLessonUnlocked(studentId, 'ratios_les1'), isFalse);

      // Complete all 5 lessons of Quest 1
      for (int i = 1; i <= 5; i++) {
        Locator.storageService.setBool('lesson_comp_${studentId}_fractions_les$i', true);
      }
      expect(progressionService.isLessonCompleted(studentId, 'fractions_les5'), isTrue);

      expect(progressionService.getNodeStatus(studentId, node1, nodes), equals(RoadmapNodeStatus.completed));
      expect(progressionService.getNodeStatus(studentId, node2, nodes), equals(RoadmapNodeStatus.claimable));
      expect(progressionService.isLessonUnlocked(studentId, 'ratios_les1'), isFalse);
      expect(progressionService.getNodeStatus(studentId, node3, nodes), equals(RoadmapNodeStatus.locked));
    });

    test('3. Second Claim Reward locks Quest 4 until Quest 3 is completed and claimed', () async {
      final nodes = roadmapRepo.getRoadmap('mod_fractions');
      final node4 = nodes[3]; // Quest 3
      final node5 = nodes[4]; // 2nd Claim Reward
      final node6 = nodes[5]; // Quest 4

      // Complete Quest 1, Claim 1, Quest 2, and Quest 3
      for (int i = 1; i <= 5; i++) {
        await Locator.storageService.setBool('lesson_comp_${studentId}_fractions_les$i', true);
        await Locator.storageService.setBool('lesson_comp_${studentId}_ratios_les$i', true);
        await Locator.storageService.setBool('lesson_comp_${studentId}_proportions_les$i', true);
      }
      await Locator.storageService.setBool('node_comp_${studentId}_fractions_node2', true);

      // Node 4 is completed, Node 5 is claimable, Quest 4 (Node 6) is locked
      expect(progressionService.isNodeCompleted(studentId, node4), isTrue);
      expect(progressionService.getNodeStatus(studentId, node5, nodes), equals(RoadmapNodeStatus.claimable));
      expect(progressionService.isLessonUnlocked(studentId, 'percentages_les1'), isFalse);
      expect(progressionService.getNodeStatus(studentId, node6, nodes), equals(RoadmapNodeStatus.locked));

      // Claim Node 5 rewards
      for (var rid in node5.rewardIds) {
        await rewardService.claimReward(studentId, rid);
      }
      await progressionService.markNodeCompleted(studentId, node5.id);

      // Now Node 5 is completed and Quest 4 is unlocked
      expect(progressionService.getNodeStatus(studentId, node5, nodes), equals(RoadmapNodeStatus.completed));
      expect(progressionService.isLessonUnlocked(studentId, 'percentages_les1'), isTrue);
      expect(progressionService.getNodeStatus(studentId, node6, nodes), equals(RoadmapNodeStatus.current));
    });

    test('4. Claiming reward grants XP and Coins and persists in storage', () async {
      final nodes = roadmapRepo.getRoadmap('mod_fractions');
      final node2 = nodes[1];

      for (int i = 1; i <= 5; i++) {
        await Locator.storageService.setBool('lesson_comp_${studentId}_fractions_les$i', true);
      }

      final initialStudent = Locator.studentRepository.getCurrentStudent()!;
      final initialXp = initialStudent.xp;
      final initialGold = initialStudent.gold;

      for (var rid in node2.rewardIds) {
        final success = await rewardService.claimReward(studentId, rid);
        expect(success, isTrue);
      }
      await progressionService.markNodeCompleted(studentId, node2.id);

      final updatedStudent = Locator.studentRepository.getCurrentStudent()!;
      expect(updatedStudent.xp, equals(initialXp + 75));
      expect(updatedStudent.gold, equals(initialGold + 10));

      expect(progressionService.isNodeCompleted(studentId, node2), isTrue);
      expect(rewardService.hasClaimedReward(studentId, node2.rewardIds.first), isTrue);
    });

    testWidgets('5. RewardRevealDialog renders 75 XP, 10 Quest Coins, Achievement Stars, and claims rewards', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1024, 768));
      bool onClaimedCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: RewardRevealDialog(
                studentId: studentId,
                rewardIds: const ['rew_fractions_q1_xp', 'rew_fractions_q1_coins'],
                title: '🎁 MILESTONE UNLOCKED!',
                earnedStars: 3,
                onClaimed: () {
                  onClaimedCalled = true;
                },
              ),
            ),
          ),
        ),
      );

      // Let chest open animation complete
      await tester.pump(const Duration(milliseconds: 1500));

      // Verify Title, XP, Coins, and Stars are visible
      expect(find.text('🎁 MILESTONE UNLOCKED!'), findsOneWidget);
      expect(find.text('+75 XP'), findsOneWidget);
      expect(find.text('+10 Quest Coins'), findsOneWidget);
      expect(find.text('3 / 3 Stars'), findsOneWidget);

      // Tap CLAIM REWARD button
      expect(find.widgetWithText(CustomButton, 'CLAIM REWARD'), findsOneWidget);
      await tester.tap(find.widgetWithText(CustomButton, 'CLAIM REWARD'));
      await tester.pump(const Duration(milliseconds: 600));

      expect(onClaimedCalled, isTrue);
    });
  });
}
