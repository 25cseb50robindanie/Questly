import 'package:flutter/foundation.dart';
import '../models/student.dart';
import 'storage_service.dart';

class StudentRepository extends ChangeNotifier {
  final StorageService _storage;
  Student? _cachedStudent;

  StudentRepository(this._storage) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final json = _storage.getCurrentStudent();
    if (json != null) {
      try {
        _cachedStudent = Student.fromJson(json);
      } catch (_) {
        _cachedStudent = null;
      }
    } else {
      _cachedStudent = null;
    }
  }

  Student? getCurrentStudent() {
    if (_cachedStudent == null) {
      _loadFromStorage();
    }
    return _cachedStudent;
  }

  Future<void> saveCurrentStudent(Student? student) async {
    _cachedStudent = student;
    if (student == null) {
      await _storage.setCurrentStudent(null);
    } else {
      final json = student.toJson();
      await _storage.setCurrentStudent(json);
      await _storage.updateUserStudentProfile(student.questlyId, json);
    }
    notifyListeners();
  }

  Future<void> updateStudentProfile(Student student) async {
    await saveCurrentStudent(student);
  }
}

