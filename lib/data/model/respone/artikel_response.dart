class Artikel {
  final int id;
  final String title;
  final String? image;
  final String isi;
  final int categoryId;
  final String author;
  final String? createdAt;  // nullable

  Artikel({
    required this.id,
    required this.title,
    this.image,
    required this.isi,
    required this.categoryId,
    required this.author,
    this.createdAt,
  });

  factory Artikel.fromJson(Map<String, dynamic> json) {
    return Artikel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      title: json['title'] ?? '',
      image: json['image'],
      isi: json['isi'] ?? '',
      categoryId: json['category_id'] is int
          ? json['category_id']
          : int.tryParse(json['category_id'].toString()) ?? 0,
      author: json['author'] ?? 'Tim Sehatin',
      createdAt: json['tanggal_pembuatan'], // nullable, boleh null
    );
  }
}
