import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/user_profile.dart';

class AuthService {
  static final SupabaseService _supabaseService = SupabaseService.instance;

  /// Sign up with email and password
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String role = 'citizen',
  }) async {
    try {
      final response = await _supabaseService.client.auth.signUp(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Sign up failed');
      }

      // Insert into user_profiles (if trigger doesn’t already do this)
      await _supabaseService.client.from('user_profiles').insert({
        'id': user.id,
        'full_name': fullName,
        'role': role,
      });

      return response;
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseService.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Sign in failed');
      }

      return response;
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _supabaseService.client.auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  /// Get current user
  static User? getCurrentUser() {
    return _supabaseService.client.auth.currentUser;
  }

  /// Check if user is authenticated
  static bool isAuthenticated() {
    return _supabaseService.client.auth.currentUser != null;
  }

  /// Get current user profile
  static Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = getCurrentUser();
      if (user == null) return null;

      final response = await _supabaseService.client
          .from('user_profiles')
          .select('*')
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  static Future<UserProfile> updateUserProfile({
    required String fullName,
    String? phone,
    String? address,
    String? governmentId,
    String? profileImageUrl,
