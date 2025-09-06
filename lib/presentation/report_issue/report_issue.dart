import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/civic_issues_service.dart';
import '../../services/storage_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/category_selection_widget.dart';
import './widgets/description_input_widget.dart';
import './widgets/gallery_picker_widget.dart';
import './widgets/location_picker_widget.dart';
import './widgets/priority_selector_widget.dart';

class ReportIssue extends StatefulWidget {
  const ReportIssue({super.key});

  @override
  State<ReportIssue> createState() => _ReportIssueState();
}

class _ReportIssueState extends State<ReportIssue>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  late AnimationController _slideController;
  late AnimationController _fadeController;

  // Form Data
  String _selectedCategory = '';
  String _selectedPriority = '';
  String _description = '';
  String _location = '';
  List<File> _selectedImages = [];
  List<String> _imageUrls = [];
  bool _isAnonymous = false;
  bool _allowPublicView = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_tabController.index < _tabController.length - 1) {
      _tabController.animateTo(_tabController.index + 1);
      HapticFeedback.selectionClick();
    }
  }

  void _previousStep() {
    if (_tabController.index > 0) {
      _tabController.animateTo(_tabController.index - 1);
      HapticFeedback.selectionClick();
    }
  }

  bool _canProceedFromStep(int step) {
    switch (step) {
      case 0:
        return _selectedCategory.isNotEmpty;
      case 1:
        return _selectedPriority.isNotEmpty;
      case 2:
        return _description.trim().isNotEmpty && _description.length >= 10;
      case 3:
        return _location.isNotEmpty;
      case 4:
        return true;
      default:
        return false;
    }
  }

  Future<List<String>> _uploadImages() async {
    if (_selectedImages.isEmpty) return [];

    List<String> uploadedUrls = [];

    try {
      for (File imageFile in _selectedImages) {
        final fileName = StorageService.generateUniqueFileName(
            imageFile.path.split('/').last);
        final imageUrl = await StorageService.uploadIssueImage(
          file: imageFile,
          fileName: fileName,
        );
        uploadedUrls.add(imageUrl);
      }
    } catch (e) {
      throw Exception('Failed to upload images: $e');
    }

    return uploadedUrls;
  }

  String _getDepartmentForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'lighting':
        return 'Public Works';
      case 'road_damage':
        return 'Transportation';
      case 'garbage':
        return 'Sanitation';
      case 'water':
        return 'Water Department';
      case 'noise':
        return 'Code Enforcement';
      case 'parks':
        return 'Parks & Recreation';
      case 'transportation':
        return 'Transportation';
      default:
        return 'General Services';
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Upload images first
      final imageUrls = await _uploadImages();

      // Get current user
      final currentUser = AuthService.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Create the issue data
      final issueData = {
        'title': '$_selectedCategory Issue',
        'category': _selectedCategory,
        'priority': _selectedPriority,
        'description': _description,
        'location': _location,
        'imageUrls': imageUrls,
        'isAnonymous': _isAnonymous,
        'allowPublicView': _allowPublicView,
        'reporterId': _isAnonymous ? null : currentUser.uid,
        'reporterName': _isAnonymous ? 'Anonymous' : currentUser.displayName,
        'status': 'pending',
        'department': _getDepartmentForCategory(_selectedCategory),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

      // Submit the issue
      await CivicIssuesService.submitIssue(issueData);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Issue reported successfully!'),
            backgroundColor: AppTheme.successLight,
          ),
        );

        // Navigate back
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit issue: $e'),
            backgroundColor: AppTheme.errorLight,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textHighEmphasisLight,
          ),
        ),
        title: Text(
          'Report Issue',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textHighEmphasisLight,
                fontWeight: FontWeight.w700,
              ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: AppTheme.lightTheme.colorScheme.primary,
          labelColor: AppTheme.lightTheme.colorScheme.primary,
          unselectedLabelColor: AppTheme.textMediumEmphasisLight,
          labelStyle: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Category'),
            Tab(text: 'Priority'),
            Tab(text: 'Details'),
            Tab(text: 'Location'),
            Tab(text: 'Review'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: Form(
          key: _formKey,
          child: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              // Category Selection
              CategorySelectionWidget(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
              ),

              // Priority Selection
              PrioritySelectorWidget(
                selectedPriority: _selectedPriority,
                onPrioritySelected: (priority) {
                  setState(() {
                    _selectedPriority = priority;
                  });
                },
              ),

              // Description Input with Image Selection
              SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DescriptionInputWidget(
                      description: _description,
                      onDescriptionChanged: (description) {
                        setState(() {
                          _description = description;
                        });
                      },
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Add Photos (Optional)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 2.h),
                    GalleryPickerWidget(
                      onImageSelected: (image) {
                        setState(() {
                          _selectedImages.add(File(image.path));
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Location Picker
              LocationPickerWidget(
                onLocationSelected: (location, address) {
                  setState(() {
                    _location = address;
                  });
                },
              ),

              // Review & Submit
              SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Review Your Report',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                color: AppTheme.textHighEmphasisLight,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    SizedBox(height: 3.h),

                    // Review Cards
                    _buildReviewCard(
                        'Category', _selectedCategory, Icons.category),
                    _buildReviewCard(
                        'Priority', _selectedPriority, Icons.priority_high),
                    _buildReviewCard('Location', _location, Icons.location_on),
                    _buildReviewCard(
                        'Description', _description, Icons.description),
                    _buildReviewCard('Images',
                        '${_selectedImages.length} image(s)', Icons.image),

                    SizedBox(height: 3.h),

                    // Additional Options
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.outlineLight,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Additional Options',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          SizedBox(height: 2.h),
                          SwitchListTile(
                            value: _isAnonymous,
                            onChanged: (value) {
                              setState(() {
                                _isAnonymous = value;
                              });
                            },
                            title: Text('Report Anonymously'),
                            subtitle: Text(
                                'Your identity will not be shown publicly'),
                            contentPadding: EdgeInsets.zero,
                            activeColor:
                                AppTheme.lightTheme.colorScheme.primary,
                          ),
                          SwitchListTile(
                            value: _allowPublicView,
                            onChanged: (value) {
                              setState(() {
                                _allowPublicView = value;
                              });
                            },
                            title: Text('Allow Public View'),
                            subtitle: Text(
                                'Other citizens can see and support this issue'),
                            contentPadding: EdgeInsets.zero,
                            activeColor:
                                AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 7.h,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              AppTheme.lightTheme.colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: _isSubmitting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    'Submitting...',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'send',
                                    color: Colors.white,
                                    size: 5.w,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    'Submit Issue Report',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          boxShadow: [
            BoxShadow(
              color: AppTheme.shadowLight,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (_tabController.index > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _previousStep,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: Text(
                    'Previous',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (_tabController.index > 0) SizedBox(width: 4.w),
            if (_tabController.index < _tabController.length - 1)
              Expanded(
                child: ElevatedButton(
                  onPressed: _canProceedFromStep(_tabController.index)
                      ? _nextStep
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 14.sp,
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

  Widget _buildReviewCard(String title, String value, IconData icon) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineLight,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 5.w,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textMediumEmphasisLight,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value.isEmpty ? 'Not specified' : value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: value.isEmpty
                            ? AppTheme.textDisabledLight
                            : AppTheme.textHighEmphasisLight,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}