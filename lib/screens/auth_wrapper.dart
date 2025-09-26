import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutriveda_mobile/screens/home_screen.dart';
import 'package:nutriveda_mobile/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading indicator while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        // If user is authenticated, show home screen
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
        
        // If user is not authenticated, show login screen
        return const LoginScreen();
      },
    );
  }
}
