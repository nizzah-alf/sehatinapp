class Artikel {
  final int id;
  final String title;
  final String? image;
  final String isi;
  final int categoryId;
  final String author;
  final DateTime? createdAt;  // <-- tambah ini

  Artikel({
    required this.id,
    required this.title,
    this.image,
    required this.isi,
    required this.categoryId,
    required this.author,
    this.createdAt,   // <-- tambah ini juga di constructor
  });

  factory Artikel.fromJson(Map<String, dynamic> json) {
    return Artikel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      image: json['image'],
      isi: json['isi'] ?? '',
      categoryId: json['category_id'] is int ? json['category_id'] : int.parse(json['category_id'].toString()),
      author: json['author'] ?? 'Tim Sehatin',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,  // <-- parsing created_at dari string
    );
  }
}
