class WantToFindModel {
  const WantToFindModel({
    required this.id,
    required this.title,
    required this.authors,
    this.summary,
    this.isbn,
    this.externalId,
    this.coverUrl,
    this.sourceUrl,
    this.notes,
    this.createdUtc,
    this.lastModifiedUtc,
  });

  final int id;
  final String title;
  final String authors;
  final String? summary;
  final String? isbn;
  final String? externalId;
  final String? coverUrl;
  final String? sourceUrl;
  final String? notes;
  final DateTime? createdUtc;
  final DateTime? lastModifiedUtc;

  factory WantToFindModel.fromJson(Map<String, dynamic> json) {
    return WantToFindModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      authors: json['authors'] as String? ?? '',
      summary: json['summary'] as String?,
      isbn: json['isbn'] as String?,
      externalId: json['externalId'] as String?,
      coverUrl: json['coverUrl'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      notes: json['notes'] as String?,
      createdUtc: DateTime.tryParse(json['createdUtc'] as String? ?? ''),
      lastModifiedUtc: DateTime.tryParse(
        json['lastModifiedUtc'] as String? ?? '',
      ),
    );
  }
}

class WantToFindDraft {
  const WantToFindDraft({
    required this.title,
    this.authors = '',
    this.summary,
    this.isbn,
    this.externalId,
    this.coverUrl,
    this.sourceUrl,
    this.notes,
  });

  final String title;
  final String authors;
  final String? summary;
  final String? isbn;
  final String? externalId;
  final String? coverUrl;
  final String? sourceUrl;
  final String? notes;

  factory WantToFindDraft.fromModel(WantToFindModel model) {
    return WantToFindDraft(
      title: model.title,
      authors: model.authors,
      summary: model.summary,
      isbn: model.isbn,
      externalId: model.externalId,
      coverUrl: model.coverUrl,
      sourceUrl: model.sourceUrl,
      notes: model.notes,
    );
  }

  Map<String, dynamic> toJson({int id = 0}) => {
    'id': id,
    'title': title.trim(),
    'authors': authors.trim(),
    'summary': _clean(summary),
    'isbn': _clean(isbn),
    'externalId': _clean(externalId),
    'coverUrl': _clean(coverUrl),
    'sourceUrl': _clean(sourceUrl),
    'notes': _clean(notes),
  };
}

String? _clean(String? value) {
  final normalized = value?.trim();
  return normalized == null || normalized.isEmpty ? null : normalized;
}
