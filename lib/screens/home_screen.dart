import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/screens/dashboard_screen.dart';
import 'package:nutriveda_mobile/screens/patient_management_screen.dart';
import 'package:nutriveda_mobile/screens/diet_chart_builder_screen.dart';
import 'package:nutriveda_mobile/screens/food_planner_screen.dart';
import 'package:nutriveda_mobile/screens/firebase_supabase_sync_test_screen.dart';
import 'package:nutriveda_mobile/theme/app_theme.dart';
import 'package:nutriveda_mobile/firebase_config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const PatientManagementScreen(),
    const DietChartBuilderScreen(),
    const FoodPlannerScreen(),
  ];

  final List<String> _screenTitles = [
    'Dashboard',
    'Patient Management',
    'Diet Chart Builder',
    'Food Planner',
  ];

  final List<IconData> _screenIcons = [
    Icons.dashboard,
    Icons.people,
    Icons.restaurant_menu,
    Icons.calendar_today,
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications feature coming soon')),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (String value) async {
              if (value == 'logout') {
                await FirebaseConfig.signOut();
                // The AuthWrapper in main.dart will automatically redirect to login
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profile settings coming soon')),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('Profile'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Sign Out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const FirebaseSupabaseSyncTestScreen(),
            ),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.sync, color: Colors.white),
        tooltip: 'Test Firebase-Supabase Sync',
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.textColor.withOpacity(0.6),
        backgroundColor: AppTheme.surfaceColor,
        items: List.generate(_screenTitles.length, (index) {
          return BottomNavigationBarItem(
            icon: Icon(_screenIcons[index]),
            label: _screenTitles[index],
          );
        }),
      ),
    );
  }
}