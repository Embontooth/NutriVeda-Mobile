import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/theme/app_theme.dart';
import 'package:nutriveda_mobile/screens/color_palette_screen.dart';
import 'package:nutriveda_mobile/services/real_data_service.dart';
import 'package:nutriveda_mobile/models/database_models.dart';
import 'package:nutriveda_mobile/utils/patient_utils.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Profile? currentUser;
  Map<String, int> stats = {};
  List<Map<String, dynamic>> activities = [];
  List<Map<String, dynamic>> recentPatients = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final user = await RealDataService.getCurrentUserProfile();
      final dashboardStats = await RealDataService.getDashboardStats();
      final recentActivities = await RealDataService.getRecentActivities();
      
      // Load recent patients if user is a dietitian
      List<Map<String, dynamic>> patients = [];
      if (user?.role == 'dietitian') {
        final allPatients = await RealDataService.getPatients();
        // Get the 5 most recent patients
        patients = allPatients.take(5).toList();
      }

      setState(() {
        currentUser = user;
        stats = dashboardStats;
        activities = recentActivities;
        recentPatients = patients;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Card(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.softSageColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${currentUser?.fullName ?? 'User'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textColor,
                                ),
                              ),
                              Text(
                                _getRoleDisplayName(currentUser?.role ?? 'user'),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Statistics Cards
            const Text(
              'Overview',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildStatsGrid(),
            
            const SizedBox(height: 24),
            
            // Recent Activities
            const Text(
              'Recent Activities',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildActivitiesCard(),
            
            const SizedBox(height: 24),
            
            // Recent Patients (only for dietitians)
            if (currentUser?.role == 'dietitian') ...[
              const Text(
                'Recent Patients',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              _buildRecentPatientsCard(),
              
              const SizedBox(height: 24),
            ],
            
            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            _buildQuickActions(),
            
            const SizedBox(height: 12),
            
            // Color Palette Demo Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ColorPaletteScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.palette),
                label: const Text('View Ayurvedic Color Palette'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.saffronColor,
                  side: const BorderSide(color: AppTheme.saffronColor, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    if (currentUser?.role == 'dietitian') {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.2,
        children: [
          _buildStatCard(
            'Total Patients',
            '${stats['totalPatients'] ?? 0}',
            Icons.people,
            AppTheme.primaryColor,
          ),
          _buildStatCard(
            'Active Plans',
            '${stats['activePlans'] ?? 0}',
            Icons.assignment,
            AppTheme.terracottaColor,
          ),
          _buildStatCard(
            'Appointments',
            '${stats['appointments'] ?? 0}',
            Icons.schedule,
            AppTheme.saffronColor,
          ),
          _buildStatCard(
            'Diet Charts',
            '${stats['dietCharts'] ?? 0}',
            Icons.restaurant_menu,
            AppTheme.warmGoldColor,
          ),
        ],
      );
    } else {
      return GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.2,
        children: [
          _buildStatCard(
            'Diet Plans',
            '${stats['dietCharts'] ?? 0}',
            Icons.restaurant_menu,
            AppTheme.primaryColor,
          ),
          _buildStatCard(
            'Active Plans',
            '${stats['activePlans'] ?? 0}',
            Icons.assignment,
            AppTheme.terracottaColor,
          ),
          _buildStatCard(
            'Food Logs',
            '${stats['foodLogs'] ?? 0}',
            Icons.fastfood,
            AppTheme.saffronColor,
          ),
          _buildStatCard(
            'Appointments',
            '${stats['appointments'] ?? 0}',
            Icons.schedule,
            AppTheme.warmGoldColor,
          ),
        ],
      );
    }
  }

  Widget _buildActivitiesCard() {
    if (activities.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 48,
                color: AppTheme.textColor.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No recent activities',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your activities will appear here',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textColor.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: activities
            .map((activity) => _buildActivityItem(
                  activity['title'],
                  activity['subtitle'],
                  _getIconFromString(activity['icon']),
                  activity['time'],
                ))
            .expand((widget) => [widget, const Divider(height: 1)])
            .take(activities.length * 2 - 1)
            .toList(),
      ),
    );
  }

  Widget _buildRecentPatientsCard() {
    if (recentPatients.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.people,
                size: 48,
                color: AppTheme.textColor.withOpacity(0.3),
              ),
              const SizedBox(height: 12),
              Text(
                'No patients yet',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Add your first patient to get started',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textColor.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          ...recentPatients.asMap().entries.map((entry) {
            final index = entry.key;
            final patient = entry.value;
            
            return Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.softSageColor,
                    child: Text(
                      (patient['name'] ?? '?').toString().substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textColor,
                      ),
                    ),
                  ),
                  title: Text(patient['name'] ?? 'Unknown'),
                  subtitle: Text(
                    patient['email'] ?? 'No email',
                    style: TextStyle(
                      color: AppTheme.textColor.withOpacity(0.6),
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          PatientUtils.showPatientDetails(context, patient);
                          break;
                        case 'create_plan':
                          PatientUtils.showCreateDietPlanDialog(
                            context, 
                            patient,
                            onDietPlanCreated: () => _loadDashboardData(),
                          );
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'view',
                        child: Row(
                          children: [
                            Icon(Icons.visibility, size: 20),
                            SizedBox(width: 8),
                            Text('View Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'create_plan',
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text('Create Diet Plan'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < recentPatients.length - 1) const Divider(height: 1),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  
  // Use PatientUtils for dialog functions
  void _showAddPatientDialog(BuildContext context) {
    PatientUtils.showAddPatientDialog(context, onPatientAdded: () {
      _loadDashboardData();
    });
  }
  Widget _buildQuickActions() {
    if (currentUser?.role == 'dietitian') {
      return Row(
        children: [
            Expanded(
            child: ElevatedButton.icon(
              onPressed: () => _showAddPatientDialog(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Add Patient'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create Plan functionality coming soon')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Plan'),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Log Food functionality coming soon')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Log Food'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View Progress functionality coming soon')),
                );
              },
              icon: const Icon(Icons.trending_up),
              label: const Text('View Progress'),
            ),
          ),
        ],
      );
    }
  }

  String _getRoleDisplayName(String role) {
    switch (role.toLowerCase()) {
      case 'dietitian':
        return 'Ayurvedic Nutrition Specialist';
      case 'patient':
        return 'Patient';
      case 'admin':
        return 'Administrator';
      default:
        return 'User';
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'person_add':
        return Icons.person_add;
      case 'edit':
        return Icons.edit;
      case 'restaurant':
        return Icons.restaurant;
      case 'star':
        return Icons.star;
      case 'schedule':
        return Icons.schedule;
      default:
        return Icons.notifications;
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textColor.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, String time) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.lightSageGray,
        child: Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: Text(
        time,
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.textColor.withOpacity(0.6),
        ),
      ),
    );
  }
}