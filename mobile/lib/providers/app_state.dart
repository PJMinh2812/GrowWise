import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../l10n/app_strings.dart';
import '../models/task_model.dart';
import '../models/task_submission.dart';
import '../models/video_lesson_model.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';

class AppState extends ChangeNotifier {
  // Demo mode (active when .env uses placeholder values OR user explicitly activated)
  bool _forcedDemoMode = false;
  int _streakDays = 0;
  DateTime? _lastStreakDate;
  String? _pendingStreakBadge;

  // Password recovery — set true khi app mở từ link reset password
  bool _pendingPasswordRecovery = false;
  bool get hasPendingPasswordRecovery => _pendingPasswordRecovery;

  void onPasswordRecovery() {
    _pendingPasswordRecovery = true;
    notifyListeners();
  }

  void clearPasswordRecovery() {
    _pendingPasswordRecovery = false;
  }

  bool get isDemoMode {
    if (_forcedDemoMode) return true;
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    return url.contains('placeholder') || url.isEmpty;
  }

  void activateDemo() {
    _forcedDemoMode = true;
    _seedDemoData();
  }

  // Auth state
  bool _isLoggedIn = false;
  bool _hasSeenOnboarding = false;
  String _parentName = '';
  String _parentEmail = '';

  // Supabase IDs
  String? _familyId;
  String? _childId;

  // Task templates (parent creates once)
  List<TaskModel> _tasks = [];
  // Submissions (each time child starts/completes a task)
  List<TaskSubmission> _submissions = [];

  // All children in the family (for multi-child management)
  List<Map<String, dynamic>> _children = [];

  // Child profile (the active child)
  String _childName = '';
  String _childAvatarEmoji = '👦';
  int _childAge = 8;
  int _level = 1;
  int _totalCoins = 0;
  int _spendJar = 0;
  int _saveJar = 0;
  int _shareJar = 0;
  int _xp = 0;
  int _xpToNextLevel = 100;
  List<String> _badges = [];
  Map<String, int> _categoryTaskCounts = {};
  TaskModel? _justApprovedTask;
  Set<String> _completedLessonIds = {};
  List<VideoLesson> _lessons = [];
  String? _pendingNewBadge; // any newly earned badge (emoji + name)

  static const _storage = FlutterSecureStorage();
  static const _completedLessonsKey = 'completed_lesson_ids';
  final Map<String, String> _customBadgeEmoji = {}; // achievementId → custom emoji

  // Dream items
  List<Map<String, dynamic>> _dreamItems = [];
  List<Map<String, dynamic>> _dreamPurchaseRequests = [];
  final Set<String> _approvedDreamIds = {};

  // Proof image bytes — keyed by taskId, kept in memory during session
  final Map<String, Uint8List> _taskProofImages = {};

  Uint8List? getTaskProofBytes(String taskId) => _taskProofImages[taskId];

  // Memory lane
  List<Map<String, String>> _memories = [];

  // Bonding message (parent → child)
  String _bondingMessage = '';

  // Notifications preference
  bool _notificationsEnabled = true;

  // Locale
  String _locale = 'vi';

  // ── Subscription / Plan ────────────────────────────────────────────────────
  String _planType = 'free'; // 'free' | 'premium' | 'family'

  String get planType => _planType;
  bool get isPremium => _planType == 'premium' || _planType == 'family';

  int get maxDailyAiMessages => isPremium ? 999 : 5;
  int get maxActiveTasks => isPremium ? 999 : 3;
  int get unlockedLessons => isPremium ? 999 : 3;

  Future<void> startPremiumTrial(String planName) async {
    if (isDemoMode) {
      _planType = planName;
      notifyListeners();
      return;
    }
    final uid = SupabaseService.userId;
    if (uid == null) return;
    await SupabaseService.startTrial(userId: uid, planName: planName);
    _planType = planName;
    notifyListeners();
  }

  Future<void> _loadPlan() async {
    final uid = SupabaseService.userId;
    if (uid == null) return;
    final plan = await SupabaseService.getUserPlan(uid);
    if (plan != null && plan != _planType) {
      _planType = plan;
      notifyListeners();
    }
  }

  /// Force-reloads the subscription plan from Supabase.
  /// Called after a successful MoMo payment.
  Future<void> refreshPlan() => _loadPlan();

  // ── Initialize ─────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (isDemoMode) {
      _seedDemoData();
      return;
    }
    await _loadCompletedLessons();

    final user = SupabaseService.auth.currentUser;
    if (user == null) return;

    _isLoggedIn = true;
    _parentEmail = user.email ?? '';

    // Load profile
    final profile = await SupabaseService.getProfile();
    if (profile != null) {
      _parentName = profile['full_name'] as String? ?? '';
    }

    // Load settings
    final settings = await SupabaseService.getSettings();
    if (settings != null) {
      _hasSeenOnboarding = settings['has_seen_onboarding'] as bool? ?? false;
      _bondingMessage = settings['bonding_message'] as String? ?? '';
      _notificationsEnabled =
          settings['notifications_enabled'] as bool? ?? true;
      _locale = settings['locale'] as String? ?? 'vi';
    }

    // Load family
    _familyId = await SupabaseService.getFamilyId();
    if (_familyId == null) return;

    // Load children list + active (first) child
    _children = await SupabaseService.getChildren(_familyId!);
    if (_children.isNotEmpty) {
      await _applyChild(_children.first);
    }
    await _reloadChildScopedData();

    // Load memories
    final memoryRows = await SupabaseService.getMemories(familyId: _familyId!);
    _memories = memoryRows
        .map(
          (row) => <String, String>{
            'date': _formatDate(row['created_at'] as String? ?? ''),
            'task': row['task_title'] as String? ?? '',
            'emoji': row['emoji'] as String? ?? '⭐',
            'note': row['note'] as String? ?? '',
            'taskId': '',
            'category': '',
            'proofImageUrl': row['proof_image_url'] as String? ?? '',
          },
        )
        .toList();

    // Load lessons từ Supabase
    final lessonRows = await SupabaseService.getLessons();
    _lessons = lessonRows.map(_parseLessonFromJson).toList();

    // Load subscription plan
    await _loadPlan();

    notifyListeners();
  }

  VideoLesson _parseLessonFromJson(Map<String, dynamic> json) {
    final quizRows = List<Map<String, dynamic>>.from(
        (json['lesson_quizzes'] as List<dynamic>?) ?? []);
    quizRows.sort((a, b) =>
        (a['order_index'] as int? ?? 0).compareTo(b['order_index'] as int? ?? 0));

    final quizzes = quizRows.map((q) {
      final optionRows = List<Map<String, dynamic>>.from(
          (q['quiz_options'] as List<dynamic>?) ?? []);
      optionRows.sort((a, b) =>
          (a['order_index'] as int? ?? 0).compareTo(b['order_index'] as int? ?? 0));
      return VideoQuiz.fromJson(q, optionRows.map(QuizOption.fromJson).toList());
    }).toList();

    return VideoLesson.fromJson(json, quizzes);
  }

  // ── Getters ────────────────────────────────────────────────────────────────

  bool get isLoggedIn => _isLoggedIn;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  String get parentName => _parentName;
  String get parentEmail => _parentEmail;
  String? get familyId => _familyId;
  String? get childId => _childId;
  List<Map<String, dynamic>> get children => List.unmodifiable(_children);
  List<TaskModel> get tasks => List.unmodifiable(_tasks);
  String get childName => _childName;
  String get childAvatarEmoji => _childAvatarEmoji;
  int get childAge => _childAge;
  int get level => _level;
  int get totalCoins => _totalCoins;
  int get spendJar => _spendJar;
  int get saveJar => _saveJar;
  int get shareJar => _shareJar;
  int get xp => _xp;
  int get xpToNextLevel => _xpToNextLevel;
  int get streakDays => _streakDays;
  String? get pendingStreakBadge => _pendingStreakBadge;
  String? get pendingNewBadge => _pendingNewBadge;
  Map<String, String> get customBadgeEmoji => Map.unmodifiable(_customBadgeEmoji);
  TaskModel? get justApprovedTask => _justApprovedTask;
  bool isLessonCompleted(String id) => _completedLessonIds.contains(id);
  int get completedLessonCount => _completedLessonIds.length;
  List<VideoLesson> get childLessons => _lessons.where((l) => l.audience == 'child').toList();
  List<VideoLesson> get parentLessons => _lessons.where((l) => l.audience == 'parent').toList();
  List<String> get badges => List.unmodifiable(_badges);
  bool get hasChild => _childId != null;
  List<Map<String, dynamic>> get dreamItemsList =>
      List.unmodifiable(_dreamItems);
  List<Map<String, dynamic>> get dreamPurchaseRequests =>
      List.unmodifiable(_dreamPurchaseRequests);
  Set<String> get approvedDreamIds => Set.unmodifiable(_approvedDreamIds);
  List<Map<String, String>> get memories => List.unmodifiable(_memories);
  String get bondingMessage => _bondingMessage;
  bool get notificationsEnabled => _notificationsEnabled;
  String get locale => _locale;
  AppStrings get strings => AppStrings.of(_locale);

  List<TaskModel> get templateTasks => List.unmodifiable(_tasks);

  /// All active templates — for parent template chips (regardless of assignment state).
  List<TaskModel> get activeTemplates =>
      _tasks.where((t) => t.isActive).toList();

  /// Only templates that have been ASSIGNED (have an active pending/submitted submission).
  /// Child only sees tasks here — parent controls when tasks appear.
  List<TaskModel> get childViewTasks {
    return _tasks.where((t) => t.isActive).expand((template) {
      final activeSub = _submissions
          .where((s) => s.taskId == template.id &&
              (s.status == TaskStatus.pending ||
               s.status == TaskStatus.submitted ||
               s.status == TaskStatus.rejected ||
               // Auto-approved within 24h: parent can still retroactively reject
               (s.status == TaskStatus.approved && s.autoApproved &&
                s.reviewedAt != null &&
                DateTime.now().difference(s.reviewedAt!).inHours < 24)))
          .fold<TaskSubmission?>(null, (latest, s) =>
              latest == null || s.createdAt.isAfter(latest.createdAt) ? s : latest);

      // No active submission → not yet assigned → invisible to child
      if (activeSub == null) return <TaskModel>[];

      return [template.copyWith(
        submissionId: activeSub.id,
        status: activeSub.status,
        proofImageUrl: activeSub.proofImageUrl,
        parentNote: activeSub.parentNote,
        submittedAt: activeSub.submittedAt,
        reviewedAt: activeSub.reviewedAt,
        qualityRating: activeSub.qualityRating,
        autoApproved: activeSub.autoApproved,
      )];
    }).toList();
  }

  /// Approved submissions merged with template data — for child history tab.
  List<TaskModel> get approvedTasks {
    return _submissions
        .where((s) => s.status == TaskStatus.approved)
        .map((sub) {
          final template = _tasks.firstWhere(
            (t) => t.id == sub.taskId,
            orElse: () => TaskModel(
              id: sub.taskId, title: '?', description: '', coinReward: 0, icon: '📋',
            ),
          );
          return template.copyWith(
            submissionId: sub.id,
            status: TaskStatus.approved,
            reviewedAt: sub.reviewedAt,
            qualityRating: sub.qualityRating,
            autoApproved: sub.autoApproved,
          );
        })
        .toList();
  }

  /// Submissions waiting for parent approval, merged with template data.
  List<TaskModel> get parentPendingSubmissions {
    return _submissions
        .where((s) => s.status == TaskStatus.submitted)
        .map((sub) {
          final template = _tasks.firstWhere(
            (t) => t.id == sub.taskId,
            orElse: () => TaskModel(
              id: sub.taskId, title: '?', description: '', coinReward: 0, icon: '📋',
            ),
          );
          return template.copyWith(
            submissionId: sub.id,
            status: sub.status,
            proofImageUrl: sub.proofImageUrl,
            submittedAt: sub.submittedAt,
          );
        })
        .toList();
  }

  List<TaskModel> get pendingTasks =>
      childViewTasks.where((t) => t.status == TaskStatus.pending).toList();
  List<TaskModel> get submittedTasks =>
      childViewTasks.where((t) => t.status == TaskStatus.submitted).toList();
  List<TaskModel> get rejectedTasks =>
      childViewTasks.where((t) => t.status == TaskStatus.rejected).toList();
  int get totalCoinsRewarded => _submissions
      .where((s) => s.status == TaskStatus.approved)
      .fold(0, (sum, s) => sum + (s.coinEarned ?? 0));

  // ── Auth actions ───────────────────────────────────────────────────────────

  Future<void> login({required String email, required String password}) async {
    await SupabaseService.signIn(email: email, password: password);
    _isLoggedIn = true;
    _parentEmail = email;
    await initialize();
  }

  Future<void> loginWithGoogle() async {
    await SupabaseService.signInWithGoogle();
    // Auth state listener in LoginScreen handles navigation after OAuth completes
  }

  Future<void> initializeAfterOAuth() async {
    final user = SupabaseService.auth.currentUser;
    if (user == null) return;
    _isLoggedIn = true;
    _parentEmail = user.email ?? '';
    await initialize();
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    await SupabaseService.signUp(
      email: email,
      password: password,
      fullName: fullName,
    );
  }

  Future<void> logout() async {
    await SupabaseService.signOut();
    _isLoggedIn = false;
    _parentName = '';
    _parentEmail = '';
    _familyId = null;
    _childId = null;
    _tasks = [];
    _childName = '';
    _childAvatarEmoji = '👦';
    _childAge = 8;
    _level = 1;
    _totalCoins = 0;
    _spendJar = 0;
    _saveJar = 0;
    _shareJar = 0;
    _xp = 0;
    _xpToNextLevel = 100;
    _badges = [];
    _dreamItems = [];
    _dreamPurchaseRequests = [];
    _approvedDreamIds.clear();
    _memories = [];
    _bondingMessage = '';
    _notificationsEnabled = true;
    notifyListeners();
  }

  Future<void> completeOnboarding() async {
    _hasSeenOnboarding = true;
    await SupabaseService.updateSettings({'has_seen_onboarding': true});
    notifyListeners();
  }

  // ── Child management ───────────────────────────────────────────────────────

  Future<void> createChild({
    required String name,
    required int age,
    String avatarEmoji = '👦',
  }) async {
    if (_familyId == null) return;
    final child = await SupabaseService.createChild(
      familyId: _familyId!,
      name: name,
      age: age,
      avatarEmoji: avatarEmoji,
    );
    _childId = child['id'] as String;
    _childName = name;
    notifyListeners();
  }

  /// Applies a child row to the active-child state (fields + badges + dreams).
  Future<void> _applyChild(Map<String, dynamic> child) async {
    _childId = child['id'] as String;
    _childName = child['name'] as String? ?? '';
    _childAvatarEmoji = child['avatar_emoji'] as String? ?? '👦';
    _childAge = child['age'] as int? ?? 8;
    _level = child['level'] as int? ?? 1;
    _totalCoins = child['total_coins'] as int? ?? 0;
    _spendJar = child['spend_jar'] as int? ?? 0;
    _saveJar = child['save_jar'] as int? ?? 0;
    _shareJar = child['share_jar'] as int? ?? 0;
    _xp = child['xp'] as int? ?? 0;
    _xpToNextLevel = child['xp_to_next_level'] as int? ?? 100;
    _streakDays = child['streak_days'] as int? ?? 0;
    final lastStreakStr = child['last_streak_date'] as String?;
    _lastStreakDate = lastStreakStr != null ? DateTime.tryParse(lastStreakStr) : null;

    final badgeRows = await SupabaseService.getBadges(_childId!);
    _badges = badgeRows.map((b) => '${b['emoji']} ${b['title']}').toList();

    final dreams = await SupabaseService.getDreamItems(_childId!);
    _dreamItems = dreams.map((item) {
      final price = item['price'] as int;
      final progress = price > 0 ? _totalCoins / price : 0.0;
      return {...item, 'progress': progress > 1.0 ? 1.0 : progress};
    }).toList();
  }

  /// Reloads task templates + submissions scoped to the active child.
  Future<void> _reloadChildScopedData() async {
    if (_familyId == null) return;
    final templateRows = await SupabaseService.getTaskTemplates(
      familyId: _familyId!,
      childId: _childId,
    );
    _tasks = templateRows.map((row) => TaskModel.fromJson(row)).toList();
    if (_childId != null) {
      final subRows = await SupabaseService.getSubmissions(childId: _childId!);
      _submissions = subRows.map((r) => TaskSubmission.fromJson(r)).toList();
    } else {
      _submissions = [];
    }
    _recomputeCategoryTaskCounts();
  }

  /// Refreshes the list of children in the family.
  Future<void> loadChildrenList() async {
    if (_familyId == null) return;
    _children = await SupabaseService.getChildren(_familyId!);
    notifyListeners();
  }

  /// Switches the active child and reloads all of its data.
  Future<void> switchChild(String childId) async {
    if (childId == _childId) return;
    final child = _children.firstWhere(
      (c) => c['id'] == childId,
      orElse: () => <String, dynamic>{},
    );
    if (child.isEmpty) return;
    await _applyChild(child);
    await _reloadChildScopedData();
    notifyListeners();
  }

  /// Adds a child, enforcing the plan's max_children limit.
  /// Returns null on success, or an error message if blocked.
  Future<String?> addChildWithLimit({
    required String name,
    required int age,
    String avatarEmoji = '👦',
  }) async {
    if (_familyId == null) return 'Chưa có hồ sơ gia đình.';
    if (isDemoMode) return 'Chế độ demo không thêm được con.';
    final uid = SupabaseService.userId;
    if (uid == null) return 'Phiên đăng nhập hết hạn.';

    final maxChildren = await SupabaseService.getPlanMaxChildren(uid);
    await loadChildrenList();
    if (_children.length >= maxChildren) {
      return 'Gói hiện tại chỉ cho phép $maxChildren hồ sơ con. Nâng cấp gói Gia Đình để thêm.';
    }

    await SupabaseService.createChild(
      familyId: _familyId!,
      name: name,
      age: age,
      avatarEmoji: avatarEmoji,
    );
    await loadChildrenList();
    return null;
  }

  // ── Task actions ───────────────────────────────────────────────────────────

  /// Creates a task template (parent). Child must call [startTask] to begin.
  Future<void> addTask(TaskModel task) async {
    if (_familyId == null || _childId == null) return;
    if (isDemoMode) {
      final demoTemplate = TaskModel(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        title: task.title,
        description: task.description,
        category: task.category,
        icon: task.icon,
        coinReward: task.coinReward,
        isTemplate: true,
        isActive: true,
        createdAt: DateTime.now(),
        dueDate: task.dueDate,
        hasPenalty: task.hasPenalty,
        penaltyPercent: task.penaltyPercent,
        autoApproveAfter: task.autoApproveAfter,
      );
      _tasks.insert(0, demoTemplate);
      notifyListeners();
      return;
    }
    final row = await SupabaseService.createTask(
      familyId: _familyId!,
      childId: _childId!,
      title: task.title,
      description: task.description,
      category: task.category,
      icon: task.icon,
      coinReward: task.coinReward,
      dueDate: task.dueDate,
      hasPenalty: task.hasPenalty,
      penaltyPercent: task.penaltyPercent,
      autoApproveAfter: task.autoApproveAfter,
    );
    _tasks.insert(0, TaskModel.fromJson(row));
    notifyListeners();
  }

  /// Parent assigns a task template to the child — creates a pending submission.
  Future<void> assignTask(String templateId) => startTask(templateId);

  /// Child starts a task template — creates a new pending submission.
  Future<void> startTask(String templateId) async {
    final templateIdx = _tasks.indexWhere((t) => t.id == templateId);
    if (templateIdx == -1) return;

    // Guard: don't create a duplicate if an active submission already exists
    final alreadyActive = _submissions.any(
      (s) => s.taskId == templateId &&
          (s.status == TaskStatus.pending || s.status == TaskStatus.submitted),
    );
    if (alreadyActive) return;

    if (isDemoMode) {
      _submissions.add(TaskSubmission(
        id: 'demo-sub-${DateTime.now().millisecondsSinceEpoch}',
        taskId: templateId,
        childId: _childId ?? '',
        status: TaskStatus.pending,
        createdAt: DateTime.now(),
      ));
      notifyListeners();
      return;
    }

    final row = await SupabaseService.createSubmission(
      taskId: templateId,
      childId: _childId!,
    );
    _submissions.add(TaskSubmission.fromJson(row));
    notifyListeners();
  }

  /// Child submits proof. If template has reached auto-approve threshold,
  /// the submission is approved immediately without waiting for parent.
  Future<void> submitTask(String templateId, {Uint8List? proofImageBytes}) async {
    final templateIdx = _tasks.indexWhere((t) => t.id == templateId);
    if (templateIdx == -1) return;
    final template = _tasks[templateIdx];

    // Accept pending OR rejected (child resubmitting after rejection)
    final subIdx = _submissions.indexWhere(
      (s) => s.taskId == templateId &&
          (s.status == TaskStatus.pending || s.status == TaskStatus.rejected),
    );
    if (subIdx == -1) return;
    final sub = _submissions[subIdx];

    // Upload proof image
    String? proofImageUrl;
    if (proofImageBytes != null) {
      _taskProofImages[templateId] = proofImageBytes;
      if (!isDemoMode) {
        proofImageUrl = await SupabaseService.uploadProofImage(
          taskId: sub.id,
          imageBytes: proofImageBytes,
        );
        proofImageUrl ??= 'data:image/jpeg;base64,${base64Encode(proofImageBytes)}';
      }
    }

    final willAutoApprove = template.canAutoApprove;

    if (willAutoApprove) {
      // Auto-approve: coin vào ngay, không cần parent
      final earnedCoins = template.coinReward;
      _submissions[subIdx] = sub.copyWith(
        status: TaskStatus.approved,
        submittedAt: DateTime.now(),
        reviewedAt: DateTime.now(),
        proofImageUrl: proofImageUrl,
        autoApproved: true,
        coinEarned: earnedCoins,
      );
      _tasks[templateIdx] = template.copyWith(
        approvalCount: template.approvalCount + 1,
      );
      notifyListeners();

      if (!isDemoMode) {
        await SupabaseService.updateSubmissionStatus(
          sub.id, 'approved',
          proofImageUrl: proofImageUrl,
          autoApproved: true,
          coinEarned: earnedCoins,
        );
        await SupabaseService.incrementApprovalCount(templateId);
      }
      _addCoins(earnedCoins);
      _addXp(15);
      _incrementStreak();
      _justApprovedTask = template;
    } else {
      // Normal flow: chờ parent duyệt
      _submissions[subIdx] = sub.copyWith(
        status: TaskStatus.submitted,
        submittedAt: DateTime.now(),
        proofImageUrl: proofImageUrl,
      );
      notifyListeners();

      if (!isDemoMode) {
        await SupabaseService.updateSubmissionStatus(
          sub.id, 'submitted', proofImageUrl: proofImageUrl,
        );
      }
      _addXp(10);
    }
    notifyListeners();
  }

  /// Parent approves a submission by template ID (uses submissionId from childViewTasks).
  Future<void> approveTask(String templateId, {int rating = 2, String? submissionId}) async {
    final templateIdx = _tasks.indexWhere((t) => t.id == templateId);
    if (templateIdx == -1) return;
    final template = _tasks[templateIdx];

    // Find the submitted submission
    final subId = submissionId ??
        _submissions
            .where((s) => s.taskId == templateId && s.status == TaskStatus.submitted)
            .fold<TaskSubmission?>(null, (latest, s) =>
                latest == null || s.createdAt.isAfter(latest.createdAt) ? s : latest)
            ?.id;
    if (subId == null) return;

    final subIdx = _submissions.indexWhere((s) => s.id == subId);
    if (subIdx == -1) return;

    final multiplier = rating == 1 ? 0.8 : (rating == 3 ? 1.2 : 1.0);
    final earnedCoins = (template.coinReward * multiplier).round();
    final newApprovalCount = template.approvalCount + 1;

    _submissions[subIdx] = _submissions[subIdx].copyWith(
      status: TaskStatus.approved,
      reviewedAt: DateTime.now(),
      qualityRating: rating,
      coinEarned: earnedCoins,
    );
    _tasks[templateIdx] = template.copyWith(approvalCount: newApprovalCount);
    notifyListeners();

    if (!isDemoMode) {
      await SupabaseService.updateSubmissionStatus(
        subId, 'approved', qualityRating: rating, coinEarned: earnedCoins,
      );
      await SupabaseService.incrementApprovalCount(templateId);
    }
    _addCoins(earnedCoins);
    _addXp(15);
    _incrementStreak();
    _justApprovedTask = template;
    _categoryTaskCounts[template.category] =
        (_categoryTaskCounts[template.category] ?? 0) + 1;
    NotificationService.showTaskApproved(
      taskTitle: template.title,
      coins: earnedCoins,
    );
    _checkCategoryBadge(template.category);

    // Add memory
    if (_familyId != null && _childId != null) {
      final proofUrl = _submissions[subIdx].proofImageUrl ?? '';
      if (!isDemoMode) {
        await SupabaseService.addMemory(
          familyId: _familyId!,
          childId: _childId!,
          taskTitle: template.title,
          emoji: template.icon,
          note: 'Hoàn thành xuất sắc!',
          proofImageUrl: proofUrl.isEmpty ? null : proofUrl,
        );
      }
      _memories.insert(0, {
        'date': _formatDate(DateTime.now().toIso8601String()),
        'task': template.title,
        'emoji': template.icon,
        'note': 'Hoàn thành xuất sắc!',
        'taskId': template.id,
        'category': template.category,
        'proofImageUrl': proofUrl,
        'mood': '',
      });
    }
    notifyListeners();
  }

  void toggleTemplate(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    _tasks[idx] = _tasks[idx].copyWith(isActive: !_tasks[idx].isActive);
    notifyListeners();
    if (!isDemoMode) {
      SupabaseService.deactivateTask(taskId);
    }
  }

  Future<void> deleteTemplate(String taskId) async {
    _tasks = _tasks.where((t) => t.id != taskId).toList();
    _submissions = _submissions.where((s) => s.taskId != taskId).toList();
    notifyListeners();
    if (!isDemoMode) {
      // Submissions reference the task via FK — delete them first, then the task.
      await SupabaseService.deleteSubmissionsForTask(taskId);
      await SupabaseService.deleteTask(taskId);
    }
  }

  void recordTaskMood(String taskId, String mood) {
    final idx = _memories.indexWhere((m) => m['taskId'] == taskId);
    if (idx != -1) {
      _memories[idx] = {..._memories[idx], 'mood': mood};
      notifyListeners();
    }
  }

  /// Child abandons their active submission. Template stays active for next attempt.
  Future<void> abandonTask(String templateId) async {
    final templateIdx = _tasks.indexWhere((t) => t.id == templateId);
    if (templateIdx == -1) return;
    final template = _tasks[templateIdx];

    // Find active submission (pending or submitted)
    final subIdx = _submissions.indexWhere(
      (s) => s.taskId == templateId &&
          (s.status == TaskStatus.pending || s.status == TaskStatus.submitted),
    );

    if (subIdx != -1) {
      final sub = _submissions[subIdx];
      _submissions[subIdx] = sub.copyWith(status: TaskStatus.rejected);
      notifyListeners();
      if (!isDemoMode) {
        await SupabaseService.updateSubmissionStatus(sub.id, 'rejected');
      }
    }

    if (template.hasPenalty) {
      final penalty = (template.coinReward * template.penaltyPercent / 100).round();
      _addCoins(-penalty);
    }
    notifyListeners();
  }

  /// Parent rejects a submission. Child sees the reason and can resubmit.
  Future<void> rejectTask(String templateId, {String? submissionId, String? reason}) async {
    final subId = submissionId ??
        _submissions
            .where((s) => s.taskId == templateId && s.status == TaskStatus.submitted)
            .fold<TaskSubmission?>(null, (latest, s) =>
                latest == null || s.createdAt.isAfter(latest.createdAt) ? s : latest)
            ?.id;
    if (subId == null) return;

    final subIdx = _submissions.indexWhere((s) => s.id == subId);
    if (subIdx == -1) return;

    _submissions[subIdx] = _submissions[subIdx].copyWith(
      status: TaskStatus.rejected,
      parentNote: reason?.isNotEmpty == true ? reason : null,
    );
    notifyListeners();
    if (!isDemoMode) {
      await SupabaseService.updateSubmissionStatus(subId, 'rejected', parentNote: reason);
    }
  }

  /// Parent retroactively rejects an auto-approved submission within 24h.
  /// Deducts the coins given and decreases approvalCount so child must earn it back.
  Future<void> retroactiveRejectTask(String templateId, {String? submissionId}) async {
    final subId = submissionId ??
        _submissions
            .where((s) => s.taskId == templateId &&
                s.status == TaskStatus.approved && s.autoApproved)
            .fold<TaskSubmission?>(null, (latest, s) =>
                latest == null || s.createdAt.isAfter(latest.createdAt) ? s : latest)
            ?.id;
    if (subId == null) return;

    final subIdx = _submissions.indexWhere((s) => s.id == subId);
    if (subIdx == -1) return;
    final sub = _submissions[subIdx];

    // Deduct coins that were auto-given
    final coinsToDeduct = sub.coinEarned ?? 0;
    if (coinsToDeduct > 0) _addCoins(-coinsToDeduct);

    // Decrease approvalCount so child must re-earn auto-approve trust
    final templateIdx = _tasks.indexWhere((t) => t.id == templateId);
    if (templateIdx != -1) {
      final t = _tasks[templateIdx];
      _tasks[templateIdx] = t.copyWith(
        approvalCount: (t.approvalCount - 1).clamp(0, 9999),
      );
    }

    // Reset submission to pending so child can redo properly
    _submissions[subIdx] = TaskSubmission(
      id: sub.id,
      taskId: sub.taskId,
      childId: sub.childId,
      status: TaskStatus.pending,
      autoApproved: false,
      createdAt: sub.createdAt,
    );
    notifyListeners();

    if (!isDemoMode) {
      await SupabaseService.updateSubmissionStatus(subId, 'pending');
      await SupabaseService.decrementApprovalCount(templateId);
    }
  }

  // ── Coin & Jar actions ─────────────────────────────────────────────────────

  void _addCoins(int amount) {
    _totalCoins += amount;
    final toSave = (amount * 0.4).round();
    final toShare = (amount * 0.2).round();
    final toSpend = amount - toSave - toShare;
    _spendJar += toSpend;
    _saveJar += toSave;
    _shareJar += toShare;
    _updateDreamProgress();
    _persistChildProfile();
  }

  void transferToJar(String jarName, int amount) {
    if (amount <= 0 || _spendJar < amount) return;
    _spendJar -= amount;
    switch (jarName) {
      case 'Tiết kiệm':
        _saveJar += amount;
        break;
      case 'Sẻ chia':
        _shareJar += amount;
        break;
      case 'Tiêu dùng':
        _spendJar += amount;
        break;
    }
    _persistChildProfile();
    notifyListeners();
  }

  // ── XP & Level actions ─────────────────────────────────────────────────────

  void _addXp(int amount) {
    _xp += amount;
    while (_xp >= _xpToNextLevel) {
      _xp -= _xpToNextLevel;
      _level++;
      _xpToNextLevel = (_xpToNextLevel * 1.2).round();

      String? newBadge;
      if (_level == 6) newBadge = '🚀 Level 6!';
      if (_level == 7) newBadge = '🌟 Level 7!';
      if (_level == 10) newBadge = '👑 Level 10!';
      if (newBadge != null) {
        _badges.add(newBadge);
        _pendingNewBadge = newBadge;
        if (_childId != null && !isDemoMode) {
          SupabaseService.addBadge(
            _childId!,
            'Level $_level!',
            newBadge.split(' ').first,
          );
        }
      }
    }
    _persistChildProfile();
  }

  // ── Dream Jar actions ──────────────────────────────────────────────────────

  Future<void> addDream(String name, int price, String icon) async {
    final progress = price > 0 ? _totalCoins / price : 0.0;
    _dreamItems.add({
      'id': 'demo-dream-${DateTime.now().millisecondsSinceEpoch}',
      'name': name,
      'price': price,
      'icon': icon,
      'progress': progress > 1.0 ? 1.0 : progress,
    });
    notifyListeners();
    if (_childId != null && !isDemoMode) {
      await SupabaseService.addDreamItem(
        childId: _childId!,
        name: name,
        price: price,
        icon: icon,
      );
    }
  }

  void _updateDreamProgress() {
    for (int i = 0; i < _dreamItems.length; i++) {
      final price = _dreamItems[i]['price'] as int;
      final progress = price > 0 ? _totalCoins / price : 0.0;
      _dreamItems[i]['progress'] = progress > 1.0 ? 1.0 : progress;
    }
  }

  Future<void> editDream(int index, String name, int price, String icon) async {
    if (index < 0 || index >= _dreamItems.length) return;
    final dream = _dreamItems[index];
    _dreamItems[index] = {...dream, 'name': name, 'price': price, 'icon': icon};
    _updateDreamProgress();
    notifyListeners();
    if (!isDemoMode) {
      await SupabaseService.editDreamItem(dream['id'] as String, name: name, price: price, icon: icon);
    }
  }

  Future<void> deleteDream(int index) async {
    if (index < 0 || index >= _dreamItems.length) return;
    final dream = _dreamItems[index];
    final dreamId = dream['id'] as String;
    _dreamPurchaseRequests.removeWhere((r) => r['id'] == dreamId);
    _approvedDreamIds.remove(dreamId);
    _dreamItems.removeAt(index);
    notifyListeners();
    if (!isDemoMode) {
      await SupabaseService.deleteDreamItem(dreamId);
    }
  }

  // ── Profile actions ────────────────────────────────────────────────────────

  Future<void> updateParentName(String name) async {
    _parentName = name;
    notifyListeners();
    if (!isDemoMode) {
      await SupabaseService.updateProfile(fullName: name);
    }
  }

  Future<void> updateChildName(String name) async {
    _childName = name;
    notifyListeners();
    if (_childId != null && !isDemoMode) {
      await SupabaseService.updateChild(_childId!, {'name': name});
    }
  }

  Future<void> updateChildEmoji(String emoji) async {
    _childAvatarEmoji = emoji;
    notifyListeners();
    if (_childId != null && !isDemoMode) {
      await SupabaseService.updateChild(_childId!, {'avatar_emoji': emoji});
    }
  }

  Future<void> updateChildAge(int age) async {
    _childAge = age;
    notifyListeners();
    if (_childId != null && !isDemoMode) {
      await SupabaseService.updateChild(_childId!, {'age': age});
    }
  }

  Future<void> addBondingMessage(String message) async {
    _bondingMessage = message;
    notifyListeners();
    if (!isDemoMode) {
      await SupabaseService.updateSettings({'bonding_message': message});
    }
  }

  Future<void> updateNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    if (!isDemoMode) {
      await SupabaseService.updateSettings({'notifications_enabled': enabled});
    }
  }

  Future<void> setLocale(String locale) async {
    _locale = locale;
    notifyListeners();
    if (!isDemoMode) {
      await SupabaseService.updateSettings({'locale': locale});
    }
  }

  // ── Dream Jar mark purchased ───────────────────────────────────────────────

  Future<void> markDreamPurchased(int index) async {
    if (index < 0 || index >= _dreamItems.length) return;
    final item = _dreamItems[index];
    final price = item['price'] as int;
    if (_totalCoins < price) return;

    _totalCoins -= price;
    // Deduct proportionally from jars
    final fromSave = (price * 0.4).round().clamp(0, _saveJar);
    final fromShare = (price * 0.2).round().clamp(0, _shareJar);
    final fromSpend = (price - fromSave - fromShare).clamp(0, _spendJar);
    _saveJar -= fromSave;
    _shareJar -= fromShare;
    _spendJar -= fromSpend;

    _dreamItems[index] = {...item, 'is_purchased': true, 'progress': 1.0};
    _updateDreamProgress();

    final dreamId = item['id'] as String?;
    if (dreamId != null && !isDemoMode) {
      await SupabaseService.markDreamPurchased(dreamId);
    }
    _persistChildProfile();
    notifyListeners();
  }

  // ── Dream Purchase Request (child xin → parent duyệt) ────────────────────

  void requestDreamPurchase(int index) {
    if (index < 0 || index >= _dreamItems.length) return;
    final item = _dreamItems[index];
    if (item['is_purchased'] as bool? ?? false) return;
    if ((_totalCoins) < (item['price'] as int)) return;
    final id = item['id'] as String? ?? 'dream-$index';
    if (_dreamPurchaseRequests.any((r) => r['id'] == id)) return;
    _dreamPurchaseRequests.add({
      'id': id,
      'dreamIndex': index,
      'name': item['name'],
      'price': item['price'],
      'icon': item['icon'],
    });
    notifyListeners();
  }

  void approveDreamPurchase(String dreamId) {
    _dreamPurchaseRequests.removeWhere((r) => r['id'] == dreamId);
    _approvedDreamIds.add(dreamId);
    notifyListeners();
  }

  void rejectDreamPurchase(String dreamId) {
    _dreamPurchaseRequests.removeWhere((r) => r['id'] == dreamId);
    _approvedDreamIds.remove(dreamId);
    notifyListeners();
  }

  Future<void> confirmDreamPurchase(int index, {Uint8List? proofBytes}) async {
    if (index < 0 || index >= _dreamItems.length) return;
    final item = _dreamItems[index];
    final dreamId = item['id'] as String? ?? 'dream-$index';
    final name = item['name'] as String? ?? '';
    final icon = item['icon'] as String? ?? '⭐';
    final price = item['price'] as int? ?? 0;

    _approvedDreamIds.remove(dreamId);

    // Deduct coins (ignore coin check since parent already approved)
    _totalCoins = (_totalCoins - price).clamp(0, _totalCoins);
    final fromSave = (price * 0.4).round().clamp(0, _saveJar);
    final fromShare = (price * 0.2).round().clamp(0, _shareJar);
    final fromSpend = (price - fromSave - fromShare).clamp(0, _spendJar);
    _saveJar -= fromSave;
    _shareJar -= fromShare;
    _spendJar -= fromSpend;
    _dreamItems[index] = {...item, 'is_purchased': true, 'progress': 1.0};
    _updateDreamProgress();

    // Handle proof image
    String? proofUrl;
    if (proofBytes != null) {
      _taskProofImages[dreamId] = proofBytes;
      if (!isDemoMode) {
        proofUrl = await SupabaseService.uploadProofImage(taskId: dreamId, imageBytes: proofBytes);
        proofUrl ??= 'data:image/jpeg;base64,${base64Encode(proofBytes)}';
      }
    }

    // Save to memories
    if (_familyId != null && _childId != null) {
      if (!isDemoMode) {
        await SupabaseService.addMemory(
          familyId: _familyId!,
          childId: _childId!,
          taskTitle: 'Mua $name',
          emoji: icon,
          note: 'Con đã thực hiện được ước mơ: $name! 🎉',
          proofImageUrl: proofUrl?.isNotEmpty == true ? proofUrl : null,
        );
        await SupabaseService.markDreamPurchased(dreamId);
      }
      _memories.insert(0, {
        'date': _formatDate(DateTime.now().toIso8601String()),
        'task': 'Mua $name',
        'emoji': icon,
        'note': 'Con đã thực hiện được ước mơ: $name! 🎉',
        'taskId': dreamId,
        'category': 'Ước mơ',
        'proofImageUrl': proofUrl ?? '',
        'mood': 'happy',
      });
    }

    _persistChildProfile();
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _incrementStreak() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (_lastStreakDate == null) {
      _streakDays = 1;
    } else {
      final lastDate = DateTime(
        _lastStreakDate!.year,
        _lastStreakDate!.month,
        _lastStreakDate!.day,
      );
      final diff = todayDate.difference(lastDate).inDays;
      if (diff == 0) return; // already counted today
      if (diff == 1) {
        _streakDays++;
      } else {
        _streakDays = 1; // streak broken
      }
    }
    _lastStreakDate = today;

    // Check milestone badges (3, 7, 14, 30 days)
    const milestones = {
      3: '🔥 Chuỗi 3 ngày',
      7: '⚡ Chuỗi 7 ngày',
      14: '💫 Chuỗi 14 ngày',
      30: '🏆 Chuỗi 30 ngày',
    };
    final badge = milestones[_streakDays];
    if (badge != null && !_badges.contains(badge)) {
      _badges.add(badge);
      _pendingStreakBadge = badge;
      _pendingNewBadge = badge;
      if (!isDemoMode && _childId != null) {
        final parts = badge.split(' ');
        SupabaseService.addBadge(
          _childId!,
          parts.sublist(1).join(' '),
          parts.first,
        );
      }
    }
  }

  void consumeStreakBadge() {
    _pendingStreakBadge = null;
    notifyListeners();
  }

  void consumeNewBadge() {
    _pendingNewBadge = null;
    notifyListeners();
  }

  void setCustomBadgeEmoji(String achievementId, String emoji) {
    _customBadgeEmoji[achievementId] = emoji;
    notifyListeners();
  }

  String getEmojiForBadge(String achievementId, String defaultEmoji) =>
      _customBadgeEmoji[achievementId] ?? defaultEmoji;

  Future<void> _saveCompletedLessons() async {
    final encoded = jsonEncode(_completedLessonIds.toList());
    await _storage.write(key: _completedLessonsKey, value: encoded);
  }

  Future<void> _loadCompletedLessons() async {
    final raw = await _storage.read(key: _completedLessonsKey);
    if (raw != null) {
      final list = jsonDecode(raw) as List<dynamic>;
      _completedLessonIds = list.cast<String>().toSet();
    }
  }

  void markLessonCompleted(String lessonId) {
    if (_completedLessonIds.contains(lessonId)) return;
    _completedLessonIds.add(lessonId);
    _addXp(10);
    _saveCompletedLessons();
    notifyListeners();
  }

  void consumeJustApprovedTask() {
    _justApprovedTask = null;
    notifyListeners();
  }

  static const _categoryBadgeThresholds = {
    'Học tập':  {5: '📚 Mọt sách', 15: '🎓 Học giỏi'},
    'Sức khỏe': {5: '💪 Năng động', 15: '🏅 Sức khỏe vàng'},
    'Việc nhà': {5: '🧹 Siêng năng', 15: '🏠 Người giữ nhà'},
    'Sáng tạo': {5: '🎨 Tài năng',  15: '✨ Nghệ sĩ'},
  };

  void _recomputeCategoryTaskCounts() {
    _categoryTaskCounts = {};
    for (final sub in _submissions) {
      if (sub.status == TaskStatus.approved) {
        final template = _tasks.firstWhere(
          (t) => t.id == sub.taskId,
          orElse: () => TaskModel(id: '', title: '', description: '', coinReward: 0, icon: ''),
        );
        if (template.id.isEmpty) continue;
        _categoryTaskCounts[template.category] =
            (_categoryTaskCounts[template.category] ?? 0) + 1;
      }
    }
  }

  void _checkCategoryBadge(String category) {
    final count = _categoryTaskCounts[category] ?? 0;
    final thresholds = _categoryBadgeThresholds[category];
    if (thresholds == null) return;
    final badge = thresholds[count];
    if (badge != null && !_badges.contains(badge)) {
      _badges.add(badge);
      _pendingNewBadge = badge;
      if (!isDemoMode && _childId != null) {
        final parts = badge.split(' ');
        SupabaseService.addBadge(
          _childId!,
          parts.sublist(1).join(' '),
          parts.first,
        );
      }
    }
  }

  void _persistChildProfile() {
    if (_childId == null || isDemoMode) return;
    SupabaseService.updateChild(_childId!, {
      'level': _level,
      'total_coins': _totalCoins,
      'spend_jar': _spendJar,
      'save_jar': _saveJar,
      'share_jar': _shareJar,
      'xp': _xp,
      'xp_to_next_level': _xpToNextLevel,
      'streak_days': _streakDays,
      'last_streak_date': _lastStreakDate?.toIso8601String(),
    });
  }

  void _seedDemoData() {
    _isLoggedIn = true;
    _hasSeenOnboarding = true;
    _parentName = 'Nguyễn Văn Hùng';
    _parentEmail = 'hung.nguyen@gmail.com';
    _familyId = 'demo-family';
    _childId = 'demo-child';
    _childName = 'Minh';
    _childAvatarEmoji = '🦊';
    _childAge = 9;
    _level = 5;
    _totalCoins = 850;
    _spendJar = 425;
    _saveJar = 255;
    _shareJar = 170;
    _xp = 78;
    _xpToNextLevel = 100;
    _streakDays = 7;
    _lastStreakDate = DateTime.now().subtract(const Duration(days: 2));
    _badges = [
      '🏅 Khởi đầu',
      '🔥 3 ngày liên tiếp',
      '🌟 Level 5!',
      '📚 Mọt sách',
      '🏆 Hoàn thành 20 việc',
      '💪 Sức khỏe tốt',
    ];
    _bondingMessage = 'Minh ơi, hôm nay con làm rất tốt! Bố rất tự hào về con 💛';
    _notificationsEnabled = true;

    final now = DateTime.now();

    // Templates (parent creates once, reusable)
    _tasks = [
      TaskModel(
        id: 'demo-1', isTemplate: true, isActive: true,
        title: 'Rửa bát sau bữa tối',
        description: 'Rửa sạch chén đĩa sau bữa tối và cất gọn vào tủ.',
        category: 'Việc nhà', icon: '🍽️', coinReward: 20,
        approvalCount: 7, autoApproveAfter: 10,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      TaskModel(
        id: 'demo-2', isTemplate: true, isActive: true,
        title: 'Đọc sách 30 phút',
        description: 'Đọc một chương sách yêu thích và kể lại cho bố mẹ.',
        category: 'Học tập', icon: '📚', coinReward: 25,
        dueDate: now.add(const Duration(hours: 2)),
        hasPenalty: true, penaltyPercent: 10,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      TaskModel(
        id: 'demo-3', isTemplate: true, isActive: true,
        title: 'Tưới cây ban công',
        description: 'Tưới đều các chậu cây trên ban công.',
        category: 'Việc nhà', icon: '🌱', coinReward: 15,
        dueDate: now.add(const Duration(minutes: 25)),
        hasPenalty: true, penaltyPercent: 10,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      TaskModel(
        id: 'demo-4', isTemplate: true, isActive: true,
        title: 'Tập thể dục buổi sáng',
        description: 'Tập 15 phút bài thể dục buổi sáng.',
        category: 'Sức khỏe', icon: '🏃', coinReward: 20,
        approvalCount: 4,
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      TaskModel(
        id: 'demo-5', isTemplate: true, isActive: true,
        title: 'Gấp quần áo',
        description: 'Gấp gọn quần áo đã giặt và cất vào tủ.',
        category: 'Việc nhà', icon: '👕', coinReward: 15,
        approvalCount: 3,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      TaskModel(
        id: 'demo-6', isTemplate: true, isActive: true,
        title: 'Học bài ôn tập Toán',
        description: 'Ôn lại bài Toán chương 3 trước khi thi.',
        category: 'Học tập', icon: '✏️', coinReward: 30,
        approvalCount: 2,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    // Submissions — each represents one attempt by the child
    _submissions = [
      // demo-1: child submitted proof, awaiting parent approval
      TaskSubmission(
        id: 'sub-1', taskId: 'demo-1', childId: 'demo-child',
        status: TaskStatus.submitted,
        submittedAt: now.subtract(const Duration(hours: 1)),
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      // demo-2: child started but hasn't submitted yet
      TaskSubmission(
        id: 'sub-2', taskId: 'demo-2', childId: 'demo-child',
        status: TaskStatus.pending,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      // demo-4: already approved (past session)
      TaskSubmission(
        id: 'sub-4', taskId: 'demo-4', childId: 'demo-child',
        status: TaskStatus.approved,
        submittedAt: now.subtract(const Duration(hours: 9)),
        reviewedAt: now.subtract(const Duration(hours: 8)),
        coinEarned: 20,
        createdAt: now.subtract(const Duration(hours: 10)),
      ),
      // demo-5: approved
      TaskSubmission(
        id: 'sub-5', taskId: 'demo-5', childId: 'demo-child',
        status: TaskStatus.approved,
        submittedAt: now.subtract(const Duration(hours: 23)),
        reviewedAt: now.subtract(const Duration(hours: 22)),
        coinEarned: 15,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      // demo-6: approved
      TaskSubmission(
        id: 'sub-6', taskId: 'demo-6', childId: 'demo-child',
        status: TaskStatus.approved,
        submittedAt: now.subtract(const Duration(days: 1, hours: 21)),
        reviewedAt: now.subtract(const Duration(days: 1, hours: 20)),
        coinEarned: 30,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    _dreamItems = [
      {
        'id': 'dream-1',
        'name': 'Lego Technic',
        'price': 1000,
        'icon': '🧱',
        'progress': (850 / 1000).clamp(0.0, 1.0),
        'is_purchased': false,
      },
      {
        'id': 'dream-2',
        'name': 'Bộ truyện Doraemon',
        'price': 350,
        'icon': '📖',
        'progress': 1.0,
        'is_purchased': true,
      },
      {
        'id': 'dream-3',
        'name': 'Xe đạp mini',
        'price': 1500,
        'icon': '🚲',
        'progress': (850 / 1500).clamp(0.0, 1.0),
        'is_purchased': false,
      },
      {
        'id': 'dream-4',
        'name': 'Bộ màu vẽ chuyên nghiệp',
        'price': 400,
        'icon': '🎨',
        'progress': 1.0,
        'is_purchased': true,
      },
    ];

    _memories = [
      {
        'date': _formatDate(now.subtract(const Duration(hours: 8)).toIso8601String()),
        'task': 'Tập thể dục buổi sáng',
        'emoji': '🏃',
        'note': 'Con tập rất chăm chỉ, bố rất tự hào!',
        'taskId': 'demo-4',
        'category': 'Sức khỏe',
        'proofImageUrl': '',
      },
      {
        'date': _formatDate(now.subtract(const Duration(hours: 22)).toIso8601String()),
        'task': 'Gấp quần áo',
        'emoji': '👕',
        'note': 'Con gấp rất gọn gàng và cẩn thận!',
        'taskId': 'demo-5',
        'category': 'Việc nhà',
        'proofImageUrl': '',
      },
      {
        'date': _formatDate(now.subtract(const Duration(days: 1, hours: 20)).toIso8601String()),
        'task': 'Học bài ôn tập Toán',
        'emoji': '✏️',
        'note': 'Con học bài rất nghiêm túc, chúc con thi tốt!',
        'taskId': 'demo-6',
        'category': 'Học tập',
        'proofImageUrl': '',
      },
      {
        'date': _formatDate(now.subtract(const Duration(days: 2, hours: 16)).toIso8601String()),
        'task': 'Vẽ tranh tặng bà',
        'emoji': '🎨',
        'note': 'Bức tranh rất đẹp, bà rất vui khi nhận được!',
        'taskId': 'demo-7',
        'category': 'Sáng tạo',
        'proofImageUrl': '',
      },
      {
        'date': _formatDate(now.subtract(const Duration(days: 3, hours: 18)).toIso8601String()),
        'task': 'Quét nhà và lau sàn',
        'emoji': '🧹',
        'note': 'Nhà sạch bóng, con thật siêng năng!',
        'taskId': 'demo-8',
        'category': 'Việc nhà',
        'proofImageUrl': '',
      },
    ];

    _recomputeCategoryTaskCounts();
    _completedLessonIds = {'cl-1'};
    _lessons = [...demoChildLessons, ...demoParentLessons];
    notifyListeners();
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
