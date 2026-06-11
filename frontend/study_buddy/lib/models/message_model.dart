class MessageModel {
  final String id;
  final String sessionId;
  final String senderId;
  final String senderName;
  final String content;
  final String sentAt;

  MessageModel({
    required this.id,
    required this.sessionId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? '',
      sessionId: json['sessionId'] ?? '',
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? '',
      content: json['content'] ?? '',
      sentAt: json['sentAt'] ?? '',
    );
  }
}
