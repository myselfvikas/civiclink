import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_export.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/category_selection_widget.dart';
import './widgets/description_input_widget.dart';
import './widgets/gallery_picker_widget.dart';
import './widgets/location_picker_widget.dart';
import './widgets/priority_selector_widget.dart';

class ReportIssue extends StatefulWidget {
  const ReportIssue({Key? key}) : super(key: key);

  @override
  State<ReportIssue> createState() => _ReportIssueState();
}

class _ReportIssueState extends State<ReportIssue> {
  final ScrollController _scrollController = ScrollController();

  // Form state
  XFile? _capturedImage;
  String? _selectedCategory;
  String? _selectedPriority;
  String _description = '';
  LatLng? _currentLocation;
  String? _detectedAddress;
  bool _isLocationDetected = false;
  bool _isSubmitting = false;
  bool _hasPermissions = false;

  // AI suggestions mock data
  Map<String, double>? _aiSuggestions;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _detectLocation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissions() async {
    if (kIsWeb) {
      setState(() {
        _hasPermissions = true;
      });
      return;
    }

    final cameraStatus = await Permission.camera.request();
    final locationStatus = await Permission.location.request();

    setState(() {
      _hasPermissions = cameraStatus.isGranted && locationStatus.isGranted;
    });
  }

  Future<void> _detectLocation() async {
    // Mock location detection
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _currentLocation =
          LatLng(37.7749, -122.4194); // San Francisco coordinates
      _detectedAddress = '123 Market Street, San Francisco, CA 94102';
      _isLocationDetected = true;
    });
  }

  void _onPhotoTaken(XFile photo) {
    setState(() {
      _capturedImage = photo;
    });

    // Simulate AI category suggestion
    _generateAISuggestions();
  }

  void _generateAISuggestions() {
    // Mock AI suggestions based on captured image
    Future.delayed(Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _aiSuggestions = {
            'roads': 0.85,
            'lighting': 0.12,
            'traffic': 0.03,
          };
        });
      }
    });
  }

  void _onRetakePhoto() {
    setState(() {
      _capturedImage = null;
      _aiSuggestions = null;
      _selectedCategory = null;
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onPrioritySelected(String priority) {
    setState(() {
      _selectedPriority = priority;
    });
  }

  void _onDescriptionChanged(String description) {
    setState(() {
      _description = description;
    });
  }

  void _onLocationSelected(LatLng location, String address) {
    setState(() {
      _currentLocation = location;
      _detectedAddress = address;
      _isLocationDetected = true;
    });
  }

  bool get _canSubmit {
    return _capturedImage != null &&
        _selectedCategory != null &&
        _description.trim().isNotEmpty &&
        _selectedPriority != null &&
        _isLocationDetected;
  }

  Future<void> _submitReport() async {
    if (!_canSubmit || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 3));

      // Generate tracking number
      final trackingNumber =
          'CL${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';

      // Show success dialog
      _showSuccessDialog(trackingNumber);
    } catch (e) {
      _showErrorDialog();
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSuccessDialog(String trackingNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: CustomIconWidget(
                iconName: 'check_circle',
                color: AppTheme.lightTheme.colorScheme.secondary,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Report Submitted',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your civic issue report has been successfully submitted and assigned to the appropriate department.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tracking Number',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    trackingNumber,
                    style:
                        AppTheme.dataTextStyleBold(isLight: true, fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'schedule',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  'Estimated response: 3-5 business days',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/issue-dashboard');
            },
            child: Text('View Dashboard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'error',
              color: Color(0xFFEF4444),
              size: 24,
            ),
            SizedBox(width: 12),
            Text('Submission Failed'),
          ],
        ),
        content: Text(
          'Unable to submit your report. Please check your internet connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Report Issue'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'close',
            color: AppTheme.lightTheme.colorScheme.onSurface,
            size: 24,
          ),
        ),
        actions: [
          if (_canSubmit)
            TextButton(
              onPressed: _isSubmitting ? null : _submitReport,
              child: _isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    )
                  : Text(
                      'Submit',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
        ],
      ),
      body: !_hasPermissions
          ? _buildPermissionView()
          : SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'report_problem',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Report a Civic Issue',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Help improve your community by reporting local issues',
                                style: AppTheme.lightTheme.textTheme.bodySmall
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Camera Section
                  Text(
                    'Photo Evidence',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: CameraPreviewWidget(
                          onPhotoTaken: _onPhotoTaken,
                          onRetake: _onRetakePhoto,
                          capturedImage: _capturedImage,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: GalleryPickerWidget(
                          onImageSelected: _onPhotoTaken,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24),

                  // Category Selection
                  CategorySelectionWidget(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _onCategorySelected,
                    aiSuggestions: _aiSuggestions,
                  ),

                  SizedBox(height: 24),

                  // Description Input
                  DescriptionInputWidget(
                    description: _description,
                    onDescriptionChanged: _onDescriptionChanged,
                  ),

                  SizedBox(height: 24),

                  // Location Picker
                  LocationPickerWidget(
                    currentLocation: _currentLocation,
                    detectedAddress: _detectedAddress,
                    onLocationSelected: _onLocationSelected,
                    isLocationDetected: _isLocationDetected,
                  ),

                  SizedBox(height: 24),

                  // Priority Selector
                  PrioritySelectorWidget(
                    selectedPriority: _selectedPriority,
                    onPrioritySelected: _onPrioritySelected,
                  ),

                  SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _canSubmit && !_isSubmitting ? _submitReport : null,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: _canSubmit
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.outline,
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
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Submitting Report...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              _canSubmit
                                  ? 'Submit Issue Report'
                                  : 'Complete Required Fields',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _canSubmit
                                    ? Colors.white
                                    : AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 16),

                  // Progress Indicator
                  _buildProgressIndicator(),

                  SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildPermissionView() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'security',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 64,
            ),
            SizedBox(height: 24),
            Text(
              'Permissions Required',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'CivicLink needs camera and location permissions to help you report issues effectively.',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: _requestPermissions,
              child: Text('Grant Permissions'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = [
      {'name': 'Photo', 'completed': _capturedImage != null},
      {'name': 'Category', 'completed': _selectedCategory != null},
      {'name': 'Description', 'completed': _description.trim().isNotEmpty},
      {'name': 'Location', 'completed': _isLocationDetected},
      {'name': 'Priority', 'completed': _selectedPriority != null},
    ];

    final completedSteps =
        steps.where((step) => step['completed'] as bool).length;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'checklist',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Progress: $completedSteps/${steps.length} steps completed',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          LinearProgressIndicator(
            value: completedSteps / steps.length,
            backgroundColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: steps.map((step) {
              final isCompleted = step['completed'] as bool;
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.1)
                      : AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: isCompleted
                          ? 'check_circle'
                          : 'radio_button_unchecked',
                      color: isCompleted
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.colorScheme.outline,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      step['name'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: isCompleted
                            ? AppTheme.lightTheme.colorScheme.secondary
                            : AppTheme.lightTheme.colorScheme.outline,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
