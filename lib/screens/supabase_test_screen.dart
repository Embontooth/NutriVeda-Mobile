import 'package:flutter/material.dart';
import 'package:nutriveda_mobile/supabase_config.dart';

class SupabaseTestScreen extends StatefulWidget {
  const SupabaseTestScreen({super.key});

  @override
  State<SupabaseTestScreen> createState() => _SupabaseTestScreenState();
}

class _SupabaseTestScreenState extends State<SupabaseTestScreen> {
  String connectionStatus = 'Testing connection...';

  @override
  void initState() {
    super.initState();
    testConnection();
  }

  Future<void> testConnection() async {
    try {
      // Simple test query to check connection
      await SupabaseConfig.client
          .from('_realtime_schema_migrations') // This table should exist
          .select('version')
          .limit(1);
      
      setState(() {
        connectionStatus = '✅ Connected to Supabase successfully!\nProject: Rose-Pryia\'s Project';
      });
    } catch (e) {
      setState(() {
        connectionStatus = '❌ Connection failed: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Connection Test'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Connection Status:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              connectionStatus,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            const Text(
              'Project Details:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('URL: ${SupabaseConfig.supabaseUrl}'),
            const SizedBox(height: 8),
            Text('Project ID: ghhkddhbmrnbbewjogpq'),
            const SizedBox(height: 8),
            Text('Region: ap-south-1 (Mumbai)'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: testConnection,
              child: const Text('Test Connection Again'),
            ),
          ],
        ),
      ),
    );
  }
}