import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class EmotionResult {
  final String emotion; // happy | angry | sad | stressed | surprised | neutral
  final String emoji;
  final String label;
  final String advice;

  const EmotionResult({
    required this.emotion,
    required this.emoji,
    required this.label,
    required this.advice,
  });

  Map<String, dynamic> toJson() => {
    'emotion': emotion,
    'emoji': emoji,
    'label': label,
    'advice': advice,
  };

  factory EmotionResult.fromJson(Map<String, dynamic> json) => EmotionResult(
    emotion: json['emotion'] as String,
    emoji:   json['emoji']   as String,
    label:   json['label']   as String,
    advice:  json['advice']  as String,
  );
}

class EmotionService {
  static const _endpoint = 'https://api-us.faceplusplus.com/facepp/v3/detect';

  static const _emotionMap = {
    'happy':     ('😊', 'Vui vẻ',      'Thời điểm tuyệt vời để khen ngợi và cùng con đặt mục tiêu mới!'),
    'angry':     ('😠', 'Bực bội',     'Hãy chờ bình tĩnh lại trước khi nói chuyện với con — phản ứng lúc này dễ gây tổn thương.'),
    'sad':       ('😢', 'Buồn bã',     'Chia sẻ cảm xúc với con là điều tốt — dạy con rằng buồn cũng là cảm xúc bình thường.'),
    'stressed':  ('😰', 'Căng thẳng',  'Hãy thở sâu trước khi tương tác với con — con rất nhạy cảm với tâm trạng của ba/mẹ.'),
    'surprised': ('😮', 'Ngạc nhiên',  'Giữ tinh thần cởi mở — đây là lúc tốt để lắng nghe những điều bất ngờ từ con.'),
    'neutral':   ('😐', 'Bình thường', 'Bạn đang ở trạng thái ổn định — lý tưởng để lắng nghe và hỗ trợ con.'),
  };

  /// Detects the dominant emotion from a face photo using Face++ API.
  static Future<EmotionResult?> detectEmotion(Uint8List imageBytes) async {
    final apiKey    = dotenv.env['FACE_PLUS_PLUS_API_KEY'] ?? '';
    final apiSecret = dotenv.env['FACE_PLUS_PLUS_API_SECRET'] ?? '';

    if (apiKey.isEmpty || apiSecret.isEmpty) {
      debugPrint('[EmotionService] Face++ keys not configured');
      return null;
    }

    try {
      final base64Image = base64Encode(imageBytes);
      final request = http.MultipartRequest('POST', Uri.parse(_endpoint))
        ..fields['api_key']            = apiKey
        ..fields['api_secret']         = apiSecret
        ..fields['image_base64']       = base64Image
        ..fields['return_attributes']  = 'emotion';

      final streamedRes = await request.send().timeout(const Duration(seconds: 20));
      final body = await streamedRes.stream.bytesToString();
      final data = jsonDecode(body) as Map<String, dynamic>;

      final faces = data['faces'] as List?;
      if (faces == null || faces.isEmpty) {
        debugPrint('[EmotionService] No face detected in image');
        return null;
      }

      final emotionScores = (faces.first as Map<String, dynamic>)['attributes']
          ['emotion'] as Map<String, dynamic>;

      // Map Face++ emotion keys → our categories
      final mapped = <String, double>{
        'happy':     (emotionScores['happiness'] as num).toDouble(),
        'angry':     ((emotionScores['anger'] as num) + (emotionScores['disgust'] as num)).toDouble(),
        'sad':       (emotionScores['sadness'] as num).toDouble(),
        'stressed':  (emotionScores['fear'] as num).toDouble(),
        'surprised': (emotionScores['surprise'] as num).toDouble(),
        'neutral':   (emotionScores['neutral'] as num).toDouble(),
      };

      final dominant = mapped.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;

      final (emoji, label, advice) = _emotionMap[dominant]!;
      return EmotionResult(emotion: dominant, emoji: emoji, label: label, advice: advice);
    } catch (e) {
      debugPrint('[EmotionService] error: $e');
      return null;
    }
  }
}
