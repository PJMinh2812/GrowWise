import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/pricing_screen.dart';

enum PaywallFeature { lesson, aiChat, tasks, miniGame, analytics }

extension PaywallFeatureExt on PaywallFeature {
  String get emoji {
    switch (this) {
      case PaywallFeature.lesson: return '🎓';
      case PaywallFeature.aiChat: return '🤖';
      case PaywallFeature.tasks: return '✅';
      case PaywallFeature.miniGame: return '🎮';
      case PaywallFeature.analytics: return '📊';
    }
  }

  String get title {
    switch (this) {
      case PaywallFeature.lesson: return 'Mở khóa tất cả bài học';
      case PaywallFeature.aiChat: return 'Chat AI không giới hạn';
      case PaywallFeature.tasks: return 'Nhiệm vụ không giới hạn';
      case PaywallFeature.miniGame: return 'Mở khóa tất cả mini-game';
      case PaywallFeature.analytics: return 'Xem báo cáo AI & Analytics';
    }
  }

  String get description {
    switch (this) {
      case PaywallFeature.lesson:
        return 'Nâng cấp Premium để truy cập toàn bộ thư viện bài học tài chính cho con.';
      case PaywallFeature.aiChat:
        return 'Bạn đã dùng hết 5 tin nhắn hôm nay. Nâng cấp để chat Wisy không giới hạn!';
      case PaywallFeature.tasks:
        return 'Gói Free chỉ cho phép 3 nhiệm vụ đang hoạt động. Nâng cấp để thêm không giới hạn!';
      case PaywallFeature.miniGame:
        return 'Mở khóa tất cả mini-game thú vị với gói Premium!';
      case PaywallFeature.analytics:
        return 'Báo cáo AI thông minh và Savings Analytics chỉ có ở gói Premium.';
    }
  }
}

/// [childMode] = true khi gọi từ màn hình của trẻ em.
/// Khi đó nút CTA sẽ hiện "Nhờ Bố/Mẹ mở khóa" thay vì navigate sang PricingScreen.
void showPaywallDialog(
  BuildContext context, {
  required PaywallFeature feature,
  bool childMode = false,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PaywallDialog(feature: feature, childMode: childMode),
  );
}

class PaywallDialog extends StatelessWidget {
  final PaywallFeature feature;
  final bool childMode;

  const PaywallDialog({super.key, required this.feature, this.childMode = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFF8F3),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDC1AE),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),

          // Emoji
          Text(feature.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),

          // Title
          Text(
            '🚀 ${feature.title}',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF211B10),
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            feature.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunitoSans(
              fontSize: 14,
              color: const Color(0xFF564334),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Price preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF6833EA).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(
                  '79.000₫ / tháng',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF6833EA),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '🎁 Dùng thử 7 ngày MIỄN PHÍ',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6833EA),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // CTA
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: childMode
                  ? () => Navigator.pop(context)
                  : () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PricingScreen()),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: childMode ? const Color(0xFFFF8C00) : const Color(0xFF6833EA),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: Text(
                childMode ? 'Nhờ Bố/Mẹ mở khóa 🏠' : 'Nâng cấp ngay →',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Dismiss
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Để sau',
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                color: const Color(0xFF897362),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
