import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Welcome Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppTheme.primaryColor,
                        child: Icon(
                          Icons.person,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome, Dr. Smith',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Registered Dietitian',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
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
          
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              _buildStatCard(
                'Total Patients',
                '24',
                Icons.people,
                AppTheme.primaryColor,
              ),
              _buildStatCard(
                'Active Plans',
                '18',
                Icons.assignment,
                AppTheme.secondaryColor,
              ),
              _buildStatCard(
                'Appointments',
                '8',
                Icons.schedule,
                Colors.green,
              ),
              _buildStatCard(
                'Diet Charts',
                '32',
                Icons.restaurant_menu,
                Colors.orange,
              ),
            ],
          ),
          
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
          
          Card(
            child: Column(
              children: [
                _buildActivityItem(
                  'New patient registered',
                  'John Doe joined your practice',
                  Icons.person_add,
                  '2 hours ago',
                ),
                const Divider(height: 1),
                _buildActivityItem(
                  'Diet plan updated',
                  'Updated diet plan for Sarah Wilson',
                  Icons.edit,
                  '4 hours ago',
                ),
                const Divider(height: 1),
                _buildActivityItem(
                  'Appointment scheduled',
                  'Follow-up with Mike Johnson',
                  Icons.schedule,
                  '6 hours ago',
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Quick Actions
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Patient functionality coming soon')),
                    );
                  },
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
          ),
        ],
      ),
    );
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
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
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
        backgroundColor: AppTheme.primaryColor,
        child: Icon(
          icon,
          color: AppTheme.secondaryColor,
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
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
    );
  }
}