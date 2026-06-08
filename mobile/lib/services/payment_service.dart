import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class PaymentResult {
  final String orderId;
  final String? payUrl;
  final String? deeplink;
  final String? qrCodeUrl;
  final int resultCode;
  final String message;

  const PaymentResult({
    required this.orderId,
    this.payUrl,
    this.deeplink,
    this.qrCodeUrl,
    required this.resultCode,
    required this.message,
  });

  bool get isSuccess => resultCode == 0;
}

class PaymentService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  /// Creates a MoMo payment order via the Next.js API.
  /// Returns a [PaymentResult] containing payUrl and deeplink.
  static Future<PaymentResult> createMoMoOrder({
    required String userId,
    required String planName,
    required String billingInterval,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/payment/momo/create');
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'planName': planName,
        'billingInterval': billingInterval,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Không thể tạo đơn thanh toán (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return PaymentResult(
      orderId:    data['orderId']    as String,
      payUrl:     data['payUrl']     as String?,
      deeplink:   data['deeplink']   as String?,
      qrCodeUrl:  data['qrCodeUrl']  as String?,
      resultCode: (data['resultCode'] as num?)?.toInt() ?? -1,
      message:    data['message']    as String? ?? '',
    );
  }

  /// Opens the MoMo app via deeplink, falling back to payUrl in browser.
  static Future<bool> launchMoMo(PaymentResult result) async {
    if (result.deeplink != null && result.deeplink!.isNotEmpty) {
      final uri = Uri.parse(result.deeplink!);
      try {
        if (await canLaunchUrl(uri)) {
          return launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        debugPrint('[PaymentService] deeplink failed: $e');
      }
    }
    if (result.payUrl != null && result.payUrl!.isNotEmpty) {
      final uri = Uri.parse(result.payUrl!);
      if (await canLaunchUrl(uri)) {
        return launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
    return false;
  }

  /// Polls the server for the payment status of the given orderId.
  /// Returns 'pending' | 'completed' | 'failed' | null on error.
  static Future<String?> checkStatus(String orderId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/payment/momo/status?orderId=$orderId');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['status'] as String?;
      }
    } catch (e) {
      debugPrint('[PaymentService] checkStatus error: $e');
    }
    return null;
  }
}
