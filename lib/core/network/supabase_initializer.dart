import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseInitializer {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: 'https://xlaekoqzqdwvfzfhtmym.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhsYWVrb3F6cWR3dmZ6Zmh0bXltIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1MjMzMDQsImV4cCI6MjA4MDA5OTMwNH0.Q6VgABZ4VB4x6cWHohN-v-yOaMjy8fuKXFhJrP-leyA',
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
