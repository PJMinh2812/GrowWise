import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

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

  static Future<http.Response?> _post(
    String apiKey,
    Map<String, dynamic> body,
    Duration timeout,
  ) async {
    try {
      return await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $apiKey',
            },
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } catch (e) {
      debugPrint('[Groq] request error: $e');
      return null;
    }
  }

  static String? _extractContent(Map<String, dynamic> json) {
    try {
      return (json['choices'] as List).first['message']['content'] as String?;
    } catch (_) {
      return null;
    }
  }

  static Future<String?> send({
    required List<Map<String, String>> history,
    required Map<String, dynamic> childContext,
  }) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty) return null;

    final messages = <Map<String, String>>[
      {'role': 'system', 'content': _buildSystemPrompt(childContext)},
      ...history.map((m) => {
        'role': m['role'] == 'model' ? 'assistant' : m['role']!,
        'content': m['text']!,
      }),
    ];

    final res = await _post(
      apiKey,
      {
        'model': _model,
        'messages': messages,
        'temperature': 0.85,
        'max_tokens': 256,
      },
      const Duration(seconds: 15),
    );

    debugPrint('[Groq] status=${res?.statusCode}');
    if (res?.statusCode == 200) {
      final json = jsonDecode(res!.body) as Map<String, dynamic>;
      return _extractContent(json)?.trim();
    }
    debugPrint('[Groq] body=${res?.body}');
    return null;
  }

  static Future<String?> weeklyReport({
    required String childName,
    required int totalApproved,
    required int streakDays,
    required Map<String, int> categoryTaskCounts,
    required int totalCoins,
    required List<String> dreamNames,
  }) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty) return null;

    final cats = categoryTaskCounts.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.key}: ${e.value} nhiệm vụ')
        .join(', ');
    final dreamStr =
        dreamNames.isNotEmpty ? 'Ước mơ: ${dreamNames.join(', ')}.' : '';

    final prompt =
        'Bạn là Wisy 🌱 của GrowWise. Viết báo cáo tiến trình ngắn gọn cho phụ huynh '
        'về bé $childName. Dữ liệu: hoàn thành $totalApproved nhiệm vụ, '
        'streak $streakDays ngày, tổng $totalCoins xu. '
        '${cats.isNotEmpty ? "Phân loại: $cats." : ""} $dreamStr\n'
        'Viết 3–4 câu tiếng Việt: tóm tắt thành tích + 1 lời khuyên cho phụ huynh '
        'tuần tới. Dùng 1–2 emoji.';

    final res = await _post(
      apiKey,
      {
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.85,
        'max_tokens': 200,
      },
      const Duration(seconds: 15),
    );

    if (res?.statusCode == 200) {
      final json = jsonDecode(res!.body) as Map<String, dynamic>;
      return _extractContent(json)?.trim();
    }
    debugPrint('[Groq.weeklyReport] status=${res?.statusCode}');
    return null;
  }

  static Future<List<Map<String, dynamic>>?> suggestTasks({
    required int childAge,
    required String category,
  }) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty) return null;

    final prompt =
        'Gợi ý 4 nhiệm vụ cho trẻ $childAge tuổi, danh mục "$category". '
        'Trả về JSON array KHÔNG có markdown, KHÔNG có giải thích:\n'
        '[{"title":"...","description":"...","icon":"emoji","coins":số}]\n'
        'Quy tắc: coins từ 5–50 tùy độ khó, description dưới 20 từ tiếng Việt, '
        'icon là 1 emoji phù hợp.';

    final res = await _post(
      apiKey,
      {
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.8,
        'max_tokens': 512,
      },
      const Duration(seconds: 20),
    );

    debugPrint('[Groq.suggestTasks] status=${res?.statusCode}');
    if (res?.statusCode == 200) {
      final json = jsonDecode(res!.body) as Map<String, dynamic>;
      final text = _extractContent(json);
      debugPrint('[Groq.suggestTasks] text=$text');
      if (text != null) {
        final match = RegExp(r'\[[\s\S]*\]').firstMatch(text);
        if (match != null) {
          return List<Map<String, dynamic>>.from(
              jsonDecode(match.group(0)!) as List);
        }
      }
    }
    return null;
  }

  static Future<String?> dreamCoach({
    required String childName,
    required String dreamName,
    required int dreamPrice,
    required int currentCoins,
  }) async {
    final apiKey = dotenv.env['GROQ_API_KEY'] ?? '';
    if (apiKey.isEmpty) return null;

    final percent = dreamPrice > 0
        ? (currentCoins / dreamPrice * 100).clamp(0.0, 100.0).toStringAsFixed(0)
        : '0';

    final prompt =
        'Bạn là Wisy 🌱 của GrowWise. Viết 2–3 câu khuyến khích $childName '
        'đang tiết kiệm để mua "$dreamName" (giá $dreamPrice xu). '
        'Hiện tại $childName có $currentCoins xu ($percent% tiến độ). '
        'Ngắn gọn, vui vẻ, thân thiện với trẻ em. Dùng 1–2 emoji.';

    final res = await _post(
      apiKey,
      {
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt},
        ],
        'temperature': 0.9,
        'max_tokens': 150,
      },
      const Duration(seconds: 15),
    );

    debugPrint('[Groq.dreamCoach] status=${res?.statusCode}');
    if (res?.statusCode == 200) {
      final json = jsonDecode(res!.body) as Map<String, dynamic>;
      return _extractContent(json)?.trim();
    }
    return null;
  }
}
