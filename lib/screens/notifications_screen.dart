import 'package:flutter/material.dart';
import '../core/locator.dart';
import '../core/theme/color_system.dart';
import '../models/student.dart';
import '../models/notification.dart';
import '../widgets/questly_background.dart';
import '../widgets/vector_asset_helper.dart';
import '../services/localization_service.dart';


class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Student? _student;
  List<NotificationItem> _list = [];

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
        _list = Locator.notificationRepository.getNotifications(s.questlyId);
      });
      // Mark all as read when opening notifications screen
      Locator.notificationRepository.markAllAsRead(s.questlyId);
    }
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
                      l('notifications'),
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

                // Notifications list box
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColorSystem.plum, width: 2),
                    ),
                    child: _list.isEmpty
                        ? Center(
                            child: Text(
                              l('all_caught_up'),
                              style: TextStyle(
                                fontFamily: 'Fredoka',
                                fontSize: 13,
                                color: ColorSystem.plum.withOpacity(0.5),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _list.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = _list[index];

                              Widget itemIconWidget;
                              if (item.title.toLowerCase().contains('reward') ||
                                  item.title.toLowerCase().contains('badge')) {
                                itemIconWidget = VectorAssetHelper.badgeIcon('badge', size: 20);
                              } else if (item.title.toLowerCase().contains('revision')) {
                                itemIconWidget = VectorAssetHelper.xpStarIcon(size: 20);
                              } else {
                                itemIconWidget = VectorAssetHelper.collectibleIcon('star', size: 20);
                              }

                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: ColorSystem.cream,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: ColorSystem.plum.withOpacity(0.15), width: 1),
                                      ),
                                      child: Center(child: itemIconWidget),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                item.title,
                                                style: const TextStyle(
                                                  fontFamily: 'Fredoka',
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: ColorSystem.plum,
                                                ),
                                              ),
                                              Text(
                                                '${item.timestamp.hour}:${item.timestamp.minute.toString().padLeft(2, '0')}',
                                                style: TextStyle(
                                                  fontFamily: 'Fredoka',
                                                  fontSize: 9,
                                                  color: ColorSystem.plum.withOpacity(0.4),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            item.description,
                                            style: TextStyle(
                                              fontFamily: 'Fredoka',
                                              fontSize: 11,
                                              color: ColorSystem.plum.withOpacity(0.7),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
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
}

