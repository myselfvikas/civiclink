import '../services/supabase_service.dart';
import '../models/civic_issue.dart';

class CivicIssuesService {
  static final SupabaseService _supabaseService = SupabaseService.instance;

  /// Get all issues with optional filtering
  static Future<List<CivicIssue>> getIssues({
    String? status,
    String? category,
    String? priority,
    int? limit,
    int? offset,
  }) async {
    try {
      var query = _supabaseService.client
          .from('civic_issues')
          .select('*')
          .eq('allow_public_view', true);

      // Apply filters
      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }
      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category);
      }
      if (priority != null && priority.isNotEmpty) {
        query = query.eq('priority', priority);
      }

      // Apply sorting and pagination
      final response = await query
          .order('created_at', ascending: false)
          .limit(limit ?? 50)
          .range(offset ?? 0, (offset ?? 0) + (limit ?? 50) - 1);

      return response
          .map<CivicIssue>((json) => CivicIssue.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch issues: $e');
    }
  }

  /// Get issue by ID
  static Future<CivicIssue?> getIssueById(String issueId) async {
    try {
      final response = await _supabaseService.client
          .from('civic_issues')
          .select('*')
          .eq('id', issueId)
          .eq('allow_public_view', true)
          .single();

      return CivicIssue.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch issue: $e');
    }
  }

  /// Create new issue
  static Future<CivicIssue> createIssue({
    required String title,
    required String description,
    required String category,
    required String priority,
    required String locationAddress,
    List<String>? imageUrls,
    bool isAnonymous = false,
    bool allowPublicView = true,
    String? department,
  }) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabaseService.client
          .from('civic_issues')
          .insert({
            'reporter_id': userId,
            'title': title,
            'description': description,
            'category': category,
            'priority': priority,
            'location_address': locationAddress,
            'image_urls': imageUrls,
            'is_anonymous': isAnonymous,
            'allow_public_view': allowPublicView,
            'department': department,
          })
          .select()
          .single();

      return CivicIssue.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create issue: $e');
    }
  }

  /// Update issue (only by reporter or officials)
  static Future<CivicIssue> updateIssue({
    required String issueId,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? locationAddress,
    List<String>? imageUrls,
    bool? isAnonymous,
    bool? allowPublicView,
    String? assignedTo,
    String? department,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (category != null) updateData['category'] = category;
      if (priority != null) updateData['priority'] = priority;
      if (status != null) updateData['status'] = status;
      if (locationAddress != null)
        updateData['location_address'] = locationAddress;
      if (imageUrls != null) updateData['image_urls'] = imageUrls;
      if (isAnonymous != null) updateData['is_anonymous'] = isAnonymous;
      if (allowPublicView != null)
        updateData['allow_public_view'] = allowPublicView;
      if (assignedTo != null) updateData['assigned_to'] = assignedTo;
      if (department != null) updateData['department'] = department;

      final response = await _supabaseService.client
          .from('civic_issues')
          .update(updateData)
          .eq('id', issueId)
          .select()
          .single();

      return CivicIssue.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update issue: $e');
    }
  }

  /// Vote on issue
  static Future<void> voteOnIssue(String issueId) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabaseService.client.from('issue_votes').insert({
        'issue_id': issueId,
        'voter_id': userId,
      });
    } catch (e) {
      throw Exception('Failed to vote on issue: $e');
    }
  }

  /// Remove vote from issue
  static Future<void> removeVoteFromIssue(String issueId) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      await _supabaseService.client
          .from('issue_votes')
          .delete()
          .eq('issue_id', issueId)
          .eq('voter_id', userId);
    } catch (e) {
      throw Exception('Failed to remove vote: $e');
    }
  }

  /// Check if user has voted on issue
  static Future<bool> hasUserVotedOnIssue(String issueId) async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabaseService.client
          .from('issue_votes')
          .select('id')
          .eq('issue_id', issueId)
          .eq('voter_id', userId);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get issues reported by current user
  static Future<List<CivicIssue>> getUserIssues() async {
    try {
      final userId = _supabaseService.client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await _supabaseService.client
          .from('civic_issues')
          .select('*')
          .eq('reporter_id', userId)
          .order('created_at', ascending: false);

      return response
          .map<CivicIssue>((json) => CivicIssue.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user issues: $e');
    }
  }

  /// Get issue statistics
  static Future<Map<String, int>> getIssueStatistics() async {
    try {
      // Get count by status
      final pendingCount = await _supabaseService.client
          .from('civic_issues')
          .select('id')
          .eq('status', 'pending')
          .eq('allow_public_view', true)
          .count();

      final inProgressCount = await _supabaseService.client
          .from('civic_issues')
          .select('id')
          .eq('status', 'in_progress')
          .eq('allow_public_view', true)
          .count();

      final resolvedCount = await _supabaseService.client
          .from('civic_issues')
          .select('id')
          .eq('status', 'resolved')
          .eq('allow_public_view', true)
          .count();

      return {
        'pending': pendingCount.count ?? 0,
        'in_progress': inProgressCount.count ?? 0,
        'resolved': resolvedCount.count ?? 0,
      };
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }
}
