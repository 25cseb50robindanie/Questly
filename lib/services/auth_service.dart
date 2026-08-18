import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../models/student.dart';
import '../models/progress.dart';
import '../models/notification.dart';
import 'storage_service.dart';
import 'student_repository.dart';
import 'progress_repository.dart';
import 'collection_repository.dart';
import 'notification_repository.dart';

abstract class AuthService {
  Future<bool> register(String questlyId, String password, String displayName);
  Future<Student?> login(String questlyId, String password);
  Future<void> logout();
  Student? getCurrentStudent();
  Future<void> saveProgress(Progress progress);
  List<Progress> getProgressList(String studentId);
}

class MockAuthService implements AuthService {
  final StorageService _storage;
  final StudentRepository _studentRepo;
  final ProgressRepository _progressRepo;
  final CollectionRepository _collectionRepo;
  final NotificationRepository _notificationRepo;

  MockAuthService(
    this._storage,
    this._studentRepo,
    this._progressRepo,
    this._collectionRepo,
    this._notificationRepo,
  );

  String _hashPassword(String password, String salt) {
    final keyBytes = utf8.encode(password + salt + "_questly_salted_secret_key");
    final digest = sha256.convert(keyBytes);
    return digest.toString();
  }

  String _getSalt(String questlyId) {
    return questlyId.trim().toLowerCase();
  }

  @override
  Future<bool> register(String questlyId, String password, String displayName) async {
    final normalizedId = questlyId.trim();
    if (normalizedId.isEmpty || password.length < 4 || displayName.trim().isEmpty) {
      return false;
    }
    final salt = _getSalt(normalizedId);
    final hashedPassword = _hashPassword(password, salt);

    // Clean Slate for New Accounts: Level 1, 0 XP, 0 Coins, 0 pre-seeded progress
    final newStudent = Student(
      questlyId: normalizedId,
      displayName: displayName.trim(),
      level: 1,
      xp: 0,
      gold: 0,
      language: 'en',
      currentModuleId: null,
      currentLessonId: null,
    );

    final success = await _storage.registerUserCredentials(
      normalizedId,
      hashedPassword,
      newStudent.toJson(),
    );

    if (success) {
      final sId = normalizedId.toLowerCase();
      await _studentRepo.saveCurrentStudent(newStudent);

      // Send initial welcome notification
      await _notificationRepo.addNotification(
        sId,
        NotificationItem(
          id: 'notif_welcome_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Welcome to Questly!',
          description: 'Your adventurer journey begins today. Choose your first module to begin!',
          timestamp: DateTime.now(),
        ),
      );
    }

    return success;
  }

  @override
  Future<Student?> login(String questlyId, String password) async {
    final normalizedId = questlyId.trim();
    if (normalizedId.isEmpty || password.isEmpty) return null;

    final creds = _storage.getUserCredentials(normalizedId);
    if (creds == null) return null;

    final salt = _getSalt(normalizedId);
    final expectedHash = creds['hashedPassword'] as String;
    final inputHash = _hashPassword(password, salt);

    if (expectedHash == inputHash) {
      final studentJson = creds['student'] as Map<String, dynamic>;
      final student = Student.fromJson(studentJson);
      await _studentRepo.saveCurrentStudent(student);
      return student;
    }

    return null;
  }

  @override
  Future<void> logout() async {
    await _studentRepo.saveCurrentStudent(null);
  }

  @override
  Student? getCurrentStudent() {
    return _studentRepo.getCurrentStudent();
  }

  @override
  Future<void> saveProgress(Progress progress) async {
    await _progressRepo.saveProgress(progress);
    
    // Auto-update XP and Level on progress
    final current = getCurrentStudent();
    if (current != null && current.questlyId.toLowerCase() == progress.studentId.toLowerCase()) {
      if (progress.status == 'completed') {
        int earnedXp = (progress.score * 50).toInt();
        int earnedGold = (progress.score * 5).toInt();
        int newXp = current.xp + earnedXp;
        int nextLevelThreshold = current.level * 200;
        int newLevel = current.level;
        
        if (newXp >= nextLevelThreshold) {
          newLevel += 1;
        }
        
        final updated = current.copyWith(
          xp: newXp,
          level: newLevel,
          gold: current.gold + earnedGold,
        );
        await _studentRepo.updateStudentProfile(updated);
      }
    }
  }

  @override
  List<Progress> getProgressList(String studentId) {
    return _progressRepo.getProgressList(studentId);
  }
}
