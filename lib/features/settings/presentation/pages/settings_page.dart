import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/ads/data/ad_service.dart';
import '../../../../features/progress/presentation/providers/progress_provider.dart';
import '../../../../features/settings/data/sound_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sound = ref.watch(soundServiceProvider);
    final prog = ref.watch(progressNotifierProvider).valueOrNull;
    final ads = ref.watch(adServiceProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'الإعدادات',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(WaqtiSpacing.md),
          children: [
            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(Icons.volume_up_rounded, 'الصوت'),
                  const SizedBox(height: WaqtiSpacing.md),
                  ListenableBuilder(
                    listenable: sound,
                    builder: (_, __) => Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sound.isMuted ? '🔇 معطّل' : '🔊 مفعّل',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      color: sound.isMuted
                                          ? WaqtiColors.textLight
                                          : WaqtiColors.mint,
                                    ),
                                  ),
                                  const Text(
                                    'تشغيل الأصوات أثناء اللعب',
                                    style: TextStyle(
                                      fontFamily: 'Cairo',
                                      fontSize: 12,
                                      color: WaqtiColors.textLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch.adaptive(
                              value: !sound.isMuted,
                              activeThumbColor: WaqtiColors.mint,
                              onChanged: (_) => sound.toggleMute(),
                            ),
                          ],
                        ),
                        if (!sound.isMuted) ...[
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Icon(Icons.volume_down, color: WaqtiColors.textLight, size: 18),
                              Expanded(
                                child: Slider(
                                  value: sound.volume,
                                  min: 0,
                                  max: 1,
                                  divisions: 10,
                                  activeColor: WaqtiColors.primary,
                                  inactiveColor: WaqtiColors.primary.withOpacity(.2),
                                  onChanged: sound.setVolume,
                                  onChangeEnd: (_) => sound.click(),
                                ),
                              ),
                              const Icon(Icons.volume_up, color: WaqtiColors.textLight, size: 18),
                            ],
                          ),
                          Text(
                            'مستوى الصوت: ${(sound.volume * 100).round()}%',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Cairo', fontSize: 12, color: WaqtiColors.textLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: WaqtiSpacing.md),

            // AdMob diagnostics: this is intentionally visible in production
            // so we can distinguish SDK/loading problems from AdMob no-fill or
            // account/app-review limitations without needing logcat.
            _Card(
              child: ListenableBuilder(
                listenable: ads,
                builder: (_, __) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionHeader(Icons.ads_click_rounded, 'تشخيص AdMob'),
                    const SizedBox(height: 10),
                    _InfoRow('SDK', ads.initialized ? 'تمت التهيئة' : 'لم تتم التهيئة'),
                    _InfoRow('App ID', AdMobIds.androidAppId),
                    const SizedBox(height: 8),
                    _AdStatusRow('Banner Home', ads.homeBannerReady, ads.errorFor('Home Banner')),
                    _AdStatusRow('Banner Lesson', ads.lessonBannerReady, ads.errorFor('Lesson Banner')),
                    _AdStatusRow('Free Play Banner', ads.freePlayBannerReady, ads.errorFor('Free Play Banner')),
                    _AdStatusRow('Interstitial', ads.interstitialReady, ads.errorFor('Interstitial')),
                    _AdStatusRow('Rewarded', ads.rewardedReady, ads.errorFor('Rewarded')),
                    _AdStatusRow('Rewarded Hint', ads.rewardedHintReady, ads.errorFor('Rewarded Hint')),
                    if (ads.errorFor('SDK') != null) ...[
                      const SizedBox(height: 8),
                      _ErrorBox(ads.errorFor('SDK')!),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: ads.reloadAll,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text(
                          'إعادة تحميل الإعلانات',
                          style: TextStyle(fontFamily: 'Cairo'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: WaqtiSpacing.md),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(Icons.bar_chart_rounded, 'إحصائياتي'),
                  const SizedBox(height: WaqtiSpacing.md),
                  Row(
                    children: [
                      _StatPill('🔥', '${prog?.streakDays ?? 0}', 'يوم متتالي'),
                      const SizedBox(width: 10),
                      _StatPill('⭐', '${prog?.totalStars ?? 0}', 'نجمة'),
                      const SizedBox(width: 10),
                      _StatPill('📚', '${prog?.totalLessons ?? 0}', 'درس'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: WaqtiSpacing.md),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(Icons.info_outline_rounded, 'عن التطبيق'),
                  const SizedBox(height: WaqtiSpacing.md),
                  _InfoRow('الإصدار', '3.0.0'),
                  _InfoRow('المطوّر', 'Daryne'),
                  _InfoRow('البريد', 'support@waqti-app.com'),
                ],
              ),
            ),

            const SizedBox(height: WaqtiSpacing.md),

            _Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionHeader(Icons.warning_amber_rounded, 'منطقة الخطر', color: Colors.red),
                  const SizedBox(height: WaqtiSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete_forever_outlined, color: Colors.red),
                      label: const Text(
                        'إعادة تعيين كل التقدم',
                        style: TextStyle(fontFamily: 'Cairo', color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () => _confirmReset(context, ref),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إعادة تعيين؟', style: TextStyle(fontFamily: 'Cairo')),
        content: const Text(
          'سيتم حذف كل تقدمك ونجومك. هذا لا يمكن التراجع عنه.',
          style: TextStyle(fontFamily: 'Cairo'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('إعادة تعيين', style: TextStyle(fontFamily: 'Cairo')),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 3)),
          ],
        ),
        child: child,
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.icon, this.label, {this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (color ?? WaqtiColors.primary).withOpacity(.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color ?? WaqtiColors.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: color ?? WaqtiColors.textDark,
            ),
          ),
        ],
      );
}

class _AdStatusRow extends StatelessWidget {
  const _AdStatusRow(this.label, this.ready, this.error);
  final String label;
  final bool ready;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final status = ready ? 'يعمل' : error == null ? 'ينتظر' : 'خطأ';
    final color = ready ? WaqtiColors.mint : error == null ? WaqtiColors.gold : Colors.red;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ready ? Icons.check_circle : Icons.info_outline, color: color, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                status,
                style: TextStyle(
                  fontFamily: 'Cairo', fontSize: 12, fontWeight: FontWeight.w700, color: color,
                ),
              ),
            ],
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(right: 26, top: 2),
              child: Text(
                error!,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 9, color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: Colors.red),
        ),
      );
}

class _StatPill extends StatelessWidget {
  const _StatPill(this.icon, this.value, this.label);
  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: WaqtiColors.sky,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 18, fontWeight: FontWeight.w800,
                  color: WaqtiColors.primary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(fontFamily: 'Cairo', fontSize: 10, color: WaqtiColors.textLight),
              ),
            ],
          ),
        ),
      );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(fontFamily: 'Cairo', fontSize: 13, color: WaqtiColors.textLight),
            ),
            Expanded(
              child: Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Cairo', fontSize: 11, fontWeight: FontWeight.w600,
                  color: WaqtiColors.textDark,
                ),
              ),
            ),
          ],
        ),
      );
