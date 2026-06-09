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

class QRPaymentResult {
  final String orderId;
  final int orderCode;
  final String qrCode;       // VietQR image URL
  final String? checkoutUrl; // web fallback
  final int amount;
  final String description;  // bank transfer reference
  final String? accountNumber;
  final String? accountName;
  final String? bankId;

  const QRPaymentResult({
    required this.orderId,
    required this.orderCode,
    required this.qrCode,
    this.checkoutUrl,
    required this.amount,
    required this.description,
    this.accountNumber,
    this.accountName,
    this.bankId,
  });
}

class PaymentService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  /// Creates a MoMo payment order via the Next.js API.
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

  /// Creates a PayOS VietQR bank-transfer order.
  static Future<QRPaymentResult> createQROrder({
    required String userId,
    required String planName,
    required String billingInterval,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/payment/qr/create');
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
      throw Exception('Không thể tạo mã QR (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return QRPaymentResult(
      orderId:       data['orderId']       as String,
      orderCode:     (data['orderCode']    as num).toInt(),
      qrCode:        data['qrCode']        as String,
      checkoutUrl:   data['checkoutUrl']   as String?,
      amount:        (data['amount']       as num).toInt(),
      description:   data['description']   as String,
      accountNumber: data['accountNumber'] as String?,
      accountName:   data['accountName']   as String?,
      bankId:        data['bankId']        as String?,
    );
  }

  /// Opens MoMo UAT app via deeplink, falls back to browser payUrl.
  static Future<bool> launchMoMo(PaymentResult result) async {
    if (result.deeplink != null && result.deeplink!.isNotEmpty) {
      try {
        final launched = await launchUrl(
          Uri.parse(result.deeplink!),
          mode: LaunchMode.externalApplication,
        );
        if (launched) return true;
      } catch (e) {
        debugPrint('[PaymentService] deeplink failed, trying payUrl: $e');
      }
    }
    if (result.payUrl != null && result.payUrl!.isNotEmpty) {
      try {
        return await launchUrl(
          Uri.parse(result.payUrl!),
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        debugPrint('[PaymentService] payUrl failed: $e');
      }
    }
    return false;
  }

  /// Polls the server for the payment status of [orderId].
  /// [provider] selects the status endpoint ('momo' or 'qr').
  /// Returns 'pending' | 'completed' | 'failed' | null on error.
  static Future<String?> checkStatus(String orderId, {String provider = 'momo'}) async {
    try {
      final path = provider == 'qr'
          ? '/api/payment/qr/status'
          : '/api/payment/momo/status';
      final uri = Uri.parse('$_baseUrl$path?orderId=$orderId');
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
