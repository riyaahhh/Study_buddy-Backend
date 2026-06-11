class SessionModel {
  final String id;
  final String title;
  final String? subject;
  final String? description;
  final String hostId;
  final String hostName;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final int maxMembers;
  final String status;
  final String scheduledAt;
  final String createdAt;

  SessionModel({
    required this.id,
    required this.title,
    this.subject,
    this.description,
    required this.hostId,
    required this.hostName,
    this.latitude,
    this.longitude,
    this.locationName,
    required this.maxMembers,
    required this.status,
    required this.scheduledAt,
    required this.createdAt,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subject: json['subject']?.toString(),
      description: json['description']?.toString(),
      hostId: json['hostId']?.toString() ?? '',
      hostName: json['hostName']?.toString() ?? '',
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      locationName: json['locationName']?.toString(),
      maxMembers: json['maxMembers'] is int
          ? json['maxMembers']
          : int.tryParse(json['maxMembers'].toString()) ?? 10,
      status: json['status']?.toString() ?? 'upcoming',
      scheduledAt: json['scheduledAt']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}
