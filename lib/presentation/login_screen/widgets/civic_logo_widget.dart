import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CivicLogoWidget extends StatelessWidget {
  const CivicLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 20.h,
      constraints: BoxConstraints(
        maxWidth: 200,
        maxHeight: 150,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20.w,
            height: 10.h,
            constraints: BoxConstraints(
              maxWidth: 80,
              maxHeight: 80,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color:
                      AppTheme.lightTheme.primaryColor.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: 'location_city',
                color: Colors.white,
                size: 8.w > 40 ? 40 : 8.w,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'CivicLink',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 6.w > 28 ? 28 : 6.w,
                ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Connecting Citizens & Communities',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textMediumEmphasisLight,
                  fontSize: 3.w > 14 ? 14 : 3.w,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
