import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Your Supabase project credentials
  static const String supabaseUrl = 'https://ghhkddhbmrnbbewjogpq.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdoaGtkZGhibXJuYmJld2pvZ3BxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2MDcwNTksImV4cCI6MjA3NDE4MzA1OX0.13JFJFIoUldpzlkE_PP3TjKMc2HKryr81zQKwdP4IVU';
  
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
      debug: true, // Remove this in production
      // Disable Supabase Auth since we're using Firebase
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.implicit,
        detectSessionInUri: false,
        localStorage: EmptyLocalStorage(),
      ),
    );
  }
}

// You can get your actual values by running:
// npx supabase status --output=json
// Or from your Supabase dashboard at: https://supabase.com/dashboard/project/YOUR_PROJECT_REF