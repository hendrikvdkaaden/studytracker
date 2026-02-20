import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../screens/home_screen.dart';
import '../screens/plan_screen.dart';
import '../screens/dashboard_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    NotificationService.requestPermission();
  }

  final List<Widget> _screens = [
    const HomeScreen(),
    const PlanScreen(),
    DashboardScreen(),
    DashboardScreen(), // Placeholder for Profile screen
  ];

  final List<String> _titles = const [
    'Daily Tasks',
    'Calendar',
    'Dashboard',
    'Stats',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.darkBackground.withOpacity(0.8)
            : AppColors.lightBackground.withOpacity(0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: AppColors.getBorderColor(context),
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
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark
              ? AppColors.darkCard.withOpacity(0.8)
              : AppColors.lightCard.withOpacity(0.8),
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Goals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
