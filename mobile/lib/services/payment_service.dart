import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class QRPaymentResult {
  final String orderId;
  final int orderCode;
  final String qrCode;       // SePay VietQR image URL
  final int amount;
  final String description;  // bank transfer reference (contains orderId)
  final String? accountNumber;
  final String? accountName;
  final String? bankId;

  const QRPaymentResult({
    required this.orderId,
    required this.orderCode,
    required this.qrCode,
    required this.amount,
    required this.description,
    this.accountNumber,
    this.accountName,
    this.bankId,
  });
}

class PlanPrice {
  final int monthly;
  final int yearly; // already discounted (-20%) by the server

  const PlanPrice({required this.monthly, required this.yearly});
}

class PaymentService {
  static String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:3000';

  /// Fetches plan prices from the web API so displayed prices match what the
  /// SePay order will actually charge. Returns a map keyed by plan name
  /// ('free' | 'premium' | 'family'); empty map on error (caller uses defaults).
  static Future<Map<String, PlanPrice>> fetchPlanPrices() async {
    try {
      final uri = Uri.parse('$_baseUrl/api/plans');
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final result = <String, PlanPrice>{};
        data.forEach((key, value) {
          final m = value as Map<String, dynamic>;
          result[key] = PlanPrice(
            monthly: (m['monthly'] as num?)?.toInt() ?? 0,
            yearly: (m['yearly'] as num?)?.toInt() ?? 0,
          );
        });
        return result;
      }
    } catch (e) {
      debugPrint('[PaymentService] fetchPlanPrices error: $e');
    }
    return {};
  }

  /// Creates a SePay VietQR bank-transfer order via the Next.js API.
  static Future<QRPaymentResult> createSePayOrder({
    required String userId,
    required String planName,
    required String billingInterval,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/payment/sepay/create');
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
      amount:        (data['amount']       as num).toInt(),
      description:   data['description']   as String,
      accountNumber: data['accountNumber'] as String?,
      accountName:   data['accountName']   as String?,
      bankId:        data['bankId']        as String?,
    );
  }

  /// Polls the server for the payment status of [orderId].
  /// Returns 'pending' | 'completed' | 'failed' | 'cancelled' | null on error.
  static Future<String?> checkStatus(String orderId) async {
    try {
      final uri = Uri.parse('$_baseUrl/api/payment/sepay/status?orderId=$orderId');
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
