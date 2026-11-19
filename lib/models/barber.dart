class Barber {
  const Barber({
    required this.id,
    required this.name,
    required this.specialty,
    required this.avatarUrl,
    required this.active,
  });

  final String id;
  final String name;
  final String specialty;
  final String avatarUrl;
  final bool active;

  factory Barber.fromMap(Map<String, dynamic> map) {
    return Barber(
      id: map['id']?.toString() ?? '',
      name: (map['name'] as String?) ?? 'Profissional',
      specialty: (map['specialty'] as String?) ?? '',
      avatarUrl: (map['avatar_url'] as String?) ?? '',
      active: (map['active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'specialty': specialty,
      'avatar_url': avatarUrl,
      'active': active,
    };
  }
}
