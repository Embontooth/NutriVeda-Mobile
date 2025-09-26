# Firebase-Supabase Integration Guide

This guide explains how Firebase Authentication is linked with Supabase database in the NutriVeda Mobile app.

## 🔗 **Integration Overview**

The app uses:
- **Firebase Auth** for user authentication (login, signup, Google sign-in)
- **Supabase** for database operations (storing user profiles, diet plans, etc.)
- **FirebaseSupabaseSync** service to link both services

## 📋 **How It Works**

### 1. User Authentication Flow
1. User signs in through Firebase (email/password or Google)
2. `FirebaseSupabaseSync.initializeUserSession()` is automatically called
3. The service creates or updates a profile in Supabase with the Firebase user's information
4. The profile is linked using the `firebase_uid` field

### 2. Data Access
- All database operations use Supabase
- User identification is done through the linked `firebase_uid` field
- Firebase token provides authentication, Supabase provides data

## 🚀 **Key Components**

### FirebaseSupabaseSync Service
Located: `lib/services/firebase_supabase_sync.dart`

**Main Methods:**
- `initializeUserSession()` - Call after Firebase login to sync user
- `getCurrentLinkedProfile()` - Get current user's Supabase profile
- `signOutFromBoth()` - Sign out from both services
- `updateUserRole()` - Change user role (patient/dietitian)

### Updated Profile Model
The `Profile` model now includes:
```dart
final String? firebaseUid; // Links to Firebase user
```

### Database Migration
Run this SQL in your Supabase dashboard:
```sql
-- Add firebase_uid column to profiles table
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS firebase_uid TEXT;
CREATE INDEX IF NOT EXISTS idx_profiles_firebase_uid ON profiles(firebase_uid);
ALTER TABLE profiles ADD CONSTRAINT unique_firebase_uid UNIQUE (firebase_uid);
```

## 🔧 **Usage Examples**

### 1. After User Login (Automatic)
The `AuthWrapper` in `main.dart` automatically handles this:
```dart
// This happens automatically when user signs in
FutureBuilder(
  future: FirebaseSupabaseSync.initializeUserSession(),
  builder: (context, snapshot) {
    // Shows loading while syncing user data
    // Then proceeds to HomeScreen
  },
);
```

### 2. Get Current User Profile
```dart
// In your screens/services
final profile = await FirebaseSupabaseSync.getCurrentLinkedProfile();
if (profile != null) {
  print('User: ${profile.fullName}, Role: ${profile.role}');
}
```

### 3. Sign Out from Both Services
```dart
// Use this instead of just Firebase.signOut()
await FirebaseConfig.signOutFromBoth();
```

### 4. Change User Role
```dart
// Promote patient to dietitian
final updatedProfile = await FirebaseSupabaseSync.updateUserRole('dietitian');
```

## ⚙️ **Configuration Requirements**

### 1. Database Setup
Make sure your Supabase `profiles` table has:
- `firebase_uid` TEXT column (nullable, unique)
- Proper RLS policies for data access

### 2. RLS Policies (Row Level Security)
Add these policies in Supabase dashboard:

```sql
-- Allow users to read their own profile
CREATE POLICY "Users can read own profile" ON profiles
FOR SELECT USING (firebase_uid = (SELECT raw_user_meta_data->>'firebase_uid' FROM auth.users WHERE id = auth.uid()));

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile" ON profiles
FOR UPDATE USING (firebase_uid = (SELECT raw_user_meta_data->>'firebase_uid' FROM auth.users WHERE id = auth.uid()));
```

### 3. Default User Role
When users first sign up, they're assigned the 'patient' role by default. You can change this in:
```dart
FirebaseSupabaseSync.initializeUserSession(defaultRole: 'dietitian')
```

## 🔍 **Troubleshooting**

### Issue: User not syncing to Supabase
**Solution:** Check the console for error messages. Common causes:
- Database connection issues
- Missing `firebase_uid` column
- RLS policy restrictions

### Issue: Authentication works but no data
**Solution:** Verify that:
1. The migration was applied to add `firebase_uid` column
2. The user profile exists in Supabase
3. RLS policies allow data access

### Issue: Multiple profiles for same user
**Solution:** The `firebase_uid` field has a unique constraint to prevent this. Check for existing profiles before creating new ones.

## 📱 **Testing the Integration**

### 1. Sign Up Test
1. Create a new account through the app
2. Check Supabase dashboard - a new profile should appear with `firebase_uid` populated
3. Verify the profile data matches the Firebase user

### 2. Sign In Test
1. Sign in with existing account
2. App should show user-specific data from Supabase
3. Dashboard should display real statistics

### 3. Role Change Test
```dart
// Test in a debug screen or console
final profile = await FirebaseSupabaseSync.updateUserRole('dietitian');
print('New role: ${profile?.role}');
```

## 🔐 **Security Considerations**

1. **Firebase UID as Primary Key**: The `firebase_uid` links the services securely
2. **RLS Policies**: Ensure users can only access their own data
3. **Token Validation**: Firebase tokens are used for API authentication
4. **Data Isolation**: Each user's data is isolated through proper database policies

## 🚀 **Next Steps**

1. Apply the database migration
2. Test user registration and login
3. Verify data synchronization
4. Set up proper RLS policies
5. Test role-based access control

The integration is now complete and ready for use! Users will experience seamless authentication through Firebase while their data is securely stored and managed through Supabase.