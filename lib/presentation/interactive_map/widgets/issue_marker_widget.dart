import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class IssueMarkerWidget extends StatelessWidget {
  final String category;
  final String status;
  final int count;
  final bool isCluster;
  final VoidCallback? onTap;

  const IssueMarkerWidget({
    Key? key,
    required this.category,
    required this.status,
    this.count = 1,
    this.isCluster = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isCluster ? 15.w : 10.w,
        height: isCluster ? 7.5.h : 5.h,
        decoration: BoxDecoration(
          color: _getCategoryColor(category),
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.surface,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isCluster
            ? Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              )
            : Center(
                child: CustomIconWidget(
                  iconName: _getCategoryIcon(category),
                  color: Colors.white,
                  size: isCluster ? 20 : 16,
                ),
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
}
