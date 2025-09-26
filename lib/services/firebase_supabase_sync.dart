import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutriveda_mobile/firebase_config.dart';
import 'package:nutriveda_mobile/supabase_config.dart';
import 'package:nutriveda_mobile/models/database_models.dart';

class FirebaseSupabaseSync {
  /// Sync Firebase user to Supabase (Database only, no Supabase Auth)
  /// This creates or updates a profile in Supabase when a user signs in with Firebase
  static Future<Profile?> syncUserToSupabase(User firebaseUser, {String role = 'patient'}) async {
    try {
      print('🔄 Starting sync for Firebase user: ${firebaseUser.email}');
      
      // Check if user profile already exists in Supabase
      final existingProfile = await _getSupabaseProfile(firebaseUser.uid);
      
      if (existingProfile != null) {
        print('✅ Existing profile found, updating...');
        // Update existing profile with latest Firebase info
        return await _updateSupabaseProfile(firebaseUser, existingProfile);
      } else {
        print('🆕 Creating new profile...');
        // Create new profile in Supabase
        return await _createSupabaseProfile(firebaseUser, role);
      }
    } catch (e) {
      print('❌ Error syncing Firebase user to Supabase: $e');
      return null;
    }
  }

  /// Get existing Supabase profile by firebase_uid
  static Future<Profile?> _getSupabaseProfile(String firebaseUid) async {
    try {
      print('🔍 Looking for profile with firebase_uid: $firebaseUid');
      
      final response = await SupabaseConfig.client
          .from('profiles')
          .select()
          .eq('firebase_uid', firebaseUid)
          .maybeSingle();
      
      if (response != null) {
        print('✅ Profile found in Supabase');
        return Profile.fromJson(response);
      } else {
        print('❌ No profile found with this firebase_uid');
        return null;
      }
    } catch (e) {
      print('❌ Error getting Supabase profile: $e');
      return null;
    }
  }

  /// Create new Supabase profile for Firebase user
  static Future<Profile?> _createSupabaseProfile(User firebaseUser, String role) async {
    try {
      print('🔄 Attempting to create profile for: ${firebaseUser.email}');
      
      // Create profile data with Firebase UID as the primary identifier
      final profileData = {
        'firebase_uid': firebaseUser.uid,
        'email': firebaseUser.email ?? 'user@example.com',
        'full_name': firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
        'role': role,
        'phone': firebaseUser.phoneNumber,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      print('📝 Creating profile with data: $profileData');

      final response = await SupabaseConfig.client
          .from('profiles')
          .insert(profileData)
          .select()
          .single();
      
      print('✅ Profile created successfully');
      return Profile.fromJson(response);
      
    } catch (e) {
      print('❌ Error creating profile: $e');
      
      // Try upsert approach in case of conflicts
      try {
        print('🔄 Trying upsert approach...');
        
        final upsertData = {
          'firebase_uid': firebaseUser.uid,
          'email': firebaseUser.email ?? 'user@example.com',
          'full_name': firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
          'role': role,
          'phone': firebaseUser.phoneNumber,
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        final upsertResponse = await SupabaseConfig.client
            .from('profiles')
            .upsert(upsertData, onConflict: 'firebase_uid')
            .select()
            .single();
        
        print('✅ Profile upserted successfully');
        return Profile.fromJson(upsertResponse);
        
      } catch (upsertError) {
        print('❌ Upsert also failed: $upsertError');
        return null;
      }
    }
  }

  /// Update existing Supabase profile
  static Future<Profile?> _updateSupabaseProfile(User firebaseUser, Profile existingProfile) async {
    try {
      final updateData = {
        'email': firebaseUser.email ?? existingProfile.email,
        'full_name': firebaseUser.displayName ?? existingProfile.fullName,
        'updated_at': DateTime.now().toIso8601String(),
        'phone': firebaseUser.phoneNumber ?? existingProfile.phone,
      };

      final response = await SupabaseConfig.client
          .from('profiles')
          .update(updateData)
          .eq('firebase_uid', firebaseUser.uid)
          .select()
          .single();
      
      return Profile.fromJson(response);
    } catch (e) {
      print('Error updating Supabase profile: $e');
      return existingProfile; // Return existing profile if update fails
    }
  }

  /// Handle Firebase user sign out (no Supabase auth to sign out from)
  static Future<void> signOut() async {
    try {
      // Only sign out from Firebase since we're not using Supabase Auth
      await FirebaseConfig.signOut();
      print('✅ Successfully signed out from Firebase');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Get current user profile from Supabase (linked to Firebase user)
  static Future<Profile?> getCurrentLinkedProfile() async {
    try {
      final firebaseUser = FirebaseConfig.currentUser;
      if (firebaseUser == null) {
        print('❌ No Firebase user found');
        return null;
      }
      
      print('🔍 Looking for profile for Firebase user: ${firebaseUser.uid}');
      return await _getSupabaseProfile(firebaseUser.uid);
    } catch (e) {
      print('Error getting current linked profile: $e');
      return null;
    }
  }

  /// Initialize user session - call this after successful Firebase authentication
  static Future<Profile?> initializeUserSession({String defaultRole = 'patient'}) async {
    try {
      final firebaseUser = FirebaseConfig.currentUser;
      if (firebaseUser == null) {
        print('❌ No Firebase user to initialize session for');
        return null;
      }
      
      print('🚀 Initializing user session for: ${firebaseUser.email}');
      
      // Sync Firebase user to Supabase database
      final profile = await syncUserToSupabase(firebaseUser, role: defaultRole);
      
      if (profile != null) {
        print('✅ User session initialized successfully: ${profile.email}');
      } else {
        print('❌ Failed to initialize user session');
      }
      
      return profile;
    } catch (e) {
      print('Error initializing user session: $e');
      return null;
    }
  }

  /// Check if Firebase user exists in Supabase database
  static Future<bool> isUserSynced() async {
    try {
      final firebaseUser = FirebaseConfig.currentUser;
      if (firebaseUser == null) return false;
      
      final supabaseProfile = await _getSupabaseProfile(firebaseUser.uid);
      return supabaseProfile != null;
    } catch (e) {
      print('Error checking user sync status: $e');
      return false;
    }
  }

  /// Handle user role change (e.g., from patient to dietitian)
  static Future<Profile?> updateUserRole(String newRole) async {
    try {
      final firebaseUser = FirebaseConfig.currentUser;
      if (firebaseUser == null) return null;
      
      final response = await SupabaseConfig.client
          .from('profiles')
          .update({
            'role': newRole,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('firebase_uid', firebaseUser.uid)
          .select()
          .single();
      
      return Profile.fromJson(response);
    } catch (e) {
      print('Error updating user role: $e');
      return null;
    }
  }
}