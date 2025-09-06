import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class CategorySelectionWidget extends StatelessWidget {
  final String? selectedCategory;
  final Function(String) onCategorySelected;
  final Map<String, double>? aiSuggestions;

  const CategorySelectionWidget({
    Key? key,
    this.selectedCategory,
    required this.onCategorySelected,
    this.aiSuggestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {
        'id': 'roads',
        'name': 'Roads & Infrastructure',
        'icon': 'construction',
        'color': AppTheme.lightTheme.colorScheme.primary,
      },
      {
        'id': 'waste',
        'name': 'Waste Management',
        'icon': 'delete',
        'color': AppTheme.lightTheme.colorScheme.secondary,
      },
      {
        'id': 'lighting',
        'name': 'Street Lighting',
        'icon': 'lightbulb',
        'color': Color(0xFFF59E0B),
      },
      {
        'id': 'water',
        'name': 'Water & Drainage',
        'icon': 'water_drop',
        'color': Color(0xFF06B6D4),
      },
      {
        'id': 'parks',
        'name': 'Parks & Recreation',
        'icon': 'park',
        'color': Color(0xFF10B981),
      },
      {
        'id': 'traffic',
        'name': 'Traffic & Parking',
        'icon': 'traffic',
        'color': Color(0xFFEF4444),
      },
      {
        'id': 'utilities',
        'name': 'Public Utilities',
        'icon': 'electrical_services',
        'color': Color(0xFF8B5CF6),
      },
      {
        'id': 'other',
        'name': 'Other Issues',
        'icon': 'more_horiz',
        'color': AppTheme.lightTheme.colorScheme.outline,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Issue Category',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        if (aiSuggestions != null && aiSuggestions!.isNotEmpty) ...[
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'auto_awesome',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'AI Suggestions',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: aiSuggestions!.entries.map((entry) {
                    final category = categories.firstWhere(
                      (cat) => cat['id'] == entry.key,
                      orElse: () => categories.last,
                    );
                    final confidence = (entry.value * 100).round();

                    return GestureDetector(
                      onTap: () => onCategorySelected(entry.key),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selectedCategory == entry.key
                              ? AppTheme.lightTheme.colorScheme.primary
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              category['name'],
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: selectedCategory == entry.key
                                    ? Colors.white
                                    : AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 4),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: selectedCategory == entry.key
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : AppTheme.lightTheme.colorScheme.primary
                                        .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$confidence%',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  fontSize: 10,
                                  color: selectedCategory == entry.key
                                      ? Colors.white
                                      : AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Text(
            'All Categories',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
        ],
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2.5,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category['id'];

            return GestureDetector(
              onTap: () => onCategorySelected(category['id']),
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? category['color'].withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? category['color']
                        : AppTheme.lightTheme.colorScheme.outline,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: category['color'].withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: category['icon'],
                        color: category['color'],
                        size: 20,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        category['name'],
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected
                              ? category['color']
                              : AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
