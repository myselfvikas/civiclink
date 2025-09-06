import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;
  double _proximityRadius = 5.0;

  final List<String> _issueTypes = [
    'All',
    'Garbage',
    'Road Damage',
    'Water',
    'Lighting',
    'Traffic',
    'Parks',
    'Noise',
  ];

  final List<String> _statusOptions = [
    'All',
    'Pending',
    'In Progress',
    'Resolved',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _proximityRadius = (_filters['proximityRadius'] as double?) ?? 5.0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[600] : Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Issues',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Issue Type Section
                  _buildFilterSection(
                    'Issue Type',
                    _buildIssueTypeFilters(),
                  ),
                  SizedBox(height: 3.h),
                  // Status Section
                  _buildFilterSection(
                    'Status',
                    _buildStatusFilters(),
                  ),
                  SizedBox(height: 3.h),
                  // Date Range Section
                  _buildFilterSection(
                    'Date Range',
                    _buildDateRangeFilters(),
                  ),
                  SizedBox(height: 3.h),
                  // Proximity Section
                  _buildFilterSection(
                    'Proximity Radius',
                    _buildProximityFilter(),
                  ),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          // Apply Button
          Container(
            padding: EdgeInsets.all(4.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: Text('Apply Filters'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 1.h),
        content,
      ],
    );
  }

  Widget _buildIssueTypeFilters() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: _issueTypes.map((type) {
        final isSelected = (_filters['issueType'] as String?) == type ||
            (type == 'All' && (_filters['issueType'] as String?) == null);
        return GestureDetector(
          onTap: () => _updateFilter('issueType', type == 'All' ? null : type),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.primary
                    : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              type,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : null,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusFilters() {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: _statusOptions.map((status) {
        final isSelected = (_filters['status'] as String?) == status ||
            (status == 'All' && (_filters['status'] as String?) == null);
        return GestureDetector(
          onTap: () => _updateFilter('status', status == 'All' ? null : status),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.getStatusColor(status, isLight: true)
                      .withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.getStatusColor(status, isLight: true)
                    : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              status,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.getStatusColor(status, isLight: true)
                        : null,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRangeFilters() {
    final dateRangeOptions = ['Today', 'This Week', 'This Month', 'All Time'];
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: dateRangeOptions.map((range) {
        final isSelected = (_filters['dateRange'] as String?) == range ||
            (range == 'All Time' && (_filters['dateRange'] as String?) == null);
        return GestureDetector(
          onTap: () =>
              _updateFilter('dateRange', range == 'All Time' ? null : range),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.lightTheme.colorScheme.secondary
                      .withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : Colors.grey,
                width: 1,
              ),
            ),
            child: Text(
              range,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.secondary
                        : null,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProximityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Within ${_proximityRadius.toInt()} km',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${_proximityRadius.toInt()} km',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.lightTheme.colorScheme.primary,
            thumbColor: AppTheme.lightTheme.colorScheme.primary,
            overlayColor:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2),
            inactiveTrackColor: Colors.grey[300],
            trackHeight: 4.0,
          ),
          child: Slider(
            value: _proximityRadius,
            min: 1.0,
            max: 50.0,
            divisions: 49,
            onChanged: (value) {
              setState(() {
                _proximityRadius = value;
              });
            },
          ),
        ),
      ],
    );
  }

  void _updateFilter(String key, dynamic value) {
    setState(() {
      if (value == null) {
        _filters.remove(key);
      } else {
        _filters[key] = value;
      }
    });
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _proximityRadius = 5.0;
    });
  }

  void _applyFilters() {
    _filters['proximityRadius'] = _proximityRadius;
    widget.onFiltersChanged(_filters);
    Navigator.pop(context);
  }
}
