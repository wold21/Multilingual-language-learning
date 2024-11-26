class Group {
  final int? id;
  final String name;
  final int createdAt;
  final int updatedAt;

  Group({
    this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Group copyWith({
    int? id,
    String? name,
    int? createdAt,
    int? updatedAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
