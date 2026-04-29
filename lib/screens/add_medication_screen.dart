import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TimeOfDay, TextInputAction;
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

import '../models/medication.dart';
import '../providers/medication_provider.dart';
import '../data/stitch_image_urls.dart';
import '../theme/app_theme.dart';
import '../services/ocr_service.dart';
import 'scan_prescription_screen.dart';
import 'screen_components.dart';

class AddMedicationScreen extends StatefulWidget {
  const AddMedicationScreen({super.key, this.onSaved});

  final VoidCallback? onSaved;

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nameController = TextEditingController();
  final _purposeController = TextEditingController();
  final _dosageController = TextEditingController();
  String _dosageUnit = 'mg';
  TimeOfDay _reminderTime = TimeOfDay.now();
  bool _saving = false;
  bool _ocrBusy = false;

  final _picker = ImagePicker();
  final _ocrService = OcrService();

  Future<void> _scanToAdd() async {
    if (_ocrBusy) return;
    debugPrint('[AddMedication] Scan-to-add started');

    setState(() => _ocrBusy = true);
    try {
      final source = kIsWeb ? ImageSource.gallery : ImageSource.camera;
      final image = await _picker.pickImage(source: source);
      if (image == null) {
        debugPrint('[AddMedication] Scan-to-add cancelled');
        return;
      }

      final result = await _ocrService.recognizeMedicationFields(image);
      debugPrint(
        '[AddMedication] OCR parsed: name="${result.name}" dosage="${result.dosageAmount}" unit="${result.dosageUnit}"',
      );

      final parsedName = result.name?.trim();
      final parsedDosage = result.dosageAmount;
      final hasName = parsedName != null && parsedName.isNotEmpty;
      final hasValidDosage = parsedDosage != null && parsedDosage > 0;

      if (!hasName && !hasValidDosage) {
        if (!mounted) return;
        await showCupertinoDialog<void>(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('Could not read fields'),
            content: const Text('We couldn’t extract a medicine name or dosage from the scan.'),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        return;
      }

      setState(() {
        if (hasName) _nameController.text = parsedName;
        if (hasValidDosage) {
          _dosageController.text = _formatDosageAmount(parsedDosage);
        }
        if (result.dosageUnit != null) {
          _dosageUnit = result.dosageUnit!;
        }
      });
    } catch (e, st) {
      debugPrint('[AddMedication] OCR failed: $e');
      debugPrint('$st');
      if (!mounted) return;
      await showCupertinoDialog<void>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Scan Failed'),
          content: Text(e.toString()),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _ocrBusy = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _purposeController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.background,
      child: SafeArea(
        bottom: true,
        child: Column(
          children: [
            const AppTopBar(
              title: 'VitalClarity',
              avatarUrl: StitchImageUrls.addMedicationAvatar,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.containerPadding,
                  AppTheme.containerPadding,
                  AppTheme.containerPadding,
                  AppTheme.containerPadding + MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(child: Text('Add Medication', style: AppTheme.h1)),
                        CupertinoButton(
                          minimumSize: const Size(44, 44),
                          padding: EdgeInsets.zero,
                          onPressed: _ocrBusy ? null : _scanToAdd,
                          child: const Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              CupertinoIcons.camera_fill,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.xs),
                    Text(
                      'Create a reminder manually or scan a prescription label.',
                      style: AppTheme.body.copyWith(color: AppTheme.outline),
                    ),
                    const SizedBox(height: AppTheme.lg),
                    _QuickActionCard(
                      icon: CupertinoIcons.camera_fill,
                      title: 'Scan Prescription',
                      subtitle: 'Use camera OCR for auto-fill.',
                      iconBg: AppTheme.primaryFixed,
                      onTap: () {
                        debugPrint('[AddMedication] Scan Prescription tapped');
                        Navigator.of(context).push(
                          CupertinoPageRoute<void>(
                            builder: (_) => const ScanPrescriptionScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppTheme.stackGap),
                    _QuickActionCard(
                      icon: CupertinoIcons.pencil,
                      title: 'Add Manually',
                      subtitle: 'Enter name, dose and schedule yourself.',
                      iconBg: AppTheme.surfaceContainer,
                      onTap: () => debugPrint('[AddMedication] Add Manually tapped'),
                    ),
                    const SizedBox(height: AppTheme.lg),
                    PrimaryCard(
                      child: Column(
                        children: [
                          _field(
                            label: 'Medicine Name',
                            child: CupertinoTextField(
                              controller: _nameController,
                              placeholder: 'e.g. Amoxicillin',
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(),
                            ),
                          ),
                          const SizedBox(height: AppTheme.md),
                          _field(
                            label: 'Purpose (Optional)',
                            child: CupertinoTextField(
                              controller: _purposeController,
                              placeholder: 'e.g. Helps your cough',
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              decoration: _inputDecoration(),
                            ),
                          ),
                          const SizedBox(height: AppTheme.md),
                          _field(
                            label: 'Dosage Amount',
                            child: Row(
                              children: [
                                Expanded(
                                  child: CupertinoTextField(
                                    controller: _dosageController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    placeholder: '250',
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                    decoration: _inputDecoration(),
                                  ),
                                ),
                                const SizedBox(width: AppTheme.sm),
                                Expanded(
                                  child: Container(
                                    height: 46,
                                    decoration: _inputDecoration(bg: AppTheme.surfaceContainerLow),
                                    child: CupertinoButton(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      onPressed: () {
                                        debugPrint('[AddMedication] Dosage unit picker tapped');
                                        _pickDosageUnit();
                                      },
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            _dosageUnit,
                                            style: AppTheme.body.copyWith(
                                              color: AppTheme.onSurface,
                                              fontSize: 16,
                                            ),
                                          ),
                                          const Icon(
                                            CupertinoIcons.chevron_down,
                                            size: 16,
                                            color: AppTheme.outline,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppTheme.md),
                          _field(
                            label: 'Reminder Time',
                            child: Container(
                              height: 46,
                              decoration: _inputDecoration(),
                              child: CupertinoButton(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                onPressed: () {
                                  debugPrint('[AddMedication] Reminder time picker tapped');
                                  _pickReminderTime();
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatTime(_reminderTime),
                                      style: AppTheme.body.copyWith(
                                        color: AppTheme.onSurface,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const Icon(
                                      CupertinoIcons.clock,
                                      size: 18,
                                      color: AppTheme.outline,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.lg),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _saving ? null : _saveMedication,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33007AFF),
                              offset: Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'Continue',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: AppTheme.onPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.labelSmall.copyWith(color: AppTheme.outline)),
        const SizedBox(height: AppTheme.sm),
        child,
      ],
    );
  }

  BoxDecoration _inputDecoration({Color bg = AppTheme.surface}) {
    return BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: AppTheme.outlineVariant.withValues(alpha: 0.4)),
    );
  }

  Future<void> _pickDosageUnit() async {
    final units = <String>['mg', 'ml', 'tabs', 'drops'];
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 260,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Done'),
              ),
            ),
            Expanded(
              child: CupertinoPicker(
                itemExtent: 36,
                scrollController: FixedExtentScrollController(
                  initialItem: units.indexOf(_dosageUnit),
                ),
                onSelectedItemChanged: (index) {
                  setState(() => _dosageUnit = units[index]);
                },
                children: units.map((e) => Center(child: Text(e))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickReminderTime() async {
    var selected = _reminderTime;
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (_) => Container(
        height: 320,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: CupertinoButton(
                onPressed: () {
                  setState(() => _reminderTime = selected);
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: DateTime(
                  2026,
                  1,
                  1,
                  _reminderTime.hour,
                  _reminderTime.minute,
                ),
                use24hFormat: false,
                onDateTimeChanged: (date) {
                  selected = TimeOfDay(hour: date.hour, minute: date.minute);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveMedication() async {
    debugPrint('[AddMedication] Continue button tapped');
    final name = _nameController.text.trim();
    final dosage = double.tryParse(_dosageController.text.trim());
    if (name.isEmpty || dosage == null || dosage <= 0) {
      await showCupertinoDialog<void>(
        context: context,
        builder: (_) => CupertinoAlertDialog(
          title: const Text('Missing Required Fields'),
          content: const Text('Please enter a valid medicine name and dosage amount.'),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => _saving = true);
    await context.read<MedicationProvider>().addMedication(
          name: name,
          purpose: _purposeController.text,
          dosageAmount: dosage,
          dosageUnit: _dosageUnit,
          reminderMinutes: Medication.timeOfDayToMinutes(_reminderTime),
        );
    if (!mounted) return;
    setState(() => _saving = false);

    // Seamless nav: pop if stacked, otherwise switch to Schedule tab via callback.
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      widget.onSaved?.call();
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour12 = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final suffix = time.hour < 12 ? 'AM' : 'PM';
    return '$hour12:$minute $suffix';
  }

  String _formatDosageAmount(double dosage) {
    final asInt = dosage.toInt();
    if ((dosage - asInt).abs() < 1e-9) return asInt.toString();
    return dosage.toString();
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: PrimaryCard(
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(shape: BoxShape.circle, color: iconBg),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const SizedBox(width: AppTheme.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.h2.copyWith(fontSize: 20)),
                  const SizedBox(height: AppTheme.xs),
                  Text(subtitle, style: AppTheme.body),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: AppTheme.outline),
          ],
        ),
      ),
    );
  }
}
