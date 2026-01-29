import 'package:flutter/material.dart';
import 'services/hive_service.dart';
import 'screens/home_screen.dart';
import 'screens/plan_screen.dart';
import 'screens/timer_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/add_goal_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Study Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF135BEC),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF6F6F8),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF135BEC),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101622),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PlanScreen(),
    StatsScreen(),
    StatsScreen(), // Placeholder for Profile screen
  ];

  final List<String> _titles = const [
    'Study Tracker',
    'Calendar',
    'Timer',
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
            ? const Color(0xFF101622).withOpacity(0.8)
            : const Color(0xFFF6F6F8).withOpacity(0.8),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (_currentIndex == 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF135BEC),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF135BEC).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  color: Colors.white,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddGoalScreen(),
                      ),
                    ).then((_) => setState(() {}));
                  },
                ),
              ),
            ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark
                  ? const Color(0xFF374151)
                  : const Color(0xFFE5E7EB),
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
              ? const Color(0xFF1F2937).withOpacity(0.8)
              : Colors.white.withOpacity(0.8),
          selectedItemColor: const Color(0xFF135BEC),
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
              label: 'Stats',
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
