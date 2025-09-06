import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/civic_stats_widget.dart';
import './widgets/my_issues_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/user_avatar_widget.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  int _currentIndex = 4; // Profile tab active

  // Mock user data
  final Map<String, dynamic> userData = {
    "name": "Sarah Johnson",
    "email": "sarah.johnson@email.com",
    "avatar":
        "https://images.unsplash.com/photo-1494790108755-2616b612b786?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    "issuesReported": 23,
    "impactScore": 1250,
    "memberSince": "Jan 2023",
    "phone": "+1 (555) 123-4567",
    "address": "123 Main St, Springfield, IL"
  };

  // Mock issues data
  final List<Map<String, dynamic>> userIssues = [
    {
      "id": "ISS-2024-001",
      "title": "Broken Street Light",
      "description":
          "Street light on Oak Avenue has been flickering for weeks and now completely out.",
      "status": "In Progress",
      "location": "Oak Avenue & 5th Street",
      "date": "Dec 15",
      "category": "Lighting",
      "image":
          "https://images.pexels.com/photos/1108572/pexels-photo-1108572.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
    },
    {
      "id": "ISS-2024-002",
      "title": "Pothole on Main Street",
      "description":
          "Large pothole causing damage to vehicles and creating safety hazard.",
      "status": "Resolved",
      "location": "Main Street near City Hall",
      "date": "Dec 10",
      "category": "Road Damage",
      "image":
          "https://images.pexels.com/photos/7031714/pexels-photo-7031714.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
    },
    {
      "id": "ISS-2024-003",
      "title": "Overflowing Trash Bin",
      "description":
          "Public trash bin at Central Park is overflowing and attracting pests.",
      "status": "Pending",
      "location": "Central Park - North Entrance",
      "date": "Dec 18",
      "category": "Waste Management",
      "image":
          "https://images.pexels.com/photos/2827392/pexels-photo-2827392.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
    }
  ];

  // Mock achievement badges
  final List<Map<String, dynamic>> achievementBadges = [
    {
      "name": "First Reporter",
      "icon": "flag",
      "earned": true,
      "progress": 1.0,
      "description": "Reported your first civic issue"
    },
    {
      "name": "Community Hero",
      "icon": "volunteer_activism",
      "earned": true,
      "progress": 1.0,
      "description": "Reported 20+ issues"
    },
    {
      "name": "Neighborhood Watch",
      "icon": "visibility",
      "earned": false,
      "progress": 0.7,
      "description": "Report issues in 5 different areas"
    },
    {
      "name": "Quick Responder",
      "icon": "speed",
      "earned": false,
      "progress": 0.4,
      "description": "Report 3 issues within 24 hours"
    }
  ];

  // Settings state
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _locationSharing = true;
  bool _biometricAuth = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Profile',
        style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () {
            _showSettingsBottomSheet();
          },
          icon: CustomIconWidget(
            iconName: 'settings',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 6.w,
          ),
        ),
      ],
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          _buildUserHeader(),
          SizedBox(height: 3.h),
          CivicStatsWidget(
            issuesReported: userData['issuesReported'] as int,
            impactScore: userData['impactScore'] as int,
            memberSince: userData['memberSince'] as String,
          ),
          SizedBox(height: 2.h),
          MyIssuesWidget(issues: userIssues),
          SizedBox(height: 1.h),
          AchievementBadgesWidget(badges: achievementBadges),
          SizedBox(height: 1.h),
          _buildAccountSettings(),
          SizedBox(height: 1.h),
          _buildNotificationSettings(),
          SizedBox(height: 1.h),
          _buildPrivacySettings(),
          SizedBox(height: 1.h),
          _buildAppSettings(),
          SizedBox(height: 1.h),
          _buildSupportSettings(),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildUserHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          UserAvatarWidget(
            imageUrl: userData['avatar'] as String,
            onTap: _showImagePickerDialog,
          ),
          SizedBox(height: 2.h),
          Text(
            userData['name'] as String,
            style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            userData['email'] as String,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSettings() {
    return SettingsSectionWidget(
      title: 'Account',
      items: [
        SettingsItem(
          title: 'Personal Information',
          subtitle: 'Edit your profile details',
          iconName: 'person',
          onTap: _showPersonalInfoDialog,
        ),
        SettingsItem(
          title: 'Email Preferences',
          subtitle: 'Manage email communications',
          iconName: 'email',
          onTap: () {},
        ),
        SettingsItem(
          title: 'Change Password',
          subtitle: 'Update your account password',
          iconName: 'lock',
          onTap: _showChangePasswordDialog,
        ),
      ],
    );
  }

  Widget _buildNotificationSettings() {
    return SettingsSectionWidget(
      title: 'Notifications',
      items: [
        SettingsItem(
          title: 'Push Notifications',
          subtitle: 'Issue updates and alerts',
          iconName: 'notifications',
          hasToggle: true,
          hasNavigation: false,
          toggleValue: _pushNotifications,
          onToggleChanged: (value) {
            setState(() {
              _pushNotifications = value;
            });
          },
        ),
        SettingsItem(
          title: 'Email Notifications',
          subtitle: 'Weekly summaries and reports',
          iconName: 'mail',
          hasToggle: true,
          hasNavigation: false,
          toggleValue: _emailNotifications,
          onToggleChanged: (value) {
            setState(() {
              _emailNotifications = value;
            });
          },
        ),
        SettingsItem(
          title: 'Community Alerts',
          subtitle: 'Nearby issue notifications',
          iconName: 'campaign',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildPrivacySettings() {
    return SettingsSectionWidget(
      title: 'Privacy & Security',
      items: [
        SettingsItem(
          title: 'Location Sharing',
          subtitle: 'Share location for better service',
          iconName: 'location_on',
          hasToggle: true,
          hasNavigation: false,
          toggleValue: _locationSharing,
          onToggleChanged: (value) {
            setState(() {
              _locationSharing = value;
            });
          },
        ),
        SettingsItem(
          title: 'Biometric Authentication',
          subtitle: 'Use fingerprint or face ID',
          iconName: 'fingerprint',
          hasToggle: true,
          hasNavigation: false,
          toggleValue: _biometricAuth,
          onToggleChanged: (value) {
            setState(() {
              _biometricAuth = value;
            });
          },
        ),
        SettingsItem(
          title: 'Data & Privacy',
          subtitle: 'Manage your data preferences',
          iconName: 'privacy_tip',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAppSettings() {
    return SettingsSectionWidget(
      title: 'App Settings',
      items: [
        SettingsItem(
          title: 'Dark Mode',
          subtitle: 'Switch to dark theme',
          iconName: 'dark_mode',
          hasToggle: true,
          hasNavigation: false,
          toggleValue: _darkMode,
          onToggleChanged: (value) {
            setState(() {
              _darkMode = value;
            });
          },
        ),
        SettingsItem(
          title: 'Language',
          subtitle: 'English (US)',
          iconName: 'language',
          onTap: () {},
        ),
        SettingsItem(
          title: 'Accessibility',
          subtitle: 'Font size, contrast, and more',
          iconName: 'accessibility',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSupportSettings() {
    return SettingsSectionWidget(
      title: 'Support',
      items: [
        SettingsItem(
          title: 'Contact Support',
          subtitle: 'Get help with your account',
          iconName: 'support_agent',
          onTap: _showContactSupportDialog,
        ),
        SettingsItem(
          title: 'About CivicLink',
          subtitle: 'Version 1.0.0',
          iconName: 'info',
          onTap: _showAboutDialog,
        ),
        SettingsItem(
          title: 'Sign Out',
          subtitle: 'Sign out of your account',
          iconName: 'logout',
          onTap: _showSignOutDialog,
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      selectedItemColor: AppTheme.lightTheme.primaryColor,
      unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        _navigateToScreen(index);
      },
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'dashboard',
            color: _currentIndex == 0
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'add_circle',
            color: _currentIndex == 1
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          label: 'Report',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'map',
            color: _currentIndex == 2
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          label: 'Map',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'person',
            color: _currentIndex == 3
                ? AppTheme.lightTheme.primaryColor
                : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 5.w,
          ),
          label: 'Profile',
        ),
      ],
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/issue-dashboard');
        break;
      case 1:
        Navigator.pushNamed(context, '/report-issue');
        break;
      case 2:
        Navigator.pushNamed(context, '/interactive-map');
        break;
      case 3:
        // Already on profile screen
        break;
    }
  }

  void _showImagePickerDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update Profile Picture',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImagePickerOption(
                  'Camera',
                  'camera_alt',
                  () {
                    Navigator.pop(context);
                    // Implement camera functionality
                  },
                ),
                _buildImagePickerOption(
                  'Gallery',
                  'photo_library',
                  () {
                    Navigator.pop(context);
                    // Implement gallery functionality
                  },
                ),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerOption(
      String title, String iconName, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.primaryColor,
              size: 8.w,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPersonalInfoDialog() {
    final nameController =
        TextEditingController(text: userData['name'] as String);
    final emailController =
        TextEditingController(text: userData['email'] as String);
    final phoneController =
        TextEditingController(text: userData['phone'] as String);
    final addressController =
        TextEditingController(text: userData['address'] as String);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Personal Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: CustomIconWidget(
                    iconName: 'person',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 5.w,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  prefixIcon: CustomIconWidget(
                    iconName: 'email',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 5.w,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone',
                  prefixIcon: CustomIconWidget(
                    iconName: 'phone',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 5.w,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  prefixIcon: CustomIconWidget(
                    iconName: 'home',
                    color: AppTheme.lightTheme.primaryColor,
                    size: 5.w,
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                userData['name'] = nameController.text;
                userData['email'] = emailController.text;
                userData['phone'] = phoneController.text;
                userData['address'] = addressController.text;
              });
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: CustomIconWidget(
                  iconName: 'lock',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 5.w,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: CustomIconWidget(
                  iconName: 'lock_outline',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 5.w,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: CustomIconWidget(
                  iconName: 'lock_outline',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 5.w,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (newPasswordController.text ==
                  confirmPasswordController.text) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Password updated successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Passwords do not match')),
                );
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Need help? Contact our support team:'),
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'email',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text('support@civiclink.com'),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'phone',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text('1-800-CIVIC-HELP'),
              ],
            ),
            SizedBox(height: 1.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 5.w,
                ),
                SizedBox(width: 2.w),
                Text('Mon-Fri, 9AM-6PM EST'),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About CivicLink'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CivicLink v1.0.0',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Empowering citizens to report local civic issues and track their resolution progress.',
            ),
            SizedBox(height: 2.h),
            Text(
              'Features:',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 0.5.h),
            Text('• Issue reporting with photos'),
            Text('• Real-time status tracking'),
            Text('• Interactive city maps'),
            Text('• Community engagement'),
            SizedBox(height: 2.h),
            Text(
              '© 2024 CivicLink. All rights reserved.',
              style: AppTheme.lightTheme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out'),
        content: Text('Are you sure you want to sign out of your account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login-screen',
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Settings',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 3.h),
            SwitchListTile(
              title: Text('Push Notifications'),
              subtitle: Text('Receive issue updates'),
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Location Services'),
              subtitle: Text('Enable location tracking'),
              value: _locationSharing,
              onChanged: (value) {
                setState(() {
                  _locationSharing = value;
                });
              },
            ),
            SwitchListTile(
              title: Text('Dark Mode'),
              subtitle: Text('Switch to dark theme'),
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
