import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static String? get userId => auth.currentUser?.id;

  // ── Parent PIN (bảo vệ chế độ Cha mẹ) ───────────────────────────────────────
  // Hash khớp với web: sha256("<userId>:<pin>") dạng hex, lưu profiles.parent_pin_hash

  static String _hashPin(String uid, String pin) =>
      sha256.convert(utf8.encode('$uid:$pin')).toString();

  /// Đã đặt PIN chưa?
  static Future<bool> hasParentPin() async {
    final uid = userId;
    if (uid == null) return false;
    final data = await client
        .from('profiles')
        .select('parent_pin_hash')
        .eq('id', uid)
        .maybeSingle();
    final hash = data?['parent_pin_hash'] as String?;
    return hash != null && hash.isNotEmpty;
  }

  /// Đặt / đổi PIN 4 số.
  static Future<void> setParentPin(String pin) async {
    final uid = userId;
    if (uid == null) return;
    await client
        .from('profiles')
        .update({'parent_pin_hash': _hashPin(uid, pin)})
        .eq('id', uid);
  }

  /// Kiểm tra PIN đúng không.
  static Future<bool> verifyParentPin(String pin) async {
    final uid = userId;
    if (uid == null) return false;
    final data = await client
        .from('profiles')
        .select('parent_pin_hash')
        .eq('id', uid)
        .maybeSingle();
    final hash = data?['parent_pin_hash'] as String?;
    return hash != null && hash == _hashPin(uid, pin);
  }

  // ── Child PIN (bảo vệ từng hồ sơ con) ───────────────────────────────────────
  // Hash: sha256("<childId>:<pin>"), lưu children.child_pin_hash

  static Future<void> setChildPin(String childId, String pin) async {
    await client
        .from('children')
        .update({'child_pin_hash': _hashPin(childId, pin)})
        .eq('id', childId);
  }

  static Future<void> clearChildPin(String childId) async {
    await client
        .from('children')
        .update({'child_pin_hash': null})
        .eq('id', childId);
  }

  /// Verify locally — no DB call needed (hash đã load từ danh sách con).
  static bool verifyChildPinLocal(String childId, String pin, String storedHash) =>
      _hashPin(childId, pin) == storedHash;

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'parent',
  }) {
    return auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': role},
    );
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return auth.signInWithPassword(email: email, password: password);
  }

  /// Opens browser/webview for Google OAuth.
  /// Requires Supabase dashboard: Authentication → Providers → Google enabled.
  /// And redirect URL: io.supabase.growwise://login-callback
  static Future<bool> signInWithGoogle() async {
    return auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.growwise://login-callback',
    );
  }

  static Future<void> signOut() => auth.signOut();

  static Future<void> resetPassword(String email) {
    final redirectTo = kIsWeb
        ? Uri.base.origin
        : 'io.supabase.growwise://login-callback';
    return auth.resetPasswordForEmail(email, redirectTo: redirectTo);
  }

  // ── Profile ───────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getProfile() async {
    final uid = userId;
    if (uid == null) return null;
    final data = await client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    return data;
  }

  static Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final uid = userId;
    if (uid == null) return;
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (fullName != null) updates['full_name'] = fullName;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    await client.from('profiles').update(updates).eq('id', uid);
  }

  // ── Family ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getFamily() async {
    final uid = userId;
    if (uid == null) return null;
    final data = await client
        .from('families')
        .select()
        .eq('parent_id', uid)
        .maybeSingle();
    return data;
  }

  static Future<String?> getFamilyId() async {
    final family = await getFamily();
    return family?['id'] as String?;
  }

  // ── Children ──────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getChildren(String familyId) async {
    final data = await client
        .from('children')
        .select()
        .eq('family_id', familyId)
        .order('created_at');
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<Map<String, dynamic>?> getChild(String childId) async {
    final data = await client
        .from('children')
        .select()
        .eq('id', childId)
        .maybeSingle();
    return data;
  }

  static Future<Map<String, dynamic>> createChild({
    required String familyId,
    required String name,
    required int age,
    String avatarEmoji = '👦',
  }) async {
    final data = await client
        .from('children')
        .insert({
          'family_id': familyId,
          'name': name,
          'age': age,
          'avatar_emoji': avatarEmoji,
        })
        .select()
        .single();
    return data;
  }

  static Future<void> updateChild(
    String childId,
    Map<String, dynamic> updates,
  ) async {
    updates['updated_at'] = DateTime.now().toIso8601String();
    await client.from('children').update(updates).eq('id', childId);
  }

  // ── Tasks ─────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getTasks({
    required String familyId,
    String? childId,
    String? status,
  }) async {
    var query = client.from('tasks').select().eq('family_id', familyId);
    if (childId != null) query = query.eq('child_id', childId);
    if (status != null) query = query.eq('status', status);
    final data = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Creates a task template (parent creates once, child submits multiple times).
  static Future<Map<String, dynamic>> createTask({
    required String familyId,
    required String childId,
    required String title,
    required String description,
    required String category,
    required String icon,
    required int coinReward,
    DateTime? dueDate,
    bool hasPenalty = false,
    int penaltyPercent = 10,
    int? autoApproveAfter,
  }) async {
    final uid = userId;
    if (uid == null) throw Exception('Not authenticated');
    final data = await client
        .from('tasks')
        .insert({
          'family_id': familyId,
          'child_id': childId,
          'created_by': uid,
          'title': title,
          'description': description,
          'category': category,
          'icon': icon,
          'coin_reward': coinReward,
          'is_template': true,
          'is_active': true,
          'approval_count': 0,
          if (dueDate != null) 'due_date': dueDate.toIso8601String(),
          'has_penalty': hasPenalty,
          'penalty_percent': penaltyPercent,
          'auto_approve_after': autoApproveAfter,
        })
        .select()
        .single();
    return data;
  }

  /// Gets active task templates for a child.
  static Future<List<Map<String, dynamic>>> getTaskTemplates({
    required String familyId,
    String? childId,
  }) async {
    var query = client
        .from('tasks')
        .select()
        .eq('family_id', familyId)
        .eq('is_template', true)
        .eq('is_active', true);
    if (childId != null) query = query.eq('child_id', childId);
    final data = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Creates a new submission for a task template (child starts a task).
  static Future<Map<String, dynamic>> createSubmission({
    required String taskId,
    required String childId,
  }) async {
    final data = await client
        .from('task_submissions')
        .insert({
          'task_id': taskId,
          'child_id': childId,
          'status': 'pending',
        })
        .select()
        .single();
    return data;
  }

  /// Gets submissions for a child (optionally filtered by status).
  static Future<List<Map<String, dynamic>>> getSubmissions({
    required String childId,
    String? status,
  }) async {
    var query = client
        .from('task_submissions')
        .select()
        .eq('child_id', childId)
        .neq('status', 'rejected');
    if (status != null) query = query.eq('status', status);
    final data = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  /// Updates submission status (submit, approve, reject).
  static Future<void> updateSubmissionStatus(
    String submissionId,
    String status, {
    String? parentNote,
    String? proofImageUrl,
    int? qualityRating,
    int? coinEarned,
    bool autoApproved = false,
  }) async {
    final updates = <String, dynamic>{'status': status};
    if (status == 'submitted') {
      updates['submitted_at'] = DateTime.now().toIso8601String();
      if (proofImageUrl != null) updates['proof_image_url'] = proofImageUrl;
    }
    if (status == 'approved' || status == 'rejected') {
      updates['reviewed_at'] = DateTime.now().toIso8601String();
    }
    if (parentNote != null) updates['parent_note'] = parentNote;
    if (qualityRating != null) updates['quality_rating'] = qualityRating;
    if (coinEarned != null) updates['coin_earned'] = coinEarned;
    if (autoApproved) updates['auto_approved'] = true;
    await client.from('task_submissions').update(updates).eq('id', submissionId);
  }

  /// Increments the approval_count on a task template after a submission is approved.
  static Future<void> incrementApprovalCount(String taskId) async {
    await client.rpc('increment_task_approval_count', params: {'p_task_id': taskId});
  }

  /// Decrements the approval_count when parent retroactively rejects an auto-approved submission.
  static Future<void> decrementApprovalCount(String taskId) async {
    await client.rpc('decrement_task_approval_count', params: {'p_task_id': taskId});
  }

  /// Deactivates a task template (soft delete).
  static Future<void> deactivateTask(String taskId) async {
    await client.from('tasks').update({'is_active': false}).eq('id', taskId);
  }

  // Legacy: kept for backward compatibility with non-template tasks
  static Future<void> updateTaskStatus(
    String taskId,
    String status, {
    String? parentNote,
    String? proofImageUrl,
  }) async {
    final updates = <String, dynamic>{'status': status};
    if (status == 'submitted') {
      updates['submitted_at'] = DateTime.now().toIso8601String();
      if (proofImageUrl != null) updates['proof_image_url'] = proofImageUrl;
    }
    if (status == 'approved' || status == 'rejected') {
      updates['reviewed_at'] = DateTime.now().toIso8601String();
    }
    if (parentNote != null) updates['parent_note'] = parentNote;
    await client.from('tasks').update(updates).eq('id', taskId);
  }

  /// Deletes all submissions belonging to a task template.
  /// Must run BEFORE deleteTask — task_submissions.task_id is a FK to tasks(id).
  static Future<void> deleteSubmissionsForTask(String taskId) async {
    await client.from('task_submissions').delete().eq('task_id', taskId);
  }

  static Future<void> deleteTask(String taskId) async {
    await client.from('tasks').delete().eq('id', taskId);
  }

  /// Uploads a proof image (bytes) to Supabase Storage bucket 'task-proofs'.
  /// Returns the public URL on success, or null on failure.
  static Future<String?> uploadProofImage({
    required String taskId,
    required Uint8List imageBytes,
  }) async {
    // Refresh session to ensure the JWT token is valid (not expired)
    try {
      await auth.refreshSession();
    } catch (_) {}

    // Use currentSession (not currentUser) — more reliable auth check
    final session = auth.currentSession;
    if (session == null) {
      debugPrint('[SupabaseStorage] No active session');
      return null;
    }
    final uid = session.user.id;

    try {
      // Path is relative to the bucket — do NOT include bucket name here
      final storagePath = '$uid/$taskId.jpg';
      debugPrint('[SupabaseStorage] Uploading to: task-proofs/$storagePath');
      debugPrint('[SupabaseStorage] User: ${session.user.email}, role: ${session.user.role}');

      await client.storage.from('task-proofs').uploadBinary(
        storagePath,
        imageBytes,
        fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: false),
      );
      final url = client.storage.from('task-proofs').getPublicUrl(storagePath);
      debugPrint('[SupabaseStorage] Upload success: $url');
      return url;
    } catch (e) {
      debugPrint('[SupabaseStorage] uploadProofImage failed: $e');
      return null;
    }
  }

  // ── Badges ────────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getBadges(String childId) async {
    final data = await client
        .from('badges')
        .select()
        .eq('child_id', childId)
        .order('earned_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> addBadge(
    String childId,
    String title,
    String emoji,
  ) async {
    await client.from('badges').insert({
      'child_id': childId,
      'title': title,
      'emoji': emoji,
    });
  }

  // ── Dream Items ───────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getDreamItems(
    String childId,
  ) async {
    final data = await client
        .from('dream_items')
        .select()
        .eq('child_id', childId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> addDreamItem({
    required String childId,
    required String name,
    required int price,
    String icon = '🎁',
  }) async {
    await client.from('dream_items').insert({
      'child_id': childId,
      'name': name,
      'price': price,
      'icon': icon,
    });
  }

  static Future<void> markDreamPurchased(String dreamId) async {
    await client
        .from('dream_items')
        .update({'is_purchased': true})
        .eq('id', dreamId);
  }

  static Future<void> editDreamItem(
    String dreamId, {
    required String name,
    required int price,
    required String icon,
  }) async {
    await client
        .from('dream_items')
        .update({'name': name, 'price': price, 'icon': icon})
        .eq('id', dreamId)
        .eq('is_purchased', false);
  }

  static Future<void> deleteDreamItem(String dreamId) async {
    await client.from('dream_items').delete().eq('id', dreamId);
  }

  // ── Memories ──────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getMemories({
    required String familyId,
    String? childId,
  }) async {
    var query = client.from('memories').select().eq('family_id', familyId);
    if (childId != null) query = query.eq('child_id', childId);
    final data = await query.order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> addMemory({
    required String familyId,
    required String childId,
    required String taskTitle,
    required String emoji,
    required String note,
    String? proofImageUrl,
  }) async {
    final data = <String, dynamic>{
      'family_id': familyId,
      'child_id': childId,
      'task_title': taskTitle,
      'emoji': emoji,
      'note': note,
    };
    if (proofImageUrl != null) data['proof_image_url'] = proofImageUrl;
    await client.from('memories').insert(data);
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getSettings() async {
    final uid = userId;
    if (uid == null) return null;
    final data = await client
        .from('user_settings')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    return data;
  }

  static Future<void> updateSettings(Map<String, dynamic> updates) async {
    final uid = userId;
    if (uid == null) return;
    updates['updated_at'] = DateTime.now().toIso8601String();
    await client.from('user_settings').update(updates).eq('user_id', uid);
  }

  // ── Lessons ───────────────────────────────────────────────────────────────

  static Future<List<Map<String, dynamic>>> getLessons({String? audience}) async {
    var query = client
        .from('lessons')
        .select('*, lesson_quizzes(*, quiz_options(*))')
        .eq('is_published', true);

    if (audience != null) {
      query = query.eq('audience', audience);
    }

    final rows = await query.order('order_index');
    return List<Map<String, dynamic>>.from(rows as List);
  }

  // ── Subscription / Pricing ─────────────────────────────────────────────────

  /// Returns the plan name ('free' | 'premium' | 'family') for the given user.
  static Future<String?> getUserPlan(String userId) async {
    try {
      final data = await client
          .from('user_subscriptions')
          .select('status, plan:plans(name)')
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return 'free';
      final status = data['status'] as String?;
      if (status == 'active' || status == 'trial') {
        return (data['plan'] as Map<String, dynamic>?)?['name'] as String? ?? 'free';
      }
      return 'free';
    } catch (e) {
      debugPrint('[SupabaseService] getUserPlan error: $e');
      return 'free';
    }
  }

  /// Returns the plan's max_children limit for the user (free/none → 1).
  static Future<int> getPlanMaxChildren(String userId) async {
    try {
      final data = await client
          .from('user_subscriptions')
          .select('status, plan:plans(name, max_children)')
          .eq('user_id', userId)
          .maybeSingle();
      if (data == null) return 1;
      final status = data['status'] as String?;
      if (status == 'active' || status == 'trial') {
        final plan = data['plan'] as Map<String, dynamic>?;
        return (plan?['max_children'] as int?) ?? 1;
      }
      return 1;
    } catch (e) {
      debugPrint('[SupabaseService] getPlanMaxChildren error: $e');
      return 1;
    }
  }

  /// Creates a 7-day trial subscription for the given user and plan.
  static Future<void> startTrial({
    required String userId,
    required String planName,
  }) async {
    try {
      final planRow = await client
          .from('plans')
          .select('id')
          .eq('name', planName)
          .single();
      final planId = planRow['id'] as String;
      final now = DateTime.now();
      await client.from('user_subscriptions').upsert({
        'user_id': userId,
        'plan_id': planId,
        'status': 'trial',
        'billing_interval': 'monthly',
        'trial_ends_at': now.add(const Duration(days: 7)).toIso8601String(),
        'current_period_start': now.toIso8601String(),
        'current_period_end': now.add(const Duration(days: 7)).toIso8601String(),
      }, onConflict: 'user_id');
    } catch (e) {
      debugPrint('[SupabaseService] startTrial error: $e');
    }
  }

  /// Returns today's AI message count for the user, or 0 if no record.
  static Future<int> getDailyAiUsage(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final data = await client
          .from('daily_ai_usage')
          .select('message_count')
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();
      return (data?['message_count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Increments today's AI message count for the user.
  static Future<void> incrementAiUsage(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await client.rpc('increment_ai_usage', params: {
        'p_user_id': userId,
        'p_date': today,
      });
    } catch (e) {
      debugPrint('[SupabaseService] incrementAiUsage error: $e');
    }
  }

  /// Returns today's emotion check-in count for the user, or 0 if no record.
  static Future<int> getDailyEmotionUsage(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final data = await client
          .from('daily_emotion_usage')
          .select('count')
          .eq('user_id', userId)
          .eq('date', today)
          .maybeSingle();
      return (data?['count'] as int?) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Increments today's emotion check-in count for the user (upsert).
  static Future<void> incrementEmotionUsage(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final current = await getDailyEmotionUsage(userId);
      await client.from('daily_emotion_usage').upsert({
        'user_id': userId,
        'date': today,
        'count': current + 1,
      }, onConflict: 'user_id,date');
    } catch (e) {
      debugPrint('[SupabaseService] incrementEmotionUsage error: $e');
    }
  }
}
