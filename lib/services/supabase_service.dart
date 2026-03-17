import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  static GoTrueClient get auth => client.auth;
  static String? get userId => auth.currentUser?.id;

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
    return auth.resetPasswordForEmail(email);
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

  static Future<Map<String, dynamic>> createTask({
    required String familyId,
    required String childId,
    required String title,
    required String description,
    required String category,
    required String icon,
    required int coinReward,
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
        })
        .select()
        .single();
    return data;
  }

  static Future<void> updateTaskStatus(
    String taskId,
    String status, {
    String? parentNote,
  }) async {
    final updates = <String, dynamic>{'status': status};
    if (status == 'submitted')
      updates['submitted_at'] = DateTime.now().toIso8601String();
    if (status == 'approved' || status == 'rejected') {
      updates['reviewed_at'] = DateTime.now().toIso8601String();
    }
    if (parentNote != null) updates['parent_note'] = parentNote;
    await client.from('tasks').update(updates).eq('id', taskId);
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
  }) async {
    await client.from('memories').insert({
      'family_id': familyId,
      'child_id': childId,
      'task_title': taskTitle,
      'emoji': emoji,
      'note': note,
    });
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
}
