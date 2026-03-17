import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/supabase_service.dart';

class AppState extends ChangeNotifier {
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

  // Dream items
  List<Map<String, dynamic>> _dreamItems = [];

  // Memory lane
  List<Map<String, String>> _memories = [];

  // Bonding message (parent → child)
  String _bondingMessage = '';

  // Notifications preference
  bool _notificationsEnabled = true;

  // ── Initialize ─────────────────────────────────────────────────────────────

  Future<void> initialize() async {
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

    // Load memories
    final memoryRows = await SupabaseService.getMemories(familyId: _familyId!);
    _memories = memoryRows
        .map(
          (row) => <String, String>{
            'date': _formatDate(row['created_at'] as String? ?? ''),
            'task': row['task_title'] as String? ?? '',
            'emoji': row['emoji'] as String? ?? '⭐',
            'note': row['note'] as String? ?? '',
          },
        )
        .toList();

    notifyListeners();
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
  List<String> get badges => List.unmodifiable(_badges);
  bool get hasChild => _childId != null;
  List<Map<String, dynamic>> get dreamItemsList =>
      List.unmodifiable(_dreamItems);
  List<Map<String, String>> get memories => List.unmodifiable(_memories);
  String get bondingMessage => _bondingMessage;
  bool get notificationsEnabled => _notificationsEnabled;

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

  Future<void> submitTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(status: TaskStatus.submitted);
    notifyListeners();
    await SupabaseService.updateTaskStatus(taskId, 'submitted');
    _addXp(10);
  }

  Future<void> approveTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;

    final task = _tasks[index];
    _tasks[index] = task.copyWith(status: TaskStatus.approved);
    notifyListeners();

    await SupabaseService.updateTaskStatus(taskId, 'approved');
    _addCoins(task.coinReward);
    _addXp(15);

    // Add memory
    if (_familyId != null && _childId != null) {
      await SupabaseService.addMemory(
        familyId: _familyId!,
        childId: _childId!,
        taskTitle: task.title,
        emoji: task.icon,
        note: 'Hoàn thành xuất sắc!',
      );
      _memories.insert(0, {
        'date': _formatDate(DateTime.now().toIso8601String()),
        'task': task.title,
        'emoji': task.icon,
        'note': 'Hoàn thành xuất sắc!',
      });
    }
    notifyListeners();
  }

  Future<void> rejectTask(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index == -1) return;
    _tasks[index] = _tasks[index].copyWith(status: TaskStatus.rejected);
    notifyListeners();
    await SupabaseService.updateTaskStatus(taskId, 'rejected');
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
        if (_childId != null) {
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
      'name': name,
      'price': price,
      'icon': icon,
      'progress': progress > 1.0 ? 1.0 : progress,
    });
    notifyListeners();
    if (_childId != null) {
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
    await SupabaseService.updateProfile(fullName: name);
    notifyListeners();
  }

  Future<void> updateChildName(String name) async {
    _childName = name;
    if (_childId != null) {
      await SupabaseService.updateChild(_childId!, {'name': name});
    }
    notifyListeners();
  }

  Future<void> updateChildEmoji(String emoji) async {
    _childAvatarEmoji = emoji;
    if (_childId != null) {
      await SupabaseService.updateChild(_childId!, {'avatar_emoji': emoji});
    }
    notifyListeners();
  }

  Future<void> updateChildAge(int age) async {
    _childAge = age;
    if (_childId != null) {
      await SupabaseService.updateChild(_childId!, {'age': age});
    }
    notifyListeners();
  }

  Future<void> addBondingMessage(String message) async {
    _bondingMessage = message;
    notifyListeners();
    await SupabaseService.updateSettings({'bonding_message': message});
  }

  Future<void> updateNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    await SupabaseService.updateSettings({'notifications_enabled': enabled});
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
    if (dreamId != null) {
      await SupabaseService.markDreamPurchased(dreamId);
    }
    _persistChildProfile();
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _persistChildProfile() {
    if (_childId == null) return;
    SupabaseService.updateChild(_childId!, {
      'level': _level,
      'total_coins': _totalCoins,
      'spend_jar': _spendJar,
      'save_jar': _saveJar,
      'share_jar': _shareJar,
      'xp': _xp,
      'xp_to_next_level': _xpToNextLevel,
    });
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return '';
    final dt = DateTime.tryParse(isoDate);
    if (dt == null) return isoDate;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}
