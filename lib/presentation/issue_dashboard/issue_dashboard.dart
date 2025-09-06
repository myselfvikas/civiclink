import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/issue_card_widget.dart';
import './widgets/skeleton_card_widget.dart';

class IssueDashboard extends StatefulWidget {
  const IssueDashboard({super.key});

  @override
  State<IssueDashboard> createState() => _IssueDashboardState();
}

class _IssueDashboardState extends State<IssueDashboard>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  int _currentIndex = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  Map<String, dynamic> _activeFilters = {};
  List<Map<String, dynamic>> _issues = [];
  List<Map<String, dynamic>> _filteredIssues = [];
  String _currentLocation = 'Downtown, Springfield';
  bool _isOffline = false;
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _loadMockData();
    _scrollController.addListener(_onScroll);
    _lastUpdated = DateTime.now();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMockData() {
    _issues = [
      {
        "id": 1,
        "title": "Broken streetlight on Main Street",
        "category": "Lighting",
        "status": "Pending",
        "priority": "High",
        "location": "Main Street & 5th Avenue",
        "imageUrl":
            "https://images.pexels.com/photos/1108572/pexels-photo-1108572.jpeg?auto=compress&cs=tinysrgb&w=800",
        "timestamp": DateTime.now().subtract(Duration(hours: 2)),
        "description":
            "The streetlight has been flickering for days and now completely dark.",
        "department": "Public Works",
        "votes": 12,
      },
      {
        "id": 2,
        "title": "Pothole causing traffic issues",
        "category": "Road Damage",
        "status": "In Progress",
        "priority": "Medium",
        "location": "Oak Street near City Hall",
        "imageUrl":
            "https://images.pexels.com/photos/1108101/pexels-photo-1108101.jpeg?auto=compress&cs=tinysrgb&w=800",
        "timestamp": DateTime.now().subtract(Duration(hours: 5)),
        "description":
            "Large pothole is causing vehicles to swerve dangerously.",
        "department": "Transportation",
        "votes": 8,
      },
      {
        "id": 3,
        "title": "Overflowing garbage bins in Central Park",
        "category": "Garbage",
        "status": "Resolved",
        "priority": "Low",
        "location": "Central Park - East Entrance",
        "imageUrl":
            "https://images.pexels.com/photos/2827392/pexels-photo-2827392.jpeg?auto=compress&cs=tinysrgb&w=800",
        "timestamp": DateTime.now().subtract(Duration(days: 1)),
        "description":
            "Multiple garbage bins are overflowing, attracting pests.",
        "department": "Sanitation",
        "votes": 15,
      },
      {
        "id": 4,
        "title": "Water leak near bus stop",
        "category": "Water",
        "status": "Pending",
        "priority": "High",
        "location": "Bus Stop #42 - Elm Street",
        "imageUrl":
            "https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg?auto=compress&cs=tinysrgb&w=800",
        "timestamp": DateTime.now().subtract(Duration(hours: 8)),
        "description":
            "Continuous water leak creating puddles and potential hazard.",
        "department": "Water Department",
        "votes": 6,
      },
      {
        "id": 5,
        "title": "Excessive noise from construction site",
        "category": "Noise",
        "status": "In Progress",
        "priority": "Medium",
        "location": "Construction Site - Pine Avenue",
        "imageUrl":
            "https://images.pexels.com/photos/1108117/pexels-photo-1108117.jpeg?auto=compress&cs=tinysrgb&w=800",
        "timestamp": DateTime.now().subtract(Duration(hours: 12)),
        "description":
            "Construction noise exceeding permitted hours and decibel levels.",
        "department": "Code Enforcement",
        "votes": 9,
      },
      {
        "id": 6,
        "title": "Damaged playground equipment",
        "category": "Parks",
        "status": "Pending",
        "priority": "High",
        "location": "Riverside Park - Playground Area",
        "imageUrl":
            "https://images.pexels.com/photos/1108101/pexels-photo-1108101.jpeg?auto=compress&cs=tinysrgb&w=800",
        "timestamp": DateTime.now().subtract(Duration(days: 2)),
        "description":
            "Swing set has broken chains, creating safety hazard for children.",
        "department": "Parks & Recreation",
        "votes": 18,
      },
    ];

    _applyFilters();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreIssues();
    }
  }

  Future<void> _loadMoreIssues() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate loading more data
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isLoadingMore = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate refresh
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _lastUpdated = DateTime.now();
    });

    Fluttertoast.showToast(
      msg: "Issues updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _applyFilters() {
    setState(() {
      _filteredIssues = _issues.where((issue) {
        // Filter by issue type
        if (_activeFilters['issueType'] != null) {
          if ((issue['category'] as String).toLowerCase() !=
              (_activeFilters['issueType'] as String).toLowerCase()) {
            return false;
          }
        }

        // Filter by status
        if (_activeFilters['status'] != null) {
          if ((issue['status'] as String).toLowerCase() !=
              (_activeFilters['status'] as String).toLowerCase()) {
            return false;
          }
        }

        // Filter by date range
        if (_activeFilters['dateRange'] != null) {
          final now = DateTime.now();
          final issueDate = issue['timestamp'] as DateTime;

          switch (_activeFilters['dateRange'] as String) {
            case 'Today':
              if (!_isSameDay(issueDate, now)) return false;
              break;
            case 'This Week':
              if (now.difference(issueDate).inDays > 7) return false;
              break;
            case 'This Month':
              if (now.difference(issueDate).inDays > 30) return false;
              break;
          }
        }

        return true;
      }).toList();
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 80.h,
        child: FilterBottomSheetWidget(
          currentFilters: _activeFilters,
          onFiltersChanged: (filters) {
            setState(() {
              _activeFilters = filters;
            });
            _applyFilters();
          },
        ),
      ),
    );
  }

  void _removeFilter(String key) {
    setState(() {
      _activeFilters.remove(key);
    });
    _applyFilters();
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Dashboard - already here
        break;
      case 1:
        Navigator.pushNamed(context, '/report-issue');
        break;
      case 2:
        Navigator.pushNamed(context, '/interactive-map');
        break;
      case 3:
        Navigator.pushNamed(context, '/user-profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                boxShadow: [
                  BoxShadow(
                    color:
                        (isDark ? AppTheme.shadowDark : AppTheme.shadowLight),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Location
                      Expanded(
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'location_on',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 5.w,
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentLocation,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (_isOffline || _lastUpdated != null)
                                    Text(
                                      _isOffline
                                          ? 'Offline mode'
                                          : 'Updated ${_formatLastUpdated()}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: _isOffline
                                                ? AppTheme.lightTheme
                                                    .colorScheme.tertiary
                                                : (isDark
                                                    ? AppTheme
                                                        .textMediumEmphasisDark
                                                    : AppTheme
                                                        .textMediumEmphasisLight),
                                          ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Filter Button
                      GestureDetector(
                        onTap: _showFilterBottomSheet,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: _activeFilters.isNotEmpty
                                ? AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _activeFilters.isNotEmpty
                                  ? AppTheme.lightTheme.colorScheme.primary
                                  : (isDark
                                      ? AppTheme.outlineDark
                                      : AppTheme.outlineLight),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              CustomIconWidget(
                                iconName: 'tune',
                                color: _activeFilters.isNotEmpty
                                    ? AppTheme.lightTheme.colorScheme.primary
                                    : (isDark
                                        ? AppTheme.textMediumEmphasisDark
                                        : AppTheme.textMediumEmphasisLight),
                                size: 5.w,
                              ),
                              if (_activeFilters.isNotEmpty)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 2.w,
                                    height: 2.w,
                                    decoration: BoxDecoration(
                                      color:
                                          AppTheme.lightTheme.colorScheme.error,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Filter Chips
                  if (_activeFilters.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    SizedBox(
                      height: 5.h,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _activeFilters.entries.map((entry) {
                          if (entry.key == 'proximityRadius')
                            return SizedBox.shrink();

                          return FilterChipWidget(
                            label: '${entry.key}: ${entry.value}',
                            isSelected: true,
                            onRemove: () => _removeFilter(entry.key),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Main Content
            Expanded(
              child: _filteredIssues.isEmpty && !_isLoading
                  ? EmptyStateWidget(
                      onReportIssue: () =>
                          Navigator.pushNamed(context, '/report-issue'),
                    )
                  : RefreshIndicator(
                      key: _refreshIndicatorKey,
                      onRefresh: _refreshData,
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: _isLoading
                            ? 5
                            : _filteredIssues.length + (_isLoadingMore ? 3 : 0),
                        itemBuilder: (context, index) {
                          if (_isLoading) {
                            return SkeletonCardWidget();
                          }

                          if (index >= _filteredIssues.length) {
                            return SkeletonCardWidget();
                          }

                          final issue = _filteredIssues[index];
                          return IssueCardWidget(
                            issue: issue,
                            onTap: () {
                              // Navigate to issue detail with shared element transition
                              Fluttertoast.showToast(
                                msg: "Opening issue details...",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            },
                            onFollow: () {
                              Fluttertoast.showToast(
                                msg: "Following issue updates",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            },
                            onShare: () {
                              Fluttertoast.showToast(
                                msg: "Sharing issue...",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            },
                            onReportDuplicate: () {
                              Fluttertoast.showToast(
                                msg: "Reporting as duplicate",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            },
                            onSave: () {
                              Fluttertoast.showToast(
                                msg: "Issue saved",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            },
                            onGetDirections: () {
                              Fluttertoast.showToast(
                                msg: "Opening directions...",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            },
                            onContactDepartment: () {
                              Fluttertoast.showToast(
                                msg: "Contacting ${issue['department']}...",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                              );
                            },
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/report-issue'),
        icon: CustomIconWidget(
          iconName: 'add_a_photo',
          color: Colors.white,
          size: 5.w,
        ),
        label: Text(
          'Report Issue',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: _currentIndex == 0
                  ? AppTheme.lightTheme.colorScheme.primary
                  : (isDark
                      ? AppTheme.textMediumEmphasisDark
                      : AppTheme.textMediumEmphasisLight),
              size: 6.w,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'add_circle_outline',
              color: _currentIndex == 1
                  ? AppTheme.lightTheme.colorScheme.primary
                  : (isDark
                      ? AppTheme.textMediumEmphasisDark
                      : AppTheme.textMediumEmphasisLight),
              size: 6.w,
            ),
            label: 'Report',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'map',
              color: _currentIndex == 2
                  ? AppTheme.lightTheme.colorScheme.primary
                  : (isDark
                      ? AppTheme.textMediumEmphasisDark
                      : AppTheme.textMediumEmphasisLight),
              size: 6.w,
            ),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'person',
              color: _currentIndex == 3
                  ? AppTheme.lightTheme.colorScheme.primary
                  : (isDark
                      ? AppTheme.textMediumEmphasisDark
                      : AppTheme.textMediumEmphasisLight),
              size: 6.w,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _formatLastUpdated() {
    if (_lastUpdated == null) return '';

    final now = DateTime.now();
    final difference = now.difference(_lastUpdated!);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
