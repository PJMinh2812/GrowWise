import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../services/payment_service.dart';
import '../services/supabase_service.dart';

// Parent theme colors (matching parent dashboard)
const _kBg          = Color(0xFFF5F0FF);  // light purple bg
const _kOrange      = Color(0xFF6B38D4);  // vibrantPrimary purple
const _kOrangeDark  = Color(0xFF5516BE);  // onPrimaryFixedVariant
const _kPurple      = Color(0xFF6833EA);
const _kPurpleLight = Color(0xFFEDE7F6);
const _kGreen       = Color(0xFF006E1C);
const _kText        = Color(0xFF1A1A2E);
const _kTextMuted   = Color(0xFF64748B);
const _kBorder      = Color(0xFFD0BCFF);  // primaryFixedDim

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen>
    with WidgetsBindingObserver {
  bool _isYearly = false;
  int? _openFaq;
  bool _loading = false;

  // Real payment tracking
  String? _pendingOrderId;
  String _paymentProvider = 'momo'; // 'momo' | 'qr'
  QRPaymentResult? _pendingQRResult;
  bool _waitingForPayment = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollTimer?.cancel();
    super.dispose();
  }

  // Called when user comes back from MoMo app / browser
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForPayment) {
      _startPolling();
    }
  }

  String _formatVND(int amount) {
    if (amount == 0) return 'Miễn phí';
    final s = amount.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return '$buffer₫';
  }

  // ── Demo mode: free trial ──────────────────────────────────────────────────
  Future<void> _startTrial(String planName) async {
    if (_loading) return;
    setState(() => _loading = true);
    final appState = context.read<AppState>();
    await appState.startPremiumTrial(planName);
    if (!mounted) return;
    setState(() => _loading = false);
    _showSuccess('7 ngày dùng thử bắt đầu! Chúc bạn trải nghiệm tốt 🎉');
    Navigator.pop(context);
  }

  // ── Real mode: MoMo payment ────────────────────────────────────────────────
  Future<void> _payWithMoMo(String planName) async {
    if (_loading) return;
    final uid = SupabaseService.userId;
    if (uid == null) {
      _showError('Vui lòng đăng nhập để thanh toán');
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await PaymentService.createMoMoOrder(
        userId: uid,
        planName: planName,
        billingInterval: _isYearly ? 'yearly' : 'monthly',
      );

      if (!mounted) return;

      if (result.resultCode != 0) {
        setState(() => _loading = false);
        _showError('Lỗi tạo đơn: ${result.message}');
        return;
      }

      _pendingOrderId  = result.orderId;
      _paymentProvider = 'momo';

      final launched = await PaymentService.launchMoMo(result);
      if (!mounted) return;

      if (!launched) {
        setState(() => _loading = false);
        _showError('Không thể mở ứng dụng MoMo. Vui lòng cài đặt MoMo và thử lại.');
        return;
      }

      setState(() {
        _loading = false;
        _waitingForPayment = true;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('Không thể kết nối đến server: $e');
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_pendingOrderId == null) return;
      final status = await PaymentService.checkStatus(_pendingOrderId!, provider: _paymentProvider);
      if (status == 'completed') {
        _pollTimer?.cancel();
        if (!mounted) return;
        setState(() => _waitingForPayment = false);
        await context.read<AppState>().refreshPlan();
        if (!mounted) return;
        _showSuccess('Thanh toán thành công! Gói Premium đã được kích hoạt 🎉');
        Navigator.pop(context);
      } else if (status == 'failed') {
        _pollTimer?.cancel();
        if (!mounted) return;
        setState(() => _waitingForPayment = false);
        _showError('Thanh toán thất bại. Vui lòng thử lại.');
      }
    });

    // Stop polling after 5 minutes
    Future.delayed(const Duration(minutes: 5), () {
      _pollTimer?.cancel();
      if (mounted && _waitingForPayment) {
        setState(() => _waitingForPayment = false);
      }
    });
  }

  void _onCtaTap(String planName, bool isDemoMode) {
    if (isDemoMode) {
      _startTrial(planName);
    } else {
      _showPaymentMethodPicker(planName);
    }
  }

  void _showPaymentMethodPicker(String planName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: _kBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Chọn phương thức thanh toán',
              style: GoogleFonts.nunitoSans(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: _kText,
              ),
            ),
            const SizedBox(height: 16),
            _PaymentMethodTile(
              icon: '📱',
              label: 'Ví MoMo',
              subtitle: 'Mở app MoMo để thanh toán',
              onTap: () {
                Navigator.pop(context);
                _payWithMoMo(planName);
              },
            ),
            const SizedBox(height: 10),
            _PaymentMethodTile(
              icon: '🏦',
              label: 'Chuyển khoản QR',
              subtitle: 'Quét mã QR bằng app ngân hàng bất kỳ',
              onTap: () {
                Navigator.pop(context);
                _payWithQR(planName);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _payWithQR(String planName) async {
    if (_loading) return;
    final uid = SupabaseService.userId;
    if (uid == null) {
      _showError('Vui lòng đăng nhập để thanh toán');
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await PaymentService.createQROrder(
        userId: uid,
        planName: planName,
        billingInterval: _isYearly ? 'yearly' : 'monthly',
      );

      if (!mounted) return;

      _pendingOrderId   = result.orderId;
      _pendingQRResult  = result;
      _paymentProvider  = 'qr';

      setState(() {
        _loading = false;
        _waitingForPayment = true;
      });

      _startPolling();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showError('Không thể tạo mã QR: $e');
    }
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: _kGreen,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  void _showError(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final appState   = context.watch<AppState>();
    final isDemoMode = appState.isDemoMode;

    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _kText),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Gói đăng ký',
          style: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _kText,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Text(
                  'Chọn gói phù hợp ☀️',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: _kText,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Đầu tư nhỏ, tương lai lớn',
                  style: GoogleFonts.nunitoSans(fontSize: 15, color: _kTextMuted),
                ),
                const SizedBox(height: 20),

                // Billing toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEE0CF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _ToggleBtn(
                        label: 'Hàng tháng',
                        active: !_isYearly,
                        onTap: () => setState(() => _isYearly = false),
                      ),
                      _ToggleBtn(
                        label: 'Hàng năm',
                        badge: '-20%',
                        active: _isYearly,
                        onTap: () => setState(() => _isYearly = true),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Free plan
                _PlanCard(
                  emoji: '🌿',
                  name: 'Cơ Bản',
                  price: '0₫',
                  priceLabel: '/ tháng',
                  features: const [
                    '3 bài học video',
                    'Hệ thống 3 lọ tiền',
                    'Tối đa 3 nhiệm vụ',
                    'Chat AI Wisy (5 tin/ngày)',
                    '2 mini-game',
                  ],
                  lockedFeatures: const ['Báo cáo AI thông minh', 'Savings Analytics'],
                  cardColor: Colors.white,
                  borderColor: _kBorder,
                  ctaLabel: 'Đang dùng',
                  ctaColor: null,
                  onCta: null,
                  isCurrentPlan: appState.planType == 'free',
                ),
                const SizedBox(height: 12),

                // Premium plan
                _PlanCard(
                  emoji: '🚀',
                  name: 'Nâng Cao',
                  price: _isYearly ? _formatVND(749000) : _formatVND(79000),
                  priceLabel: _isYearly ? '/ năm' : '/ tháng',
                  subtitle: _isYearly
                      ? '≈ 62.400₫/tháng'
                      : '~2.600₫/ngày — ít hơn 1 tô phở!',
                  savingBadge: _isYearly ? 'Tiết kiệm 200.000₫' : null,
                  features: const [
                    'Tất cả bài học (không giới hạn)',
                    'Nhiệm vụ không giới hạn',
                    'Chat AI không giới hạn',
                    'Tất cả mini-game',
                    'Báo cáo AI thông minh 📊',
                    'Custom badge riêng',
                  ],
                  lockedFeatures: const [],
                  cardColor: _kPurpleLight,
                  borderColor: _kPurple,
                  ctaLabel: isDemoMode
                      ? 'Dùng thử 7 ngày MIỄN PHÍ →'
                      : (_isYearly
                          ? 'Mua gói năm — ${_formatVND(749000)}'
                          : 'Mua gói tháng — ${_formatVND(79000)}'),
                  ctaColor: _kPurple,
                  onCta: appState.isPremium
                      ? null
                      : () => _onCtaTap('premium', isDemoMode),
                  badge: 'PHỔ BIẾN NHẤT',
                  badgeColor: _kOrange,
                  isCurrentPlan: appState.planType == 'premium',
                  loading: _loading,
                ),
                const SizedBox(height: 12),

                // Family plan
                _PlanCard(
                  emoji: '👨‍👩‍👧‍👦',
                  name: 'Gia Đình',
                  price: _isYearly ? _formatVND(1419000) : _formatVND(149000),
                  priceLabel: _isYearly ? '/ năm' : '/ tháng',
                  subtitle: _isYearly ? '≈ 118.250₫/tháng' : 'Tối đa 3 hồ sơ trẻ',
                  savingBadge: _isYearly ? 'Tiết kiệm 369.000₫' : null,
                  features: const [
                    'Tất cả tính năng Nâng Cao',
                    'Tối đa 3 hồ sơ trẻ',
                    'Dashboard phụ huynh chia sẻ',
                    'So sánh tiến độ các con',
                  ],
                  lockedFeatures: const [],
                  cardColor: const Color(0xFFE9DDFF),
                  borderColor: _kOrange,
                  ctaLabel: isDemoMode
                      ? 'Dùng thử 7 ngày MIỄN PHÍ →'
                      : (_isYearly
                          ? 'Mua gói năm — ${_formatVND(1419000)}'
                          : 'Mua gói tháng — ${_formatVND(149000)}'),
                  ctaColor: _kOrangeDark,
                  onCta: appState.planType == 'family'
                      ? null
                      : () => _onCtaTap('family', isDemoMode),
                  isCurrentPlan: appState.planType == 'family',
                  loading: _loading,
                ),
                const SizedBox(height: 28),

                // Payment badge (real mode only)
                if (!isDemoMode)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _kBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📱', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 6),
                        const Text('🏦', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'MoMo · Chuyển khoản QR — An toàn & Bảo mật',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _kOrangeDark,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                // Trust row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    _TrustItem(icon: Icons.lock_outline_rounded, label: 'Thanh toán\nan toàn'),
                    _TrustItem(icon: Icons.cancel_outlined, label: 'Hủy bất cứ\nlúc nào'),
                    _TrustItem(icon: Icons.card_giftcard_rounded, label: '7 ngày\nmiễn phí'),
                  ],
                ),
                const SizedBox(height: 28),

                // FAQ
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Câu hỏi thường gặp',
                    style: GoogleFonts.nunitoSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _kText,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ..._faqs.asMap().entries.map((e) => _FaqItem(
                  index: e.key,
                  q: e.value['q']!,
                  a: e.value['a']!,
                  isOpen: _openFaq == e.key,
                  onToggle: () =>
                      setState(() => _openFaq = _openFaq == e.key ? null : e.key),
                )),
                const SizedBox(height: 20),
                Text(
                  'Bằng cách đăng ký, bạn đồng ý với Điều khoản & Chính sách của GrowWise.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(fontSize: 11, color: _kTextMuted),
                ),
              ],
            ),
          ),

          // Waiting for payment overlay
          if (_waitingForPayment)
            Container(
              color: Colors.black54,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: _paymentProvider == 'qr' && _pendingQRResult != null
                      ? _QRPaymentOverlay(
                          result: _pendingQRResult!,
                          formatVND: _formatVND,
                          onCancel: () {
                            _pollTimer?.cancel();
                            setState(() => _waitingForPayment = false);
                          },
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('📱', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 16),
                            Text(
                              'Đang chờ xác nhận thanh toán...',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: _kText,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hoàn tất thanh toán trong ứng dụng MoMo rồi quay lại đây.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 13,
                                color: _kTextMuted,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const CircularProgressIndicator(color: _kOrange),
                            const SizedBox(height: 16),
                            TextButton(
                              onPressed: () {
                                _pollTimer?.cancel();
                                setState(() => _waitingForPayment = false);
                              },
                              child: Text(
                                'Hủy',
                                style: GoogleFonts.nunitoSans(
                                  color: _kTextMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

const _faqs = [
  {'q': 'Tôi có thể hủy không?', 'a': 'Có, bạn có thể hủy bất kỳ lúc nào mà không mất thêm phí.'},
  {'q': 'Dùng thử có cần thẻ không?', 'a': 'Không cần! 7 ngày dùng thử hoàn toàn miễn phí, không yêu cầu thông tin thanh toán.'},
  {'q': 'Family package dùng được mấy điện thoại?', 'a': 'Mỗi hồ sơ trẻ được dùng trên 1 thiết bị. Gói Gia Đình cho tối đa 3 hồ sơ trẻ.'},
  {'q': 'Thanh toán qua MoMo có an toàn không?', 'a': 'Có! Toàn bộ giao dịch được mã hóa và xử lý bởi MoMo — GrowWise không lưu thông tin thẻ hay ví của bạn.'},
];

// ── Widgets ────────────────────────────────────────────────────────────────────

class _ToggleBtn extends StatelessWidget {
  final String label;
  final String? badge;
  final bool active;
  final VoidCallback onTap;

  const _ToggleBtn({required this.label, this.badge, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          color: active ? _kOrange : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: active
              ? [BoxShadow(color: _kOrange.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.nunitoSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: active ? Colors.white : _kTextMuted,
              ),
            ),
            if (badge != null) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: active
                      ? Colors.white.withValues(alpha: 0.3)
                      : const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge!,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String emoji;
  final String name;
  final String price;
  final String priceLabel;
  final String? subtitle;
  final String? savingBadge;
  final List<String> features;
  final List<String> lockedFeatures;
  final Color cardColor;
  final Color borderColor;
  final String ctaLabel;
  final Color? ctaColor;
  final VoidCallback? onCta;
  final String? badge;
  final Color? badgeColor;
  final bool isCurrentPlan;
  final bool loading;

  const _PlanCard({
    required this.emoji,
    required this.name,
    required this.price,
    required this.priceLabel,
    this.subtitle,
    this.savingBadge,
    required this.features,
    required this.lockedFeatures,
    required this.cardColor,
    required this.borderColor,
    required this.ctaLabel,
    this.ctaColor,
    this.onCta,
    this.badge,
    this.badgeColor,
    required this.isCurrentPlan,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _kText,
                    ),
                  ),
                  if (savingBadge != null) ...[
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        savingBadge!,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: price,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: ctaColor ?? _kText,
                      ),
                    ),
                    TextSpan(
                      text: ' $priceLabel',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _kTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12,
                    color: ctaColor ?? _kTextMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 16, color: _kGreen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: GoogleFonts.nunitoSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _kText,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
              ...lockedFeatures.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_rounded, size: 16, color: _kBorder),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        f,
                        style: GoogleFonts.nunitoSans(fontSize: 13, color: _kBorder),
                      ),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ctaColor == null
                    ? OutlinedButton(
                        onPressed: null,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: _kBorder),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: Text(
                          isCurrentPlan ? 'Đang dùng' : ctaLabel,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _kTextMuted,
                          ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: isCurrentPlan ? null : onCta,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCurrentPlan ? _kBorder : ctaColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                isCurrentPlan ? 'Gói hiện tại ✓' : ctaLabel,
                                style: GoogleFonts.nunitoSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
              ),
            ],
          ),
        ),
        if (badge != null)
          Positioned(
            top: -12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: badgeColor ?? _kOrange,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: (badgeColor ?? _kOrange).withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                badge!,
                style: GoogleFonts.nunitoSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TrustItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _TrustItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Icon(icon, size: 20, color: _kOrangeDark),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.nunitoSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _kTextMuted,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _FaqItem extends StatelessWidget {
  final int index;
  final String q;
  final String a;
  final bool isOpen;
  final VoidCallback onToggle;

  const _FaqItem({
    required this.index,
    required this.q,
    required this.a,
    required this.isOpen,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      q,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kText,
                      ),
                    ),
                  ),
                  Icon(
                    isOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: _kTextMuted,
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                a,
                style: GoogleFonts.nunitoSans(
                  fontSize: 13,
                  color: _kTextMuted,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _QRPaymentOverlay extends StatelessWidget {
  final QRPaymentResult result;
  final String Function(int) formatVND;
  final VoidCallback onCancel;

  const _QRPaymentOverlay({
    required this.result,
    required this.formatVND,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Step indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(
                color: _kGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 14),
            ),
            Container(width: 24, height: 2, color: _kBorder),
            Container(
              width: 24, height: 24,
              decoration: const BoxDecoration(
                color: _kOrange,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('2', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Quét mã QR để thanh toán',
          style: GoogleFonts.nunitoSans(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: _kText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Mở app ngân hàng và quét mã bên dưới',
          style: GoogleFonts.nunitoSans(fontSize: 12, color: _kTextMuted),
        ),
        const SizedBox(height: 14),
        // QR image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            result.qrCode,
            width: 200,
            height: 200,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const SizedBox(
                    width: 200, height: 200,
                    child: Center(child: CircularProgressIndicator(color: _kOrange)),
                  ),
            errorBuilder: (ctx, err, stack) => const SizedBox(
              width: 200, height: 200,
              child: Center(child: Icon(Icons.qr_code, size: 80, color: _kBorder)),
            ),
          ),
        ),
        const SizedBox(height: 14),
        // Payment info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _kOrange.withValues(alpha: 0.4)),
          ),
          child: Column(
            children: [
              _InfoRow(label: 'SỐ TIỀN', value: '${formatVND(result.amount)} VNĐ', valueColor: _kOrange),
              const SizedBox(height: 6),
              _InfoRow(label: 'NỘI DUNG', value: result.description, valueColor: _kOrange),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(
              width: 16, height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: _kOrange),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Đang chờ xác nhận... gói tự kích hoạt sau khi chuyển khoản',
                style: GoogleFonts.nunitoSans(fontSize: 11, color: _kTextMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Hủy thanh toán',
            style: GoogleFonts.nunitoSans(color: _kTextMuted, fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoRow({required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.nunitoSans(fontSize: 11, color: _kTextMuted, fontWeight: FontWeight.w700)),
        Text(value, style: GoogleFonts.nunitoSans(fontSize: 13, color: valueColor, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  final String icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: _kBorder),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _kText,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12,
                        color: _kTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _kBorder),
            ],
          ),
        ),
      ),
    );
  }
}
