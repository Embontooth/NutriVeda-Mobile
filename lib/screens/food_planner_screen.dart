import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/theme/app_theme.dart';

class FoodPlannerScreen extends StatefulWidget {
  const FoodPlannerScreen({super.key});

  @override
  State<FoodPlannerScreen> createState() => _FoodPlannerScreenState();
}

class _FoodPlannerScreenState extends State<FoodPlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();

  final List<Map<String, dynamic>> _weeklyPlans = [
    {
      'id': '001',
      'name': 'Weight Loss Week 1',
      'patient': 'John Doe',
      'startDate': '2024-01-15',
      'endDate': '2024-01-21',
      'status': 'Active',
      'totalCalories': '12,600 kcal',
    },
    {
      'id': '002',
      'name': 'Diabetes Management Week 2',
      'patient': 'Sarah Wilson',
      'startDate': '2024-01-22',
      'endDate': '2024-01-28',
      'status': 'Planned',
      'totalCalories': '11,200 kcal',
    },
  ];

  final List<Map<String, dynamic>> _dailyMeals = [
    {
      'time': '7:00 AM',
      'meal': 'Breakfast',
      'food': 'Oatmeal with berries and almonds',
      'calories': 350,
      'proteins': '12g',
      'carbs': '45g',
      'fats': '8g',
    },
    {
      'time': '10:00 AM',
      'meal': 'Mid-Morning Snack',
      'food': 'Apple with peanut butter',
      'calories': 200,
      'proteins': '5g',
      'carbs': '25g',
      'fats': '8g',
    },
    {
      'time': '1:00 PM',
      'meal': 'Lunch',
      'food': 'Grilled chicken breast with quinoa salad',
      'calories': 450,
      'proteins': '35g',
      'carbs': '40g',
      'fats': '12g',
    },
    {
      'time': '4:00 PM',
      'meal': 'Afternoon Snack',
      'food': 'Greek yogurt with honey',
      'calories': 150,
      'proteins': '15g',
      'carbs': '18g',
      'fats': '2g',
    },
    {
      'time': '7:30 PM',
      'meal': 'Dinner',
      'food': 'Baked salmon with steamed vegetables',
      'calories': 500,
      'proteins': '40g',
      'carbs': '30g',
      'fats': '20g',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar
        Container(
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppTheme.secondaryColor,
            unselectedLabelColor: AppTheme.textColor.withOpacity(0.6),
            indicatorColor: AppTheme.secondaryColor,
            tabs: const [
              Tab(
                icon: Icon(Icons.calendar_view_week),
                text: 'Weekly Plans',
              ),
              Tab(
                icon: Icon(Icons.today),
                text: 'Daily Planning',
              ),
            ],
          ),
        ),
        
        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildWeeklyPlansTab(),
              _buildDailyPlanningTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyPlansTab() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCreateWeeklyPlanDialog(),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Weekly Plan'),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Template functionality coming soon')),
                  );
                },
                icon: const Icon(Icons.template_add),
                label: const Text('Templates'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: AppTheme.textColor,
                ),
              ),
            ],
          ),
        ),
        
        // Weekly Plans List
        Expanded(
          child: _weeklyPlans.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_view_week,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No weekly plans created yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _weeklyPlans.length,
                  itemBuilder: (context, index) {
                    final plan = _weeklyPlans[index];
                    return _buildWeeklyPlanCard(plan);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildWeeklyPlanCard(Map<String, dynamic> plan) {
    Color statusColor;
    switch (plan['status']) {
      case 'Active':
        statusColor = Colors.green;
        break;
      case 'Planned':
        statusColor = Colors.blue;
        break;
      case 'Completed':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.orange;
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
                        plan['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Patient: ${plan['patient']}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
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
                    plan['status'],
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
                Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${plan['startDate']} - ${plan['endDate']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.local_fire_department, size: 16, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  plan['totalCalories'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _viewWeeklyPlan(plan),
                  icon: const Icon(Icons.visibility),
                  label: const Text('View'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _editWeeklyPlan(plan),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyPlanningTab() {
    return Column(
      children: [
        // Date Selector
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: AppTheme.secondaryColor,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Planning Date',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => _selectDate(context),
                          child: const Text('Change'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Daily Summary
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Card(
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNutritionSummary('Calories', '1,650', Icons.local_fire_department, Colors.orange),
                  _buildNutritionSummary('Proteins', '107g', Icons.fitness_center, Colors.red),
                  _buildNutritionSummary('Carbs', '158g', Icons.grain, Colors.green),
                  _buildNutritionSummary('Fats', '50g', Icons.opacity, Colors.blue),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Meals List
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _dailyMeals.length,
            itemBuilder: (context, index) {
              final meal = _dailyMeals[index];
              return _buildMealCard(meal, index);
            },
          ),
        ),
        
        // Add Meal Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showAddMealDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Meal'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionSummary(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    meal['time'],
                    style: TextStyle(
                      color: AppTheme.secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal['meal'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        meal['food'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleMealAction(value, index),
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
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
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMealNutrition('${meal['calories']} cal', Icons.local_fire_department),
                _buildMealNutrition(meal['proteins'], Icons.fitness_center),
                _buildMealNutrition(meal['carbs'], Icons.grain),
                _buildMealNutrition(meal['fats'], Icons.opacity),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealNutrition(String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showCreateWeeklyPlanDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create Weekly Plan dialog - Coming Soon')),
    );
  }

  void _viewWeeklyPlan(Map<String, dynamic> plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View ${plan['name']} - Coming Soon')),
    );
  }

  void _editWeeklyPlan(Map<String, dynamic> plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${plan['name']} - Coming Soon')),
    );
  }

  void _showAddMealDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Meal dialog - Coming Soon')),
    );
  }

  void _handleMealAction(String action, int index) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit meal - Coming Soon')),
        );
        break;
      case 'delete':
        setState(() {
          _dailyMeals.removeAt(index);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal deleted successfully')),
        );
        break;
    }
  }
}