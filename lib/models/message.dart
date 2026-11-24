/// A row from `messages` (chat text or snap).
class ChatMessage {
  final String id;
  final String pairId;
  final String senderId;
  final String text;
  final String type; // 'text' or 'snap'
  final String? imageUrl;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.pairId,
    required this.senderId,
    required this.text,
    required this.type,
    this.imageUrl,
    required this.createdAt,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> m) => ChatMessage(
        id: m['id'].toString(),
        pairId: m['pair_id'].toString(),
        senderId: m['sender_id'].toString(),
        text: (m['text'] ?? '').toString(),
        type: (m['type'] ?? 'text').toString(),
        imageUrl: m['image_url']?.toString(),
        createdAt: DateTime.tryParse(m['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.now(),
      );

  bool get isSnap => type == 'snap' && (imageUrl ?? '').isNotEmpty;

  String get timeLabel {
    final h = createdAt.hour % 12 == 0 ? 12 : createdAt.hour % 12;
    final m = createdAt.minute.toString().padLeft(2, '0');
    return '$h:$m ${createdAt.hour < 12 ? 'AM' : 'PM'}';
  }
}
