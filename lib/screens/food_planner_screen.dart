import 'package:flutter/material.dart';
import '../services/real_data_service.dart';
import '../theme/app_theme.dart';

class FoodPlannerScreen extends StatefulWidget {
  const FoodPlannerScreen({super.key});

  @override
  State<FoodPlannerScreen> createState() => _FoodPlannerScreenState();
}

class _FoodPlannerScreenState extends State<FoodPlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> patients = [];
  Map<String, dynamic>? selectedPatient;
  List<Map<String, dynamic>> dietCharts = [];
  Map<String, dynamic>? selectedDietChart;
  List<Map<String, dynamic>> mealPlans = [];
  List<Map<String, dynamic>> todayIntakeLogs = [];
  List<Map<String, dynamic>> searchResults = [];
  
  bool isLoadingPatients = true;
  bool isLoadingDietCharts = false;
  bool isLoadingMealPlans = false;
  bool isLoadingIntake = false;
  bool isSearching = false;
  
  String selectedMealType = 'Breakfast';
  final TextEditingController searchController = TextEditingController();
  final List<String> mealTypes = ['Breakfast', 'Mid-Morning', 'Lunch', 'Evening', 'Dinner'];
  final List<String> weekDays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _loadPatients();
  }

  Future<void> _loadPatients() async {
    setState(() => isLoadingPatients = true);
    try {
      final loadedPatients = await RealDataService.getPatients();
      setState(() {
        patients = loadedPatients;
        if (patients.isNotEmpty && selectedPatient == null) {
          selectedPatient = patients.first;
          _loadDietChartsForPatient();
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load patients: $e');
    } finally {
      setState(() => isLoadingPatients = false);
    }
  }

  Future<void> _loadDietChartsForPatient() async {
    if (selectedPatient == null) return;
    
    setState(() => isLoadingDietCharts = true);
    try {
      final charts = await RealDataService.getDietCharts(patientId: selectedPatient!['id']);
      setState(() {
        dietCharts = charts.where((chart) => chart['status'] == 'active').toList();
        if (dietCharts.isNotEmpty && selectedDietChart == null) {
          selectedDietChart = dietCharts.first;
          _loadMealPlansForDietChart();
          _loadTodayIntakeLog();
        } else if (dietCharts.isEmpty) {
          mealPlans = [];
          todayIntakeLogs = [];
        }
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load diet charts: $e');
    } finally {
      setState(() => isLoadingDietCharts = false);
    }
  }

  Future<void> _loadMealPlansForDietChart() async {
    if (selectedDietChart == null) return;
    
    setState(() => isLoadingMealPlans = true);
    try {
      final plans = await RealDataService.getMealPlans(selectedDietChart!['id']);
      setState(() => mealPlans = plans);
    } catch (e) {
      _showErrorSnackBar('Failed to load meal plans: $e');
    } finally {
      setState(() => isLoadingMealPlans = false);
    }
  }

  Future<void> _loadTodayIntakeLog() async {
    if (selectedPatient == null) return;
    
    setState(() => isLoadingIntake = true);
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(Duration(days: 1));
      
      final logs = await RealDataService.getFoodIntakeLogs(
        patientId: selectedPatient!['id'],
        startDate: startOfDay,
        endDate: endOfDay,
      );
      setState(() => todayIntakeLogs = logs);
    } catch (e) {
      _showErrorSnackBar('Failed to load intake logs: $e');
    } finally {
      setState(() => isLoadingIntake = false);
    }
  }

  Future<void> _searchFoodItems(String query) async {
    if (query.isEmpty) {
      setState(() => searchResults = []);
      return;
    }
    
    setState(() => isSearching = true);
    try {
      final results = await RealDataService.searchFoodItems(
        searchQuery: query,
        restrictions: selectedPatient?['dietaryRestrictions'] ?? [],
      );
      setState(() => searchResults = results);
    } catch (e) {
      _showErrorSnackBar('Failed to search food items: $e');
    } finally {
      setState(() => isSearching = false);
    }
  }

  Future<void> _logFoodIntake(Map<String, dynamic> foodItem, double quantity) async {
    if (selectedPatient == null) return;
    
    final success = await RealDataService.logFoodIntake(
      patientId: selectedPatient!['id'],
      foodItemId: foodItem['id'],
      quantity: quantity,
      mealType: selectedMealType,
      consumedAt: DateTime.now(),
    );
    
    if (success) {
      _showSuccessSnackBar('Food intake logged successfully!');
      _loadTodayIntakeLog();
    } else {
      _showErrorSnackBar('Failed to log food intake');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Planner', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Meal Plans'),
            Tab(icon: Icon(Icons.add_circle), text: 'Food Logger'),
            Tab(icon: Icon(Icons.analytics), text: 'Nutrition'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildPatientSelector(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMealPlansTab(),
                _buildFoodLoggerTab(),
                _buildNutritionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Patient:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          SizedBox(height: 8),
          if (isLoadingPatients)
            Center(child: CircularProgressIndicator())
          else if (patients.isEmpty)
            Text('No patients found. Add patients first.', style: TextStyle(color: Colors.grey))
          else
            DropdownButton<Map<String, dynamic>>(
              value: selectedPatient,
              hint: Text('Choose a patient'),
              isExpanded: true,
              items: patients.map((patient) {
                return DropdownMenuItem(
                  value: patient,
                  child: Text(patient['name'] ?? 'Unknown'),
                );
              }).toList(),
              onChanged: (patient) {
                setState(() {
                  selectedPatient = patient;
                  selectedDietChart = null;
                  dietCharts = [];
                  mealPlans = [];
                  todayIntakeLogs = [];
                });
                if (patient != null) {
                  _loadDietChartsForPatient();
                }
              },
            ),
          if (selectedPatient != null) ...[
            SizedBox(height: 8),
            Text('Diet Chart:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            if (isLoadingDietCharts)
              Center(child: CircularProgressIndicator())
            else if (dietCharts.isEmpty)
              Text('No active diet charts found.', style: TextStyle(color: Colors.grey))
            else
              DropdownButton<Map<String, dynamic>>(
                value: selectedDietChart,
                hint: Text('Choose a diet chart'),
                isExpanded: true,
                items: dietCharts.map((chart) {
                  return DropdownMenuItem(
                    value: chart,
                    child: Text(chart['name'] ?? 'Unknown Chart'),
                  );
                }).toList(),
                onChanged: (chart) {
                  setState(() {
                    selectedDietChart = chart;
                    mealPlans = [];
                    todayIntakeLogs = [];
                  });
                  if (chart != null) {
                    _loadMealPlansForDietChart();
                    _loadTodayIntakeLog();
                  }
                },
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMealPlansTab() {
    if (selectedDietChart == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Select a patient and diet chart to view meal plans', 
                 style: TextStyle(color: Colors.grey, fontSize: 16)),
          ],
        ),
      );
    }

    if (isLoadingMealPlans) {
      return Center(child: CircularProgressIndicator());
    }

    if (mealPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_meals, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No meal plans found for this diet chart', 
                 style: TextStyle(color: Colors.grey, fontSize: 16)),
            SizedBox(height: 8),
            Text('Create meal plans in the Diet Chart Builder', 
                 style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }

    // Group meal plans by day of week
    Map<int, List<Map<String, dynamic>>> weeklyPlans = {};
    for (var plan in mealPlans) {
      final day = plan['dayOfWeek'] as int;
      if (!weeklyPlans.containsKey(day)) {
        weeklyPlans[day] = [];
      }
      weeklyPlans[day]!.add(plan);
    }

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 7,
      itemBuilder: (context, index) {
        final dayPlans = weeklyPlans[index] ?? [];
        final dayName = weekDays[index];
        
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: ExpansionTile(
            title: Text(dayName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            subtitle: Text('${dayPlans.length} meal plans'),
            children: [
              if (dayPlans.isEmpty)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No meal plans for this day', 
                             style: TextStyle(color: Colors.grey)),
                )
              else
                ...dayPlans.map((plan) => _buildMealPlanTile(plan)).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMealPlanTile(Map<String, dynamic> plan) {
    return ListTile(
      leading: Icon(Icons.schedule, color: AppTheme.primaryColor),
      title: Text(plan['mealType'] ?? 'Unknown Meal'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Time: ${plan['mealTime'] ?? 'Not specified'}'),
          SizedBox(height: 4),
          Text('Items: ${(plan['items'] as List).map((item) => item['name']).join(', ')}'),
        ],
      ),
      onTap: () => _showMealPlanDetails(plan),
    );
  }

  void _showMealPlanDetails(Map<String, dynamic> plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${plan['mealType']} - ${weekDays[plan['dayOfWeek']]}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Time: ${plan['mealTime'] ?? 'Not specified'}', 
                   style: TextStyle(fontWeight: FontWeight.w600)),
              SizedBox(height: 16),
              Text('Food Items:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              ...(plan['items'] as List).map((item) => Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['name'], style: TextStyle(fontWeight: FontWeight.w600)),
                          Text('Quantity: ${item['quantity']}', style: TextStyle(fontSize: 12)),
                          if (item['preparationMethod'] != null)
                            Text('Preparation: ${item['preparationMethod']}', style: TextStyle(fontSize: 12)),
                          if (item['notes'] != null)
                            Text('Notes: ${item['notes']}', style: TextStyle(fontSize: 12)),
                          Text('Calories: ${((item['calories'] ?? 0) * item['quantity']).toStringAsFixed(1)}', 
                               style: TextStyle(fontSize: 12, color: AppTheme.primaryColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodLoggerTab() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal type selector
          Text('Log food for:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: mealTypes.map((type) => ChoiceChip(
              label: Text(type),
              selected: selectedMealType == type,
              onSelected: (selected) {
                if (selected) {
                  setState(() => selectedMealType = type);
                }
              },
            )).toList(),
          ),
          SizedBox(height: 16),
          
          // Search bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search food items...',
              prefixIcon: Icon(Icons.search),
              suffixIcon: isSearching ? 
                Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ) : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: _searchFoodItems,
          ),
          SizedBox(height: 16),
          
          // Search results
          if (searchResults.isNotEmpty) ...[
            Text('Search Results:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final food = searchResults[index];
                  return Card(
                    child: ListTile(
                      title: Text(food['name']),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Category: ${food['category']}'),
                          Text('Calories: ${food['calories']}/100g'),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _showQuantityDialog(food),
                        child: Text('Add'),
                      ),
                    ),
                  );
                },
              ),
            ),
          ] else if (searchController.text.isNotEmpty && !isSearching) ...[
            Center(
              child: Text('No food items found', style: TextStyle(color: Colors.grey)),
            ),
          ] else ...[
            // Today's logged foods
            Text('Today\'s Food Log:', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Expanded(
              child: isLoadingIntake 
                ? Center(child: CircularProgressIndicator())
                : todayIntakeLogs.isEmpty 
                  ? Center(child: Text('No food logged today', style: TextStyle(color: Colors.grey)))
                  : ListView.builder(
                      itemCount: todayIntakeLogs.length,
                      itemBuilder: (context, index) {
                        final log = todayIntakeLogs[index];
                        return Card(
                          child: ListTile(
                            title: Text(log['foodName']),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${log['mealType']} - Quantity: ${log['quantity']}'),
                                Text('Calories: ${log['caloriesConsumed'].toStringAsFixed(1)}'),
                                Text('Time: ${log['consumedAt'].toString().substring(11, 16)}'),
                              ],
                            ),
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryColor,
                              child: Icon(Icons.restaurant, color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }

  void _showQuantityDialog(Map<String, dynamic> food) {
    final quantityController = TextEditingController(text: '1.0');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log ${food['name']}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meal: $selectedMealType', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Quantity (portions)',
                border: OutlineInputBorder(),
                helperText: 'Nutritional values are per 100g',
              ),
            ),
            SizedBox(height: 16),
            Text('Nutritional Info (per 100g):', style: TextStyle(fontWeight: FontWeight.w600)),
            Text('Calories: ${food['calories']}'),
            Text('Protein: ${food['protein']}g'),
            Text('Carbs: ${food['carbohydrates']}g'),
            Text('Fat: ${food['fat']}g'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final quantity = double.tryParse(quantityController.text) ?? 1.0;
              Navigator.pop(context);
              _logFoodIntake(food, quantity);
            },
            child: Text('Log Food'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionTab() {
    if (todayIntakeLogs.isEmpty && !isLoadingIntake) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.analytics, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No nutrition data available', 
                 style: TextStyle(color: Colors.grey, fontSize: 16)),
            Text('Log some food to see nutrition analysis', 
                 style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      );
    }

    if (isLoadingIntake) {
      return Center(child: CircularProgressIndicator());
    }

    // Calculate today's totals
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var log in todayIntakeLogs) {
      totalCalories += log['caloriesConsumed'] ?? 0;
      totalProtein += log['proteinConsumed'] ?? 0;
      totalCarbs += log['carbsConsumed'] ?? 0;
      totalFat += log['fatConsumed'] ?? 0;
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Today\'s Nutrition Summary', 
               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 20),
          
          // Nutrition cards
          Row(
            children: [
              Expanded(child: _buildNutritionCard('Calories', totalCalories, 'kcal', Colors.orange)),
              SizedBox(width: 8),
              Expanded(child: _buildNutritionCard('Protein', totalProtein, 'g', Colors.red)),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildNutritionCard('Carbs', totalCarbs, 'g', Colors.blue)),
              SizedBox(width: 8),
              Expanded(child: _buildNutritionCard('Fat', totalFat, 'g', Colors.green)),
            ],
          ),
          SizedBox(height: 20),
          
          // Meal breakdown
          Text('Meal Breakdown:', 
               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          
          Expanded(
            child: ListView(
              children: mealTypes.map((mealType) {
                final mealLogs = todayIntakeLogs.where((log) => log['mealType'] == mealType).toList();
                if (mealLogs.isEmpty) return SizedBox.shrink();
                
                double mealCalories = mealLogs.fold(0, (sum, log) => sum + (log['caloriesConsumed'] ?? 0));
                
                return Card(
                  child: ExpansionTile(
                    title: Text(mealType),
                    subtitle: Text('${mealCalories.toStringAsFixed(0)} kcal'),
                    children: mealLogs.map((log) => ListTile(
                      title: Text(log['foodName']),
                      subtitle: Text('Qty: ${log['quantity']} | Cal: ${log['caloriesConsumed'].toStringAsFixed(0)}'),
                      dense: true,
                    )).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionCard(String title, double value, String unit, Color color) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.show_chart, color: color, size: 30),
            SizedBox(height: 8),
            Text(value.toStringAsFixed(1), 
                 style: TextStyle(fontSize: 24, color: color, fontWeight: FontWeight.bold)),
            Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey)),
            Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}