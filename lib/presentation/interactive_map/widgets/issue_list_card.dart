import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class IssueListCard extends StatelessWidget {
  final Map<String, dynamic> issue;
  final VoidCallback onTap;

  const IssueListCard({
    Key? key,
    required this.issue,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIssueImage(context),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildIssueContent(context),
              ),
              _buildStatusBadge(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueImage(BuildContext context) {
    return Container(
      width: 15.w,
      height: 7.h,
      decoration: BoxDecoration(
        color: _getCategoryColor(issue['category'] as String),
        borderRadius: BorderRadius.circular(8),
      ),
      child: issue['imageUrl'] != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CustomImageWidget(
                imageUrl: issue['imageUrl'] as String,
                width: 15.w,
                height: 7.h,
                fit: BoxFit.cover,
              ),
            )
          : Center(
              child: CustomIconWidget(
                iconName: _getCategoryIcon(issue['category'] as String),
                color: Colors.white,
                size: 20,
              ),
            ),
    );
  }

  Widget _buildIssueContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatCategory(issue['category'] as String),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          issue['description'] as String,
          style: Theme.of(context).textTheme.bodySmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'location_on',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 14,
            ),
            SizedBox(width: 1.w),
            Expanded(
              child: Text(
                issue['address'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          _formatDate(issue['reportedAt'] as DateTime),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color:
            _getStatusColor(issue['status'] as String).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _formatStatus(issue['status'] as String),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: _getStatusColor(issue['status'] as String),
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'garbage':
        return const Color(0xFF8B5CF6);
      case 'road_damage':
        return const Color(0xFFEF4444);
      case 'water':
        return const Color(0xFF3B82F6);
      case 'lighting':
        return const Color(0xFFF59E0B);
      case 'traffic':
        return const Color(0xFF10B981);
      case 'noise':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'garbage':
        return 'delete';
      case 'road_damage':
        return 'construction';
      case 'water':
        return 'water_drop';
      case 'lighting':
        return 'lightbulb';
      case 'traffic':
        return 'traffic';
      case 'noise':
        return 'volume_up';
      default:
        return 'report_problem';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return const Color(0xFF10B981);
      case 'in_progress':
        return const Color(0xFFF59E0B);
      case 'pending':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _formatCategory(String category) {
    return category.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatStatus(String status) {
    return status.replaceAll('_', ' ').split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
