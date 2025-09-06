import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MapFilterSheet extends StatefulWidget {
  final List<String> selectedCategories;
  final List<String> selectedStatuses;
  final Function(List<String>, List<String>) onFiltersChanged;

  const MapFilterSheet({
    Key? key,
    required this.selectedCategories,
    required this.selectedStatuses,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<MapFilterSheet> createState() => _MapFilterSheetState();
}

class _MapFilterSheetState extends State<MapFilterSheet> {
  late List<String> _selectedCategories;
  late List<String> _selectedStatuses;

  final List<Map<String, dynamic>> _categories = [
    {
      'id': 'garbage',
      'name': 'Garbage',
      'icon': 'delete',
      'color': Color(0xFF8B5CF6)
    },
    {
      'id': 'road_damage',
      'name': 'Road Damage',
      'icon': 'construction',
      'color': Color(0xFFEF4444)
    },
    {
      'id': 'water',
      'name': 'Water Issues',
      'icon': 'water_drop',
      'color': Color(0xFF3B82F6)
    },
    {
      'id': 'lighting',
      'name': 'Street Lighting',
      'icon': 'lightbulb',
      'color': Color(0xFFF59E0B)
    },
    {
      'id': 'traffic',
      'name': 'Traffic',
      'icon': 'traffic',
      'color': Color(0xFF10B981)
    },
    {
      'id': 'noise',
      'name': 'Noise Pollution',
      'icon': 'volume_up',
      'color': Color(0xFFEC4899)
    },
  ];

  final List<Map<String, dynamic>> _statuses = [
    {'id': 'pending', 'name': 'Pending', 'color': Color(0xFF6B7280)},
    {'id': 'in_progress', 'name': 'In Progress', 'color': Color(0xFFF59E0B)},
    {'id': 'resolved', 'name': 'Resolved', 'color': Color(0xFF10B981)},
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.selectedCategories);
    _selectedStatuses = List.from(widget.selectedStatuses);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoriesSection(context),
                  SizedBox(height: 3.h),
                  _buildStatusSection(context),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      width: 10.w,
      height: 0.5.h,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Filter Issues',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedCategories.clear();
                _selectedStatuses.clear();
              });
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _categories.map((category) {
            final isSelected = _selectedCategories.contains(category['id']);
            return FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category['id']);
                  } else {
                    _selectedCategories.remove(category['id']);
                  }
                });
              },
              avatar: CustomIconWidget(
                iconName: category['icon'],
                color: isSelected ? Colors.white : category['color'],
                size: 16,
              ),
              label: Text(category['name']),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: category['color'],
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _statuses.map((status) {
            final isSelected = _selectedStatuses.contains(status['id']);
            return FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedStatuses.add(status['id']);
                  } else {
                    _selectedStatuses.remove(status['id']);
                  }
                });
              },
              label: Text(status['name']),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              selectedColor: status['color'],
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                widget.onFiltersChanged(_selectedCategories, _selectedStatuses);
                Navigator.pop(context);
              },
              child: const Text('Apply Filters'),
            ),
          ),
        ],
      ),
    );
  }
}
