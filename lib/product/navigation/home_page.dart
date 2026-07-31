import 'package:flutter/material.dart';
import '../../main.dart';
import '../../services/notification_service.dart';
import '../../services/settings_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme_extension.dart';
import '../../utils/l10n_extension.dart';
import '../screens/home_screen.dart';
import '../screens/plan_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/profile_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final _homeScreenKey = GlobalKey<HomeScreenState>();
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    NotificationService.requestPermission();
    _screens = [
      HomeScreen(key: _homeScreenKey),
      const PlanScreen(),
      DashboardScreen(),
      ProfileScreen(onThemeChanged: _onThemeChanged),
    ];
  }

  void _onThemeChanged() {
    themeModeNotifier.value = SettingsService.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logo.png',
          width: 32,
          height: 32,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: context.colors.background.withValues(alpha: 0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: context.colors.border,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            if (index == 0) {
              _homeScreenKey.currentState?.refresh();
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: context.colors.card.withValues(alpha: 0.8),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: context.colors.textSecondary,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home),
              label: context.l10n.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calendar_today),
              label: context.l10n.navCalendar,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart),
              label: context.l10n.navDeadlines,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person),
              label: context.l10n.navProfile,
            ),
          ],
        ),
      ),
    );
  }
}
