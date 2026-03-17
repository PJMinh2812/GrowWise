class TaskModel {
  final String id;
  final String familyId;
  final String childId;
  final String createdBy;
  final String title;
  final String description;
  final String category;
  final int coinReward;
  final String icon;
  final TaskStatus status;
  final String? proofImageUrl;
  final String? parentNote;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    this.familyId = '',
    this.childId = '',
    this.createdBy = '',
    required this.title,
    required this.description,
    this.category = 'Việc nhà',
    required this.coinReward,
    required this.icon,
    this.status = TaskStatus.pending,
    this.proofImageUrl,
    this.parentNote,
    this.submittedAt,
    this.reviewedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? const _DefaultDateTime();

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      familyId: json['family_id'] as String? ?? '',
      childId: json['child_id'] as String? ?? '',
      createdBy: json['created_by'] as String? ?? '',
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'Việc nhà',
      coinReward: json['coin_reward'] as int,
      icon: json['icon'] as String? ?? '📋',
      status: TaskStatus.values.byName(json['status'] as String? ?? 'pending'),
      proofImageUrl: json['proof_image_url'] as String?,
      parentNote: json['parent_note'] as String?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  TaskModel copyWith({
    TaskStatus? status,
    String? proofImageUrl,
    String? parentNote,
    DateTime? submittedAt,
    DateTime? reviewedAt,
  }) {
    return TaskModel(
      id: id,
      familyId: familyId,
      childId: childId,
      createdBy: createdBy,
      title: title,
      description: description,
      category: category,
      coinReward: coinReward,
      icon: icon,
      status: status ?? this.status,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      parentNote: parentNote ?? this.parentNote,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      createdAt: createdAt,
    );
  }
}

enum TaskStatus { pending, submitted, approved, rejected }

// Helper for const default DateTime
class _DefaultDateTime implements DateTime {
  const _DefaultDateTime();
  @override
  dynamic noSuchMethod(Invocation invocation) => DateTime(2026);
}
