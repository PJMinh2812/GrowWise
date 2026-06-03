import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  static String _buildSystemPrompt(Map<String, dynamic> ctx) {
    final name = ctx['childName'] as String;
    final age = ctx['childAge'] as int;
    final pending = (ctx['pendingTaskTitles'] as List<String>).isEmpty
        ? 'Không có nhiệm vụ đang chờ'
        : (ctx['pendingTaskTitles'] as List<String>).join(', ');
    final dreams = (ctx['dreamNames'] as List<String>).isEmpty
        ? 'Chưa có ước mơ'
        : (ctx['dreamNames'] as List<String>).join(', ');
    final bonding = (ctx['bondingMessage'] as String).isEmpty
        ? 'Bố mẹ chưa có tin nhắn mới'
        : '"${ctx['bondingMessage']}"';
    final badges = (ctx['badges'] as List<String>).isEmpty
        ? 'Chưa có huy hiệu'
        : (ctx['badges'] as List<String>).join(', ');

    return '''Bạn là Wisy 🌱, trợ lý AI thân thiện của GrowWise — ứng dụng giáo dục tài chính cho trẻ em.
Bạn đang trò chuyện với $name, $age tuổi.

Thông tin của $name:
• Xu: ${ctx['totalCoins']} xu (Chi tiêu: ${ctx['spendJar']} | Tiết kiệm: ${ctx['saveJar']} | Chia sẻ: ${ctx['shareJar']})
• Level ${ctx['level']} — ${ctx['xp']}/${ctx['xpToNextLevel']} XP
• Chuỗi ngày liên tiếp: ${ctx['streakDays']} ngày
• Nhiệm vụ đang chờ: $pending
• Ước mơ: $dreams
• Tin từ bố/mẹ: $bonding
• Huy hiệu: $badges

Quy tắc:
- Luôn dùng tiếng Việt, ngắn gọn (tối đa 3 câu), thân thiện, vui vẻ.
- Dùng 1–2 emoji mỗi câu trả lời.
- Ngôn ngữ đơn giản phù hợp $age tuổi.
- Dùng đúng dữ liệu của $name khi liên quan, không bịa số.
- Luôn khuyến khích và tích cực.
- Giải thích tài chính một cách thú vị, dễ hiểu.''';
  }

  /// Gửi tin nhắn đến Gemini và trả về phản hồi.
  /// [history] là lịch sử hội thoại (không bao gồm lời chào đầu tiên).
  /// Trả về null nếu API key chưa cấu hình hoặc có lỗi.
  static Future<String?> send({
    required List<Map<String, String>> history,
    required Map<String, dynamic> childContext,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return null;

    final contents = history
        .map(
          (m) => {
            'role': m['role'],
            'parts': [
              {'text': m['text']},
            ],
          },
        )
        .toList();

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': _buildSystemPrompt(childContext)},
        ],
      },
      'contents': contents,
      'generationConfig': {'temperature': 0.85, 'maxOutputTokens': 256},
    });

    try {
      final res = await http
          .post(
            Uri.parse('$_endpoint?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      debugPrint('[Gemini] status=${res.statusCode}');
      debugPrint('[Gemini] body=${res.body}');

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final candidates = json['candidates'] as List<dynamic>;
        if (candidates.isNotEmpty) {
          final parts =
              (candidates.first['content'] as Map<String, dynamic>)['parts']
                  as List<dynamic>;
          return (parts.first['text'] as String).trim();
        }
      }
    } catch (e, st) {
      debugPrint('[Gemini] error: $e\n$st');
    }
    return null;
  }

  // Lọc thinking parts (gemini-2.5-flash trả về thought trước answer thật)
  static String? _extractText(Map<String, dynamic> body) {
    try {
      final parts = (body['candidates'] as List).first['content']['parts'] as List;
      final answer = parts.firstWhere(
        (p) => (p as Map)['thought'] != true,
        orElse: () => parts.first,
      );
      return (answer['text'] as String).trim();
    } catch (_) {
      return null;
    }
  }

  static Map<String, dynamic> _noThinkingConfig(Map<String, dynamic> base) =>
      {...base, 'thinkingConfig': {'thinkingBudget': 0}};

  /// Gợi ý 4 nhiệm vụ cho phụ huynh dựa trên tuổi trẻ và danh mục.
  /// Returns list of {title, description, icon, coins} hoặc null nếu lỗi.
  static Future<List<Map<String, dynamic>>?> suggestTasks({
    required int childAge,
    required String category,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return null;

    final prompt =
        'Gợi ý 4 nhiệm vụ cho trẻ $childAge tuổi, danh mục "$category". '
        'Trả về JSON array KHÔNG có markdown, KHÔNG có giải thích:\n'
        '[{"title":"...","description":"...","icon":"emoji","coins":số}]\n'
        'Quy tắc: coins từ 5–50 tùy độ khó, description dưới 20 từ tiếng Việt, '
        'icon là 1 emoji phù hợp.';

    final body = jsonEncode({
      'contents': [
        {'role': 'user', 'parts': [{'text': prompt}]},
      ],
      'generationConfig': _noThinkingConfig({'temperature': 0.8, 'maxOutputTokens': 512}),
    });

    try {
      final res = await http
          .post(Uri.parse('$_endpoint?key=$apiKey'),
              headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 20));

      debugPrint('[Gemini.suggestTasks] status=${res.statusCode}');
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final text = _extractText(decoded);
        debugPrint('[Gemini.suggestTasks] text=$text');
        if (text != null) {
          // Greedy regex: lấy từ [ đầu tiên đến ] cuối cùng
          final match = RegExp(r'\[[\s\S]*\]').firstMatch(text);
          if (match != null) {
            return List<Map<String, dynamic>>.from(
                jsonDecode(match.group(0)!) as List);
          }
        }
      }
    } catch (e) {
      debugPrint('[Gemini.suggestTasks] $e');
    }
    return null;
  }

  /// Lời khuyến khích từ Wisy cho ước mơ đang tiết kiệm.
  static Future<String?> dreamCoach({
    required String childName,
    required String dreamName,
    required int dreamPrice,
    required int currentCoins,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isEmpty) return null;

    final percent = dreamPrice > 0
        ? (currentCoins / dreamPrice * 100).clamp(0.0, 100.0).toStringAsFixed(0)
        : '0';

    final prompt =
        'Bạn là Wisy 🌱 của GrowWise. Viết 2–3 câu khuyến khích $childName '
        'đang tiết kiệm để mua "$dreamName" (giá $dreamPrice xu). '
        'Hiện tại $childName có $currentCoins xu ($percent% tiến độ). '
        'Ngắn gọn, vui vẻ, thân thiện với trẻ em. Dùng 1–2 emoji.';

    final body = jsonEncode({
      'contents': [
        {'role': 'user', 'parts': [{'text': prompt}]},
      ],
      'generationConfig': _noThinkingConfig({'temperature': 0.9, 'maxOutputTokens': 150}),
    });

    try {
      final res = await http
          .post(Uri.parse('$_endpoint?key=$apiKey'),
              headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 15));

      debugPrint('[Gemini.dreamCoach] status=${res.statusCode}');
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        return _extractText(decoded);
      }
    } catch (e) {
      debugPrint('[Gemini.dreamCoach] $e');
    }
    return null;
  }
}
