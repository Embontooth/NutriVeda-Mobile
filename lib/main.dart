import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/theme/app_theme.dart';
import 'package:nutriveda_mobile/screens/login_screen.dart';
import 'package:nutriveda_mobile/screens/home_screen.dart';
import 'package:nutriveda_mobile/firebase_config.dart';
import 'package:nutriveda_mobile/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase and Supabase
  await FirebaseConfig.initialize();
  await SupabaseConfig.initialize();
  
  runApp(const NutriVedaApp());
}

class NutriVedaApp extends StatelessWidget {
  const NutriVedaApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriVeda Mobile',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseConfig.auth.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is signed in, go to home screen (sync can be tested manually)
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        
        // If user is not signed in, go to login screen
        return const LoginScreen();
      },
    );
  }
}