import 'dart:convert';
import '../models/notification.dart';
import 'storage_service.dart';

class NotificationRepository {
  final StorageService _storage;

  NotificationRepository(this._storage);

  List<NotificationItem> getNotifications(String studentId) {
    final raw = _storage.getNotificationsRaw(studentId);
    return raw.map((item) => NotificationItem.fromJson(item)).toList();
  }

  Future<void> saveNotifications(String studentId, List<NotificationItem> list) async {
    final raw = list.map((item) => item.toJson()).toList();
    await _storage.saveNotificationsRaw(studentId, raw);
  }

  Future<void> addNotification(String studentId, NotificationItem item) async {
    final list = getNotifications(studentId);
    list.insert(0, item); // Newest first
    await saveNotifications(studentId, list);
  }

  Future<void> markAllAsRead(String studentId) async {
    final list = getNotifications(studentId);
    final updated = list.map((item) => item.copyWith(isRead: true)).toList();
    await saveNotifications(studentId, updated);
  }

  int getUnreadCount(String studentId) {
    return getNotifications(studentId).where((item) => !item.isRead).length;
  }
}
