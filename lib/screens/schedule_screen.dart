import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../data/stitch_image_urls.dart';
import '../models/medication.dart';
import '../providers/medication_provider.dart';
import '../theme/app_theme.dart';
import 'screen_components.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(title: 'Schedule', avatarUrl: StitchImageUrls.scheduleAvatar),
            Expanded(
              child: Consumer<MedicationProvider>(
                builder: (context, meds, _) {
                  final today = DateTime.now();
                  final todaysMeds = meds.medicationsForDate(today);
                  final morning = todaysMeds.where((m) => m.reminderMinutes < 12 * 60).toList();
                  final evening = todaysMeds.where((m) => m.reminderMinutes >= 12 * 60).toList();

                  return ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      _DateStrip(today: today),
                      if (todaysMeds.isEmpty)
                        const _EmptyScheduleState()
                      else ...[
                        _TimeBlock(
                          icon: CupertinoIcons.sun_max_fill,
                          title: 'Morning',
                          meds: morning,
                          selectedDate: today,
                        ),
                        _TimeBlock(
                          icon: CupertinoIcons.moon_fill,
                          title: 'Evening',
                          meds: evening,
                          selectedDate: today,
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({required this.today});

  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final base = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(
      5,
      (i) => base.add(Duration(days: i)),
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.containerPadding,
        AppTheme.lg,
        AppTheme.containerPadding,
        AppTheme.lg,
      ),
      child: Row(
        children: List.generate(days.length, (index) {
          final d = days[index];
          final active = d.day == today.day && d.month == today.month && d.year == today.year;
          return Container(
            width: 54,
            height: 72,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: active ? AppTheme.primary : AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              boxShadow: active
                  ? const [
                      BoxShadow(
                        color: Color(0x26000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _weekdayLabel(d.weekday),
                  style: AppTheme.caption.copyWith(
                    color: active ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  d.day.toString(),
                  style: AppTheme.h2.copyWith(
                    color: active ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[weekday - 1];
  }
}

class _TimeBlock extends StatelessWidget {
  const _TimeBlock({
    required this.icon,
    required this.title,
    required this.meds,
    required this.selectedDate,
  });

  final IconData icon;
  final String title;
  final List<Medication> meds;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.containerPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppTheme.sm),
          Row(
            children: [
              Icon(icon, color: AppTheme.onSurfaceVariant),
              const SizedBox(width: AppTheme.sm),
              Text(title, style: AppTheme.h2),
            ],
          ),
          const SizedBox(height: AppTheme.stackGap),
          if (meds.isEmpty)
            Text('No medications in this period.', style: AppTheme.labelSmall),
          ...meds.map((med) => Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.stackGap),
                child: _MedicationRow(data: med, selectedDate: selectedDate),
              )),
        ],
      ),
    );
  }
}

class _MedicationRow extends StatelessWidget {
  const _MedicationRow({required this.data, required this.selectedDate});

  final Medication data;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    final isTaken = data.isTakenOn(selectedDate);
    return PrimaryCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTaken ? AppTheme.secondaryContainer : AppTheme.primaryFixed,
            ),
            child: Icon(
              CupertinoIcons.capsule_fill,
              color: isTaken ? AppTheme.onSecondaryContainer : AppTheme.primary,
            ),
          ),
          const SizedBox(width: AppTheme.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name, style: AppTheme.labelBold),
                const SizedBox(height: 2),
                Text(_subtitle(data), style: AppTheme.body),
              ],
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isTaken ? AppTheme.secondary : CupertinoColors.white,
              border: isTaken ? null : Border.all(color: AppTheme.outlineVariant, width: 2),
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                context.read<MedicationProvider>().toggleTakenForDate(data.id, selectedDate);
              },
              child: isTaken
                  ? const Icon(CupertinoIcons.check_mark, size: 18, color: AppTheme.onSecondary)
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle(Medication m) {
    final hour = m.reminderTime.hourOfPeriod == 0 ? 12 : m.reminderTime.hourOfPeriod;
    final minute = m.reminderTime.minute.toString().padLeft(2, '0');
    final ampm = m.reminderTime.hour < 12 ? 'AM' : 'PM';
    final dosage = m.dosageAmount % 1 == 0
        ? m.dosageAmount.toStringAsFixed(0)
        : m.dosageAmount.toString();
    return '$dosage ${m.dosageUnit} • $hour:$minute $ampm';
  }
}

class _EmptyScheduleState extends StatelessWidget {
  const _EmptyScheduleState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.containerPadding),
      child: PrimaryCard(
        child: Column(
          children: [
            const Icon(CupertinoIcons.calendar_badge_plus, size: 32, color: AppTheme.outline),
            const SizedBox(height: AppTheme.sm),
            Text(
              'No medications added yet',
              style: AppTheme.labelBold.copyWith(color: AppTheme.onSurface),
            ),
            const SizedBox(height: AppTheme.xs),
            const Text(
              'Go to the Add tab and create your first medication reminder.',
              textAlign: TextAlign.center,
              style: AppTheme.body,
            ),
          ],
        ),
      ),
    );
  }
}
