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
        data: {
          'full_name': fullName,
          'role': role,
        },
      );

      if (response.user == null) {
        throw Exception('Sign up failed');
      }

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
  }) async {
    try {
      final user = getCurrentUser();
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final updateData = <String, dynamic>{
        'full_name': fullName,
      };

      if (phone != null) updateData['phone'] = phone;
      if (address != null) updateData['address'] = address;
      if (governmentId != null) updateData['government_id'] = governmentId;
      if (profileImageUrl != null)
        updateData['profile_image_url'] = profileImageUrl;

      final response = await _supabaseService.client
          .from('user_profiles')
          .update(updateData)
          .eq('id', user.id)
          .select()
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Reset password
  static Future<void> resetPassword({required String email}) async {
    try {
      await _supabaseService.client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    return _supabaseService.client.auth.onAuthStateChange;
  }

  /// Check if user has admin privileges
  static Future<bool> isUserAdmin() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.role == 'admin' ||
          profile?.role == 'inspector' ||
          profile?.role == 'government_official';
    } catch (e) {
      return false;
    }
  }

  /// Get user role
  static Future<String> getUserRole() async {
    try {
      final profile = await getCurrentUserProfile();
      return profile?.role ?? 'citizen';
    } catch (e) {
      return 'citizen';
    }
  }
}
