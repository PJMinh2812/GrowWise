import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_theme.dart';

/// Full-screen preview of a memory postcard / album with a "share image" action.
/// The content lives in the widget tree so network images finish painting
/// before capture.
class MemoryPostcardPreview extends StatefulWidget {
  final Widget content;
  final String childName;
  final double pixelRatio;

  const MemoryPostcardPreview({
    super.key,
    required this.content,
    required this.childName,
    this.pixelRatio = 3.0,
  });

  @override
  State<MemoryPostcardPreview> createState() => _MemoryPostcardPreviewState();
}

class _MemoryPostcardPreviewState extends State<MemoryPostcardPreview> {
  final _boundaryKey = GlobalKey();
  bool _busy = false;

  Future<void> _shareImage() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      // Give the frame a beat to ensure images are painted.
      await Future.delayed(const Duration(milliseconds: 300));
      final boundary =
          _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: widget.pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final file = await File('${dir.path}/ky-niem-$ts.png').writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png')],
        text: 'Kỷ niệm của ${widget.childName} trên GrowWise 🌱',
      );
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Không tạo được ảnh kỷ niệm. Thử lại nhé.')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceBright,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Xem trước kỷ niệm',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: RepaintBoundary(
            key: _boundaryKey,
            child: widget.content,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _busy ? null : _shareImage,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.vibrantPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: _busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.ios_share),
              label: Text(
                _busy ? 'Đang tạo ảnh…' : 'Chia sẻ ảnh',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
