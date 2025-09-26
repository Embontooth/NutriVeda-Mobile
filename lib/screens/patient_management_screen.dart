import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/theme/app_theme.dart';
import 'package:nutriveda_mobile/services/real_data_service.dart';
import 'package:nutriveda_mobile/utils/patient_utils.dart';

class PatientManagementScreen extends StatefulWidget {
  const PatientManagementScreen({super.key});

  @override
  State<PatientManagementScreen> createState() => _PatientManagementScreenState();
}

class _PatientManagementScreenState extends State<PatientManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final patients = await RealDataService.getPatientList();
      setState(() {
        _patients = patients;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading patients: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading patients from database')),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredPatients {
    if (_searchQuery.isEmpty) {
      return _patients;
    }
    return _patients.where((patient) {
      return patient['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (patient['email'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Section
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search patients by name or email...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => PatientUtils.showAddPatientDialog(context, onPatientAdded: _loadPatients),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Patient'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _loadPatients,
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Patient List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredPatients.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: AppTheme.textColor.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isNotEmpty 
                                ? 'No patients found matching "$_searchQuery"'
                                : 'No patients yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppTheme.textColor.withOpacity(0.6),
                            ),
                          ),
                          if (_searchQuery.isEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Your patients will appear here when they register',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textColor.withOpacity(0.4),
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPatients,
                      child: ListView.builder(
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];
                          return _buildPatientCard(patient);
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    final activePlans = patient['activePlans'] ?? 0;
    final totalPlans = patient['totalPlans'] ?? 0;
    final weight = patient['weight'];
    final height = patient['height'];
    final joinedDate = patient['joinedDate'] as DateTime?;

    String statusText = 'No Plans';
    Color statusColor = Colors.grey;
    
    if (activePlans > 0) {
      statusText = 'Active ($activePlans)';
      statusColor = Colors.green;
    } else if (totalPlans > 0) {
      statusText = 'Inactive';
      statusColor = Colors.orange;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            patient['name'][0].toUpperCase(),
            style: TextStyle(
              color: AppTheme.backgroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          patient['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (patient['email'] != null) Text(patient['email']),
            if (patient['phone'] != null) Text('📞 ${patient['phone']}'),
            if (weight != null && height != null)
              Text('📏 ${height.toStringAsFixed(1)}cm, ${weight.toStringAsFixed(1)}kg'),
            if (joinedDate != null)
              Text('Joined: ${_formatDate(joinedDate)}'),
            Text('Plans: $totalPlans total'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 4),
            PopupMenuButton<String>(
              onSelected: (value) => _handlePatientAction(value, patient),
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: ListTile(
                    leading: Icon(Icons.visibility),
                    title: Text('View Details'),
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
                  value: 'history',
                  child: ListTile(
                    leading: Icon(Icons.history),
                    title: Text('View History'),
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
        onTap: () => _handlePatientAction('view', patient),
      ),
    );
  }

  void _handlePatientAction(String action, Map<String, dynamic> patient) {
    switch (action) {
      case 'view':
        PatientUtils.showPatientDetails(context, patient);
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Edit ${patient['name']} - Coming Soon')),
        );
        break;
      case 'history':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('View history for ${patient['name']} - Coming Soon')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(patient);
        break;
    }
  }

  void _showPatientDetails(Map<String, dynamic> patient) async {
    // Get detailed patient information
    final patientDetails = await RealDataService.getPatientDetails(patient['id']);
    
    if (patientDetails == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error loading patient details')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${patientDetails['name']} - Details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic Information
                _buildSectionTitle('Basic Information'),
                _buildDetailRow('Email', patientDetails['email'] ?? 'Not provided'),
                _buildDetailRow('Phone', patientDetails['phone'] ?? 'Not provided'),
                _buildDetailRow('Gender', patientDetails['gender'] ?? 'Not specified'),
                if (patientDetails['dateOfBirth'] != null)
                  _buildDetailRow('Date of Birth', _formatDate(patientDetails['dateOfBirth'])),
                
                const SizedBox(height: 16),
                
                // Physical Information
                _buildSectionTitle('Physical Information'),
                if (patientDetails['height'] != null)
                  _buildDetailRow('Height', '${patientDetails['height']} cm'),
                if (patientDetails['weight'] != null)
                  _buildDetailRow('Weight', '${patientDetails['weight']} kg'),
                if (patientDetails['activityLevel'] != null)
                  _buildDetailRow('Activity Level', patientDetails['activityLevel']),
                
                const SizedBox(height: 16),
                
                // Medical Information
                _buildSectionTitle('Medical Information'),
                if (patientDetails['medicalConditions'].isNotEmpty)
                  _buildListRow('Medical Conditions', patientDetails['medicalConditions']),
                if (patientDetails['allergies'].isNotEmpty)
                  _buildListRow('Allergies', patientDetails['allergies']),
                if (patientDetails['dietaryRestrictions'].isNotEmpty)
                  _buildListRow('Dietary Restrictions', patientDetails['dietaryRestrictions']),
                if (patientDetails['healthGoals'].isNotEmpty)
                  _buildListRow('Health Goals', patientDetails['healthGoals']),
                
                const SizedBox(height: 16),
                
                // Diet Plans
                _buildSectionTitle('Diet Plans (${patientDetails['dietCharts'].length})'),
                if (patientDetails['dietCharts'].isNotEmpty) ...[
                  for (var chart in patientDetails['dietCharts'])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text('• ${chart['name']}'),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(chart['status']).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              chart['status'].toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: _getStatusColor(chart['status']),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ] else ...[
                  const Text('No diet plans yet'),
                ],
                
                _buildDetailRow('Joined', _formatDate(patientDetails['joinedDate'])),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                PatientUtils.showCreateDietPlanDialog(context, patientDetails, onDietPlanCreated: _loadPatients);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Diet Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildListRow(String label, List<String> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          for (var item in items)
            Text('• $item'),
        ],
      ),
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

  void _showCreateDietPlanDialog(Map<String, dynamic> patient) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final caloriesController = TextEditingController(text: '2000');
    final proteinController = TextEditingController(text: '120');
    final carbsController = TextEditingController(text: '250');
    final fatController = TextEditingController(text: '65');
    final fiberController = TextEditingController(text: '25');
    final seasonalController = TextEditingController();
    final instructionsController = TextEditingController();
    
    DateTime selectedStartDate = DateTime.now();
    DateTime? selectedEndDate;
    List<String> selectedDoshaFocus = [];
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Create Diet Plan for ${patient['name']}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Plan Name*',
                        hintText: 'e.g., Weight Loss Plan',
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
                    
                    // Start Date
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
                    
                    // End Date
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        selectedEndDate == null 
                            ? 'End Date (Optional)' 
                            : 'End Date: ${_formatDate(selectedEndDate!)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedEndDate ?? selectedStartDate.add(const Duration(days: 30)),
                          firstDate: selectedStartDate,
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        setDialogState(() {
                          selectedEndDate = date;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 12),
                    const Text(
                      'Nutritional Targets:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    
                    // Nutritional Targets
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
                    const SizedBox(height: 12),
                    
                    // Dosha Focus
                    const Text(
                      'Dosha Focus (Ayurvedic):',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      children: ['vata', 'pitta', 'kapha'].map((dosha) {
                        return FilterChip(
                          label: Text(dosha.toUpperCase()),
                          selected: selectedDoshaFocus.contains(dosha),
                          onSelected: (selected) {
                            setDialogState(() {
                              if (selected) {
                                selectedDoshaFocus.add(dosha);
                              } else {
                                selectedDoshaFocus.remove(dosha);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    
                    TextField(
                      controller: seasonalController,
                      decoration: const InputDecoration(
                        labelText: 'Seasonal Considerations',
                        hintText: 'e.g., Winter warming foods',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: instructionsController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Special Instructions',
                        hintText: 'Any specific instructions for the patient',
                      ),
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
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter a plan name')),
                      );
                      return;
                    }

                    setDialogState(() {
                      isSubmitting = true;
                    });

                    try {
                      final dietChart = await RealDataService.createDietChart(
                        patientId: patient['id'],
                        name: nameController.text.trim(),
                        description: descriptionController.text.trim(),
                        startDate: selectedStartDate,
                        endDate: selectedEndDate,
                        targetCalories: double.parse(caloriesController.text),
                        targetProtein: double.parse(proteinController.text),
                        targetCarbs: double.parse(carbsController.text),
                        targetFat: double.parse(fatController.text),
                        targetFiber: double.parse(fiberController.text),
                        doshaFocus: selectedDoshaFocus,
                        seasonalConsiderations: seasonalController.text.trim().isEmpty 
                            ? null : seasonalController.text.trim(),
                        specialInstructions: instructionsController.text.trim().isEmpty 
                            ? null : instructionsController.text.trim(),
                      );

                      if (dietChart != null) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Diet plan "${nameController.text}" created successfully')),
                        );
                        // Refresh the patient list to update plan counts
                        _loadPatients();
                      } else {
                        throw Exception('Failed to create diet plan');
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
                      : const Text('Create Plan'),
                ),
              ],
            );
          },
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

  void _showDeleteConfirmation(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Patient'),
          content: Text('Are you sure you want to delete ${patient['name']}?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _patients.removeWhere((p) => p['id'] == patient['id']);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${patient['name']} deleted successfully')),
                );
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showAddPatientDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final heightController = TextEditingController();
    final weightController = TextEditingController();
    String selectedGender = 'male';
    String selectedActivityLevel = 'moderately_active';
    DateTime? selectedDateOfBirth;
    final medicalConditionsController = TextEditingController();
    final allergiesController = TextEditingController();
    final dietaryRestrictionsController = TextEditingController();
    final healthGoalsController = TextEditingController();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Patient'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Basic Information
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name*',
                        hintText: 'Enter patient full name',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email*',
                        hintText: 'Enter email address',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number*',
                        hintText: 'Enter phone number',
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Date of Birth
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        selectedDateOfBirth == null 
                            ? 'Select Date of Birth*' 
                            : 'DOB: ${_formatDate(selectedDateOfBirth!)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                          firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setDialogState(() {
                            selectedDateOfBirth = date;
                          });
                        }
                      },
                    ),
                    
                    // Gender Selection
                    DropdownButtonFormField<String>(
                      value: selectedGender,
                      decoration: const InputDecoration(labelText: 'Gender*'),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Male')),
                        DropdownMenuItem(value: 'female', child: Text('Female')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedGender = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Physical Information
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: heightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Height (cm)*',
                              hintText: '170',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: weightController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)*',
                              hintText: '70',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Activity Level
                    DropdownButtonFormField<String>(
                      value: selectedActivityLevel,
                      decoration: const InputDecoration(labelText: 'Activity Level*'),
                      items: const [
                        DropdownMenuItem(value: 'sedentary', child: Text('Sedentary')),
                        DropdownMenuItem(value: 'lightly_active', child: Text('Lightly Active')),
                        DropdownMenuItem(value: 'moderately_active', child: Text('Moderately Active')),
                        DropdownMenuItem(value: 'very_active', child: Text('Very Active')),
                        DropdownMenuItem(value: 'extremely_active', child: Text('Extremely Active')),
                      ],
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedActivityLevel = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    
                    // Medical Information
                    TextField(
                      controller: medicalConditionsController,
                      decoration: const InputDecoration(
                        labelText: 'Medical Conditions',
                        hintText: 'Separate multiple conditions with commas',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: allergiesController,
                      decoration: const InputDecoration(
                        labelText: 'Allergies',
                        hintText: 'Separate multiple allergies with commas',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: dietaryRestrictionsController,
                      decoration: const InputDecoration(
                        labelText: 'Dietary Restrictions',
                        hintText: 'e.g., Vegetarian, Gluten-free',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: healthGoalsController,
                      decoration: const InputDecoration(
                        labelText: 'Health Goals',
                        hintText: 'e.g., Weight loss, Muscle gain',
                      ),
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
                    // Validate required fields
                    if (nameController.text.isEmpty ||
                        emailController.text.isEmpty ||
                        phoneController.text.isEmpty ||
                        selectedDateOfBirth == null ||
                        heightController.text.isEmpty ||
                        weightController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill all required fields')),
                      );
                      return;
                    }

                    setDialogState(() {
                      isSubmitting = true;
                    });

                    try {
                      // Parse height and weight
                      final height = double.parse(heightController.text);
                      final weight = double.parse(weightController.text);

                      // Parse lists
                      final medicalConditions = medicalConditionsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                      
                      final allergies = allergiesController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                      
                      final dietaryRestrictions = dietaryRestrictionsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();
                      
                      final healthGoals = healthGoalsController.text
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .toList();

                      // Add patient to database
                      final newPatient = await RealDataService.addPatient(
                        email: emailController.text.trim(),
                        fullName: nameController.text.trim(),
                        phone: phoneController.text.trim(),
                        dateOfBirth: selectedDateOfBirth!,
                        gender: selectedGender,
                        height: height,
                        weight: weight,
                        activityLevel: selectedActivityLevel,
                        medicalConditions: medicalConditions,
                        allergies: allergies,
                        dietaryRestrictions: dietaryRestrictions,
                        healthGoals: healthGoals,
                      );

                      if (newPatient != null) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('${nameController.text} added successfully')),
                        );
                        // Refresh the patient list
                        _loadPatients();
                      } else {
                        throw Exception('Failed to add patient');
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
                  child: isSubmitting 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add Patient'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}