import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

/// A published survey targeted at the current viewer.
class ActiveSurvey {
  ActiveSurvey({
    required this.id,
    required this.title,
    this.description,
    required this.url,
    required this.verified,
  });

  final String id;
  final String title;
  final String? description;
  final String url;

  /// True when the link carries a `__TOKEN__` placeholder (web tokenises it
  /// server-side). Mobile can't sign tokens, so it strips the placeholder.
  final bool verified;
}

/// Mirrors the web survey flow (`lib/app/surveys.ts` + `survey-actions.ts`):
/// the newest published survey for an audience that the current subject
/// (parent = user; child = user+child) hasn't dismissed yet.
class SurveyService {
  static Future<ActiveSurvey?> getActiveSurvey({
    required String audience, // 'parent' | 'child'
    String? childId,
    int? childAge,
  }) async {
    final uid = SupabaseService.userId;
    if (uid == null) return null;
    final client = SupabaseService.client;

    try {
      final rows = await client
          .from('surveys')
          .select('id, title, description, url, min_age, max_age')
          .eq('is_published', true)
          .inFilter('audience', [audience, 'all'])
          .order('published_at', ascending: false);

      final surveys = (rows as List).cast<Map<String, dynamic>>();
      if (surveys.isEmpty) return null;

      var dq = client.from('survey_dismissals').select('survey_id').eq('user_id', uid);
      dq = childId != null ? dq.eq('child_id', childId) : dq.isFilter('child_id', null);
      final dismissedRows = (await dq as List).cast<Map<String, dynamic>>();
      final done = dismissedRows.map((d) => d['survey_id'] as String).toSet();

      for (final s in surveys) {
        final id = s['id'] as String;
        if (done.contains(id)) continue;
        if (childId != null && childAge != null) {
          final minAge = s['min_age'] as int?;
          final maxAge = s['max_age'] as int?;
          if (minAge != null && childAge < minAge) continue;
          if (maxAge != null && childAge > maxAge) continue;
        }
        final rawUrl = s['url'] as String;
        final verified = rawUrl.contains('__TOKEN__');
        return ActiveSurvey(
          id: id,
          title: s['title'] as String,
          description: s['description'] as String?,
          url: verified ? rawUrl.replaceAll('__TOKEN__', '') : rawUrl,
          verified: verified,
        );
      }
      return null;
    } catch (e) {
      debugPrint('SurveyService.getActiveSurvey error: $e');
      return null;
    }
  }

  /// Records a dismissal so the banner stops showing (idempotent — duplicate
  /// inserts are ignored, matching the web's 23505 handling).
  static Future<void> dismiss(String surveyId, {String? childId}) async {
    final uid = SupabaseService.userId;
    if (uid == null) return;
    try {
      await SupabaseService.client.from('survey_dismissals').insert({
        'survey_id': surveyId,
        'user_id': uid,
        'child_id': childId,
      });
    } catch (e) {
      // Unique-violation (already dismissed) is harmless.
      debugPrint('SurveyService.dismiss ignored: $e');
    }
  }
}
