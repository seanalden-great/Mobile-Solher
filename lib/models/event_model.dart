class EventModel {
  final int id;
  final String title;
  final String description;
  final String season;
  final String eventDate;
  final List<String> images;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.season,
    required this.eventDate,
    required this.images,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      season: json['season'] ?? 'Editorial',
      eventDate: json['event_date'] ?? '',
      // Konversi array JSON ke List String
      images: List<String>.from(json['images'] ?? []), 
    );
  }

  // Helper untuk mendapatkan tahun
  String get year {
    if (eventDate.isEmpty) return '';
    return DateTime.tryParse(eventDate)?.year.toString() ?? '';
  }

  // Helper untuk URL gambar penuh
  List<String> get fullImageUrls {
    return images.map((path) {
      if (path.startsWith('http')) return path;
      return 'https://back.solher.co.id/storage/$path';
    }).toList();
  }
}