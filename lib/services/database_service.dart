import 'package:nutriveda_mobile/supabase_config.dart';
import 'package:nutriveda_mobile/models/database_models.dart';

class DatabaseService {
  // Get all food items
  static Future<List<FoodItem>> getAllFoodItems() async {
    final response = await SupabaseConfig.client
        .from('food_items')
        .select()
        .order('name');
    
    return (response as List)
        .map((json) => FoodItem.fromJson(json))
        .toList();
  }

  // Search food items by name
  static Future<List<FoodItem>> searchFoodItems(String query) async {
    final response = await SupabaseConfig.client
        .from('food_items')
        .select()
        .textSearch('name', query)
        .order('name');
    
    return (response as List)
        .map((json) => FoodItem.fromJson(json))
        .toList();
  }

  // Get food items by category
  static Future<List<FoodItem>> getFoodItemsByCategory(String category) async {
    final response = await SupabaseConfig.client
        .from('food_items')
        .select()
        .eq('category', category)
        .order('name');
    
    return (response as List)
        .map((json) => FoodItem.fromJson(json))
        .toList();
  }

  // Get user profile
  static Future<Profile?> getUserProfile(String userId) async {
    final response = await SupabaseConfig.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    
    return response != null ? Profile.fromJson(response) : null;
  }

  // Get patient health profile
  static Future<PatientHealthProfile?> getPatientHealthProfile(String patientId) async {
    final response = await SupabaseConfig.client
        .from('patient_health_profiles')
        .select()
        .eq('patient_id', patientId)
        .maybeSingle();
    
    return response != null ? PatientHealthProfile.fromJson(response) : null;
  }

  // Get patient's diet charts
  static Future<List<DietChart>> getPatientDietCharts(String patientId) async {
    final response = await SupabaseConfig.client
        .from('diet_charts')
        .select()
        .eq('patient_id', patientId)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => DietChart.fromJson(json))
        .toList();
  }

  // Get dietitian's diet charts
  static Future<List<DietChart>> getDietitianDietCharts(String dietitianId) async {
    final response = await SupabaseConfig.client
        .from('diet_charts')
        .select()
        .eq('dietitian_id', dietitianId)
        .order('created_at', ascending: false);
    
    return (response as List)
        .map((json) => DietChart.fromJson(json))
        .toList();
  }

  // Log food intake
  static Future<void> logFoodIntake({
    required String patientId,
    required String foodItemId,
    required double quantity,
    required String mealType,
    required DateTime consumedAt,
  }) async {
    // First get the food item to calculate consumed nutrients
    final foodItem = await SupabaseConfig.client
        .from('food_items')
        .select('calories, protein, carbohydrates, fat')
        .eq('id', foodItemId)
        .single();

    // Calculate consumed nutrients based on quantity
    final caloriesConsumed = (foodItem['calories'] as num) * quantity / 100;
    final proteinConsumed = (foodItem['protein'] as num) * quantity / 100;
    final carbsConsumed = (foodItem['carbohydrates'] as num) * quantity / 100;
    final fatConsumed = (foodItem['fat'] as num) * quantity / 100;

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
    });
  }

  // Get patient's food intake logs for a specific date
  static Future<List<FoodIntakeLog>> getPatientIntakeLogsForDate(
    String patientId, 
    DateTime date
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final response = await SupabaseConfig.client
        .from('food_intake_logs')
        .select()
        .eq('patient_id', patientId)
        .gte('consumed_at', startOfDay.toIso8601String())
        .lt('consumed_at', endOfDay.toIso8601String())
        .order('consumed_at');
    
    return (response as List)
        .map((json) => FoodIntakeLog.fromJson(json))
        .toList();
  }

  // Get all patients for a dietitian
  static Future<List<Profile>> getDietitianPatients(String dietitianId) async {
    final response = await SupabaseConfig.client
        .from('patient_health_profiles')
        .select('patient_id, profiles!inner(*)')
        .eq('dietitian_id', dietitianId);
    
    return (response as List)
        .map((json) => Profile.fromJson(json['profiles']))
        .toList();
  }

  // Get daily nutrition summary for a patient
  static Future<Map<String, double>> getDailyNutritionSummary(
    String patientId, 
    DateTime date
  ) async {
    final logs = await getPatientIntakeLogsForDate(patientId, date);
    
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final log in logs) {
      totalCalories += log.caloriesConsumed ?? 0;
      totalProtein += log.proteinConsumed ?? 0;
      totalCarbs += log.carbsConsumed ?? 0;
      totalFat += log.fatConsumed ?? 0;
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbohydrates': totalCarbs,
      'fat': totalFat,
    };
  }

  // Create or update user profile
  static Future<void> upsertProfile({
    required String id,
    required String email,
    required String fullName,
    required String role,
    String? phone,
    DateTime? dateOfBirth,
    String? gender,
  }) async {
    await SupabaseConfig.client.from('profiles').upsert({
      'id': id,
      'email': email,
      'full_name': fullName,
      'role': role,
      'phone': phone,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'gender': gender,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}