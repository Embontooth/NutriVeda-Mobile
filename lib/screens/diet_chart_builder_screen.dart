import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/theme/app_theme.dart';
import 'package:nutriveda_mobile/services/real_data_service.dart';

class DietChartBuilderScreen extends StatefulWidget {
  const DietChartBuilderScreen({super.key});

  @override
  State<DietChartBuilderScreen> createState() => _DietChartBuilderScreenState();
}

class _DietChartBuilderScreenState extends State<DietChartBuilderScreen> {
  List<Map<String, dynamic>> _dietCharts = [];
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dietCharts = await RealDataService.getDietCharts();
      final patients = await RealDataService.getPatientList();
      
      setState(() {
        _dietCharts = dietCharts;
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading diet charts')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredDietCharts {
    if (_selectedFilter == 'all') {
      return _dietCharts;
    }
    return _dietCharts.where((chart) => chart['status'] == _selectedFilter).toList();
  }

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Text(
              //   'Diet Chart Builder',
              //   style: TextStyle(
              //     fontSize: 24,
              //     fontWeight: FontWeight.bold,
              //     color: Colors.white,
              //   ),
              // ),
              const SizedBox(height: 8),
              Text(
                'Create and manage personalized diet plans',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Expanded(
                  //   child: ElevatedButton.icon(
                  //     icon: const Icon(Icons.add, color:Colors.white),
                  //     label: const Text(
                  //       'New Diet Chart',
                  //       style: TextStyle(color: Colors.white),
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor: Colors.white.withValues(alpha: 0.2),
                  //       foregroundColor: Colors.white,
                  //     ),
                  //   ),
                  // ),
                    Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: _patients.isEmpty ? null : () => _showCreateDietChartDialog(),
                      label: const Text(
                      'New Diet Chart',
                      style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                      backgroundColor: _patients.isEmpty 
                        ? Colors.grey.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                      disabledForegroundColor: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Filter Chips
        Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', 'all', _dietCharts.length),
                _buildFilterChip('Active', 'active', 
                    _dietCharts.where((c) => c['status'] == 'active').length),
                _buildFilterChip('Draft', 'draft', 
                    _dietCharts.where((c) => c['status'] == 'draft').length),
                _buildFilterChip('Completed', 'completed', 
                    _dietCharts.where((c) => c['status'] == 'completed').length),
              ],
            ),
          ),
        ),

        // Diet Charts List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredDietCharts.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredDietCharts.length,
                        itemBuilder: (context, index) {
                          final chart = _filteredDietCharts[index];
                          return _buildDietChartCard(chart);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value, int count) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        backgroundColor: Colors.grey[200],
        selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
        checkmarkColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: AppTheme.textColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'all'
                ? 'No diet charts yet'
                : 'No ${_selectedFilter} diet charts',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.textColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _patients.isEmpty
                ? 'Add patients first to create diet charts'
                : 'Create your first diet chart to get started',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textColor.withValues(alpha: 0.4),
            ),
          ),
          if (_patients.isNotEmpty) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showCreateDietChartDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Create Diet Chart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDietChartCard(Map<String, dynamic> chart) {
    final status = chart['status'] as String;
    final statusColor = _getStatusColor(status);
    final targetCalories = chart['targetCalories']?.toStringAsFixed(0) ?? '0';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
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
                          color: AppTheme.textColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            if (chart['description'] != null && chart['description'].isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                chart['description'],
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textColor.withValues(alpha: 0.6),
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Nutritional Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildNutritionInfo('Calories', '${targetCalories} kcal', Icons.local_fire_department),
                  const SizedBox(width: 16),
                  _buildNutritionInfo('Protein', '${chart['targetProtein']?.toStringAsFixed(0) ?? '0'}g', Icons.fitness_center),
                  const Spacer(),
                  Text(
                    'Started: ${_formatDate(chart['startDate'])}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textColor.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewDietChartDetails(chart),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addMealPlans(chart),
                    icon: const Icon(Icons.restaurant_menu, size: 18),
                    label: const Text('Add Meals'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleChartAction(value, chart),
                  itemBuilder: (context) => [
                    if (status == 'draft')
                      const PopupMenuItem(
                        value: 'activate',
                        child: ListTile(
                          leading: Icon(Icons.play_arrow, color: Colors.green),
                          title: Text('Activate'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    if (status == 'active')
                      const PopupMenuItem(
                        value: 'complete',
                        child: ListTile(
                          leading: Icon(Icons.check, color: Colors.blue),
                          title: Text('Mark Complete'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: ListTile(
                        leading: Icon(Icons.copy),
                        title: Text('Duplicate'),
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

  Widget _buildNutritionInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.primaryColor),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showCreateDietChartDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final caloriesController = TextEditingController(text: '2000');
    final proteinController = TextEditingController(text: '120');
    final carbsController = TextEditingController(text: '250');
    final fatController = TextEditingController(text: '65');
    final fiberController = TextEditingController(text: '25');
    
    String? selectedPatientId;
    DateTime selectedStartDate = DateTime.now();
    DateTime? selectedEndDate;
    bool isSubmitting = false;

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
                    // Patient Selection
                    DropdownButtonFormField<String>(
                      value: selectedPatientId,
                      decoration: const InputDecoration(labelText: 'Select Patient*'),
                      items: _patients.map((patient) {
                        return DropdownMenuItem<String>(
                          value: patient['id'],
                          child: Text(patient['name']),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedPatientId = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Plan Name*',
                        hintText: 'e.g., Weight Management Plan',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descriptionController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Brief description of the plan',
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Date Selection
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('Start Date: ${_formatDate(selectedStartDate)}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedStartDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedStartDate = date;
                          });
                        }
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    const Text(
                      'Nutritional Targets:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: caloriesController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Calories',
                              suffix: Text('kcal'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: proteinController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Protein',
                              suffix: Text('g'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: carbsController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Carbs',
                              suffix: Text('g'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: fatController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Fat',
                              suffix: Text('g'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: fiberController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Fiber',
                              suffix: Text('g'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSubmitting ? null : () async {
                    if (selectedPatientId == null || nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select patient and enter plan name')),
                      );
                      return;
                    }

                    setDialogState(() {
                      isSubmitting = true;
                    });

                    try {
                      final dietChart = await RealDataService.createDietChart(
                        patientId: selectedPatientId!,
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        startDate: selectedStartDate,
                        endDate: selectedEndDate,
                        targetCalories: double.parse(caloriesController.text),
                        targetProtein: double.parse(proteinController.text),
                        targetCarbs: double.parse(carbsController.text),
                        targetFat: double.parse(fatController.text),
                        targetFiber: double.parse(fiberController.text),
                      );

                      if (dietChart != null) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Diet chart "${nameController.text}" created successfully')),
                        );
                        _loadData();
                      } else {
                        throw Exception('Failed to create diet chart');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    } finally {
                      setDialogState(() {
                        isSubmitting = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: isSubmitting 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create Chart'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _viewDietChartDetails(Map<String, dynamic> chart) {
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
                _buildDetailRow('Status', chart['status'].toUpperCase()),
                _buildDetailRow('Start Date', _formatDate(chart['startDate'])),
                if (chart['endDate'] != null)
                  _buildDetailRow('End Date', _formatDate(chart['endDate'])),
                if (chart['description'].isNotEmpty)
                  _buildDetailRow('Description', chart['description']),
                
                const SizedBox(height: 16),
                const Text(
                  'Nutritional Targets:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildDetailRow('Calories', '${chart['targetCalories']?.toStringAsFixed(0)} kcal'),
                _buildDetailRow('Protein', '${chart['targetProtein']?.toStringAsFixed(0)}g'),
                _buildDetailRow('Carbohydrates', '${chart['targetCarbs']?.toStringAsFixed(0)}g'),
                _buildDetailRow('Fat', '${chart['targetFat']?.toStringAsFixed(0)}g'),
                _buildDetailRow('Fiber', '${chart['targetFiber']?.toStringAsFixed(0)}g'),
                
                if (chart['doshaFocus'].isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Dosha Focus', chart['doshaFocus'].join(', ')),
                ],
                
                if (chart['seasonalConsiderations'] != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Seasonal Considerations', chart['seasonalConsiderations']),
                ],
                
                if (chart['specialInstructions'] != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow('Special Instructions', chart['specialInstructions']),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _addMealPlans(Map<String, dynamic> chart) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MealPlannerScreen(
          dietChart: chart,
          onMealPlansUpdated: () {
            _loadData(); // Refresh the list when meal plans are updated
          },
        ),
      ),
    );
  }

  void _handleChartAction(String action, Map<String, dynamic> chart) async {
    switch (action) {
      case 'activate':
        final success = await RealDataService.updateDietChartStatus(chart['id'], 'active');
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${chart['name']} activated successfully')),
          );
          _loadData();
        }
        break;
      case 'complete':
        final success = await RealDataService.updateDietChartStatus(chart['id'], 'completed');
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${chart['name']} marked as complete')),
          );
          _loadData();
        }
        break;
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Duplicate "${chart['name']}" - Coming Soon')),
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
          content: Text('Are you sure you want to delete "${chart['name']}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final success = await RealDataService.deleteDietChart(chart['id']);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${chart['name']} deleted successfully')),
                  );
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error deleting diet chart')),
                  );
                }
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Meal Planner Screen for adding meal plans to diet charts
class MealPlannerScreen extends StatefulWidget {
  final Map<String, dynamic> dietChart;
  final VoidCallback onMealPlansUpdated;

  const MealPlannerScreen({
    super.key,
    required this.dietChart,
    required this.onMealPlansUpdated,
  });

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  List<Map<String, dynamic>> _mealPlans = [];
  List<Map<String, dynamic>> _foodItems = [];
  bool _isLoading = true;
  
  final List<String> _weekDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final [mealPlans, foodItems] = await Future.wait([
        RealDataService.getMealPlans(widget.dietChart['id']),
        RealDataService.searchFoodItems(),
      ]);
      
      setState(() {
        _mealPlans = mealPlans;
        _foodItems = foodItems;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Plans - ${widget.dietChart['name']}'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showAddMealPlanDialog(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildMealPlansList(),
    );
  }

  Widget _buildMealPlansList() {
    if (_mealPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No meal plans created yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add meal plans for each day of the week',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddMealPlanDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Add Meal Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Group meal plans by day of week
    Map<int, List<Map<String, dynamic>>> weeklyPlans = {};
    for (var plan in _mealPlans) {
      final day = plan['dayOfWeek'] as int;
      weeklyPlans.putIfAbsent(day, () => []).add(plan);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 7,
      itemBuilder: (context, index) {
        final dayPlans = weeklyPlans[index] ?? [];
        final dayName = _weekDays[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(dayName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text('${dayPlans.length} meal plans'),
            trailing: IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => _showAddMealPlanDialog(dayOfWeek: index),
            ),
            children: [
              if (dayPlans.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No meal plans for this day', style: TextStyle(color: Colors.grey)),
                )
              else
                ...dayPlans.map((plan) => _buildMealPlanTile(plan)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealPlanTile(Map<String, dynamic> plan) {
    final items = plan['items'] as List? ?? [];
    return ListTile(
      leading: Icon(
        _getMealIcon(plan['mealType']),
        color: AppTheme.primaryColor,
      ),
      title: Text(plan['mealType'] ?? 'Unknown Meal'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Time: ${plan['mealTime'] ?? 'Not specified'}'),
          const SizedBox(height: 4),
          Text('Items: ${items.map((item) => item['name'] ?? 'Unknown').join(', ')}'),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleMealPlanAction(value, plan),
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'add_food',
            child: ListTile(
              leading: Icon(Icons.add),
              title: Text('Add Food'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
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
      onTap: () => _showMealPlanDetails(plan),
    );
  }

  IconData _getMealIcon(String? mealType) {
    switch (mealType?.toLowerCase()) {
      case 'breakfast':
        return Icons.free_breakfast;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      case 'evening':
        return Icons.local_cafe;
      default:
        return Icons.restaurant;
    }
  }

  void _showAddMealPlanDialog({int? dayOfWeek}) {
    showDialog(
      context: context,
      builder: (context) => AddMealPlanDialog(
        dietChartId: widget.dietChart['id'],
        initialDayOfWeek: dayOfWeek,
        onMealPlanAdded: () {
          _loadData();
          widget.onMealPlansUpdated();
        },
      ),
    );
  }

  void _handleMealPlanAction(String action, Map<String, dynamic> plan) {
    switch (action) {
      case 'add_food':
        _showAddFoodDialog(plan);
        break;
      case 'edit':
        _showEditMealPlanDialog(plan);
        break;
      case 'delete':
        _showDeleteConfirmation(plan);
        break;
    }
  }

  void _showAddFoodDialog(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AddFoodItemDialog(
        mealPlanId: plan['id'],
        foodItems: _foodItems,
        onFoodAdded: () {
          _loadData();
          widget.onMealPlansUpdated();
        },
      ),
    );
  }

  void _showEditMealPlanDialog(Map<String, dynamic> plan) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit meal plan - Coming Soon')),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Meal Plan'),
        content: Text('Are you sure you want to delete this ${plan['mealType']} plan?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete meal plan
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete functionality - Coming Soon')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMealPlanDetails(Map<String, dynamic> plan) {
    final items = plan['items'] as List? ?? [];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${plan['mealType']} - ${_weekDays[plan['dayOfWeek']]}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Time: ${plan['mealTime'] ?? 'Not specified'}', 
                   style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),
              const Text('Food Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (items.isEmpty)
                const Text('No food items added yet', style: TextStyle(color: Colors.grey))
              else
                ...items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Text('Quantity: ${item['quantity'] ?? 'Not specified'}', style: const TextStyle(fontSize: 12)),
                      if (item['preparationMethod'] != null)
                        Text('Preparation: ${item['preparationMethod']}', style: const TextStyle(fontSize: 12)),
                      if (item['notes'] != null)
                        Text('Notes: ${item['notes']}', style: const TextStyle(fontSize: 12)),
                      Text('Calories: ${((item['calories'] ?? 0) * (item['quantity'] ?? 1)).toStringAsFixed(1)}', 
                           style: TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
                    ],
                  ),
                )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Dialog for adding new meal plans
class AddMealPlanDialog extends StatefulWidget {
  final String dietChartId;
  final int? initialDayOfWeek;
  final VoidCallback onMealPlanAdded;

  const AddMealPlanDialog({
    super.key,
    required this.dietChartId,
    this.initialDayOfWeek,
    required this.onMealPlanAdded,
  });

  @override
  State<AddMealPlanDialog> createState() => _AddMealPlanDialogState();
}

class _AddMealPlanDialogState extends State<AddMealPlanDialog> {
  final List<String> _weekDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final List<String> _mealTypes = ['Breakfast', 'Mid-Morning', 'Lunch', 'Evening', 'Dinner'];
  
  late int _selectedDayOfWeek;
  String _selectedMealType = 'Breakfast';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedDayOfWeek = widget.initialDayOfWeek ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Meal Plan'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Day of Week
          DropdownButtonFormField<int>(
            value: _selectedDayOfWeek,
            decoration: const InputDecoration(labelText: 'Day of Week'),
            items: _weekDays.asMap().entries.map((entry) {
              return DropdownMenuItem<int>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedDayOfWeek = value);
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Meal Type
          DropdownButtonFormField<String>(
            value: _selectedMealType,
            decoration: const InputDecoration(labelText: 'Meal Type'),
            items: _mealTypes.map((type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedMealType = value);
              }
            },
          ),
          const SizedBox(height: 16),
          
          // Time
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Time: ${_selectedTime.format(context)}'),
            trailing: const Icon(Icons.access_time),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (time != null) {
                setState(() => _selectedTime = time);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _addMealPlan,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Plan'),
        ),
      ],
    );
  }

  Future<void> _addMealPlan() async {
    setState(() => _isSubmitting = true);
    
    try {
      final mealTime = '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}';
      
      final result = await RealDataService.addMealPlan(
        dietChartId: widget.dietChartId,
        dayOfWeek: _selectedDayOfWeek,
        mealType: _selectedMealType,
        mealTime: mealTime,
      );
      
      if (result != null) {
        Navigator.pop(context);
        widget.onMealPlanAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedMealType} plan added for ${_weekDays[_selectedDayOfWeek]}')),
        );
      } else {
        throw Exception('Failed to add meal plan');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}

// Dialog for adding food items to meal plans
class AddFoodItemDialog extends StatefulWidget {
  final String mealPlanId;
  final List<Map<String, dynamic>> foodItems;
  final VoidCallback onFoodAdded;

  const AddFoodItemDialog({
    super.key,
    required this.mealPlanId,
    required this.foodItems,
    required this.onFoodAdded,
  });

  @override
  State<AddFoodItemDialog> createState() => _AddFoodItemDialogState();
}

class _AddFoodItemDialogState extends State<AddFoodItemDialog> {
  Map<String, dynamic>? _selectedFoodItem;
  final _quantityController = TextEditingController(text: '1.0');
  final _preparationController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  
  List<Map<String, dynamic>> _filteredFoodItems = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredFoodItems = widget.foodItems;
    _searchController.addListener(_filterFoodItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _quantityController.dispose();
    _preparationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _filterFoodItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFoodItems = widget.foodItems.where((item) {
        final name = (item['name'] as String? ?? '').toLowerCase();
        final category = (item['category'] as String? ?? '').toLowerCase();
        return name.contains(query) || category.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Food Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search food items
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Food Items',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            
            // Food item selection
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: _filteredFoodItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredFoodItems[index];
                  final isSelected = _selectedFoodItem?['id'] == item['id'];
                  
                  return ListTile(
                    title: Text(item['name'] ?? 'Unknown'),
                    subtitle: Text('${item['category']} - ${item['calories']} cal/100g'),
                    selected: isSelected,
                    onTap: () {
                      setState(() => _selectedFoodItem = item);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            
            // Quantity
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Quantity (portions)',
                helperText: 'Nutritional values are per 100g',
              ),
            ),
            const SizedBox(height: 16),
            
            // Preparation method
            TextField(
              controller: _preparationController,
              decoration: const InputDecoration(
                labelText: 'Preparation Method (Optional)',
                hintText: 'e.g., Boiled, Grilled, Raw',
              ),
            ),
            const SizedBox(height: 16),
            
            // Notes
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Any additional instructions',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting || _selectedFoodItem == null ? null : _addFoodItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add Food'),
        ),
      ],
    );
  }

  Future<void> _addFoodItem() async {
    setState(() => _isSubmitting = true);
    
    try {
      final quantity = double.tryParse(_quantityController.text) ?? 1.0;
      
      final success = await RealDataService.addMealItem(
        mealPlanId: widget.mealPlanId,
        foodItemId: _selectedFoodItem!['id'],
        quantity: quantity,
        preparationMethod: _preparationController.text.trim().isEmpty ? null : _preparationController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      
      if (success) {
        Navigator.pop(context);
        widget.onFoodAdded();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_selectedFoodItem!['name']} added to meal plan')),
        );
      } else {
        throw Exception('Failed to add food item');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }
}