import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'providers/medication_provider.dart';
import 'screens/add_medication_screen.dart';
import 'screens/health_hub_screen.dart';
import 'screens/home_dashboard_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/screen_components.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MedicationProvider()..load(),
      child: const CupertinoApp(
        debugShowCheckedModeBanner: false,
        home: MedGuardAppShell(),
      ),
    );
  }
}

class MedGuardAppShell extends StatefulWidget {
  const MedGuardAppShell({super.key});

  @override
  State<MedGuardAppShell> createState() => _MedGuardAppShellState();
}

class _MedGuardAppShellState extends State<MedGuardAppShell> {
  late final CupertinoTabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = CupertinoTabController(initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _goToTab(int index) {
    _tabController.index = index;
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const HomeDashboardScreen(),
      const ScheduleScreen(),
      AddMedicationScreen(
        onSaved: () => _goToTab(1),
      ),
      const HealthHubScreen(),
      const SettingsScreen(),
    ];

    return CupertinoTheme(
      data: const CupertinoThemeData(
        scaffoldBackgroundColor: AppTheme.background,
        primaryColor: AppTheme.primary,
      ),
      child: CupertinoTabScaffold(
        controller: _tabController,
        tabBar: buildAppTabBar(),
        tabBuilder: (context, index) => screens[index],
      ),
    );
  }
}
