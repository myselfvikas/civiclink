import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SkeletonCardWidget extends StatefulWidget {
  const SkeletonCardWidget({super.key});

  @override
  State<SkeletonCardWidget> createState() => _SkeletonCardWidgetState();
}

class _SkeletonCardWidgetState extends State<SkeletonCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Skeleton Image
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.grey[700] : Colors.grey[300])
                              ?.withValues(alpha: _animation.value),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      // Skeleton Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Skeleton Category Icon
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: BoxDecoration(
                                    color: (isDark
                                            ? Colors.grey[700]
                                            : Colors.grey[300])
                                        ?.withValues(alpha: _animation.value),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                // Skeleton Status Badge
                                Container(
                                  width: 20.w,
                                  height: 3.h,
                                  decoration: BoxDecoration(
                                    color: (isDark
                                            ? Colors.grey[700]
                                            : Colors.grey[300])
                                        ?.withValues(alpha: _animation.value),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            // Skeleton Title
                            Container(
                              width: double.infinity,
                              height: 2.h,
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[300])
                                    ?.withValues(alpha: _animation.value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Container(
                              width: 60.w,
                              height: 2.h,
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[300])
                                    ?.withValues(alpha: _animation.value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            // Skeleton Location
                            Container(
                              width: 40.w,
                              height: 1.5.h,
                              decoration: BoxDecoration(
                                color: (isDark
                                        ? Colors.grey[700]
                                        : Colors.grey[300])
                                    ?.withValues(alpha: _animation.value),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Skeleton Bottom Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 25.w,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.grey[700] : Colors.grey[300])
                              ?.withValues(alpha: _animation.value),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Container(
                        width: 15.w,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.grey[700] : Colors.grey[300])
                              ?.withValues(alpha: _animation.value),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
