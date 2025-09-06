import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class PrioritySelectorWidget extends StatelessWidget {
  final String? selectedPriority;
  final Function(String) onPrioritySelected;

  const PrioritySelectorWidget({
    Key? key,
    this.selectedPriority,
    required this.onPrioritySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> priorities = [
      {
        'id': 'low',
        'name': 'Low Priority',
        'description':
            'Minor issues that can be addressed in routine maintenance',
        'icon': 'trending_down',
        'color': AppTheme.lightTheme.colorScheme.secondary,
        'examples': 'Cosmetic damage, minor landscaping',
      },
      {
        'id': 'medium',
        'name': 'Medium Priority',
        'description': 'Issues that affect daily life but are not urgent',
        'icon': 'trending_flat',
        'color': Color(0xFFF59E0B),
        'examples': 'Broken streetlight, minor road damage',
      },
      {
        'id': 'high',
        'name': 'High Priority',
        'description':
            'Urgent issues that pose safety risks or major inconvenience',
        'icon': 'trending_up',
        'color': Color(0xFFEF4444),
        'examples': 'Water main break, dangerous road conditions',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority Level',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Help us understand the urgency of this issue',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 12),
        Column(
          children: priorities.map((priority) {
            final isSelected = selectedPriority == priority['id'];

            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onPrioritySelected(priority['id']),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? priority['color'].withValues(alpha: 0.1)
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? priority['color']
                          : AppTheme.lightTheme.colorScheme.outline,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: priority['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: CustomIconWidget(
                          iconName: priority['icon'],
                          color: priority['color'],
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  priority['name'],
                                  style: AppTheme
                                      .lightTheme.textTheme.titleSmall
                                      ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? priority['color']
                                        : AppTheme
                                            .lightTheme.colorScheme.onSurface,
                                  ),
                                ),
                                if (isSelected) ...[
                                  SizedBox(width: 8),
                                  CustomIconWidget(
                                    iconName: 'check_circle',
                                    color: priority['color'],
                                    size: 16,
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              priority['description'],
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 6),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: priority['color'].withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Examples: ${priority['examples']}',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  fontSize: 10,
                                  color: priority['color'],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
