import 'package:flutter/cupertino.dart';

import '../data/stitch_image_urls.dart';
import '../theme/app_theme.dart';
import 'screen_components.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotificationsEnabled = true;
  bool _criticalAlertsEnabled = true;

  void _handleAddEmergencyContact() {
    debugPrint('[Settings] Add Emergency Contact tapped');
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Coming Soon'),
        content: const Text('Emergency contact creation flow is not wired yet.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const AppTopBar(title: 'VitalClarity', avatarUrl: StitchImageUrls.settingsTopAvatar),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppTheme.containerPadding),
                children: [
                  const Text('Settings', style: AppTheme.h1),
                  const SizedBox(height: AppTheme.xs),
                  const Text('Manage your account and preferences.', style: AppTheme.body),
                  const SizedBox(height: AppTheme.lg),
                  const _ProfileCard(),
                  const SizedBox(height: AppTheme.lg),
                  _PreferenceGroup(
                    pushNotificationsEnabled: _pushNotificationsEnabled,
                    criticalAlertsEnabled: _criticalAlertsEnabled,
                    onPushNotificationsChanged: (value) {
                      debugPrint('[Settings] Push Notifications toggled: $value');
                      setState(() => _pushNotificationsEnabled = value);
                    },
                    onCriticalAlertsChanged: (value) {
                      debugPrint('[Settings] Critical Alerts toggled: $value');
                      setState(() => _criticalAlertsEnabled = value);
                    },
                  ),
                  const SizedBox(height: AppTheme.lg),
                  _EmergencyGroup(onAddEmergencyContact: _handleAddEmergencyContact),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: AppTheme.surfaceContainerHigh, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              StitchImageUrls.settingsProfileAvatar,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(CupertinoIcons.person_fill),
            ),
          ),
          const SizedBox(width: AppTheme.md),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Eleanor Vance', style: AppTheme.h2),
                SizedBox(height: AppTheme.xs),
                Text('Edit Profile Information', style: AppTheme.labelSmall),
              ],
            ),
          ),
          const Icon(CupertinoIcons.chevron_right, color: AppTheme.outline),
        ],
      ),
    );
  }
}

class _PreferenceGroup extends StatelessWidget {
  const _PreferenceGroup({
    required this.pushNotificationsEnabled,
    required this.criticalAlertsEnabled,
    required this.onPushNotificationsChanged,
    required this.onCriticalAlertsChanged,
  });

  final bool pushNotificationsEnabled;
  final bool criticalAlertsEnabled;
  final ValueChanged<bool> onPushNotificationsChanged;
  final ValueChanged<bool> onCriticalAlertsChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PREFERENCES', style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppTheme.sm),
        PrimaryCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SwitchRow(
                title: 'Push Notifications',
                subtitle: 'Daily reminders and updates',
                value: pushNotificationsEnabled,
                onChanged: onPushNotificationsChanged,
              ),
              Container(height: 1, color: AppTheme.surfaceContainerHigh),
              _SwitchRow(
                title: 'Critical Alerts',
                subtitle: 'Bypasses Do Not Disturb',
                subtitleColor: AppTheme.error,
                value: criticalAlertsEnabled,
                onChanged: onCriticalAlertsChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.subtitleColor = AppTheme.outline,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.body.copyWith(color: AppTheme.onSurface)),
                const SizedBox(height: AppTheme.xs),
                Text(subtitle, style: AppTheme.labelSmall.copyWith(color: subtitleColor)),
              ],
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged, activeTrackColor: AppTheme.primary),
        ],
      ),
    );
  }
}

class _EmergencyGroup extends StatelessWidget {
  const _EmergencyGroup({required this.onAddEmergencyContact});

  final VoidCallback onAddEmergencyContact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EMERGENCY CONTACTS', style: AppTheme.labelSmall.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppTheme.sm),
        const _ContactRow(
          name: 'Dr. Robert Chen',
          role: 'Primary Care Physician',
          icon: CupertinoIcons.heart_fill,
          bg: AppTheme.primaryFixed,
        ),
        const SizedBox(height: AppTheme.stackGap),
        const _ContactRow(
          name: 'Martha Jenkins',
          role: 'Daughter (Primary Proxy)',
          icon: CupertinoIcons.person_fill,
          bg: AppTheme.tertiaryFixed,
        ),
        const SizedBox(height: AppTheme.stackGap),
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            debugPrint('[Settings] Emergency CTA pressed');
            onAddEmergencyContact();
          },
          child: SizedBox(
            height: 54,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text(
                  'Add Emergency Contact',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.name,
    required this.role,
    required this.icon,
    required this.bg,
  });

  final String name;
  final String role;
  final IconData icon;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return PrimaryCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
            child: Icon(icon, color: AppTheme.primary),
          ),
          const SizedBox(width: AppTheme.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTheme.labelBold),
                const SizedBox(height: AppTheme.xs),
                Text(role, style: AppTheme.body),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(22),
            ),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => debugPrint('[Settings] Contact call tapped: $name'),
              child: const Icon(CupertinoIcons.phone_fill, color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
