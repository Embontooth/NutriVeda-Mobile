import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/firebase_config.dart';
import 'package:nutriveda_mobile/services/firebase_supabase_sync.dart';
import 'package:nutriveda_mobile/models/database_models.dart';

class FirebaseSupabaseSyncTestScreen extends StatefulWidget {
  const FirebaseSupabaseSyncTestScreen({super.key});

  @override
  State<FirebaseSupabaseSyncTestScreen> createState() => _FirebaseSupabaseSyncTestScreenState();
}

class _FirebaseSupabaseSyncTestScreenState extends State<FirebaseSupabaseSyncTestScreen> {
  Profile? _currentProfile;
  bool _isLoading = false;
  String _statusMessage = 'Ready to test sync';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase-Supabase Sync Test'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Firebase User Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Firebase User Info',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Signed In: ${FirebaseConfig.isSignedIn}'),
                    if (FirebaseConfig.currentUser != null) ...[
                      Text('Email: ${FirebaseConfig.currentUser!.email}'),
                      Text('UID: ${FirebaseConfig.currentUser!.uid}'),
                      Text('Display Name: ${FirebaseConfig.currentUser!.displayName ?? 'N/A'}'),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Supabase Profile Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Supabase Profile Info',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (_currentProfile != null) ...[
                      Text('ID: ${_currentProfile!.id}'),
                      Text('Email: ${_currentProfile!.email}'),
                      Text('Full Name: ${_currentProfile!.fullName}'),
                      Text('Role: ${_currentProfile!.role}'),
                      Text('Firebase UID: ${_currentProfile!.firebaseUid}'),
                      Text('Created: ${_currentProfile!.createdAt}'),
                    ] else ...[
                      const Text('No profile found'),
                    ],
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Status Message
            Card(
              color: Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Status: $_statusMessage',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Test Buttons
            if (FirebaseConfig.isSignedIn) ...[
              ElevatedButton(
                onPressed: _isLoading ? null : _testGetLinkedProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Get Linked Profile'),
              ),
              
              const SizedBox(height: 8),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _testSyncUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Force Sync User'),
              ),
              
              const SizedBox(height: 8),
              
              ElevatedButton(
                onPressed: _isLoading ? null : _testIsUserSynced,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Check If User Synced'),
              ),
            ] else ...[
              const Text(
                'Please sign in first to test sync functionality',
                style: TextStyle(fontSize: 16, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _testGetLinkedProfile() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Getting linked profile...';
    });

    try {
      final profile = await FirebaseSupabaseSync.getCurrentLinkedProfile();
      setState(() {
        _currentProfile = profile;
        _statusMessage = profile != null 
          ? 'Profile loaded successfully' 
          : 'No linked profile found';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting profile: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testSyncUser() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Syncing user to Supabase...';
    });

    try {
      final firebaseUser = FirebaseConfig.currentUser;
      if (firebaseUser != null) {
        final profile = await FirebaseSupabaseSync.syncUserToSupabase(firebaseUser);
        setState(() {
          _currentProfile = profile;
          _statusMessage = profile != null 
            ? 'User synced successfully!' 
            : 'Failed to sync user';
        });
      } else {
        setState(() {
          _statusMessage = 'No Firebase user found';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error syncing user: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testIsUserSynced() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking sync status...';
    });

    try {
      final isSynced = await FirebaseSupabaseSync.isUserSynced();
      setState(() {
        _statusMessage = 'User sync status: ${isSynced ? 'SYNCED' : 'NOT SYNCED'}';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking sync: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}