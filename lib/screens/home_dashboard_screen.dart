import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show CircularProgressIndicator;
import 'package:provider/provider.dart';

import '../data/stitch_image_urls.dart';
import '../providers/medication_provider.dart';
import '../theme/app_theme.dart';
import 'screen_components.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(title: 'VitalClarity', avatarUrl: StitchImageUrls.homeAvatar),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.containerPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    _DailyProgressCard(),
                    SizedBox(height: AppTheme.md),
                    _DoctorQuickCallCard(),
                    SizedBox(height: AppTheme.lg),
                    _TodayScheduleSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyProgressCard extends StatelessWidget {
  const _DailyProgressCard();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final provider = context.watch<MedicationProvider>();
    final total = provider.medicationsForDate(now).length;
    final taken = provider.takenCountForDate(now);
    final progress = total == 0 ? 0.0 : taken / total;

    return PrimaryCard(
      padding: const EdgeInsets.all(AppTheme.lg),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Progress', style: AppTheme.h2),
                SizedBox(height: AppTheme.xs),
                Text('$taken of $total doses taken', style: AppTheme.body),
              ],
            ),
          ),
          SizedBox(
            width: 72,
            height: 72,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  color: AppTheme.secondary,
                  backgroundColor: AppTheme.surfaceContainerHigh,
                ),
                Text('${(progress * 100).round()}%', style: AppTheme.labelBold),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayScheduleSection extends StatelessWidget {
  const _TodayScheduleSection();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final meds = context.watch<MedicationProvider>().medicationsForDate(now);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Today\'s Schedule', style: AppTheme.h1),
        const SizedBox(height: AppTheme.stackGap),
        if (meds.isEmpty)
          const PrimaryCard(
            child: Text(
              'No medications added yet. Add one from the Add tab.',
              style: AppTheme.body,
            ),
          )
        else
          ...meds.take(2).map((m) {
            final subtitle = _timeSubtitle(m.reminderMinutes, m.dosageAmount, m.dosageUnit);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.stackGap),
              child: _MedicationTile(
                name: m.name,
                subtitle: subtitle,
                complete: m.isTakenOn(now),
              ),
            );
          }),
      ],
    );
  }

  String _timeSubtitle(int minutes, double dosageAmount, String unit) {
    final hour24 = minutes ~/ 60;
    final minute = (minutes % 60).toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final dosage = dosageAmount % 1 == 0 ? dosageAmount.toStringAsFixed(0) : '$dosageAmount';
    return '$hour:$minute $period • $dosage $unit';
  }
}

class _DoctorQuickCallCard extends StatelessWidget {
  const _DoctorQuickCallCard();

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        debugPrint('[HomeDashboard] Doctor quick call tapped');
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.md),
        decoration: BoxDecoration(
          color: AppTheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.primaryFixed, width: 2),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                StitchImageUrls.homeDoctor,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(CupertinoIcons.person_fill),
              ),
            ),
            const SizedBox(width: AppTheme.md),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dr. Sarah Jenkins',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppTheme.onPrimary,
                    ),
                  ),
                  SizedBox(height: AppTheme.xs),
                  Text(
                    'Primary Care Physician',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: AppTheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(CupertinoIcons.phone_fill, color: AppTheme.onPrimary),
          ],
        ),
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({
    required this.name,
    required this.subtitle,
    required this.complete,
  });

  final String name;
  final String subtitle;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: complete ? AppTheme.secondary : CupertinoColors.white,
              border: complete ? null : Border.all(color: AppTheme.outlineVariant, width: 2),
            ),
            child: complete
                ? const Icon(CupertinoIcons.check_mark, color: AppTheme.onSecondary)
                : null,
          ),
          const SizedBox(width: AppTheme.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.h2.copyWith(fontSize: 28 / 1.2)),
                const SizedBox(height: AppTheme.xs),
                Text(
                  subtitle,
                  style: AppTheme.labelBold.copyWith(
                    color: complete ? AppTheme.outline : AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: complete ? AppTheme.surfaceContainer : AppTheme.primaryFixed,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              CupertinoIcons.capsule_fill,
              color: complete ? AppTheme.outline : AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
