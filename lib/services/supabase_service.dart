import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Singleton pattern
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  /// --- Option 1: Use dart-define (preferred for production) ---
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  /// --- Option 2: Fallback to hardcoded keys (for local dev) ---
  static const String fallbackUrl =
      'https://nwraxhyomamwyxsscdup.supabase.co'; // your project URL
  static const String fallbackAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53cmF4aHlvbWFtd3l4c3NjZHVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODIyNjAsImV4cCI6MjA3MzE1ODI2MH0.0c9AOJn-aWO6LFIbsh4WRnbMLL2kY9cTX3XXk-oz-Ho';

  /// Initialize Supabase - call this in main()
  static Future<void> initialize() async {
    final url = supabaseUrl.isNotEmpty ? supabaseUrl : fallbackUrl;
    final key = supabaseAnonKey.isNotEmpty ? supabaseAnonKey : fallbackAnonKey;

    if (url.isEmpty || key.isEmpty) {
      throw Exception(
          'Supabase URL and Anon Key are missing. Please configure them.');
    }

    await Supabase.initialize(
      url: url,
      anonKey: key,
    );
  }

  /// Get Supabase client
  SupabaseClient get client => Supabase.instance.client;
}
