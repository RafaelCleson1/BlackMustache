class Service {
  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    required this.imageUrl,
    required this.isFeatured,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String imageUrl;
  final bool isFeatured;

  factory Service.fromMap(Map<String, dynamic> map) {
    return Service(
      id: map['id']?.toString() ?? '',
      name: (map['name'] as String?) ?? 'Serviço',
      description: (map['description'] as String?) ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      durationMinutes: (map['duration_minutes'] as num?)?.toInt() ?? 0,
      imageUrl: (map['image_url'] as String?) ?? '',
      isFeatured: (map['is_featured'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'duration_minutes': durationMinutes,
      'image_url': imageUrl,
      'is_featured': isFeatured,
    };
  }
}
