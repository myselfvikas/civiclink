import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class MapLayerControls extends StatelessWidget {
  final bool isHeatmapEnabled;
  final bool isClusteringEnabled;
  final VoidCallback onHeatmapToggle;
  final VoidCallback onClusteringToggle;

  const MapLayerControls({
    Key? key,
    required this.isHeatmapEnabled,
    required this.isClusteringEnabled,
    required this.onHeatmapToggle,
    required this.onClusteringToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 15.h,
      right: 4.w,
      child: Column(
        children: [
          _buildControlButton(
            context: context,
            icon: 'layers',
            isActive: isHeatmapEnabled,
            onTap: onHeatmapToggle,
            tooltip: 'Toggle Heatmap',
          ),
          SizedBox(height: 1.h),
          _buildControlButton(
            context: context,
            icon: 'scatter_plot',
            isActive: isClusteringEnabled,
            onTap: onClusteringToggle,
            tooltip: 'Toggle Clustering',
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required String icon,
    required bool isActive,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        elevation: 4,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 12.w,
            height: 6.h,
            decoration: BoxDecoration(
              color: isActive
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: icon,
                color: isActive
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
