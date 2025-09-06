import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyStateWidget extends StatelessWidget {
  final VoidCallback? onReportIssue;

  const EmptyStateWidget({
    super.key,
    this.onReportIssue,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 60.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: (isDark
                      ? AppTheme.surfaceVariantDark
                      : AppTheme.surfaceVariantLight)
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'location_city',
                  color: isDark
                      ? AppTheme.textMediumEmphasisDark
                      : AppTheme.textMediumEmphasisLight,
                  size: 20.w,
                ),
                SizedBox(height: 2.h),
                CustomIconWidget(
                  iconName: 'add_circle_outline',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 12.w,
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          // Title
          Text(
            'No Issues Reported Yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.textHighEmphasisDark
                      : AppTheme.textHighEmphasisLight,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          // Description
          Text(
            'Be the first to make your community better by reporting local issues that need attention.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: isDark
                      ? AppTheme.textMediumEmphasisDark
                      : AppTheme.textMediumEmphasisLight,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          // CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onReportIssue,
              icon: CustomIconWidget(
                iconName: 'add_a_photo',
                color: Colors.white,
                size: 5.w,
              ),
              label: Text(
                'Report First Issue',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Secondary Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSecondaryAction(
                context,
                'View Map',
                'map',
                () => Navigator.pushNamed(context, '/interactive-map'),
              ),
              _buildSecondaryAction(
                context,
                'Learn More',
                'info',
                () {
                  // Show info dialog
                  _showInfoDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSecondaryAction(
    BuildContext context,
    String label,
    String iconName,
    VoidCallback onTap,
  ) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isDark ? AppTheme.outlineDark : AppTheme.outlineLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About CivicLink'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CivicLink helps you report and track local civic issues in your community.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Text(
              'How it works:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            SizedBox(height: 1.h),
            _buildInfoStep('1. Take a photo of the issue'),
            _buildInfoStep('2. Add location and description'),
            _buildInfoStep('3. Submit to relevant department'),
            _buildInfoStep('4. Track resolution progress'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoStep(String step) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomIconWidget(
            iconName: 'check_circle',
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              step,
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
        ],
      ),
    );
  }
}
