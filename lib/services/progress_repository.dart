import '../models/progress.dart';
import 'storage_service.dart';

class ProgressRepository {
  final StorageService _storage;

  ProgressRepository(this._storage);

  Future<void> saveProgress(Progress progress) async {
    await _storage.saveProgress(
      progress.studentId,
      progress.lessonId,
      progress.toJson(),
    );
  }

  List<Progress> getProgressList(String studentId) {
    final rawList = _storage.getProgressForStudent(studentId);
    return rawList.map((p) => Progress.fromJson(p)).toList();
  }

  Progress? getProgressForLesson(String studentId, String lessonId) {
    final list = getProgressList(studentId);
    for (var p in list) {
      if (p.lessonId == lessonId) return p;
    }
    return null;
  }
}
