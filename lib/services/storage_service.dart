import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

class StorageService {
  static final SupabaseService _supabaseService = SupabaseService.instance;

  /// Upload issue image
  static Future<String> uploadIssueImage({
    required File file,
    required String fileName,
  }) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final filePath = '$userId/issues/$fileName';

      await _supabaseService.client.storage
          .from('issue-images')
          .upload(filePath, file);

      final publicUrl = _supabaseService.client.storage
          .from('issue-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload issue image from bytes (web support)
  static Future<String> uploadIssueImageFromBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final filePath = '$userId/issues/$fileName';

      await _supabaseService.client.storage
          .from('issue-images')
          .uploadBinary(filePath, bytes);

      final publicUrl = _supabaseService.client.storage
          .from('issue-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Upload profile image
  static Future<String> uploadProfileImage({
    required File file,
    required String fileName,
  }) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final filePath = '$userId/profile/$fileName';

      await _supabaseService.client.storage
          .from('profile-images')
          .upload(filePath, file);

      final publicUrl = _supabaseService.client.storage
          .from('profile-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Upload profile image from bytes (web support)
  static Future<String> uploadProfileImageFromBytes({
    required Uint8List bytes,
    required String fileName,
  }) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final filePath = '$userId/profile/$fileName';

      await _supabaseService.client.storage.from('profile-images').uploadBinary(
          filePath, bytes);

      final publicUrl = _supabaseService.client.storage
          .from('profile-images')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Delete image from storage
  static Future<void> deleteImage({
    required String bucket,
    required String filePath,
  }) async {
    try {
      await _supabaseService.client.storage.from(bucket).remove([filePath]);
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Get image download URL
  static String getPublicUrl({
    required String bucket,
    required String filePath,
  }) {
    return _supabaseService.client.storage.from(bucket).getPublicUrl(filePath);
  }

  /// Download image as bytes
  static Future<Uint8List> downloadImage({
    required String bucket,
    required String filePath,
  }) async {
    try {
      final response =
          await _supabaseService.client.storage.from(bucket).download(filePath);

      return response;
    } catch (e) {
      throw Exception('Failed to download image: $e');
    }
  }

  /// Generate unique filename for image
  static String generateUniqueFileName(String originalFileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final extension = originalFileName.split('.').last;
    return '${timestamp}_image.$extension';
  }
}