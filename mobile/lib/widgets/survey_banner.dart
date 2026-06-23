import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/survey_service.dart';

/// Purple "campaign" survey banner (matches the Stitch `dashboard-preview`
/// mockup). Self-fetches the active survey; renders nothing when there is none.
/// On tap it opens the external form and records a dismissal so it stops nagging.
class SurveyBanner extends StatefulWidget {
  const SurveyBanner({
    super.key,
    required this.audience, // 'parent' | 'child'
    this.childId,
    this.childAge,
  });

  final String audience;
  final String? childId;
  final int? childAge;

  @override
  State<SurveyBanner> createState() => _SurveyBannerState();
}

class _SurveyBannerState extends State<SurveyBanner> {
  late Future<ActiveSurvey?> _future;
  bool _hidden = false;

  @override
  void initState() {
    super.initState();
    _future = SurveyService.getActiveSurvey(
      audience: widget.audience,
      childId: widget.childId,
      childAge: widget.childAge,
    );
  }

  Future<void> _open(ActiveSurvey survey) async {
    final uri = Uri.tryParse(survey.url);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    await SurveyService.dismiss(survey.id, childId: widget.childId);
    if (mounted) setState(() => _hidden = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_hidden) return const SizedBox.shrink();
    return FutureBuilder<ActiveSurvey?>(
      future: _future,
      builder: (context, snap) {
        final survey = snap.data;
        if (survey == null) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => _open(survey),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFC9B6F2), Color(0xFFA78BEC)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6833EA).withValues(alpha: 0.45),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Color(0xFF6833EA),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.campaign_rounded, color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        survey.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF3A1E70),
                        ),
                      ),
                      if (survey.description != null && survey.description!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            survey.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4A2E86),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF5B3FC0)),
              ],
            ),
          ),
        );
      },
    );
  }
}
