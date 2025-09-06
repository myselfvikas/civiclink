import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/civic_issues_service.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/civic_stats_widget.dart';
import './widgets/my_issues_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/user_avatar_widget.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile>
    with TickerProviderStateMixin {
  late TabController _tabController;

  UserProfile? _userProfile;
  Map<String, int> _issueStats = {};
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _isAuthenticated = AuthService.isAuthenticated();

      if (_isAuthenticated) {
        // Load user profile
        final profile = await AuthService.getCurrentUserProfile();

        // Load user statistics
        final userIssues = await CivicIssuesService.getUserIssues();
        final stats = <String, int>{
          'total_issues': userIssues.length,
          'pending': userIssues.where((i) => i.status == 'pending').length,
          'in_progress':
              userIssues.where((i) => i.status == 'in_progress').length,
          'resolved': userIssues.where((i) => i.status == 'resolved').length,
        };

        setState(() {
          _userProfile = profile as UserProfile?;
          _issueStats = stats;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleSignOut() async {
    try {
      await AuthService.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login-screen');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to sign out: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildUnauthenticatedView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 20.w,
              color: AppTheme.textMediumEmphasisLight,
            ),
            SizedBox(height: 3.h),
            Text(
              'Sign In Required',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textHighEmphasisLight,
                  ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Please sign in to view your profile and track your civic engagement.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textMediumEmphasisLight,
                  ),
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login-screen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Profile',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textHighEmphasisLight,
                  fontWeight: FontWeight.w700,
                ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _buildUnauthenticatedView(),
      );
    }

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'My Profile',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: AppTheme.textHighEmphasisLight,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                      IconButton(
                        onPressed: _handleSignOut,
                        icon: Icon(
                          Icons.logout,
                          color: AppTheme.lightTheme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  UserAvatarWidget(
                    imageUrl: _userProfile?.profileImageUrl ?? '',
                    onTap: () {},
                  ),
                  SizedBox(height: 3.h),
                  CivicStatsWidget(
                    issuesReported: _issueStats['total_issues'] ?? 0,
                    impactScore: _issueStats['resolved'] ?? 0,
                    memberSince: 'Jan 2024',
                  ),
                ],
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.lightTheme.colorScheme.primary,
              labelColor: AppTheme.lightTheme.colorScheme.primary,
              unselectedLabelColor: AppTheme.textMediumEmphasisLight,
              tabs: const [
                Tab(text: 'My Issues'),
                Tab(text: 'Achievements'),
                Tab(text: 'Settings'),
              ],
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  MyIssuesWidget(
                    issues: [],
                  ),
                  AchievementBadgesWidget(
                    badges: [],
                  ),
                  SettingsSectionWidget(
                    title: 'Account Settings',
                    items: [],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}