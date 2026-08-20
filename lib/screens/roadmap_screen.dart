import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/color_system.dart';
import '../models/module.dart';
import '../models/roadmap_node.dart';
import '../models/roadmap_enums.dart';
import '../models/reward_definition.dart';
import '../models/student.dart';
import '../models/lesson.dart';
import '../models/activity.dart';
import '../core/locator.dart';
import '../widgets/custom_button.dart';
import '../widgets/questly_background.dart';
import '../widgets/reward_reveal_dialog.dart';
import '../widgets/dendy_mascot.dart';
import '../widgets/vector_asset_helper.dart';
import '../widgets/quest_brief_modal.dart';
import '../services/localization_service.dart';
import '../services/sound_service.dart';

class RoadmapScreen extends StatefulWidget {
  const RoadmapScreen({Key? key}) : super(key: key);

  @override
  _RoadmapScreenState createState() => _RoadmapScreenState();
}

class _RoadmapScreenState extends State<RoadmapScreen> with SingleTickerProviderStateMixin {
  Student? _student;
  late ScrollController _scrollController;
  late AnimationController _pulseController;
  Map<String, Offset> _coordinates = {};
  bool _masteryCelebrationActive = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _loadState();
  }

  void _loadState() {
    setState(() {
      _student = Locator.studentRepository.getCurrentStudent();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }


  // Programmatic coordinates generator (sine-wave curves + vertical branch shifts)
  Map<String, Offset> _calculateCoordinates(List<RoadmapNode> nodes, {double availableHeight = 280.0}) {
    final Map<String, Offset> coordinates = {};
    int mainIndex = 0;
    final double centerY = (availableHeight / 2).clamp(90.0, 150.0);
    final double amplitude = (centerY * 0.40).clamp(25.0, 55.0);

    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (!node.isOptional) {
        // Main path node: sine wave coordinates horizontally
        final double x = 80.0 + mainIndex * 190.0;
        final double y = centerY + amplitude * sin(mainIndex * 1.3);
        coordinates[node.id] = Offset(x, y);
        mainIndex++;
      }
    }

    // Now layout optional branch nodes (Side Quests / Mystery Drops)
    for (var i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.isOptional) {
        // Place it relative to its prerequisite node
        if (node.prerequisiteNodeIds.isNotEmpty) {
          final parentCoord = coordinates[node.prerequisiteNodeIds.first];
          if (parentCoord != null) {
            // Shift horizontally right by 95px and vertically up
            final double x = parentCoord.dx + 95.0;
            final double y = (parentCoord.dy - (centerY * 0.55)).clamp(30.0, availableHeight - 30.0);
            coordinates[node.id] = Offset(x, y);
            continue;
          }
        }
        // Fallback
        final double x = 80.0 + i * 190.0;
        final double y = centerY;
        coordinates[node.id] = Offset(x, y);
      }
    }

    return coordinates;
  }

  // Scroll viewport to focus on the active current node
  void _centerOnCurrentNode(List<RoadmapNode> nodes) {
    if (!mounted || _student == null) return;
    final currentId = Locator.progressionService.getCurrentNodeId(_student!.questlyId, nodes);
    if (currentId == null) return;

    final offset = _coordinates[currentId];
    if (offset != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final double targetScroll = (offset.dx - screenWidth / 2).clamp(0.0, _scrollController.position.maxScrollExtent);
        _scrollController.animateTo(
          targetScroll,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final Module module = (args is Module)
        ? args
        : (args is String ? Locator.moduleRepository.getModuleById(args) : null) ??
            Locator.moduleRepository.getAllModules().first;
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 450;

    return ListenableBuilder(
      listenable: Locator.studentRepository,
      builder: (context, _) {
        final currentStudent = Locator.studentRepository.getCurrentStudent();
        if (currentStudent == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        _student = currentStudent;

        final nodes = Locator.roadmapRepository.getRoadmap(module.id);

        // Compute progress details
        int totalMainEdu = nodes.where((n) => !n.isOptional && (n.type == RoadmapNodeType.level || n.type == RoadmapNodeType.lesson)).length;
        int completedMainEdu = nodes.where((n) => !n.isOptional && (n.type == RoadmapNodeType.level || n.type == RoadmapNodeType.lesson) && Locator.progressionService.isNodeCompleted(currentStudent.questlyId, n)).length;
        double progressFraction = totalMainEdu > 0 ? completedMainEdu / totalMainEdu : 0.0;

        return Scaffold(
          backgroundColor: ColorSystem.cream,
          body: QuestlyBackground(
            child: SafeArea(
              child: _masteryCelebrationActive
                  ? _buildMasteryCelebration(module, nodes)
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: isShort ? 14 : 20, vertical: isShort ? 8 : 12),
                      child: Column(
                        children: [
                          // Top Row (Back button + Module Progress Summary)
                          _buildHeaderRow(module, progressFraction),
                          SizedBox(height: isShort ? 8 : 12),

                          // Interactive Winding Viewport
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: ColorSystem.plum, width: 1.5),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final canvasHeight = constraints.maxHeight;
                                    _coordinates = _calculateCoordinates(nodes, availableHeight: canvasHeight);

                                    // Call scroll auto-centering once on load
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      if (_scrollController.hasClients && _scrollController.offset == 0.0) {
                                        _centerOnCurrentNode(nodes);
                                      }
                                    });

                                    final canvasWidth = 160.0 + nodes.length * 190.0;

                                    return SingleChildScrollView(
                                      controller: _scrollController,
                                      scrollDirection: Axis.horizontal,
                                      physics: const BouncingScrollPhysics(),
                                      child: Stack(
                                        children: [
                                          // Winding dashed connector paths CustomPainter
                                          CustomPaint(
                                            size: Size(canvasWidth, canvasHeight),
                                            painter: RoadmapPath(
                                              nodes: nodes,
                                              coordinates: _coordinates,
                                              studentId: currentStudent.questlyId,
                                            ),
                                          ),

                                          // Overlaid Node Buttons Widgets
                                          ...nodes.map((node) {
                                            final Offset? offset = _coordinates[node.id];
                                            if (offset == null) return const SizedBox();

                                            final status = Locator.progressionService.getNodeStatus(currentStudent.questlyId, node, nodes);

                                            return Positioned(
                                              left: offset.dx - 28,
                                              top: offset.dy - 28,
                                              child: _buildRoadmapNodeWidget(node, status, nodes),
                                            );
                                          }).toList(),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  // Header progress panel
  Widget _buildHeaderRow(Module module, double progressFraction) {
    final size = MediaQuery.of(context).size;
    final isShort = size.height < 450;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: ColorSystem.plum, size: 22),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      module.title.toUpperCase(),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: isShort ? 13 : 15,
                        fontWeight: FontWeight.w900,
                        color: ColorSystem.plum,
                      ),
                    ),
                    Text(
                      '${(progressFraction * 100).toInt()}% ${l('completed').toLowerCase()}',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: isShort ? 9.5 : 11,
                        color: ColorSystem.plum.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Clean Progress Bar
        Container(
          width: isShort ? 120 : 150,
          height: isShort ? 8 : 10,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: ColorSystem.plum, width: 1.2),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progressFraction.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: ColorSystem.green,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Node button visual overlay switcher with 3-Star Display, Pulse & Tooltip
  Widget _buildRoadmapNodeWidget(RoadmapNode node, RoadmapNodeStatus status, List<RoadmapNode> allNodes) {
    final isLocked = status == RoadmapNodeStatus.locked;
    final isCompleted = status == RoadmapNodeStatus.completed;
    final isCurrent = status == RoadmapNodeStatus.current;
    final isClaimable = status == RoadmapNodeStatus.claimable;
    final int earnedStars = _student != null ? Locator.progressionService.getNodeStars(_student!.questlyId, node) : 0;

    Color bg = Colors.white;
    Color border = ColorSystem.plum;

    if (isCompleted) {
      bg = ColorSystem.green.withOpacity(0.2);
      border = ColorSystem.green;
    } else if (isCurrent) {
      bg = ColorSystem.purple.withOpacity(0.15);
      border = ColorSystem.purple;
    } else if (isClaimable) {
      bg = ColorSystem.gold.withOpacity(0.2);
      border = ColorSystem.gold;
    } else if (status == RoadmapNodeStatus.available) {
      bg = ColorSystem.lavender.withOpacity(0.3);
      border = ColorSystem.plum;
    } else if (isLocked) {
      bg = Colors.grey.shade200;
      border = Colors.grey.shade400;
    }

    double size = 56.0;
    if (node.type == RoadmapNodeType.mastery || node.type == RoadmapNodeType.milestone) {
      size = 66.0;
    }

    // Determine visual reward asset to display inside node
    Widget nodeAssetWidget;
    final rewards = Locator.roadmapRepository.getRewardsForNode(node);

    if (isLocked) {
      nodeAssetWidget = VectorAssetHelper.lockIcon(size: size * 0.45, isLocked: true);
    } else if (node.type == RoadmapNodeType.mastery) {
      nodeAssetWidget = VectorAssetHelper.chestIcon(size: size * 0.55, isEpic: true);
    } else if (node.type == RoadmapNodeType.mystery) {
      nodeAssetWidget = VectorAssetHelper.chestIcon(size: size * 0.5, isOpen: isCompleted);
    } else if (rewards.any((r) => r.type == RewardType.collectible)) {
      final collReward = rewards.firstWhere((r) => r.type == RewardType.collectible);
      nodeAssetWidget = VectorAssetHelper.collectibleIcon(
        collReward.assetPath.isNotEmpty ? collReward.assetPath : collReward.name,
        size: size * 0.5,
      );
    } else if (rewards.any((r) => r.type == RewardType.coins)) {
      nodeAssetWidget = VectorAssetHelper.questCoinIcon(size: size * 0.5);
    } else {
      nodeAssetWidget = VectorAssetHelper.xpStarIcon(size: size * 0.5);
    }

    // Node Action Handler
    void handleTap() {
      SoundService.playClick();

      if (isClaimable && (node.type == RoadmapNodeType.mystery || node.type == RoadmapNodeType.reward || node.type == RoadmapNodeType.mastery)) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => RewardRevealDialog(
            studentId: _student!.questlyId,
            rewardIds: node.rewardIds,
            title: node.title,
            onClaimed: () {
              Locator.progressionService.markNodeCompleted(_student!.questlyId, node.id);
              _loadState();
            },
          ),
        );
        return;
      }

      // Show Mission Quest Brief Modal
      showDialog(
        context: context,
        builder: (context) => QuestBriefModal(
          node: node,
          status: status,
          studentId: _student!.questlyId,
          onStartQuest: () async {
            final String targetLessonId = node.lessonId ?? 'density_les1';
            final Lesson? targetLesson = Locator.moduleRepository.getLessonById(targetLessonId);
            if (targetLesson != null && targetLesson.activities.isNotEmpty) {
              final updatedStudent = _student!.copyWith(
                currentModuleId: node.moduleId,
                currentLessonId: targetLessonId,
              );
              await Locator.studentRepository.updateStudentProfile(updatedStudent);

              if (!mounted) return;
              await Navigator.pushNamed(
                context,
                '/activity_renderer',
                arguments: targetLesson.activities.first,
              );
            }
          },
        ),
      );
    }

    // Node Outer Structure + Pulsing Active Scale & 3-Star Footer
    Widget nodeWidget = Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Pulsing Circle Container for Active Current Node
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final double scale = isCurrent ? 1.0 + (_pulseController.value * 0.08) : 1.0;
            return Transform.scale(
              scale: scale,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: border, width: isCurrent ? 3 : 2),
                  boxShadow: [
                    if (isCurrent)
                      BoxShadow(
                        color: ColorSystem.purple.withOpacity(0.35),
                        offset: const Offset(0, 4),
                        blurRadius: 8,
                      )
                  ],
                ),
                child: Center(child: nodeAssetWidget),
              ),
            );
          },
        ),

        // 3-Star Rating compact badge display under completed nodes
        if (isCompleted)
          Positioned(
            bottom: -10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: ColorSystem.plum,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorSystem.gold, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 1; i <= 3; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 1),
                      child: VectorAssetHelper.xpStarIcon(
                        size: 9,
                        isFilled: i <= earnedStars,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );

    // Wrap in Desktop Tooltip preview card
    return Tooltip(
      message: '${node.title}\n~8 Mins • 3 Activities\n+75 XP • +10 Quest Coins',
      textStyle: const TextStyle(
        fontFamily: 'Fredoka',
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: ColorSystem.plum,
        borderRadius: BorderRadius.circular(8),
      ),
      child: GestureDetector(
        onTap: handleTap,
        child: nodeWidget,
      ),
    );
  }



  // Detailed Modal Inspection Sheet
  void _showNodeDetailSheet(RoadmapNode node, RoadmapNodeStatus status, List<RoadmapNode> allNodes) {
    final isLocked = status == RoadmapNodeStatus.locked;
    final isCompleted = status == RoadmapNodeStatus.completed;
    final isClaimable = status == RoadmapNodeStatus.claimable;

    final rewards = Locator.roadmapRepository.getRewardsForNode(node);

    showModalBottomSheet(
      context: context,
      backgroundColor: ColorSystem.cream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: ColorSystem.plum, width: 2),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left Panel: Info & Description
              Expanded(
                flex: 11,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          node.type.name.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: ColorSystem.plum.withOpacity(0.55),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          node.title,
                          style: const TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: ColorSystem.plum,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          node.description,
                          style: TextStyle(
                            fontFamily: 'Fredoka',
                            fontSize: 12,
                            color: ColorSystem.plum.withOpacity(0.85),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                    DendyMascot(
                      state: isLocked ? DendyState.confused : DendyState.idle,
                      message: isLocked
                          ? 'This is currently locked! Resolve the prerequisites first.'
                          : 'You are ready to proceed with this challenge!',
                      size: 68,
                    ),
                  ],
                ),
              ),

              const VerticalDivider(width: 32, thickness: 1.5, color: ColorSystem.plum),

              // Right Panel: Rewards Previews & Actions
              Expanded(
                flex: 9,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'EARNABLE REWARDS',
                      style: TextStyle(
                        fontFamily: 'Fredoka',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: ColorSystem.purple,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rewards cards grid using Production Assets
                    Column(
                      children: rewards.map((reward) {
                        Widget iconWidget;
                        String labelText = '';

                        if (reward.type == RewardType.xp) {
                          iconWidget = VectorAssetHelper.xpStarIcon(size: 16);
                          labelText = '+${reward.amount} XP';
                        } else if (reward.type == RewardType.coins) {
                          iconWidget = VectorAssetHelper.questCoinIcon(size: 16);
                          labelText = '+${reward.amount} Quest Coins';
                        } else if (reward.type == RewardType.collectible) {
                          iconWidget = VectorAssetHelper.collectibleIcon(
                            reward.assetPath.isNotEmpty ? reward.assetPath : reward.name,
                            size: 16,
                          );
                          labelText = reward.name;
                        } else if (reward.type == RewardType.badge) {
                          iconWidget = VectorAssetHelper.badgeIcon(reward.name, size: 16);
                          labelText = '${reward.name} Badge';
                        } else {
                          iconWidget = VectorAssetHelper.chestIcon(size: 16, isEpic: true);
                          labelText = reward.name;
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: ColorSystem.plum.withOpacity(0.12), width: 1),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  iconWidget,
                                  const SizedBox(width: 6),
                                  Text(
                                    reward.name,
                                    style: const TextStyle(
                                      fontFamily: 'Fredoka',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: ColorSystem.plum,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                labelText,
                                style: const TextStyle(
                                  fontFamily: 'Fredoka',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  color: ColorSystem.purple,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 14),

                    // CTAs Actions
                    if (isLocked)
                      Column(
                        children: [
                          const Icon(Icons.lock_rounded, color: ColorSystem.pink, size: 22),
                          const SizedBox(height: 4),
                          Text(
                            'PREREQUISITE REQUIRED',
                            style: TextStyle(
                              fontFamily: 'Fredoka',
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: ColorSystem.plum.withOpacity(0.55),
                            ),
                          ),
                        ],
                      )
                    else if (isClaimable)
                      CustomButton(
                        text: 'CLAIM REWARD',
                        backgroundColor: ColorSystem.gold,
                        textColor: Colors.white,
                        onPressed: () {
                          Navigator.pop(context); // close sheet
                          _triggerRewardClaims(node);
                        },
                      )
                    else if (node.type == RoadmapNodeType.sideQuest)
                      CustomButton(
                        text: isCompleted ? 'RESOLVED ✓' : 'START QUEST',
                        backgroundColor: isCompleted ? ColorSystem.cream : ColorSystem.purple,
                        textColor: isCompleted ? ColorSystem.plum : Colors.white,
                        onPressed: isCompleted
                            ? () {}
                            : () async {
                                Navigator.pop(context); // close sheet
                                // Mark side quest complete directly
                                await Locator.progressionService.markNodeCompleted(_student!.questlyId, node.id);
                                _triggerRewardClaims(node);
                              },
                      )
                    else
                      CustomButton(
                        text: isCompleted ? 'REPLAY' : 'START LEVEL',
                        backgroundColor: isCompleted ? ColorSystem.cream : ColorSystem.purple,
                        textColor: isCompleted ? ColorSystem.plum : Colors.white,
                        onPressed: () async {
                          Navigator.pop(context); // close sheet

                          // Lock update active lesson on profile repository
                          if (node.levelId != null && node.lessonId != null) {
                            final updated = _student!.copyWith(
                              currentModuleId: node.moduleId,
                              currentLessonId: node.lessonId,
                            );
                            await Locator.studentRepository.updateStudentProfile(updated);
                            _loadState();

                            // Get lesson details and activities
                            final lesson = Locator.moduleRepository.getLessonById(node.lessonId!);
                            if (lesson != null && lesson.activities.isNotEmpty) {
                              // Route to Activity Renderer
                              if (!mounted) return;
                              await Navigator.pushNamed(
                                context,
                                '/activity_renderer',
                                arguments: lesson.activities.first,
                              );
                              _loadState(); // reload states
                              
                              // Check if completed to trigger rewards dialog immediately!
                              final isDone = Locator.progressionService.isNodeCompleted(_student!.questlyId, node);
                              if (isDone) {
                                _triggerRewardClaims(node);
                              }
                            }
                          }
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Trigger claim reveals dialogs
  void _triggerRewardClaims(RoadmapNode node) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return RewardRevealDialog(
          studentId: _student!.questlyId,
          rewardIds: node.rewardIds,
          title: node.type == RoadmapNodeType.mastery
              ? 'THE EXPEDITION IS CONQUERED!'
              : 'CHEST REWARD DISCOVERED!',
          onClaimed: () async {
            // Force complete nodes flag if necessary
            await Locator.progressionService.markNodeCompleted(_student!.questlyId, node.id);
            _loadState();

            // Trigger mastery congratulations screen if final node is claimed!
            if (node.type == RoadmapNodeType.mastery) {
              setState(() {
                _masteryCelebrationActive = true;
              });
            }
          },
        );
      },
    );
  }

  // Mastery screen Payoff UI
  Widget _buildMasteryCelebration(Module module, List<RoadmapNode> allNodes) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorSystem.plum, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const DendyMascot(
            state: DendyState.success,
            size: 80,
          ),
          const SizedBox(height: 14),
          Text(
            l('module_mastered').toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: ColorSystem.purple,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            module.title,
            style: const TextStyle(
              fontFamily: 'Fredoka',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorSystem.plum,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: ColorSystem.plum.withOpacity(0.15)),
          const SizedBox(height: 12),

          // Completion Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMasteryStat('Levels Unlocked', '${allNodes.where((n) => n.type == RoadmapNodeType.level).length} / 5'),
              _buildMasteryStat('Badges Earned', '1 Badge'),
              _buildMasteryStat('Quest Coins Gift', '+100 Coins'),
            ],
          ),

          const SizedBox(height: 20),
          CustomButton(
            text: 'RETURN TO MODULES',
            backgroundColor: ColorSystem.green,
            textColor: Colors.white,
            width: 220,
            onPressed: () {
              Navigator.pop(context); // Close roadmap screen back to overview
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMasteryStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: ColorSystem.purple,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Fredoka',
            fontSize: 11,
            color: ColorSystem.plum.withOpacity(0.55),
          ),
        ),
      ],
    );
  }
}

// Dash Connection Trail Painter
class RoadmapPath extends CustomPainter {
  final List<RoadmapNode> nodes;
  final Map<String, Offset> coordinates;
  final String studentId;

  RoadmapPath({
    required this.nodes,
    required this.coordinates,
    required this.studentId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw lines linking prerequisites to each node
    for (var node in nodes) {
      final endOffset = coordinates[node.id];
      if (endOffset == null) continue;

      for (var prereqId in node.prerequisiteNodeIds) {
        final startOffset = coordinates[prereqId];
        if (startOffset == null) continue;

        // Find prerequisite node
        final prereqNode = nodes.firstWhere((n) => n.id == prereqId);
        final isPrereqDone = Locator.progressionService.isNodeCompleted(studentId, prereqNode);
        final isEndNodeDone = Locator.progressionService.isNodeCompleted(studentId, node);

        final activePaint = Paint()
          ..color = (isPrereqDone &&
                  (isEndNodeDone ||
                      Locator.progressionService.getNodeStatus(studentId, node, nodes) != RoadmapNodeStatus.locked))
              ? ColorSystem.green
              : ColorSystem.plum.withOpacity(0.35)
          ..strokeWidth = 4.0
          ..style = PaintingStyle.stroke;

        // Draw cubic bezier winding curves between coordinates
        final path = Path();
        path.moveTo(startOffset.dx, startOffset.dy);

        final double controlX1 = startOffset.dx + (endOffset.dx - startOffset.dx) * 0.5;
        final double controlY1 = startOffset.dy;
        final double controlX2 = startOffset.dx + (endOffset.dx - startOffset.dx) * 0.5;
        final double controlY2 = endOffset.dy;

        path.cubicTo(controlX1, controlY1, controlX2, controlY2, endOffset.dx, endOffset.dy);

        // Dashed lines layout metrics loop
        final metrics = path.computeMetrics();
        for (var metric in metrics) {
          double distance = 0.0;
          const double dashLength = 8.0;
          const double gapLength = 6.0;
          while (distance < metric.length) {
            final nextDistance = distance + dashLength;
            final dashPath = metric.extractPath(
              distance,
              nextDistance > metric.length ? metric.length : nextDistance,
            );
            canvas.drawPath(dashPath, activePaint);
            distance = nextDistance + gapLength;
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant RoadmapPath oldDelegate) => true;
}
