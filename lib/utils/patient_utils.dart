import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/services/real_data_service.dart';
import 'package:nutriveda_mobile/theme/app_theme.dart';

class PatientUtils {
  // Shared function to show add patient dialog
  static void showAddPatientDialog(BuildContext context, {VoidCallback? onPatientAdded}) {
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
                        // Call the callback to refresh data in parent screen
                        onPatientAdded?.call();
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
                      : const Text('Add Patient'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Shared function to show patient details
  static void showPatientDetails(BuildContext context, Map<String, dynamic> patient) async {
    // Load full patient details
    final patientDetails = await RealDataService.getPatientDetails(patient['id']);
    
    if (patientDetails == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading patient details')),
        );
      }
      return;
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(patientDetails['name'] ?? 'Patient Details'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow('Email', patientDetails['email'] ?? 'N/A'),
                  _buildDetailRow('Phone', patientDetails['phone'] ?? 'N/A'),
                  _buildDetailRow('Date of Birth', patientDetails['dateOfBirth'] != null 
                      ? _formatDate(patientDetails['dateOfBirth']) : 'N/A'),
                  _buildDetailRow('Gender', patientDetails['gender'] ?? 'N/A'),
                  _buildDetailRow('Height', '${patientDetails['height'] ?? 'N/A'} cm'),
                  _buildDetailRow('Weight', '${patientDetails['weight'] ?? 'N/A'} kg'),
                  _buildDetailRow('Activity Level', patientDetails['activityLevel'] ?? 'N/A'),
                  
                  const SizedBox(height: 16),
                  const Text('Medical Information:', 
                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  
                  _buildListDetail('Medical Conditions', patientDetails['medicalConditions'] ?? []),
                  _buildListDetail('Allergies', patientDetails['allergies'] ?? []),
                  _buildListDetail('Dietary Restrictions', patientDetails['dietaryRestrictions'] ?? []),
                  _buildListDetail('Health Goals', patientDetails['healthGoals'] ?? []),
                  
                  const SizedBox(height: 16),
                  _buildDetailRow('Joined Date', _formatDate(patientDetails['joinedDate'])),
                  _buildDetailRow('Diet Charts', '${(patientDetails['dietCharts'] as List).length}'),
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
  }

  // Shared function to create diet plan dialog
  static void showCreateDietPlanDialog(BuildContext context, Map<String, dynamic> patient, {VoidCallback? onDietPlanCreated}) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final caloriesController = TextEditingController(text: '2000');
    final proteinController = TextEditingController(text: '120');
    final carbsController = TextEditingController(text: '250');
    final fatController = TextEditingController(text: '65');
    final fiberController = TextEditingController(text: '25');
    
    DateTime selectedStartDate = DateTime.now();
    DateTime? selectedEndDate;
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
                    if (nameController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter plan name')),
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
                      );

                      if (dietChart != null) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Diet plan "${nameController.text}" created successfully')),
                        );
                        onDietPlanCreated?.call();
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
                      : const Text('Create Plan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper methods
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static Widget _buildDetailRow(String label, String value) {
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

  static Widget _buildListDetail(String label, List<dynamic> items) {
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
          Expanded(
            child: Text(
              items.isEmpty ? 'None' : items.join(', '),
              style: TextStyle(
                color: items.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}