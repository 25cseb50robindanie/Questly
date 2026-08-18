import 'dart:convert';
import '../models/doubt.dart';
import '../core/locator.dart';

class DoubtRepository {
  // Save doubt locally
  Future<void> saveDoubt(Doubt doubt) async {
    final list = getDoubts(doubt.studentId);
    
    // Prevent duplicate doubts for similar questions
    final normalizedNew = doubt.question.trim().toLowerCase();
    if (list.any((d) => d.question.trim().toLowerCase() == normalizedNew)) {
      return;
    }
    
    list.add(doubt);
    await _saveList(doubt.studentId, list);
  }

  // Load all doubts for a student
  List<Doubt> getDoubts(String studentId) {
    final key = 'questly_doubts_${studentId.toLowerCase()}';
    final raw = Locator.storageService.getStringList(key);
    if (raw == null) return [];
    
    return raw
        .map((str) {
          try {
            return Doubt.fromJson(json.decode(str) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .where((d) => d != null)
        .cast<Doubt>()
        .toList();
  }

  Future<void> _saveList(String studentId, List<Doubt> list) async {
    final key = 'questly_doubts_${studentId.toLowerCase()}';
    final raw = list.map((d) => json.encode(d.toJson())).toList();
    await Locator.storageService.setStringList(key, raw);
  }
}
