import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class IssueCardWidget extends StatelessWidget {
  final Map<String, dynamic> issue;
  final VoidCallback? onTap;
  final VoidCallback? onFollow;
  final VoidCallback? onShare;
  final VoidCallback? onReportDuplicate;
  final VoidCallback? onSave;
  final VoidCallback? onGetDirections;
  final VoidCallback? onContactDepartment;

  const IssueCardWidget({
    super.key,
    required this.issue,
    this.onTap,
    this.onFollow,
    this.onShare,
    this.onReportDuplicate,
    this.onSave,
    this.onGetDirections,
    this.onContactDepartment,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Slidable(
        key: ValueKey(issue['id']),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onFollow?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              foregroundColor: Colors.white,
              icon: Icons.notifications_active,
              label: 'Follow',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onShare?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              icon: Icons.share,
              label: 'Share',
              borderRadius: BorderRadius.circular(12),
            ),
            SlidableAction(
              onPressed: (_) => onReportDuplicate?.call(),
              backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
              foregroundColor: Colors.white,
              icon: Icons.report,
              label: 'Duplicate',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onTap,
          onLongPress: () => _showContextMenu(context),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Issue Image
                      Hero(
                        tag: 'issue_image_${issue['id']}',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CustomImageWidget(
                            imageUrl: issue['imageUrl'] as String,
                            width: 20.w,
                            height: 20.w,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      // Issue Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Category Icon
                                Container(
                                  padding: EdgeInsets.all(1.w),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(
                                            issue['category'] as String)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: CustomIconWidget(
                                    iconName: _getCategoryIcon(
                                        issue['category'] as String),
                                    color: _getCategoryColor(
                                        issue['category'] as String),
                                    size: 4.w,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                // Status Badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 2.w, vertical: 0.5.h),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getStatusColor(
                                        issue['status'] as String,
                                        isLight: !isDark),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    (issue['status'] as String).toUpperCase(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 9.sp,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            // Issue Title
                            Text(
                              issue['title'] as String,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 0.5.h),
                            // Location
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'location_on',
                                  color: isDark
                                      ? AppTheme.textMediumEmphasisDark
                                      : AppTheme.textMediumEmphasisLight,
                                  size: 3.5.w,
                                ),
                                SizedBox(width: 1.w),
                                Expanded(
                                  child: Text(
                                    issue['location'] as String,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: isDark
                                              ? AppTheme.textMediumEmphasisDark
                                              : AppTheme
                                                  .textMediumEmphasisLight,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Bottom Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Timestamp
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'access_time',
                            color: isDark
                                ? AppTheme.textMediumEmphasisDark
                                : AppTheme.textMediumEmphasisLight,
                            size: 3.5.w,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            _formatTimestamp(issue['timestamp'] as DateTime),
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: isDark
                                          ? AppTheme.textMediumEmphasisDark
                                          : AppTheme.textMediumEmphasisLight,
                                    ),
                          ),
                        ],
                      ),
                      // Priority Indicator
                      if (issue['priority'] != null)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: AppTheme.getPriorityColor(
                                    issue['priority'] as String,
                                    isLight: !isDark)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.getPriorityColor(
                                  issue['priority'] as String,
                                  isLight: !isDark),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            (issue['priority'] as String).toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelSmall
                                ?.copyWith(
                                  color: AppTheme.getPriorityColor(
                                      issue['priority'] as String,
                                      isLight: !isDark),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 9.sp,
                                ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 2.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'bookmark',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 6.w,
              ),
              title: Text('Save Issue'),
              onTap: () {
                Navigator.pop(context);
                onSave?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'directions',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 6.w,
              ),
              title: Text('Get Directions'),
              onTap: () {
                Navigator.pop(context);
                onGetDirections?.call();
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'contact_support',
                color: AppTheme.lightTheme.colorScheme.tertiary,
                size: 6.w,
              ),
              title: Text('Contact Department'),
              onTap: () {
                Navigator.pop(context);
                onContactDepartment?.call();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'garbage':
        return 'delete';
      case 'road damage':
        return 'construction';
      case 'water':
        return 'water_drop';
      case 'lighting':
        return 'lightbulb';
      case 'traffic':
        return 'traffic';
      case 'parks':
        return 'park';
      case 'noise':
        return 'volume_up';
      default:
        return 'report_problem';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'garbage':
        return Colors.brown;
      case 'road damage':
        return Colors.orange;
      case 'water':
        return Colors.blue;
      case 'lighting':
        return Colors.yellow[700]!;
      case 'traffic':
        return Colors.red;
      case 'parks':
        return Colors.green;
      case 'noise':
        return Colors.purple;
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}
