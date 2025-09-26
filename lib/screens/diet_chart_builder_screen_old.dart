import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/theme/app_theme.dart';

class DietChartBuilderScreen extends StatefulWidget {
  const DietChartBuilderScreen({super.key});

  @override
  State<DietChartBuilderScreen> createState() => _DietChartBuilderScreenState();
}

class _DietChartBuilderScreenState extends State<DietChartBuilderScreen> {
  final List<String> _patients = ['John Doe', 'Sarah Wilson', 'Mike Johnson', 'Emily Davis'];
  
  final List<Map<String, dynamic>> _dietCharts = [
    {
      'name': 'Weight Loss Plan - John Doe',
      'patient': 'John Doe',
      'created': '2024-01-15',
      'status': 'Active',
      'meals': 6,
      'calories': '1800 kcal',
    },
    {
      'name': 'Diabetes Management - Sarah Wilson',
      'patient': 'Sarah Wilson',
      'created': '2024-01-12',
      'status': 'Active',
      'meals': 5,
      'calories': '1600 kcal',
    },
    {
      'name': 'Heart Health Diet - Mike Johnson',
      'patient': 'Mike Johnson',
      'created': '2024-01-10',
      'status': 'Draft',
      'meals': 4,
      'calories': '2000 kcal',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text(
              //   'Diet Chart Builder',
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //     color: AppTheme.textColor,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => _showCreateDietChartDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Create New Diet Chart'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
        
        // Diet Charts List
        Expanded(
          child: _dietCharts.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No diet charts created yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _dietCharts.length,
                  itemBuilder: (context, index) {
                    final chart = _dietCharts[index];
                    return _buildDietChartCard(chart);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildDietChartCard(Map<String, dynamic> chart) {
    Color statusColor;
    switch (chart['status']) {
      case 'Active':
        statusColor = AppTheme.saffronColor;
        break;
      case 'Draft':
        statusColor = AppTheme.warmGoldColor;
        break;
      case 'Completed':
        statusColor = AppTheme.softSageColor;
        break;
      default:
        statusColor = AppTheme.lightSageGray;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chart['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Patient: ${chart['patient']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    chart['status'],
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(Icons.restaurant, '${chart['meals']} Meals'),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.local_fire_department, chart['calories']),
                const SizedBox(width: 8),
                _buildInfoChip(Icons.calendar_today, chart['created']),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewDietChart(chart),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _editDietChart(chart),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleChartAction(value, chart),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: ListTile(
                        leading: Icon(Icons.copy),
                        title: Text('Duplicate'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export',
                      child: ListTile(
                        leading: Icon(Icons.download),
                        title: Text('Export'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text('Delete', style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                  child: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 16, color: AppTheme.primaryColor),
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: AppTheme.lightSageGray,
      side: BorderSide.none,
    );
  }

  void _showCreateDietChartDialog(BuildContext context) {
    final chartNameController = TextEditingController();
    String selectedPatient = _patients.first;
    String selectedGoal = 'Weight Loss';
    final caloriesController = TextEditingController(text: '1800');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create New Diet Chart'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: chartNameController,
                      decoration: const InputDecoration(
                        labelText: 'Chart Name',
                        hintText: 'e.g., Weight Loss Plan',
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPatient,
                      decoration: const InputDecoration(labelText: 'Patient'),
                      items: _patients.map((String patient) {
                        return DropdownMenuItem<String>(
                          value: patient,
                          child: Text(patient),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedPatient = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedGoal,
                      decoration: const InputDecoration(labelText: 'Goal'),
                      items: [
                        'Weight Loss',
                        'Weight Gain',
                        'Maintenance',
                        'Diabetes Management',
                        'Heart Health',
                        'Sports Nutrition'
                      ].map((String goal) {
                        return DropdownMenuItem<String>(
                          value: goal,
                          child: Text(goal),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedGoal = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Target Calories',
                        hintText: '1800',
                        suffixText: 'kcal',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (chartNameController.text.isNotEmpty) {
                      setState(() {
                        _dietCharts.add({
                          'name': chartNameController.text,
                          'patient': selectedPatient,
                          'created': '2024-01-20',
                          'status': 'Draft',
                          'meals': 4,
                          'calories': '${caloriesController.text} kcal',
                        });
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Diet chart created successfully')),
                      );
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _viewDietChart(Map<String, dynamic> chart) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(chart['name']),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Patient', chart['patient']),
                _buildDetailRow('Status', chart['status']),
                _buildDetailRow('Total Calories', chart['calories']),
                _buildDetailRow('Number of Meals', '${chart['meals']}'),
                _buildDetailRow('Created Date', chart['created']),
                const SizedBox(height: 16),
                const Text(
                  'Sample Meal Plan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildMealItem('Breakfast', 'Oatmeal with berries (350 kcal)'),
                _buildMealItem('Lunch', 'Grilled chicken salad (450 kcal)'),
                _buildMealItem('Snack', 'Greek yogurt (150 kcal)'),
                _buildMealItem('Dinner', 'Baked salmon with vegetables (500 kcal)'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _editDietChart(chart);
              },
              child: const Text('Edit'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildMealItem(String mealTime, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$mealTime: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }

  void _editDietChart(Map<String, dynamic> chart) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${chart['name']} - Advanced editing coming soon')),
    );
  }

  void _handleChartAction(String action, Map<String, dynamic> chart) {
    switch (action) {
      case 'duplicate':
        setState(() {
          _dietCharts.add({
            ...chart,
            'name': '${chart['name']} (Copy)',
            'created': '2024-01-20',
            'status': 'Draft',
          });
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diet chart duplicated successfully')),
        );
        break;
      case 'export':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export ${chart['name']} - Coming Soon')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(chart);
        break;
    }
  }

  void _showDeleteConfirmation(Map<String, dynamic> chart) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Diet Chart'),
          content: Text('Are you sure you want to delete "${chart['name']}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _dietCharts.remove(chart);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Diet chart deleted successfully')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}