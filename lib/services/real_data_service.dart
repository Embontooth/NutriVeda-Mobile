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
            .select('created_at, profiles!inner(full_name)')
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
            .select('updated_at, name, profiles!inner(full_name)')
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
      
      final response = await SupabaseConfig.client
          .from('patient_health_profiles')
          .select('''
            patient_id,
            height,
            weight,
            created_at,
            profiles!inner(full_name, email, phone),
            diet_charts(id, status, name)
          ''')
          .eq('dietitian_id', profile.id)
          .order('created_at', ascending: false);
      
      return (response as List).map((patient) {
        final profileData = patient['profiles'];
        final dietCharts = patient['diet_charts'] as List;
        final activePlans = dietCharts.where((chart) => chart['status'] == 'active').length;
        
        return {
          'id': patient['patient_id'],
          'name': profileData['full_name'],
          'email': profileData['email'],
          'phone': profileData['phone'],
          'height': patient['height'],
          'weight': patient['weight'],
          'activePlans': activePlans,
          'totalPlans': dietCharts.length,
          'joinedDate': DateTime.parse(patient['created_at']),
        };
      }).toList();
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
}