enum ShopCategory { avatar, dendySkin, theme }

enum ItemRarity { common, rare, epic, legendary }

class ShopItem {
  final String id;
  final String nameKey;
  final String descriptionKey;
  final ShopCategory category;
  final int price;
  final ItemRarity rarity;
  final String previewKey;
  final bool isDefaultOwned;

  const ShopItem({
    required this.id,
    required this.nameKey,
    required this.descriptionKey,
    required this.category,
    required this.price,
    required this.rarity,
    required this.previewKey,
    this.isDefaultOwned = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameKey': nameKey,
        'descriptionKey': descriptionKey,
        'category': category.name,
        'price': price,
        'rarity': rarity.name,
        'previewKey': previewKey,
        'isDefaultOwned': isDefaultOwned,
      };

  factory ShopItem.fromJson(Map<String, dynamic> json) => ShopItem(
        id: json['id'] as String,
        nameKey: json['nameKey'] as String,
        descriptionKey: json['descriptionKey'] as String,
        category: ShopCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => ShopCategory.avatar,
        ),
        price: json['price'] as int? ?? 0,
        rarity: ItemRarity.values.firstWhere(
          (r) => r.name == json['rarity'],
          orElse: () => ItemRarity.common,
        ),
        previewKey: json['previewKey'] as String,
        isDefaultOwned: json['isDefaultOwned'] as bool? ?? false,
      );
}

/// Official Populated Catalog for Questly
class ShopCatalog {
  // Category 1: 12 Profile Avatars across 4 Rarity Tiers
  static const List<ShopItem> avatars = [
    // Common (50 coins)
    ShopItem(
      id: 'avatar_fox',
      nameKey: 'avatar_fox',
      descriptionKey: 'avatar_fox_desc',
      category: ShopCategory.avatar,
      price: 0,
      rarity: ItemRarity.common,
      previewKey: 'fox',
      isDefaultOwned: true,
    ),
    ShopItem(
      id: 'avatar_rabbit',
      nameKey: 'avatar_rabbit',
      descriptionKey: 'avatar_rabbit_desc',
      category: ShopCategory.avatar,
      price: 50,
      rarity: ItemRarity.common,
      previewKey: 'rabbit',
    ),
    ShopItem(
      id: 'avatar_turtle',
      nameKey: 'avatar_turtle',
      descriptionKey: 'avatar_turtle_desc',
      category: ShopCategory.avatar,
      price: 50,
      rarity: ItemRarity.common,
      previewKey: 'turtle',
    ),
    ShopItem(
      id: 'avatar_cat',
      nameKey: 'avatar_cat',
      descriptionKey: 'avatar_cat_desc',
      category: ShopCategory.avatar,
      price: 50,
      rarity: ItemRarity.common,
      previewKey: 'cat',
    ),

    // Rare (150 coins)
    ShopItem(
      id: 'avatar_panda',
      nameKey: 'avatar_panda',
      descriptionKey: 'avatar_panda_desc',
      category: ShopCategory.avatar,
      price: 150,
      rarity: ItemRarity.rare,
      previewKey: 'panda',
    ),
    ShopItem(
      id: 'avatar_owl',
      nameKey: 'avatar_owl',
      descriptionKey: 'avatar_owl_desc',
      category: ShopCategory.avatar,
      price: 150,
      rarity: ItemRarity.rare,
      previewKey: 'owl',
    ),
    ShopItem(
      id: 'avatar_eagle',
      nameKey: 'avatar_eagle',
      descriptionKey: 'avatar_eagle_desc',
      category: ShopCategory.avatar,
      price: 150,
      rarity: ItemRarity.rare,
      previewKey: 'eagle',
    ),
    ShopItem(
      id: 'avatar_wolf',
      nameKey: 'avatar_wolf',
      descriptionKey: 'avatar_wolf_desc',
      category: ShopCategory.avatar,
      price: 150,
      rarity: ItemRarity.rare,
      previewKey: 'wolf',
    ),

    // Epic (300 coins)
    ShopItem(
      id: 'avatar_dolphin',
      nameKey: 'avatar_dolphin',
      descriptionKey: 'avatar_dolphin_desc',
      category: ShopCategory.avatar,
      price: 300,
      rarity: ItemRarity.epic,
      previewKey: 'dolphin',
    ),
    ShopItem(
      id: 'avatar_tiger',
      nameKey: 'avatar_tiger',
      descriptionKey: 'avatar_tiger_desc',
      category: ShopCategory.avatar,
      price: 300,
      rarity: ItemRarity.epic,
      previewKey: 'tiger',
    ),

    // Legendary (500 coins)
    ShopItem(
      id: 'avatar_dragon',
      nameKey: 'avatar_dragon',
      descriptionKey: 'avatar_dragon_desc',
      category: ShopCategory.avatar,
      price: 500,
      rarity: ItemRarity.legendary,
      previewKey: 'dragon',
    ),
    ShopItem(
      id: 'avatar_space_robot',
      nameKey: 'avatar_space_robot',
      descriptionKey: 'avatar_space_robot_desc',
      category: ShopCategory.avatar,
      price: 500,
      rarity: ItemRarity.legendary,
      previewKey: 'space_robot',
    ),
  ];

  // Category 2: Dendy Customizations (Cosmetic versions)
  static const List<ShopItem> dendySkins = [
    ShopItem(
      id: 'dendy_classic',
      nameKey: 'dendy_classic',
      descriptionKey: 'dendy_classic_desc',
      category: ShopCategory.dendySkin,
      price: 0,
      rarity: ItemRarity.common,
      previewKey: 'classic',
      isDefaultOwned: true,
    ),
    ShopItem(
      id: 'dendy_explorer',
      nameKey: 'dendy_explorer',
      descriptionKey: 'dendy_explorer_desc',
      category: ShopCategory.dendySkin,
      price: 150,
      rarity: ItemRarity.rare,
      previewKey: 'explorer',
    ),
    ShopItem(
      id: 'dendy_scientist',
      nameKey: 'dendy_scientist',
      descriptionKey: 'dendy_scientist_desc',
      category: ShopCategory.dendySkin,
      price: 150,
      rarity: ItemRarity.rare,
      previewKey: 'scientist',
    ),
    ShopItem(
      id: 'dendy_space',
      nameKey: 'dendy_space',
      descriptionKey: 'dendy_space_desc',
      category: ShopCategory.dendySkin,
      price: 300,
      rarity: ItemRarity.epic,
      previewKey: 'space',
    ),
    ShopItem(
      id: 'dendy_astronaut',
      nameKey: 'dendy_astronaut',
      descriptionKey: 'dendy_astronaut_desc',
      category: ShopCategory.dendySkin,
      price: 300,
      rarity: ItemRarity.epic,
      previewKey: 'astronaut',
    ),
    ShopItem(
      id: 'dendy_wizard',
      nameKey: 'dendy_wizard',
      descriptionKey: 'dendy_wizard_desc',
      category: ShopCategory.dendySkin,
      price: 450,
      rarity: ItemRarity.legendary,
      previewKey: 'wizard',
    ),
  ];

  // Category 3: Unlockable Themes
  static const List<ShopItem> themes = [
    ShopItem(
      id: 'theme_classic',
      nameKey: 'theme_classic',
      descriptionKey: 'theme_classic_desc',
      category: ShopCategory.theme,
      price: 0,
      rarity: ItemRarity.common,
      previewKey: 'classic',
      isDefaultOwned: true,
    ),
    ShopItem(
      id: 'theme_ocean',
      nameKey: 'theme_ocean',
      descriptionKey: 'theme_ocean_desc',
      category: ShopCategory.theme,
      price: 150,
      rarity: ItemRarity.rare,
      previewKey: 'ocean',
    ),
    ShopItem(
      id: 'theme_forest',
      nameKey: 'theme_forest',
      descriptionKey: 'theme_forest_desc',
      category: ShopCategory.theme,
      price: 150,
      rarity: ItemRarity.rare,
      previewKey: 'forest',
    ),
    ShopItem(
      id: 'theme_sunset',
      nameKey: 'theme_sunset',
      descriptionKey: 'theme_sunset_desc',
      category: ShopCategory.theme,
      price: 300,
      rarity: ItemRarity.epic,
      previewKey: 'sunset',
    ),
    ShopItem(
      id: 'theme_space',
      nameKey: 'theme_space',
      descriptionKey: 'theme_space_desc',
      category: ShopCategory.theme,
      price: 300,
      rarity: ItemRarity.epic,
      previewKey: 'space',
    ),
    ShopItem(
      id: 'theme_aurora',
      nameKey: 'theme_aurora',
      descriptionKey: 'theme_aurora_desc',
      category: ShopCategory.theme,
      price: 450,
      rarity: ItemRarity.legendary,
      previewKey: 'aurora',
    ),
  ];

  static List<ShopItem> getAllItems() {
    return [...avatars, ...dendySkins, ...themes];
  }

  static ShopItem? getItemById(String id) {
    for (final item in getAllItems()) {
      if (item.id == id) return item;
    }
    return null;
  }
}
