import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

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
        .map((m) => {
              'role': m['role'],
              'parts': [
                {'text': m['text']}
              ],
            })
        .toList();

    final body = jsonEncode({
      'system_instruction': {
        'parts': [
          {'text': _buildSystemPrompt(childContext)}
        ],
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.85,
        'maxOutputTokens': 256,
      },
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
          final parts = (candidates.first['content']
              as Map<String, dynamic>)['parts'] as List<dynamic>;
          return (parts.first['text'] as String).trim();
        }
      }
    } catch (e, st) {
      debugPrint('[Gemini] error: $e\n$st');
    }
    return null;
  }
}
