import 'task_model.dart';

class TaskSubmission {
  final String id;
  final String taskId; // references tasks (template)
  final String childId;
  final TaskStatus status;
  final String? proofImageUrl;
  final String? parentNote;
  final int? qualityRating;
  final int? coinEarned;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final bool autoApproved;
  final DateTime createdAt;

  const TaskSubmission({
    required this.id,
    required this.taskId,
    required this.childId,
    this.status = TaskStatus.pending,
    this.proofImageUrl,
    this.parentNote,
    this.qualityRating,
    this.coinEarned,
    this.submittedAt,
    this.reviewedAt,
    this.autoApproved = false,
    required this.createdAt,
  });

  factory TaskSubmission.fromJson(Map<String, dynamic> json) {
    return TaskSubmission(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      childId: json['child_id'] as String? ?? '',
      status: TaskStatus.values.byName(json['status'] as String? ?? 'pending'),
      proofImageUrl: json['proof_image_url'] as String?,
      parentNote: json['parent_note'] as String?,
      qualityRating: json['quality_rating'] as int?,
      coinEarned: json['coin_earned'] as int?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.parse(json['reviewed_at'] as String)
          : null,
      autoApproved: json['auto_approved'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  TaskSubmission copyWith({
    TaskStatus? status,
    String? proofImageUrl,
    String? parentNote,
    int? qualityRating,
    int? coinEarned,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    bool? autoApproved,
  }) {
    return TaskSubmission(
      id: id,
      taskId: taskId,
      childId: childId,
      status: status ?? this.status,
      proofImageUrl: proofImageUrl ?? this.proofImageUrl,
      parentNote: parentNote ?? this.parentNote,
      qualityRating: qualityRating ?? this.qualityRating,
      coinEarned: coinEarned ?? this.coinEarned,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      autoApproved: autoApproved ?? this.autoApproved,
      createdAt: createdAt,
    );
  }
}
