// Generated Dart models for NutriVeda database tables

class Profile {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'admin', 'dietitian', 'patient'
  final String? phone;
  final DateTime? dateOfBirth;
  final String? gender; // 'male', 'female', 'other'
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? firebaseUid; // Link to Firebase user

  Profile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.phone,
    this.dateOfBirth,
    this.gender,
    required this.createdAt,
    required this.updatedAt,
    this.firebaseUid,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'] != null 
          ? DateTime.parse(json['date_of_birth']) 
          : null,
      gender: json['gender'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      firebaseUid: json['firebase_uid'],
    );
  }
}

class FoodItem {
  final String id;
  final String name;
  final String category;
  final String? subcategory;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;
  final double fiber;
  final List<String> rasa; // Ayurvedic tastes
  final String? virya; // 'heating' or 'cooling'
  final String? vipaka; // 'sweet', 'sour', 'pungent'
  final Map<String, dynamic> doshaEffect;
  final List<String> healthBenefits;
  final List<String> seasonalAvailability;

  FoodItem({
    required this.id,
    required this.name,
    required this.category,
    this.subcategory,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
    required this.fiber,
    this.rasa = const [],
    this.virya,
    this.vipaka,
    this.doshaEffect = const {},
    this.healthBenefits = const [],
    this.seasonalAvailability = const [],
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      subcategory: json['subcategory'],
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbohydrates: (json['carbohydrates'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num).toDouble(),
      rasa: List<String>.from(json['rasa'] ?? []),
      virya: json['virya'],
      vipaka: json['vipaka'],
      doshaEffect: Map<String, dynamic>.from(json['dosha_effect'] ?? {}),
      healthBenefits: List<String>.from(json['health_benefits'] ?? []),
      seasonalAvailability: List<String>.from(json['seasonal_availability'] ?? []),
    );
  }
}

class DietChart {
  final String id;
  final String patientId;
  final String dietitianId;
  final String name;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // 'draft', 'active', 'completed', 'cancelled'
  final double? targetCalories;
  final double? targetProtein;
  final double? targetCarbs;
  final double? targetFat;
  final List<String> doshaFocus;
  final String? specialInstructions;

  DietChart({
    required this.id,
    required this.patientId,
    required this.dietitianId,
    required this.name,
    this.description,
    required this.startDate,
    this.endDate,
    required this.status,
    this.targetCalories,
    this.targetProtein,
    this.targetCarbs,
    this.targetFat,
    this.doshaFocus = const [],
    this.specialInstructions,
  });

  factory DietChart.fromJson(Map<String, dynamic> json) {
    return DietChart(
      id: json['id'],
      patientId: json['patient_id'],
      dietitianId: json['dietitian_id'],
      name: json['name'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date']) 
          : null,
      status: json['status'],
      targetCalories: json['target_calories']?.toDouble(),
      targetProtein: json['target_protein']?.toDouble(),
      targetCarbs: json['target_carbs']?.toDouble(),
      targetFat: json['target_fat']?.toDouble(),
      doshaFocus: List<String>.from(json['dosha_focus'] ?? []),
      specialInstructions: json['special_instructions'],
    );
  }
}

class PatientHealthProfile {
  final String id;
  final String patientId;
  final String? dietitianId;
  final double? height;
  final double? weight;
  final String? activityLevel;
  final double prakritiVata;
  final double prakritiPitta;
  final double prakritiKapha;
  final double vikritiVata;
  final double vikritiPitta;
  final double vikritiKapha;
  final List<String> medicalConditions;
  final List<String> allergies;
  final List<String> dietaryRestrictions;
  final List<String> healthGoals;

  PatientHealthProfile({
    required this.id,
    required this.patientId,
    this.dietitianId,
    this.height,
    this.weight,
    this.activityLevel,
    this.prakritiVata = 0,
    this.prakritiPitta = 0,
    this.prakritiKapha = 0,
    this.vikritiVata = 0,
    this.vikritiPitta = 0,
    this.vikritiKapha = 0,
    this.medicalConditions = const [],
    this.allergies = const [],
    this.dietaryRestrictions = const [],
    this.healthGoals = const [],
  });

  factory PatientHealthProfile.fromJson(Map<String, dynamic> json) {
    return PatientHealthProfile(
      id: json['id'],
      patientId: json['patient_id'],
      dietitianId: json['dietitian_id'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      activityLevel: json['activity_level'],
      prakritiVata: (json['prakriti_vata'] as num?)?.toDouble() ?? 0,
      prakritiPitta: (json['prakriti_pitta'] as num?)?.toDouble() ?? 0,
      prakritiKapha: (json['prakriti_kapha'] as num?)?.toDouble() ?? 0,
      vikritiVata: (json['vikriti_vata'] as num?)?.toDouble() ?? 0,
      vikritiPitta: (json['vikriti_pitta'] as num?)?.toDouble() ?? 0,
      vikritiKapha: (json['vikriti_kapha'] as num?)?.toDouble() ?? 0,
      medicalConditions: List<String>.from(json['medical_conditions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      dietaryRestrictions: List<String>.from(json['dietary_restrictions'] ?? []),
      healthGoals: List<String>.from(json['health_goals'] ?? []),
    );
  }
}

class FoodIntakeLog {
  final String id;
  final String patientId;
  final String foodItemId;
  final double quantity;
  final String mealType; // 'breakfast', 'mid_morning', 'lunch', 'evening_snack', 'dinner', 'bedtime'
  final DateTime consumedAt;
  final double? caloriesConsumed;
  final double? proteinConsumed;
  final double? carbsConsumed;
  final double? fatConsumed;

  FoodIntakeLog({
    required this.id,
    required this.patientId,
    required this.foodItemId,
    required this.quantity,
    required this.mealType,
    required this.consumedAt,
    this.caloriesConsumed,
    this.proteinConsumed,
    this.carbsConsumed,
    this.fatConsumed,
  });

  factory FoodIntakeLog.fromJson(Map<String, dynamic> json) {
    return FoodIntakeLog(
      id: json['id'],
      patientId: json['patient_id'],
      foodItemId: json['food_item_id'],
      quantity: (json['quantity'] as num).toDouble(),
      mealType: json['meal_type'],
      consumedAt: DateTime.parse(json['consumed_at']),
      caloriesConsumed: json['calories_consumed']?.toDouble(),
      proteinConsumed: json['protein_consumed']?.toDouble(),
      carbsConsumed: json['carbs_consumed']?.toDouble(),
      fatConsumed: json['fat_consumed']?.toDouble(),
    );
  }
}