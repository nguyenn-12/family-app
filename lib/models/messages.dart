class MessageModel {
  final String senderId;
  final String senderName;
  final String avatarUrl;
  final String? text;
  final String? imageUrl;
  final DateTime timestamp;
  final List<String> readBy;

  MessageModel({
    required this.senderId,
    required this.senderName,
    required this.avatarUrl,
    this.text,
    this.imageUrl,
    required this.timestamp,
    required this.readBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderName': senderName,
      'avatarUrl': avatarUrl,
      'text': text,
      'imageUrl': imageUrl,
      'timestamp': timestamp.toIso8601String(),
      'readBy': readBy,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    return MessageModel(
      senderId: map['senderId'],
      senderName: map['senderName'],
      avatarUrl: map['avatarUrl'],
      text: map['text'],
      imageUrl: map['imageUrl'],
      timestamp: DateTime.parse(map['timestamp']),
      readBy: List<String>.from(map['readBy'] ?? []),
    );
  }
}
