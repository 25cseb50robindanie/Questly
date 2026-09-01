class CurriculumChunk {
  final String id;
  final String concept;
  final String text;
  final List<String> keywords;

  const CurriculumChunk({
    required this.id,
    required this.concept,
    required this.text,
    required this.keywords,
  });

  factory CurriculumChunk.fromJson(Map<String, dynamic> json) {
    return CurriculumChunk(
      id: json['id'] as String? ?? '',
      concept: json['concept'] as String? ?? '',
      text: json['text'] as String? ?? '',
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase().trim())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'concept': concept,
        'text': text,
        'keywords': keywords,
      };
}

class CurriculumMisconception {
  final String id;
  final String pattern;
  final List<String> keywords;
  final String correction;

  const CurriculumMisconception({
    required this.id,
    required this.pattern,
    required this.keywords,
    required this.correction,
  });

  factory CurriculumMisconception.fromJson(Map<String, dynamic> json) {
    return CurriculumMisconception(
      id: json['id'] as String? ?? '',
      pattern: json['pattern'] as String? ?? '',
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString().toLowerCase().trim())
              .toList() ??
          [],
      correction: json['correction'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'pattern': pattern,
        'keywords': keywords,
        'correction': correction,
      };
}

class CurriculumPackage {
  final String packageId;
  final String name;
  final String moduleId;
  final String version;
  final List<CurriculumChunk> chunks;
  final List<CurriculumMisconception> misconceptions;

  const CurriculumPackage({
    required this.packageId,
    required this.name,
    required this.moduleId,
    required this.version,
    required this.chunks,
    required this.misconceptions,
  });

  factory CurriculumPackage.fromJson(Map<String, dynamic> json) {
    final rawChunks = json['chunks'] as List<dynamic>? ?? [];
    final rawMisconceptions = json['misconceptions'] as List<dynamic>? ?? [];

    return CurriculumPackage(
      packageId: json['packageId'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      moduleId: json['moduleId'] as String? ?? '',
      version: json['version'] as String? ?? '1.0.0',
      chunks: rawChunks.map((c) => CurriculumChunk.fromJson(c as Map<String, dynamic>)).toList(),
      misconceptions: rawMisconceptions
          .map((m) => CurriculumMisconception.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PackageManifestEntry {
  final String id;
  final String name;
  final String version;
  final String subject;
  final String path;
  final List<String> languages;

  const PackageManifestEntry({
    required this.id,
    required this.name,
    required this.version,
    required this.subject,
    required this.path,
    required this.languages,
  });

  factory PackageManifestEntry.fromJson(Map<String, dynamic> json) {
    return PackageManifestEntry(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      version: json['version'] as String? ?? '1.0.0',
      subject: json['subject'] as String? ?? 'SCIENCE',
      path: json['path'] as String? ?? '',
      languages: (json['languages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['en'],
    );
  }
}
