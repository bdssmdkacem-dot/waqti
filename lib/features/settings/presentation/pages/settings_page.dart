import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/progress/presentation/providers/progress_provider.dart';
import '../../../../features/settings/data/sound_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sound = ref.watch(soundServiceProvider);
    final prog  = ref.watch(progressNotifierProvider).valueOrNull;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('الإعدادات', style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontWeight: FontWeight.w700))),
        body: ListView(
          padding: const EdgeInsets.all(WaqtiSpacing.md),
          children: [
            // ── Sound ───────────────────────────────────────────
            _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _SectionHeader(Icons.volume_up_rounded, 'الصوت'),
              const SizedBox(height: WaqtiSpacing.md),
              ListenableBuilder(
                listenable: sound,
                builder: (_, __) => Column(children: [
                  Row(children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(sound.isMuted ? '🔇 معطّل' : '🔊 مفعّل',
                        style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: 15, fontWeight: FontWeight.w600,
                          color: sound.isMuted ? WaqtiColors.textLight : WaqtiColors.mint)),
                      const Text('تشغيل الأصوات أثناء اللعب',
                        style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: 12, color: WaqtiColors.textLight)),
                    ])),
                    Switch.adaptive(
                      value: !sound.isMuted,
                      activeColor: WaqtiColors.mint,
                      onChanged: (_) => sound.toggleMute(),
                    ),
                  ]),
                  if (!sound.isMuted) ...[
                    const Divider(height: 24),
                    Row(children: [
                      const Icon(Icons.volume_down, color: WaqtiColors.textLight, size: 18),
                      Expanded(
                        child: Slider(
                          value: sound.volume,
                          min: 0, max: 1, divisions: 10,
                          activeColor: WaqtiColors.primary,
                          inactiveColor: WaqtiColors.primary.withOpacity(.2),
                          onChanged: (v) => sound.setVolume(v),
                          onChangeEnd: (_) => sound.click(),
                        ),
                      ),
                      const Icon(Icons.volume_up, color: WaqtiColors.textLight, size: 18),
                    ]),
                    Text('مستوى الصوت: ${(sound.volume*100).round()}%',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: 12, color: WaqtiColors.textLight)),
                  ],
                ]),
              ),
            ])),

            const SizedBox(height: WaqtiSpacing.md),

            // ── Stats ────────────────────────────────────────────
            _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _SectionHeader(Icons.bar_chart_rounded, 'إحصائياتي'),
              const SizedBox(height: WaqtiSpacing.md),
              Row(children: [
                _StatPill('🔥', '${prog?.streakDays ?? 0}', 'يوم متتالي'),
                const SizedBox(width: 10),
                _StatPill('⭐', '${prog?.totalStars ?? 0}', 'نجمة'),
                const SizedBox(width: 10),
                _StatPill('📚', '${prog?.totalLessons ?? 0}', 'درس'),
              ]),
            ])),

            const SizedBox(height: WaqtiSpacing.md),

            // ── App info ─────────────────────────────────────────
            _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _SectionHeader(Icons.info_outline_rounded, 'عن التطبيق'),
              const SizedBox(height: WaqtiSpacing.md),
              _InfoRow('الإصدار', '3.0.0'),
              _InfoRow('المطوّر', 'Daryne'),
              _InfoRow('البريد', 'support@waqti-app.com'),
            ])),

            const SizedBox(height: WaqtiSpacing.md),

            // ── Reset ─────────────────────────────────────────────
            _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _SectionHeader(Icons.warning_amber_rounded, 'منطقة الخطر', color: Colors.red),
              const SizedBox(height: WaqtiSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                  label: const Text('إعادة تعيين كل التقدم', style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, color: Colors.red)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                  onPressed: () => _confirmReset(context, ref),
                ),
              ),
            ])),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إعادة تعيين؟', style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily)),
        content: const Text('سيتم حذف كل تقدمك ونجومك. هذا لا يمكن التراجع عنه.', style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء', style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily))),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إعادة تعيين', style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(progressNotifierProvider.notifier).reset();
    }
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white, borderRadius: BorderRadius.circular(18),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12, offset: const Offset(0,3))],
    ),
    child: child,
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.icon, this.label, {this.color});
  final IconData icon; final String label; final Color? color;
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: (color ?? WaqtiColors.primary).withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color ?? WaqtiColors.primary, size: 22),
    ),
    const SizedBox(width: 12),
    Text(label, style: TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: 17, fontWeight: FontWeight.w700,
      color: color ?? WaqtiColors.textDark)),
  ]);
}

class _StatPill extends StatelessWidget {
  const _StatPill(this.icon, this.value, this.label);
  final String icon, value, label;
  @override
  Widget build(BuildContext context) => Expanded(child: Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: BoxDecoration(color: WaqtiColors.sky, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(icon, style: const TextStyle(fontSize: 20)),
      Text(value, style: const TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: 18, fontWeight: FontWeight.w800, color: WaqtiColors.primary)),
      Text(label, style: const TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: 10, color: WaqtiColors.textLight)),
    ]),
  ));
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(children: [
      Text('$label: ', style: const TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: 13, color: WaqtiColors.textLight)),
      Text(value,      style: const TextStyle(fontFamily: GoogleFonts.cairo().fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: WaqtiColors.textDark)),
    ]),
  );
}
