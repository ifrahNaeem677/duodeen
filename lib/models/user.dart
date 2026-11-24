/// A row from the `profiles` table.
class Profile {
  final String id;
  final String name;
  final String email;
  final String pairCode;
  final String? pairId;
  final String? avatarUrl;
  final String fajrTime; // "HH:MM"

  const Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.pairCode,
    this.pairId,
    this.avatarUrl,
    this.fajrTime = '05:00',
  });

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        id: m['id'].toString(),
        name: (m['name'] ?? '').toString(),
        email: (m['email'] ?? '').toString(),
        pairCode: (m['pair_code'] ?? '').toString(),
        pairId: m['pair_id']?.toString(),
        avatarUrl: m['avatar_url']?.toString(),
        fajrTime: (m['fajr_time'] ?? '05:00').toString(),
      );

  bool get isPaired => pairId != null;

  String get firstName {
    final n = name.trim();
    if (n.isEmpty) return 'Friend';
    return n.split(' ').first;
  }

  String get initial => name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
}
