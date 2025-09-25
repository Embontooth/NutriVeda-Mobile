import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/theme/app_theme.dart';

class PatientManagementScreen extends StatefulWidget {
  const PatientManagementScreen({super.key});

  @override
  State<PatientManagementScreen> createState() => _PatientManagementScreenState();
}

class _PatientManagementScreenState extends State<PatientManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Sample patient data
  final List<Map<String, dynamic>> _patients = [
    {
      'id': '001',
      'name': 'John Doe',
      'age': 35,
      'gender': 'Male',
      'lastVisit': '2024-01-15',
      'status': 'Active',
      'condition': 'Weight Management',
    },
    {
      'id': '002',
      'name': 'Sarah Wilson',
      'age': 28,
      'gender': 'Female',
      'lastVisit': '2024-01-12',
      'status': 'Active',
      'condition': 'Diabetes Management',
    },
    {
      'id': '003',
      'name': 'Mike Johnson',
      'age': 42,
      'gender': 'Male',
      'lastVisit': '2024-01-10',
      'status': 'Follow-up',
      'condition': 'Hypertension Diet',
    },
    {
      'id': '004',
      'name': 'Emily Davis',
      'age': 31,
      'gender': 'Female',
      'lastVisit': '2024-01-08',
      'status': 'Active',
      'condition': 'Sports Nutrition',
    },
    {
      'id': '005',
      'name': 'Robert Brown',
      'age': 55,
      'gender': 'Male',
      'lastVisit': '2024-01-05',
      'status': 'Inactive',
      'condition': 'Heart Health',
    },
  ];

  List<Map<String, dynamic>> get _filteredPatients {
    if (_searchQuery.isEmpty) {
      return _patients;
    }
    return _patients.where((patient) {
      return patient['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          patient['condition'].toLowerCase().contains(_searchQuery.toLowerCase());
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
                  hintText: 'Search patients...',
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
                      onPressed: () => _showAddPatientDialog(context),
                      icon: const Icon(Icons.person_add),
                      label: const Text('Add Patient'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Filter functionality coming soon')),
                      );
                    },
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    label: const Text('Filter'),
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
          child: _filteredPatients.isEmpty
              ? const Center(
                  child: Text(
                    'No patients found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = _filteredPatients[index];
                    return _buildPatientCard(patient);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    Color statusColor;
    switch (patient['status']) {
      case 'Active':
        statusColor = Colors.green;
        break;
      case 'Follow-up':
        statusColor = Colors.orange;
        break;
      case 'Inactive':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = Colors.blue;
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
            Text('${patient['age']} years, ${patient['gender']}'),
            Text('Condition: ${patient['condition']}'),
            Text('Last Visit: ${patient['lastVisit']}'),
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
                patient['status'],
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
        _showPatientDetails(patient);
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

  void _showPatientDetails(Map<String, dynamic> patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('${patient['name']} - Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('Patient ID', patient['id']),
              _buildDetailRow('Age', '${patient['age']} years'),
              _buildDetailRow('Gender', patient['gender']),
              _buildDetailRow('Condition', patient['condition']),
              _buildDetailRow('Status', patient['status']),
              _buildDetailRow('Last Visit', patient['lastVisit']),
            ],
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
    final ageController = TextEditingController();
    String selectedGender = 'Male';
    final conditionController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add New Patient'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'Enter patient name',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      hintText: 'Enter age',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    decoration: const InputDecoration(labelText: 'Gender'),
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedGender = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: conditionController,
                    decoration: const InputDecoration(
                      labelText: 'Condition/Focus Area',
                      hintText: 'e.g., Weight Management',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        ageController.text.isNotEmpty &&
                        conditionController.text.isNotEmpty) {
                      setState(() {
                        _patients.add({
                          'id': '00${_patients.length + 1}',
                          'name': nameController.text,
                          'age': int.parse(ageController.text),
                          'gender': selectedGender,
                          'lastVisit': '2024-01-20',
                          'status': 'Active',
                          'condition': conditionController.text,
                        });
                      });
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${nameController.text} added successfully')),
                      );
                    }
                  },
                  child: const Text('Add Patient'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}