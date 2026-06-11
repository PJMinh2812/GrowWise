class TaskModel {
  final String id;           // template ID (tasks table)
  final String? submissionId; // active submission ID (task_submissions table), null = not started
  final String familyId;
  final String childId;
  final String createdBy;
  final String title;
  final String description;
  final String category;
  final int coinReward;
  final String icon;
  final TaskStatus status;   // from submission if exists, else 'pending'
  final String? proofImageUrl;
  final String? parentNote;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final DateTime createdAt;
  final bool isTemplate;
  final bool isActive;
  final int? qualityRating;
  final DateTime? dueDate;
  final bool hasPenalty;
  final int penaltyPercent;
  final int? autoApproveAfter;
  final int approvalCount;
  final bool autoApproved;

  bool get canAutoApprove =>
      autoApproveAfter != null && approvalCount >= autoApproveAfter!;

  const TaskModel({
    required this.id,
    this.submissionId,
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
    this.isTemplate = false,
    this.isActive = true,
    this.qualityRating,
    this.dueDate,
    this.hasPenalty = false,
    this.penaltyPercent = 10,
    this.autoApproveAfter,
    this.approvalCount = 0,
    this.autoApproved = false,
  }) : createdAt = createdAt ?? const _DefaultDateTime();

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      submissionId: json['submission_id'] as String?,
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
      isTemplate: json['is_template'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      qualityRating: json['quality_rating'] as int?,
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      hasPenalty: json['has_penalty'] as bool? ?? false,
      penaltyPercent: json['penalty_percent'] as int? ?? 10,
      autoApproveAfter: json['auto_approve_after'] as int?,
      approvalCount: json['approval_count'] as int? ?? 0,
      autoApproved: json['auto_approved'] as bool? ?? false,
    );
  }

  TaskModel copyWith({
    String? submissionId,
    TaskStatus? status,
    String? proofImageUrl,
    String? parentNote,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    bool? isTemplate,
    bool? isActive,
    int? qualityRating,
    DateTime? dueDate,
    bool? hasPenalty,
    int? penaltyPercent,
    int? autoApproveAfter,
    int? approvalCount,
    bool? autoApproved,
  }) {
    return TaskModel(
      id: id,
      submissionId: submissionId ?? this.submissionId,
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
      isTemplate: isTemplate ?? this.isTemplate,
      isActive: isActive ?? this.isActive,
      qualityRating: qualityRating ?? this.qualityRating,
      dueDate: dueDate ?? this.dueDate,
      hasPenalty: hasPenalty ?? this.hasPenalty,
      penaltyPercent: penaltyPercent ?? this.penaltyPercent,
      autoApproveAfter: autoApproveAfter ?? this.autoApproveAfter,
      approvalCount: approvalCount ?? this.approvalCount,
      autoApproved: autoApproved ?? this.autoApproved,
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
