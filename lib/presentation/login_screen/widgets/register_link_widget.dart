import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class RegisterLinkWidget extends StatelessWidget {
  const RegisterLinkWidget({super.key});

  void _handleRegisterNavigation(BuildContext context) {
    // TODO: Navigate to registration screen when available
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Registration feature coming soon'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'New Citizen? ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                  fontSize: 4.w > 16 ? 16 : 4.w,
                ),
          ),
          GestureDetector(
            onTap: () => _handleRegisterNavigation(context),
            child: Text(
              'Register',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 4.w > 16 ? 16 : 4.w,
                    decoration: TextDecoration.underline,
                    decorationColor: AppTheme.lightTheme.primaryColor,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}