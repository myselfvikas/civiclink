class CivicIssue {
  final String id;
  final String reporterId;
  final String title;
  final String description;
  final String category;
  final String priority;
  final String status;
  final String locationAddress;
  final List<double>? locationCoordinates;
  final List<String> imageUrls;
  final bool isAnonymous;
  final bool allowPublicView;
  final String? assignedTo;
  final String? department;
  final int votesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  CivicIssue({
    required this.id,
    required this.reporterId,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.locationAddress,
    this.locationCoordinates,
    this.imageUrls = const [],
    this.isAnonymous = false,
    this.allowPublicView = true,
    this.assignedTo,
    this.department,
    this.votesCount = 0,
    this.commentsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CivicIssue.fromJson(Map<String, dynamic> json) {
    return CivicIssue(
      id: json['id'] ?? '',
      reporterId: json['reporter_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      priority: json['priority'] ?? '',
      status: json['status'] ?? '',
      locationAddress: json['location_address'] ?? '',
      locationCoordinates: json['location_coordinates'] != null
          ? List<double>.from(json['location_coordinates'])
          : null,
      imageUrls: json['image_urls'] != null
          ? List<String>.from(json['image_urls'])
          : [],
      isAnonymous: json['is_anonymous'] ?? false,
      allowPublicView: json['allow_public_view'] ?? true,
      assignedTo: json['assigned_to'],
      department: json['department'],
      votesCount: json['votes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reporter_id': reporterId,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'location_address': locationAddress,
      'location_coordinates': locationCoordinates,
      'image_urls': imageUrls,
      'is_anonymous': isAnonymous,
      'allow_public_view': allowPublicView,
      'assigned_to': assignedTo,
      'department': department,
      'votes_count': votesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CivicIssue copyWith({
    String? id,
    String? reporterId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? locationAddress,
    List<double>? locationCoordinates,
    List<String>? imageUrls,
    bool? isAnonymous,
    bool? allowPublicView,
    String? assignedTo,
    String? department,
    int? votesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CivicIssue(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      locationAddress: locationAddress ?? this.locationAddress,
      locationCoordinates: locationCoordinates ?? this.locationCoordinates,
      imageUrls: imageUrls ?? this.imageUrls,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      allowPublicView: allowPublicView ?? this.allowPublicView,
      assignedTo: assignedTo ?? this.assignedTo,
      department: department ?? this.department,
      votesCount: votesCount ?? this.votesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
