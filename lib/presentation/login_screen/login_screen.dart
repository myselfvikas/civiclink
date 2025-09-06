import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import './widgets/civic_logo_widget.dart';
import './widgets/government_id_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/register_link_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _handleLogin(String email, String password) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Use Supabase authentication instead of mock credentials
      final response = await AuthService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Success - provide haptic feedback
        HapticFeedback.lightImpact();

        // Get user profile to determine role
        final userProfile = await AuthService.getCurrentUserProfile();
        final userName = userProfile?.fullName ?? 'User';

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login successful! Welcome back, $userName'),
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // Navigate to dashboard
          Navigator.pushReplacementNamed(context, '/issue-dashboard');
        }
      }
    } catch (e) {
      // Error - show specific error message
      if (mounted) {
        String errorMessage = 'Login failed. Please check your credentials.';

        if (e.toString().contains('Invalid login credentials')) {
          errorMessage = 'Invalid email or password. Please try again.';
        } else if (e.toString().contains('Email not confirmed')) {
          errorMessage = 'Please confirm your email address before signing in.';
        } else if (e.toString().contains('Too many requests')) {
          errorMessage = 'Too many login attempts. Please try again later.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: GestureDetector(
          onTap: _dismissKeyboard,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top spacing
                    SizedBox(height: 4.h),

                    // Civic Logo
                    const CivicLogoWidget(),

                    SizedBox(height: 6.h),

                    // Welcome Text
                    Text(
                      'Welcome Back',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.textHighEmphasisLight,
                                fontWeight: FontWeight.w700,
                                fontSize: 7.w > 32 ? 32 : 7.w,
                              ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 1.h),

                    Text(
                      'Sign in to report issues and track community progress',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textMediumEmphasisLight,
                            fontSize: 4.w > 16 ? 16 : 4.w,
                          ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: 6.h),

                    // Login Form
                    LoginFormWidget(
                      onLogin: _handleLogin,
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: 4.h),

                    // Government ID Login Section
                    const GovernmentIdWidget(),

                    SizedBox(height: 4.h),

                    // Register Link
                    const RegisterLinkWidget(),

                    // Demo Credentials Info
                    if (!_isLoading) ...[
                      SizedBox(height: 3.h),
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Demo Accounts:',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textHighEmphasisLight,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              '• Citizen: citizen@civiclink.gov / citizen123\n'
                              '• Admin: admin@civiclink.gov / admin123\n'
                              '• Inspector: inspector@civiclink.gov / inspector123',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppTheme.textMediumEmphasisLight,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Bottom spacing
                    SizedBox(height: 2.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
