import 'package:flutter/cupertino.dart';

import '../data/stitch_image_urls.dart';
import '../theme/app_theme.dart';
import 'screen_components.dart';

class HealthHubScreen extends StatelessWidget {
  const HealthHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(title: 'VitalClarity', avatarUrl: StitchImageUrls.healthHubAvatar),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.containerPadding),
                children: const [
                  Text('Health Hub', style: AppTheme.h1),
                  SizedBox(height: AppTheme.xs),
                  Text('Track adherence and health trends.', style: AppTheme.body),
                  SizedBox(height: AppTheme.lg),
                  _WeeklyAdherenceCard(),
                  SizedBox(height: AppTheme.lg),
                  Text('Vitals', style: AppTheme.h2),
                  SizedBox(height: AppTheme.stackGap),
                  _VitalsGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyAdherenceCard extends StatelessWidget {
  const _WeeklyAdherenceCard();

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Adherence', style: AppTheme.h2),
          const SizedBox(height: AppTheme.sm),
          Row(
            children: List.generate(
              7,
              (i) => Expanded(
                child: Container(
                  height: 84,
                  margin: EdgeInsets.only(right: i == 6 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: i <= 4 ? AppTheme.primary.withValues(alpha: .9) : AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                      style: AppTheme.labelSmall.copyWith(
                        color: i <= 4 ? AppTheme.onPrimary : AppTheme.outline,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VitalsGrid extends StatelessWidget {
  const _VitalsGrid();

  @override
  Widget build(BuildContext context) {
    final cards = <({IconData icon, String label, String value, Color bg})>[
      (icon: CupertinoIcons.heart_fill, label: 'Heart Rate', value: '72 bpm', bg: AppTheme.tertiaryFixed),
      (icon: CupertinoIcons.drop_fill, label: 'Blood Pressure', value: '120/78', bg: AppTheme.primaryFixed),
      (icon: CupertinoIcons.bed_double_fill, label: 'Sleep', value: '7h 18m', bg: AppTheme.surfaceContainer),
      (icon: CupertinoIcons.waveform_path_ecg, label: 'Stress', value: 'Low', bg: AppTheme.secondaryContainer),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppTheme.stackGap,
        mainAxisSpacing: AppTheme.stackGap,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (_, i) {
        final item = cards[i];
        return PrimaryCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(shape: BoxShape.circle, color: item.bg),
                child: Icon(item.icon, size: 20, color: AppTheme.primary),
              ),
              const Spacer(),
              Text(item.label, style: AppTheme.labelSmall),
              const SizedBox(height: 2),
              Text(item.value, style: AppTheme.h2.copyWith(fontSize: 20)),
            ],
          ),
        );
      },
    );
  }
}
