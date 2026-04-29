import 'package:flutter/cupertino.dart';

import '../data/stitch_image_urls.dart';
import '../theme/app_theme.dart';

class ScanPrescriptionScreen extends StatelessWidget {
  const ScanPrescriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              StitchImageUrls.scanPrescriptionFeed,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: CupertinoColors.black),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    CupertinoColors.black.withValues(alpha: .45),
                    CupertinoColors.black.withValues(alpha: .15),
                    CupertinoColors.black.withValues(alpha: .45),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.containerPadding,
                    vertical: AppTheme.md,
                  ),
                  child: Row(
                    children: [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                        onPressed: () {
                          debugPrint('[ScanPrescription] Back tapped');
                          Navigator.of(context).maybePop();
                        },
                        child: const Icon(CupertinoIcons.back, color: AppTheme.onPrimary),
                      ),
                      Spacer(),
                      const Text(
                        'Scan Label',
                        style: TextStyle(
                          color: AppTheme.onPrimary,
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(32, 32),
                        onPressed: () {
                          debugPrint('[ScanPrescription] Info tapped');
                        },
                        child: const Icon(CupertinoIcons.info_circle, color: AppTheme.onPrimary),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.onPrimary, width: 3),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 36),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ghostButton(
                        icon: CupertinoIcons.photo,
                        onPressed: () => debugPrint('[ScanPrescription] Gallery tapped'),
                      ),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => debugPrint('[ScanPrescription] Capture tapped'),
                        child: Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.onPrimary, width: 4),
                            color: AppTheme.onPrimary.withValues(alpha: .08),
                          ),
                          child: const Center(
                            child: Icon(CupertinoIcons.camera_fill, color: AppTheme.onPrimary),
                          ),
                        ),
                      ),
                      _ghostButton(
                        icon: CupertinoIcons.bolt_fill,
                        onPressed: () => debugPrint('[ScanPrescription] Flash tapped'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _ghostButton({required IconData icon, required VoidCallback onPressed}) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.surfaceContainer.withValues(alpha: .25),
        ),
        child: Icon(icon, color: AppTheme.onPrimary),
      ),
    );
  }
}
