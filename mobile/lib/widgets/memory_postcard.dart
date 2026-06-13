import 'dart:convert';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const _cream1 = Color(0xFFFFF8E7);
const _cream2 = Color(0xFFFFFDE7);
const _orange = Color(0xFFF97316);
const _navy = Color(0xFF1A1A2E);
const _slate = Color(0xFF475569);
const _gray = Color(0xFF94A3B8);

/// A single decorated GrowWise "postcard" for one memory.
/// Fixed width (360) so RepaintBoundary capture at pixelRatio 3 ≈ 1080px.
class MemoryPostcard extends StatelessWidget {
  final String emoji;
  final String task;
  final String note;
  final String date;
  final String childName;
  final String proofImageUrl;
  final Uint8List? proofBytes;

  const MemoryPostcard({
    super.key,
    required this.emoji,
    required this.task,
    required this.note,
    required this.date,
    required this.childName,
    required this.proofImageUrl,
    this.proofBytes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_cream1, _cream2],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 6),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'GrowWise',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _orange,
                  ),
                ),
                const SizedBox(width: 6),
                const Text('🌱', style: TextStyle(fontSize: 18)),
              ],
            ),
            Text(
              'Kỷ niệm của con',
              style: GoogleFonts.plusJakartaSans(fontSize: 13, color: _gray),
            ),
            const SizedBox(height: 16),

            // Photo with white frame
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _image(),
              ),
            ),
            const SizedBox(height: 16),

            // Task title
            Text(
              '$emoji $task',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: _navy,
              ),
            ),

            // Note
            if (note.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                '"$note"',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: _slate,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 10),

            // Child + date
            Text(
              childName.isNotEmpty ? '$childName · $date' : date,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _gray,
              ),
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Footer
            Center(
              child: Text(
                '🌱 GrowWise — Dạy con yêu tiền',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _orange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _image() {
    const h = 220.0;
    if (proofBytes != null) {
      return Image.memory(proofBytes!, height: h, width: double.infinity,
          fit: BoxFit.cover, errorBuilder: (_, _, _) => _placeholder(h));
    }
    if (proofImageUrl.isNotEmpty) {
      if (proofImageUrl.startsWith('data:')) {
        try {
          final bytes = base64Decode(proofImageUrl.split(',').last);
          return Image.memory(bytes, height: h, width: double.infinity,
              fit: BoxFit.cover, errorBuilder: (_, _, _) => _placeholder(h));
        } catch (_) {}
      }
      return CachedNetworkImage(
        imageUrl: proofImageUrl,
        height: h,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, _) =>
            const SizedBox(height: h, child: Center(child: CircularProgressIndicator())),
        errorWidget: (_, _, _) => _placeholder(h),
      );
    }
    return _placeholder(h);
  }

  Widget _placeholder(double h) => Container(
        height: h,
        width: double.infinity,
        color: const Color(0xFFF1F5F9),
        child: const Center(child: Text('📷', style: TextStyle(fontSize: 48))),
      );
}

/// A vertical album of multiple postcards (for "share all").
class MemoryAlbum extends StatelessWidget {
  final List<MemoryPostcard> postcards;
  const MemoryAlbum({super.key, required this.postcards});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_cream1, _cream2],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'GrowWise 🌱',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _orange,
            ),
          ),
          Text(
            'Album kỷ niệm của con',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _navy,
            ),
          ),
          const SizedBox(height: 16),
          for (final p in postcards) ...[
            p,
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}
