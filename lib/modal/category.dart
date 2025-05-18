class Category {
  final String name;
  final DateTime? createdAt;
  final String description;
  final String id;

  Category({
    required this.name,
    required this.description,
    required this.id,
    this.createdAt,
  });

  factory Category.fromMap(String id, Map<String, dynamic> map) {
    return Category(
      name: map['name'] ?? "",
      description: map['description'] ?? "",
      id: id,
      createdAt: map['createdAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  Category copyWith({
    String? name,
    DateTime? createdAt,
    String? description,
    String? id,
  }) {
    return Category(
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      id: id ?? this.id,
    );
  }
}
