import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../l10n/app_strings.dart';
import '../models/task_model.dart';
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

  // Task list
  List<TaskModel> _tasks = [];

  // Child profile
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
  Map<String, String> _customBadgeEmoji = {}; // achievementId → custom emoji

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

    // Load first child
    final children = await SupabaseService.getChildren(_familyId!);
    if (children.isNotEmpty) {
      final child = children.first;
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

      // Load badges
      final badgeRows = await SupabaseService.getBadges(_childId!);
      _badges = badgeRows.map((b) => '${b['emoji']} ${b['title']}').toList();

      // Load dream items
      final dreams = await SupabaseService.getDreamItems(_childId!);
      _dreamItems = dreams.map((item) {
        final price = item['price'] as int;
        final progress = price > 0 ? _totalCoins / price : 0.0;
        return {...item, 'progress': progress > 1.0 ? 1.0 : progress};
      }).toList();
    }

    // Load tasks
    final taskRows = await SupabaseService.getTasks(familyId: _familyId!);
    _tasks = taskRows.map((row) => TaskModel.fromJson(row)).toList();
    _recomputeCategoryTaskCounts();

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

  List<TaskModel> get templateTasks =>
      _tasks.where((t) => t.isTemplate).toList();
  List<TaskModel> get pendingTasks =>
      _tasks.where((t) => t.status == TaskStatus.pending).toList();
  List<TaskModel> get submittedTasks =>
      _tasks.where((t) => t.status == TaskStatus.submitted).toList();
  List<TaskModel> get approvedTasks =>
      _tasks.where((t) => t.status == TaskStatus.approved).toList();
  int get totalCoinsRewarded => _tasks
      .where((t) => t.status == TaskStatus.approved)
      .fold(0, (sum, t) => sum + t.coinReward);

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

  // ── Task actions ───────────────────────────────────────────────────────────

  Future<void> addTask(TaskModel task) async {
    if (_familyId == null || _childId == null) return;
    if (isDemoMode) {
      _tasks.insert(
        0,
        TaskModel(
          id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
          title: task.title,
          description: task.description,
          category: task.category,
          icon: task.icon,
          coinReward: task.coinReward,
          createdAt: DateTime.now(),
        ),
      );
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
    );
    _tasks.insert(0, TaskModel.fromJson(row));
    notifyListeners();
  }

  Future<void> submitTask(String taskId, {Uint8List? proofImageBytes}) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    String? proofImageUrl;
    if (proofImageBytes != null) {
      // Always keep bytes in memory for instant display this session
      _taskProofImages[taskId] = proofImageBytes;

      if (!isDemoMode) {
        // Try Supabase Storage first
        proofImageUrl = await SupabaseService.uploadProofImage(
          taskId: taskId,
          imageBytes: proofImageBytes,
        );
        // If Storage fails, fall back to base64 stored in DB
        if (proofImageUrl == null) {
          debugPrint('[AppState] Storage upload failed, falling back to base64');
          proofImageUrl = 'data:image/jpeg;base64,${base64Encode(proofImageBytes)}';
        }
      }
    }

    _tasks[index] = _tasks[index].copyWith(
      status: TaskStatus.submitted,
      submittedAt: DateTime.now(),
      proofImageUrl: proofImageUrl,
    );
    notifyListeners();
    if (!isDemoMode) {
      await SupabaseService.updateTaskStatus(
        taskId,
        'submitted',
        proofImageUrl: proofImageUrl,
      );
    }
    _addXp(10);
  }

  Future<void> approveTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = _tasks[index];
    _tasks[index] = task.copyWith(
      status: TaskStatus.approved,
      reviewedAt: DateTime.now(),
    );
    notifyListeners();

    if (!isDemoMode) {
      await SupabaseService.updateTaskStatus(taskId, 'approved');
    }
    _addCoins(task.coinReward);
    _addXp(15);
    _incrementStreak();
    _justApprovedTask = task;
    _categoryTaskCounts[task.category] =
        (_categoryTaskCounts[task.category] ?? 0) + 1;
    NotificationService.showTaskApproved(
      taskTitle: task.title,
      coins: task.coinReward,
    );
    _checkCategoryBadge(task.category);

    // Add memory
    if (_familyId != null && _childId != null) {
      final proofUrl = task.proofImageUrl ?? '';
      if (!isDemoMode) {
        await SupabaseService.addMemory(
          familyId: _familyId!,
          childId: _childId!,
          taskTitle: task.title,
          emoji: task.icon,
          note: 'Hoàn thành xuất sắc!',
          proofImageUrl: proofUrl.isEmpty ? null : proofUrl,
        );
      }
      _memories.insert(0, {
        'date': _formatDate(DateTime.now().toIso8601String()),
        'task': task.title,
        'emoji': task.icon,
        'note': 'Hoàn thành xuất sắc!',
        'taskId': task.id,
        'category': task.category,
        'proofImageUrl': proofUrl,
        'mood': '',
      });
    }
    notifyListeners();
  }

  void toggleTemplate(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx == -1) return;
    _tasks[idx] = _tasks[idx].copyWith(isTemplate: !_tasks[idx].isTemplate);
    notifyListeners();
  }

  void recordTaskMood(String taskId, String mood) {
    final idx = _memories.indexWhere((m) => m['taskId'] == taskId);
    if (idx != -1) {
      _memories[idx] = {..._memories[idx], 'mood': mood};
      notifyListeners();
    }
  }

  Future<void> rejectTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(status: TaskStatus.rejected);
    notifyListeners();
    if (!isDemoMode) {
      await SupabaseService.updateTaskStatus(taskId, 'rejected');
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
    for (final t in _tasks) {
      if (t.status == TaskStatus.approved) {
        _categoryTaskCounts[t.category] =
            (_categoryTaskCounts[t.category] ?? 0) + 1;
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
    _tasks = [
      TaskModel(
        id: 'demo-1',
        title: 'Rửa bát sau bữa tối',
        description: 'Rửa sạch chén đĩa sau bữa tối và cất gọn vào tủ.',
        category: 'Việc nhà',
        icon: '🍽️',
        coinReward: 20,
        status: TaskStatus.submitted,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      TaskModel(
        id: 'demo-2',
        title: 'Đọc sách 30 phút',
        description: 'Đọc một chương sách yêu thích và kể lại cho bố mẹ.',
        category: 'Học tập',
        icon: '📚',
        coinReward: 25,
        status: TaskStatus.pending,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      TaskModel(
        id: 'demo-3',
        title: 'Tưới cây ban công',
        description: 'Tưới đều các chậu cây trên ban công.',
        category: 'Việc nhà',
        icon: '🌱',
        coinReward: 15,
        status: TaskStatus.pending,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      TaskModel(
        id: 'demo-4',
        title: 'Tập thể dục buổi sáng',
        description: 'Tập 15 phút bài thể dục buổi sáng.',
        category: 'Sức khỏe',
        icon: '🏃',
        coinReward: 20,
        status: TaskStatus.approved,
        createdAt: now.subtract(const Duration(hours: 10)),
        reviewedAt: now.subtract(const Duration(hours: 8)),
      ),
      TaskModel(
        id: 'demo-5',
        title: 'Gấp quần áo',
        description: 'Gấp gọn quần áo đã giặt và cất vào tủ.',
        category: 'Việc nhà',
        icon: '👕',
        coinReward: 15,
        status: TaskStatus.approved,
        createdAt: now.subtract(const Duration(days: 1)),
        reviewedAt: now.subtract(const Duration(hours: 22)),
      ),
      TaskModel(
        id: 'demo-6',
        title: 'Học bài ôn tập Toán',
        description: 'Ôn lại bài Toán chương 3 trước khi thi.',
        category: 'Học tập',
        icon: '✏️',
        coinReward: 30,
        status: TaskStatus.approved,
        createdAt: now.subtract(const Duration(days: 2)),
        reviewedAt: now.subtract(const Duration(days: 1, hours: 20)),
      ),
      TaskModel(
        id: 'demo-7',
        title: 'Vẽ tranh tặng bà',
        description: 'Vẽ một bức tranh đẹp tặng bà nhân dịp sinh nhật.',
        category: 'Sáng tạo',
        icon: '🎨',
        coinReward: 25,
        status: TaskStatus.approved,
        createdAt: now.subtract(const Duration(days: 3)),
        reviewedAt: now.subtract(const Duration(days: 2, hours: 16)),
      ),
      TaskModel(
        id: 'demo-8',
        title: 'Quét nhà và lau sàn',
        description: 'Quét sạch toàn bộ nhà và lau sàn phòng khách.',
        category: 'Việc nhà',
        icon: '🧹',
        coinReward: 20,
        status: TaskStatus.approved,
        createdAt: now.subtract(const Duration(days: 4)),
        reviewedAt: now.subtract(const Duration(days: 3, hours: 18)),
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
