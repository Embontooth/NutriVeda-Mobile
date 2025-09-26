import 'package:nutriveda_mobile/supabase_config.dart';
import 'package:nutriveda_mobile/models/database_models.dart';
import 'package:nutriveda_mobile/services/firebase_supabase_sync.dart';

class RealDataService {
  // Ensure user is synced between Firebase and Supabase
  static Future<bool> ensureUserSynced() async {
    try {
      // Check if user is synced
      final isSynced = await FirebaseSupabaseSync.isUserSynced();
      if (!isSynced) {
        // Initialize sync if not already done
        final profile = await FirebaseSupabaseSync.initializeUserSession();
        return profile != null;
      }
      return true;
    } catch (e) {
      print('Error ensuring user sync: $e');
      return false;
    }
  }

  // Get current user's profile with Firebase Auth only
  static Future<Profile?> getCurrentUserProfile() async {
    try {
      // Get the linked profile from Firebase-Supabase sync
      final linkedProfile = await FirebaseSupabaseSync.getCurrentLinkedProfile();
      if (linkedProfile != null) {
        return linkedProfile;
      }
      
      // If no profile found, initialize user session (this will create the profile)
      print('🔄 No profile found, initializing user session...');
      final initializedProfile = await FirebaseSupabaseSync.initializeUserSession();
      return initializedProfile;
      
    } catch (e) {
      print('Error getting current user profile: $e');
      return null;
    }
  }

  // Get dashboard statistics for the current user
  static Future<Map<String, int>> getDashboardStats() async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null) return _getDefaultStats();

      Map<String, int> stats = {};
      
      if (profile.role == 'dietitian') {
        // Get dietitian-specific stats using firebase_uid
        
        // Total patients
        final patientsResponse = await SupabaseConfig.client
            .from('patient_health_profiles')
            .select('patient_id')
            .eq('dietitian_id', profile.id);
        stats['totalPatients'] = (patientsResponse as List).length;
        
        // Active diet plans
        final activePlansResponse = await SupabaseConfig.client
            .from('diet_charts')
            .select('id')
            .eq('dietitian_id', profile.id)
            .eq('status', 'active');
        stats['activePlans'] = (activePlansResponse as List).length;
        
        // Total diet charts
        final dietChartsResponse = await SupabaseConfig.client
            .from('diet_charts')
            .select('id')
            .eq('dietitian_id', profile.id);
        stats['dietCharts'] = (dietChartsResponse as List).length;
        
        // Mock appointments for now (you can add appointments table later)
        stats['appointments'] = 8;
        
      } else if (profile.role == 'patient') {
        // Get patient-specific stats using firebase_uid
        
        // Diet charts assigned to patient
        final dietChartsResponse = await SupabaseConfig.client
            .from('diet_charts')
            .select('id')
            .eq('patient_id', profile.id);
        stats['dietCharts'] = (dietChartsResponse as List).length;
        
        // Food logs this month
        final now = DateTime.now();
        final startOfMonth = DateTime(now.year, now.month, 1);
        final logsResponse = await SupabaseConfig.client
            .from('food_intake_logs')
            .select('id')
            .eq('patient_id', profile.id)
            .gte('consumed_at', startOfMonth.toIso8601String());
        stats['foodLogs'] = (logsResponse as List).length;
        
        // Active plans
        final activePlansResponse = await SupabaseConfig.client
            .from('diet_charts')
            .select('id')
            .eq('patient_id', profile.id)
            .eq('status', 'active');
        stats['activePlans'] = (activePlansResponse as List).length;
        
        // Mock appointments
        stats['appointments'] = 3;
      }
      
      return stats;
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return _getDefaultStats();
    }
  }

  static Map<String, int> _getDefaultStats() {
    return {
      'totalPatients': 0,
      'activePlans': 0,
      'dietCharts': 0,
      'appointments': 0,
      'foodLogs': 0,
    };
  }

  // Get recent activities based on user role
  static Future<List<Map<String, dynamic>>> getRecentActivities() async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null) return _getDefaultActivities();

      List<Map<String, dynamic>> activities = [];
      
      if (profile.role == 'dietitian') {
        // Get recent patients using profile.id instead of user.id
        final recentPatients = await SupabaseConfig.client
            .from('patient_health_profiles')
            .select('created_at, profiles!patient_health_profiles_patient_id_fkey(full_name)')
            .eq('dietitian_id', profile.id)
            .order('created_at', ascending: false)
            .limit(3);
        
        for (var patient in recentPatients as List) {
          final createdAt = DateTime.parse(patient['created_at']);
          final timeAgo = _getTimeAgo(createdAt);
          activities.add({
            'title': 'New patient registered',
            'subtitle': '${patient['profiles']['full_name']} joined your practice',
            'icon': 'person_add',
            'time': timeAgo,
          });
        }
        
        // Get recent diet chart updates
        final recentCharts = await SupabaseConfig.client
            .from('diet_charts')
            .select('updated_at, name, profiles!diet_charts_patient_id_fkey(full_name)')
            .eq('dietitian_id', profile.id)
            .order('updated_at', ascending: false)
            .limit(2);
        
        for (var chart in recentCharts as List) {
          final updatedAt = DateTime.parse(chart['updated_at']);
          final timeAgo = _getTimeAgo(updatedAt);
          activities.add({
            'title': 'Diet plan updated',
            'subtitle': 'Updated ${chart['name']} for ${chart['profiles']['full_name']}',
            'icon': 'edit',
            'time': timeAgo,
          });
        }
        
      } else if (profile.role == 'patient') {
        // Get recent food logs using profile.id
        final recentLogs = await SupabaseConfig.client
            .from('food_intake_logs')
            .select('consumed_at, meal_type, food_items!inner(name)')
            .eq('patient_id', profile.id)
            .order('consumed_at', ascending: false)
            .limit(5);
        
        for (var log in recentLogs as List) {
          final consumedAt = DateTime.parse(log['consumed_at']);
          final timeAgo = _getTimeAgo(consumedAt);
          activities.add({
            'title': 'Food logged',
            'subtitle': 'Logged ${log['food_items']['name']} for ${log['meal_type']}',
            'icon': 'restaurant',
            'time': timeAgo,
          });
        }
      }
      
      // Sort by most recent
      activities.sort((a, b) => a['time'].compareTo(b['time']));
      return activities.take(5).toList();
      
    } catch (e) {
      print('Error getting recent activities: $e');
      return _getDefaultActivities();
    }
  }

  static List<Map<String, dynamic>> _getDefaultActivities() {
    return [
      {
        'title': 'Welcome to NutriVeda!',
        'subtitle': 'Start by exploring your dashboard',
        'icon': 'star',
        'time': 'Just now',
      }
    ];
  }

  static String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Get patient list for dietitians
  static Future<List<Map<String, dynamic>>> getPatientList() async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null) return [];
      
      // First get patient health profiles for this dietitian
      final response = await SupabaseConfig.client
          .from('patient_health_profiles')
          .select('''
            patient_id,
            height,
            weight,
            created_at,
            profiles!patient_health_profiles_patient_id_fkey(full_name, email, phone)
          ''')
          .eq('dietitian_id', profile.id)
          .order('created_at', ascending: false);

      // Then get diet charts for each patient separately
      List<Map<String, dynamic>> patientList = [];
      for (var patient in response as List) {
        final patientId = patient['patient_id'];
        
        // Get diet charts for this specific patient
        final dietChartsResponse = await SupabaseConfig.client
            .from('diet_charts')
            .select('id, status, name')
            .eq('patient_id', patientId)
            .eq('dietitian_id', profile.id);

        final dietCharts = dietChartsResponse as List;
        final profileData = patient['profiles'];
        final activePlans = dietCharts.where((chart) => chart['status'] == 'active').length;
        
        patientList.add({
          'id': patient['patient_id'],
          'name': profileData['full_name'],
          'email': profileData['email'],
          'phone': profileData['phone'],
          'height': patient['height'],
          'weight': patient['weight'],
          'activePlans': activePlans,
          'totalPlans': dietCharts.length,
          'joinedDate': DateTime.parse(patient['created_at']),
        });
      }
      
      return patientList;
    } catch (e) {
      print('Error getting patient list: $e');
      return [];
    }
  }

  // Get food items for food planner
  static Future<List<FoodItem>> getFoodItems({String? category, String? searchQuery}) async {
    try {
      var query = SupabaseConfig.client.from('food_items').select();
      
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.textSearch('name', searchQuery);
      }
      
      final response = await query.order('name').limit(50);
      
      return (response as List)
          .map((json) => FoodItem.fromJson(json))
          .toList();
    } catch (e) {
      print('Error getting food items: $e');
      return [];
    }
  }

  // Get food categories
  static Future<List<String>> getFoodCategories() async {
    try {
      final response = await SupabaseConfig.client
          .from('food_items')
          .select('category')
          .order('category');
      
      final categories = (response as List)
          .map((item) => item['category'] as String)
          .toSet()
          .toList();
      
      return categories;
    } catch (e) {
      print('Error getting food categories: $e');
      return ['Grains', 'Vegetables', 'Fruits', 'Proteins', 'Dairy', 'Spices'];
    }
  }

  // Create user profile after Firebase authentication
  static Future<bool> createUserProfile({
    required String firebaseUid,
    required String email,
    required String fullName,
    required String role,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    try {
      await SupabaseConfig.client.from('profiles').upsert({
        'firebase_uid': firebaseUid,
        'email': email,
        'full_name': fullName,
        'role': role,
        'phone': phone,
        'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
        'gender': gender,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'firebase_uid');
      return true;
    } catch (e) {
      print('Error creating user profile: $e');
      return false;
    }
  }

  // Add a new patient (creates both profile and health profile)
  static Future<Map<String, dynamic>?> addPatient({
    required String email,
    required String fullName,
    required String phone,
    required DateTime dateOfBirth,
    required String gender,
    required double height,
    required double weight,
    required String activityLevel,
    List<String> medicalConditions = const [],
    List<String> allergies = const [],
    List<String> dietaryRestrictions = const [],
    List<String> healthGoals = const [],
  }) async {
    try {
      final currentProfile = await getCurrentUserProfile();
      if (currentProfile == null) {
        throw Exception('User not found. Please log in again.');
      }
      
      // Auto-update role to dietitian if not set (for development/demo purposes)
      String dietitianId = currentProfile.id;
      if (currentProfile.role != 'dietitian') {
        await _ensureUserIsDietitian(currentProfile.id);
        // Refresh profile after role update
        final updatedProfile = await getCurrentUserProfile();
        if (updatedProfile == null || updatedProfile.role != 'dietitian') {
          throw Exception('Failed to set user role to dietitian');
        }
        dietitianId = updatedProfile.id;
      }

      // Step 1: Create patient profile
      final patientProfileData = {
        'email': email,
        'full_name': fullName,
        'role': 'patient',
        'phone': phone,
        'date_of_birth': dateOfBirth.toIso8601String().split('T')[0],
        'gender': gender,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final profileResponse = await SupabaseConfig.client
          .from('profiles')
          .insert(patientProfileData)
          .select()
          .single();

      final patientId = profileResponse['id'];

      // Step 2: Create patient health profile
      final healthProfileData = {
        'patient_id': patientId,
        'dietitian_id': dietitianId,
        'height': height,
        'weight': weight,
        'activity_level': activityLevel,
        'medical_conditions': medicalConditions,
        'allergies': allergies,
        'dietary_restrictions': dietaryRestrictions,
        'health_goals': healthGoals,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await SupabaseConfig.client
          .from('patient_health_profiles')
          .insert(healthProfileData);

      return {
        'id': patientId,
        'name': fullName,
        'email': email,
        'phone': phone,
        'height': height,
        'weight': weight,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'activityLevel': activityLevel,
        'joinedDate': DateTime.now(),
        'activePlans': 0,
        'totalPlans': 0,
      };
    } catch (e) {
      print('Error adding patient: $e');
      return null;
    }
  }

  // Create a new diet chart
  static Future<Map<String, dynamic>?> createDietChart({
    required String patientId,
    required String name,
    required String description,
    required DateTime startDate,
    DateTime? endDate,
    required double targetCalories,
    required double targetProtein,
    required double targetCarbs,
    required double targetFat,
    required double targetFiber,
    List<String> doshaFocus = const [],
    String? seasonalConsiderations,
    String? specialInstructions,
  }) async {
    try {
      final currentProfile = await getCurrentUserProfile();
      if (currentProfile == null) {
        throw Exception('User not found. Please log in again.');
      }
      
      // Auto-update role to dietitian if not set (for development/demo purposes)
      String dietitianId = currentProfile.id;
      if (currentProfile.role != 'dietitian') {
        await _ensureUserIsDietitian(currentProfile.id);
        // Refresh profile after role update
        final updatedProfile = await getCurrentUserProfile();
        if (updatedProfile == null || updatedProfile.role != 'dietitian') {
          throw Exception('Failed to set user role to dietitian');
        }
        dietitianId = updatedProfile.id;
      }

      final dietChartData = {
        'patient_id': patientId,
        'dietitian_id': dietitianId,
        'name': name,
        'description': description,
        'start_date': startDate.toIso8601String().split('T')[0],
        'end_date': endDate?.toIso8601String().split('T')[0],
        'status': 'draft',
        'target_calories': targetCalories,
        'target_protein': targetProtein,
        'target_carbs': targetCarbs,
        'target_fat': targetFat,
        'target_fiber': targetFiber,
        'dosha_focus': doshaFocus,
        'seasonal_considerations': seasonalConsiderations,
        'special_instructions': specialInstructions,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await SupabaseConfig.client
          .from('diet_charts')
          .insert(dietChartData)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error creating diet chart: $e');
      return null;
    }
  }

  // Get diet charts for current user (dietitian sees all their charts, patient sees theirs)
  static Future<List<Map<String, dynamic>>> getDietCharts({String? patientId}) async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null) return [];

      var query = SupabaseConfig.client
          .from('diet_charts')
          .select('''
            *,
            profiles!diet_charts_patient_id_fkey(full_name, email)
          ''');

      if (patientId != null) {
        // Filter by specific patient
        query = query.eq('patient_id', patientId);
      } else if (profile.role == 'dietitian') {
        query = query.eq('dietitian_id', profile.id);
      } else {
        query = query.eq('patient_id', profile.id);
      }

      final response = await query.order('created_at', ascending: false);
      
      return (response as List).map((chart) {
        return {
          'id': chart['id'],
          'name': chart['name'],
          'description': chart['description'],
          'patient': chart['profiles']['full_name'],
          'patientEmail': chart['profiles']['email'],
          'startDate': DateTime.parse(chart['start_date']),
          'endDate': chart['end_date'] != null ? DateTime.parse(chart['end_date']) : null,
          'status': chart['status'],
          'targetCalories': chart['target_calories'],
          'targetProtein': chart['target_protein'],
          'targetCarbs': chart['target_carbs'],
          'targetFat': chart['target_fat'],
          'targetFiber': chart['target_fiber'],
          'doshaFocus': chart['dosha_focus'] ?? [],
          'seasonalConsiderations': chart['seasonal_considerations'],
          'specialInstructions': chart['special_instructions'],
          'createdAt': DateTime.parse(chart['created_at']),
          'updatedAt': DateTime.parse(chart['updated_at']),
        };
      }).toList();
    } catch (e) {
      print('Error getting diet charts: $e');
      return [];
    }
  }

  // Update diet chart status
  static Future<bool> updateDietChartStatus(String chartId, String status) async {
    try {
      await SupabaseConfig.client
          .from('diet_charts')
          .update({
            'status': status,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', chartId);
      return true;
    } catch (e) {
      print('Error updating diet chart status: $e');
      return false;
    }
  }

  // Delete diet chart
  static Future<bool> deleteDietChart(String chartId) async {
    try {
      await SupabaseConfig.client
          .from('diet_charts')
          .delete()
          .eq('id', chartId);
      return true;
    } catch (e) {
      print('Error deleting diet chart: $e');
      return false;
    }
  }

  // Add meal plan to diet chart
  static Future<Map<String, dynamic>?> addMealPlan({
    required String dietChartId,
    required int dayOfWeek,
    required String mealType,
    required String mealTime,
  }) async {
    try {
      final mealPlanData = {
        'diet_chart_id': dietChartId,
        'day_of_week': dayOfWeek,
        'meal_type': mealType,
        'meal_time': mealTime,
        'created_at': DateTime.now().toIso8601String(),
      };

      final response = await SupabaseConfig.client
          .from('meal_plans')
          .insert(mealPlanData)
          .select()
          .single();

      return response;
    } catch (e) {
      print('Error adding meal plan: $e');
      return null;
    }
  }

  // Add food item to meal plan
  static Future<bool> addMealItem({
    required String mealPlanId,
    required String foodItemId,
    required double quantity,
    String? preparationMethod,
    String? notes,
  }) async {
    try {
      await SupabaseConfig.client.from('meal_items').insert({
        'meal_plan_id': mealPlanId,
        'food_item_id': foodItemId,
        'quantity': quantity,
        'preparation_method': preparationMethod,
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      print('Error adding meal item: $e');
      return false;
    }
  }

  // Get detailed patient information with health profile
  static Future<Map<String, dynamic>?> getPatientDetails(String patientId) async {
    try {
      final response = await SupabaseConfig.client
          .from('profiles')
          .select('''
            *,
            patient_health_profiles(*),
            diet_charts(id, name, status, created_at)
          ''')
          .eq('id', patientId)
          .single();

      final healthProfile = response['patient_health_profiles'].isNotEmpty 
          ? response['patient_health_profiles'][0] 
          : null;

      return {
        'id': response['id'],
        'name': response['full_name'],
        'email': response['email'],
        'phone': response['phone'],
        'dateOfBirth': response['date_of_birth'] != null 
            ? DateTime.parse(response['date_of_birth']) 
            : null,
        'gender': response['gender'],
        'height': healthProfile?['height'],
        'weight': healthProfile?['weight'],
        'activityLevel': healthProfile?['activity_level'],
        'medicalConditions': healthProfile?['medical_conditions'] ?? [],
        'allergies': healthProfile?['allergies'] ?? [],
        'dietaryRestrictions': healthProfile?['dietary_restrictions'] ?? [],
        'healthGoals': healthProfile?['health_goals'] ?? [],
        'dietCharts': response['diet_charts'] ?? [],
        'joinedDate': DateTime.parse(response['created_at']),
      };
    } catch (e) {
      print('Error getting patient details: $e');
      return null;
    }
  }

  // Get meal plans for a specific diet chart
  static Future<List<Map<String, dynamic>>> getMealPlans(String dietChartId) async {
    try {
      final response = await SupabaseConfig.client
          .from('meal_plans')
          .select('''
            *,
            meal_items(
              *,
              food_items(*)
            )
          ''')
          .eq('diet_chart_id', dietChartId)
          .order('day_of_week')
          .order('meal_time');

      return (response as List).map((mealPlan) {
        return {
          'id': mealPlan['id'],
          'dayOfWeek': mealPlan['day_of_week'],
          'mealType': mealPlan['meal_type'],
          'mealTime': mealPlan['meal_time'],
          'items': (mealPlan['meal_items'] as List).map((item) {
            final foodItem = item['food_items'];
            return {
              'id': item['id'],
              'foodItemId': item['food_item_id'],
              'name': foodItem['name'],
              'quantity': item['quantity'],
              'preparationMethod': item['preparation_method'],
              'notes': item['notes'],
              'calories': foodItem['calories'],
              'protein': foodItem['protein'],
              'carbohydrates': foodItem['carbohydrates'],
              'fat': foodItem['fat'],
              'fiber': foodItem['fiber'],
              'category': foodItem['category'],
            };
          }).toList(),
        };
      }).toList();
    } catch (e) {
      print('Error getting meal plans: $e');
      return [];
    }
  }

  // Get food intake logs for a patient (for tracking actual consumption)
  static Future<List<Map<String, dynamic>>> getFoodIntakeLogs({
    String? patientId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null) return [];

      String targetPatientId = patientId ?? profile.id;

      var query = SupabaseConfig.client
          .from('food_intake_logs')
          .select('''
            *,
            food_items(name, category, calories, protein, carbohydrates, fat)
          ''')
          .eq('patient_id', targetPatientId);

      if (startDate != null) {
        query = query.gte('consumed_at', startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.lte('consumed_at', endDate.toIso8601String());
      }

      final response = await query.order('consumed_at', ascending: false);

      return (response as List).map((log) {
        final foodItem = log['food_items'];
        return {
          'id': log['id'],
          'patientId': log['patient_id'],
          'foodName': foodItem['name'],
          'category': foodItem['category'],
          'quantity': log['quantity'],
          'mealType': log['meal_type'],
          'consumedAt': DateTime.parse(log['consumed_at']),
          'caloriesConsumed': log['calories_consumed'] ?? (foodItem['calories'] * log['quantity']),
          'proteinConsumed': log['protein_consumed'] ?? (foodItem['protein'] * log['quantity']),
          'carbsConsumed': log['carbs_consumed'] ?? (foodItem['carbohydrates'] * log['quantity']),
          'fatConsumed': log['fat_consumed'] ?? (foodItem['fat'] * log['quantity']),
        };
      }).toList();
    } catch (e) {
      print('Error getting food intake logs: $e');
      return [];
    }
  }

  // Log food intake for a patient
  static Future<bool> logFoodIntake({
    required String patientId,
    required String foodItemId,
    required double quantity,
    required String mealType,
    required DateTime consumedAt,
  }) async {
    try {
      // Get food item details to calculate consumed nutrients
      final foodItem = await SupabaseConfig.client
          .from('food_items')
          .select()
          .eq('id', foodItemId)
          .single();

      final caloriesConsumed = foodItem['calories'] * quantity;
      final proteinConsumed = foodItem['protein'] * quantity;
      final carbsConsumed = foodItem['carbohydrates'] * quantity;
      final fatConsumed = foodItem['fat'] * quantity;

      await SupabaseConfig.client.from('food_intake_logs').insert({
        'patient_id': patientId,
        'food_item_id': foodItemId,
        'quantity': quantity,
        'meal_type': mealType,
        'consumed_at': consumedAt.toIso8601String(),
        'calories_consumed': caloriesConsumed,
        'protein_consumed': proteinConsumed,
        'carbs_consumed': carbsConsumed,
        'fat_consumed': fatConsumed,
        'created_at': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      print('Error logging food intake: $e');
      return false;
    }
  }

  // Search for food items with filters
  static Future<List<Map<String, dynamic>>> searchFoodItems({
    String? searchQuery,
    String? category,
    List<String>? doshaEffects,
    List<String>? restrictions,
  }) async {
    try {
      var query = SupabaseConfig.client.from('food_items').select();

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.textSearch('name', searchQuery);
      }

      if (category != null && category.isNotEmpty && category != 'All') {
        query = query.eq('category', category);
      }

      final response = await query.order('name').limit(100);

      List<Map<String, dynamic>> items = (response as List)
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      // Apply client-side filters for complex queries
      if (restrictions != null && restrictions.isNotEmpty) {
        items = items.where((item) {
          // Check if item conflicts with dietary restrictions
          final itemName = (item['name'] as String).toLowerCase();
          final itemCategory = (item['category'] as String).toLowerCase();
          
          for (String restriction in restrictions) {
            final restrictionLower = restriction.toLowerCase();
            if (restrictionLower.contains('vegetarian') && 
                (itemCategory.contains('meat') || itemCategory.contains('fish'))) {
              return false;
            }
            if (restrictionLower.contains('gluten-free') && 
                (itemName.contains('wheat') || itemName.contains('bread'))) {
              return false;
            }
            // Add more restriction checks as needed
          }
          return true;
        }).toList();
      }

      return items;
    } catch (e) {
      print('Error searching food items: $e');
      return [];
    }
  }

  // Get weekly meal planning summary
  static Future<Map<String, dynamic>> getWeeklyMealPlanSummary({
    required String dietChartId,
    required DateTime weekStartDate,
  }) async {
    try {
      final mealPlans = await getMealPlans(dietChartId);
      
      Map<int, List<Map<String, dynamic>>> weeklyPlan = {};
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (var plan in mealPlans) {
        final dayOfWeek = plan['dayOfWeek'] as int;
        if (!weeklyPlan.containsKey(dayOfWeek)) {
          weeklyPlan[dayOfWeek] = [];
        }

        double dayCalories = 0;
        double dayProtein = 0;
        double dayCarbs = 0;
        double dayFat = 0;

        for (var item in plan['items']) {
          final quantity = item['quantity'] as double;
          dayCalories += (item['calories'] ?? 0) * quantity;
          dayProtein += (item['protein'] ?? 0) * quantity;
          dayCarbs += (item['carbohydrates'] ?? 0) * quantity;
          dayFat += (item['fat'] ?? 0) * quantity;
        }

        weeklyPlan[dayOfWeek]!.add({
          ...plan,
          'dayCalories': dayCalories,
          'dayProtein': dayProtein,
          'dayCarbs': dayCarbs,
          'dayFat': dayFat,
        });

        totalCalories += dayCalories;
        totalProtein += dayProtein;
        totalCarbs += dayCarbs;
        totalFat += dayFat;
      }

      return {
        'weekStartDate': weekStartDate,
        'weeklyPlan': weeklyPlan,
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
        'averageDailyCalories': totalCalories / 7,
      };
    } catch (e) {
      print('Error getting weekly meal plan summary: $e');
      return {};
    }
  }

  // Get all patients for the current nutritionist
  static Future<List<Map<String, dynamic>>> getPatients() async {
    try {
      final profile = await getCurrentUserProfile();
      if (profile == null) return [];

      final response = await SupabaseConfig.client
          .from('profiles')
          .select('''
            id,
            full_name,
            email,
            phone,
            date_of_birth,
            gender,
            created_at,
            patient_health_profiles(*)
          ''')
          .eq('role', 'patient')
          .order('created_at', ascending: false);

      return (response as List).map((patient) {
        return {
          'id': patient['id'],
          'name': patient['full_name'],
          'email': patient['email'],
          'phone': patient['phone'],
          'dateOfBirth': patient['date_of_birth'] != null 
              ? DateTime.parse(patient['date_of_birth']) 
              : null,
          'gender': patient['gender'],
          'joinedDate': DateTime.parse(patient['created_at']),
          'hasHealthProfile': patient['patient_health_profiles'].isNotEmpty,
        };
      }).toList();
    } catch (e) {
      print('Error getting all patients: $e');
      return [];
    }
  }

  // Helper method to ensure user has dietitian role (for development/demo)
  static Future<void> _ensureUserIsDietitian(String userId) async {
    try {
      print('🔄 Updating user role to dietitian...');
      await SupabaseConfig.client
          .from('profiles')
          .update({'role': 'dietitian'})
          .eq('id', userId);
      print('✅ User role updated to dietitian');
    } catch (e) {
      print('Error updating user role: $e');
      throw Exception('Failed to update user role to dietitian');
    }
  }
}