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
                  child: OutlinedButton.icon(
                    onPressed: status == 'draft' 
                        ? () => _editDietChart(chart) 
                        : null,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
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

  void _editDietChart(Map<String, dynamic> chart) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit "${chart['name']}" - Coming Soon')),
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