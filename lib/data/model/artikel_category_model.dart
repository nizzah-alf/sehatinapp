class ArtikelCategory {
  final int id;
  final String name;
  final String? deskripsi;
  final String? slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ArtikelCategory({
    required this.id,
    required this.name,
    this.deskripsi,
    this.slug,
    this.createdAt,
    this.updatedAt,
  });

  factory ArtikelCategory.fromJson(Map<String, dynamic> json) {
    return ArtikelCategory(
      id: json['id'],
      name: json['name'],
      deskripsi: json['deskripsi'],
      slug: json['slug'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }
}
