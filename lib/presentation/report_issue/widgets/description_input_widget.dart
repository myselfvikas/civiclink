import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class DescriptionInputWidget extends StatefulWidget {
  final String? description;
  final Function(String) onDescriptionChanged;
  final int maxLength;

  const DescriptionInputWidget({
    Key? key,
    this.description,
    required this.onDescriptionChanged,
    this.maxLength = 280,
  }) : super(key: key);

  @override
  State<DescriptionInputWidget> createState() => _DescriptionInputWidgetState();
}

class _DescriptionInputWidgetState extends State<DescriptionInputWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  int _currentLength = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.description ?? '');
    _focusNode = FocusNode();
    _currentLength = _controller.text.length;

    _controller.addListener(() {
      setState(() {
        _currentLength = _controller.text.length;
      });
      widget.onDescriptionChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNearLimit = _currentLength > (widget.maxLength * 0.8);
    final isAtLimit = _currentLength >= widget.maxLength;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Issue Description',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline,
              width: _focusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: 4,
                maxLength: widget.maxLength,
                decoration: InputDecoration(
                  hintText:
                      'Describe the issue in detail. Include what you observed, when it occurred, and any safety concerns...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  counterText: '',
                  hintStyle: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
                ),
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.5),
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info_outline',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Provide clear details to help authorities understand and prioritize your report',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAtLimit
                            ? Color(0xFFEF4444).withValues(alpha: 0.1)
                            : isNearLimit
                                ? Color(0xFFF59E0B).withValues(alpha: 0.1)
                                : AppTheme.lightTheme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_currentLength/${widget.maxLength}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color: isAtLimit
                              ? Color(0xFFEF4444)
                              : isNearLimit
                                  ? Color(0xFDF59E0B)
                                  : AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_currentLength > 0) ...[
          SizedBox(height: 8),
          Row(
            children: [
              CustomIconWidget(
                iconName: _currentLength >= 50
                    ? 'check_circle'
                    : 'radio_button_unchecked',
                color: _currentLength >= 50
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.lightTheme.colorScheme.outline,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Detailed description (recommended: 50+ characters)',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: _currentLength >= 50
                      ? AppTheme.lightTheme.colorScheme.secondary
                      : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
