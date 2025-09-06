import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class GovernmentIdWidget extends StatelessWidget {
  final VoidCallback? onGovernmentIdLogin;

  const GovernmentIdWidget({
    super.key,
    this.onGovernmentIdLogin,
  });

  void _handleGovernmentIdLogin(BuildContext context) {
    if (kIsWeb) {
      // Web implementation - show dialog for government ID
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Government ID Login'),
          content: const Text(
              'Government ID authentication is not available on web platform. Please use email/password login.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } else {
      // Mobile implementation - simulate government ID integration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Government ID authentication coming soon'),
          backgroundColor: AppTheme.lightTheme.primaryColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Divider with "OR" text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: AppTheme.dividerLight,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OR',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textMediumEmphasisLight,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Expanded(
              child: Divider(
                color: AppTheme.dividerLight,
                thickness: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),

        // Government ID Login Button
        SizedBox(
          width: double.infinity,
          height: 7.h,
          child: OutlinedButton.icon(
            onPressed: () => _handleGovernmentIdLogin(context),
            icon: CustomIconWidget(
              iconName: 'account_balance',
              color: AppTheme.lightTheme.primaryColor,
              size: 5.w > 24 ? 24 : 5.w,
            ),
            label: Text(
              'Login with Government ID',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 4.w > 16 ? 16 : 4.w,
                  ),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppTheme.lightTheme.primaryColor,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(height: 2.h),

        // Info text
        Text(
          'Secure authentication using your government-issued digital ID',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textMediumEmphasisLight,
                fontSize: 3.w > 12 ? 12 : 3.w,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
