import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/screens/dashboard_screen.dart';
import 'package:nutriveda_mobile/screens/patient_management_screen.dart';
import 'package:nutriveda_mobile/screens/diet_chart_builder_screen.dart';
import 'package:nutriveda_mobile/screens/food_planner_screen.dart';
import 'package:nutriveda_mobile/theme/app_theme.dart';

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
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile settings coming soon')),
              );
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppTheme.secondaryColor,
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