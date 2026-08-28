import 'package:flutter/foundation.dart';
import '../models/shop_item.dart';
import '../models/student.dart';
import 'storage_service.dart';
import 'student_repository.dart';
import 'sound_service.dart';

class ShopRepository extends ChangeNotifier {
  final StorageService _storage;
  final StudentRepository _studentRepository;

  ShopRepository(this._storage, this._studentRepository);

  List<ShopItem> getItemsByCategory(ShopCategory category) {
    switch (category) {
      case ShopCategory.avatar:
        return ShopCatalog.avatars;
      case ShopCategory.dendySkin:
        return ShopCatalog.dendySkins;
      case ShopCategory.theme:
        return ShopCatalog.themes;
    }
  }

  List<String> getOwnedItemIds(String studentId) {
    final list = _storage.getOwnedShopItemsRaw(studentId);
    final baseOwned = ['avatar_fox', 'dendy_classic', 'theme_classic'];
    for (final base in baseOwned) {
      if (!list.contains(base)) {
        list.add(base);
      }
    }
    return list;
  }

  bool isItemOwned(String studentId, String itemId) {
    final item = ShopCatalog.getItemById(itemId);
    if (item != null && item.isDefaultOwned) return true;
    return getOwnedItemIds(studentId).contains(itemId);
  }

  bool isItemEquipped(Student student, ShopItem item) {
    switch (item.category) {
      case ShopCategory.avatar:
        return student.equippedAvatarId == item.id;
      case ShopCategory.dendySkin:
        return student.equippedDendySkinId == item.id;
      case ShopCategory.theme:
        return student.equippedThemeId == item.id;
    }
  }

  /// Purchase an item with coins. Returns true on success.
  Future<bool> purchaseItem(String studentId, String itemId) async {
    final student = _studentRepository.getCurrentStudent();
    if (student == null) return false;

    final item = ShopCatalog.getItemById(itemId);
    if (item == null) return false;

    if (isItemOwned(studentId, itemId)) {
      return false; // already owned
    }

    if (student.gold < item.price) {
      return false; // insufficient coins
    }

    // Deduct coins
    final updatedStudent = student.copyWith(
      gold: student.gold - item.price,
    );
    await _studentRepository.updateStudentProfile(updatedStudent);

    // Save owned status
    final owned = getOwnedItemIds(studentId);
    if (!owned.contains(itemId)) {
      owned.add(itemId);
      await _storage.saveOwnedShopItemsRaw(studentId, owned);
    }

    // Auto-equip upon first purchase for instant gratification
    await equipItem(studentId, itemId);

    SoundService.playRewardClaim();
    notifyListeners();
    return true;
  }

  /// Equip an owned item
  Future<bool> equipItem(String studentId, String itemId) async {
    final student = _studentRepository.getCurrentStudent();
    if (student == null) return false;

    final item = ShopCatalog.getItemById(itemId);
    if (item == null) return false;

    if (!isItemOwned(studentId, itemId)) {
      return false;
    }

    Student updated;
    switch (item.category) {
      case ShopCategory.avatar:
        updated = student.copyWith(equippedAvatarId: itemId);
        break;
      case ShopCategory.dendySkin:
        updated = student.copyWith(equippedDendySkinId: itemId);
        break;
      case ShopCategory.theme:
        updated = student.copyWith(equippedThemeId: itemId);
        break;
    }

    await _studentRepository.updateStudentProfile(updated);
    SoundService.playClick();
    notifyListeners();
    return true;
  }
}
