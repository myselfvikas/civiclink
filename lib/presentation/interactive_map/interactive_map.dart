import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/current_location_button.dart';
import './widgets/issue_preview_card.dart';
import './widgets/map_bottom_sheet.dart';
import './widgets/map_filter_sheet.dart';
import './widgets/map_layer_controls.dart';
import './widgets/map_search_bar.dart';

class InteractiveMap extends StatefulWidget {
  const InteractiveMap({Key? key}) : super(key: key);

  @override
  State<InteractiveMap> createState() => _InteractiveMapState();
}

class _InteractiveMapState extends State<InteractiveMap>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  bool _isLocationLoading = false;
  bool _isHeatmapEnabled = false;
  bool _isClusteringEnabled = true;
  Map<String, dynamic>? _selectedIssue;
  List<String> _selectedCategories = [];
  List<String> _selectedStatuses = [];
  String _searchQuery = '';

  // Mock data for issues
  final List<Map<String, dynamic>> _allIssues = [
    {
      'id': '1',
      'category': 'garbage',
      'status': 'pending',
      'description':
          'Overflowing garbage bins near the park entrance causing unpleasant odors and attracting pests.',
      'address': '123 Park Avenue, Downtown',
      'latitude': 37.7749,
      'longitude': -122.4194,
      'reportedAt': DateTime.now().subtract(const Duration(hours: 2)),
      'imageUrl':
          'https://images.pexels.com/photos/2827392/pexels-photo-2827392.jpeg?auto=compress&cs=tinysrgb&w=800',
      'priority': 'medium',
      'votes': 12,
    },
    {
      'id': '2',
      'category': 'road_damage',
      'status': 'in_progress',
      'description':
          'Large pothole on Main Street causing vehicle damage and traffic delays.',
      'address': '456 Main Street, City Center',
      'latitude': 37.7849,
      'longitude': -122.4094,
      'reportedAt': DateTime.now().subtract(const Duration(days: 1)),
      'imageUrl':
          'https://images.pexels.com/photos/163016/highway-the-way-forward-road-marking-163016.jpeg?auto=compress&cs=tinysrgb&w=800',
      'priority': 'high',
      'votes': 28,
    },
    {
      'id': '3',
      'category': 'water',
      'status': 'resolved',
      'description':
          'Water leak from underground pipe flooding the sidewalk area.',
      'address': '789 Oak Street, Residential Area',
      'latitude': 37.7649,
      'longitude': -122.4294,
      'reportedAt': DateTime.now().subtract(const Duration(days: 3)),
      'imageUrl':
          'https://images.pexels.com/photos/416978/pexels-photo-416978.jpeg?auto=compress&cs=tinysrgb&w=800',
      'priority': 'high',
      'votes': 45,
    },
    {
      'id': '4',
      'category': 'lighting',
      'status': 'pending',
      'description':
          'Street light not working, creating safety concerns for pedestrians at night.',
      'address': '321 Elm Street, Suburb',
      'latitude': 37.7549,
      'longitude': -122.4394,
      'reportedAt': DateTime.now().subtract(const Duration(hours: 6)),
      'imageUrl':
          'https://images.pexels.com/photos/301920/pexels-photo-301920.jpeg?auto=compress&cs=tinysrgb&w=800',
      'priority': 'medium',
      'votes': 8,
    },
    {
      'id': '5',
      'category': 'traffic',
      'status': 'in_progress',
      'description':
          'Traffic signal malfunction causing congestion during rush hours.',
      'address': '654 Broadway, Commercial District',
      'latitude': 37.7949,
      'longitude': -122.3994,
      'reportedAt': DateTime.now().subtract(const Duration(hours: 12)),
      'imageUrl':
          'https://images.pexels.com/photos/280222/pexels-photo-280222.jpeg?auto=compress&cs=tinysrgb&w=800',
      'priority': 'high',
      'votes': 67,
    },
    {
      'id': '6',
      'category': 'noise',
      'status': 'pending',
      'description':
          'Construction noise exceeding permitted hours, disturbing residents.',
      'address': '987 Pine Street, Residential',
      'latitude': 37.7449,
      'longitude': -122.4494,
      'reportedAt': DateTime.now().subtract(const Duration(minutes: 30)),
      'imageUrl':
          'https://images.pexels.com/photos/1105766/pexels-photo-1105766.jpeg?auto=compress&cs=tinysrgb&w=800',
      'priority': 'low',
      'votes': 3,
    },
  ];

  Set<Marker> _markers = {};
  List<Map<String, dynamic>> _filteredIssues = [];

  @override
  void initState() {
    super.initState();
    _filteredIssues = List.from(_allIssues);
    _getCurrentLocation();
    _createMarkers();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      if (_mapController != null) {
        await _mapController!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(position.latitude, position.longitude),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
      // Use default San Francisco location as fallback
      setState(() {
        _currentPosition = Position(
          latitude: 37.7749,
          longitude: -122.4194,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      });
    } finally {
      setState(() {
        _isLocationLoading = false;
      });
    }
  }

  void _createMarkers() {
    Set<Marker> markers = {};

    for (var issue in _filteredIssues) {
      markers.add(
        Marker(
          markerId: MarkerId(issue['id']),
          position: LatLng(issue['latitude'], issue['longitude']),
          onTap: () => _onMarkerTapped(issue),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getMarkerColor(issue['category']),
          ),
        ),
      );
    }

    // Add current location marker if available
    if (_currentPosition != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position:
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    }

    setState(() {
      _markers = markers;
    });
  }

  double _getMarkerColor(String category) {
    switch (category.toLowerCase()) {
      case 'garbage':
        return BitmapDescriptor.hueViolet;
      case 'road_damage':
        return BitmapDescriptor.hueRed;
      case 'water':
        return BitmapDescriptor.hueBlue;
      case 'lighting':
        return BitmapDescriptor.hueYellow;
      case 'traffic':
        return BitmapDescriptor.hueGreen;
      case 'noise':
        return BitmapDescriptor.hueMagenta;
      default:
        return BitmapDescriptor.hueOrange;
    }
  }

  void _onMarkerTapped(Map<String, dynamic> issue) {
    setState(() {
      _selectedIssue = issue;
    });
  }

  void _onMapTapped(LatLng position) {
    setState(() {
      _selectedIssue = null;
    });
  }

  void _onMapLongPressed(LatLng position) {
    Navigator.pushNamed(context, '/report-issue');
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();
  }

  void _onFiltersChanged(List<String> categories, List<String> statuses) {
    setState(() {
      _selectedCategories = categories;
      _selectedStatuses = statuses;
    });
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = _allIssues.where((issue) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        if (!issue['description']
                .toString()
                .toLowerCase()
                .contains(searchLower) &&
            !issue['address'].toString().toLowerCase().contains(searchLower) &&
            !issue['category'].toString().toLowerCase().contains(searchLower)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategories.isNotEmpty &&
          !_selectedCategories.contains(issue['category'])) {
        return false;
      }

      // Status filter
      if (_selectedStatuses.isNotEmpty &&
          !_selectedStatuses.contains(issue['status'])) {
        return false;
      }

      return true;
    }).toList();

    setState(() {
      _filteredIssues = filtered;
    });
    _createMarkers();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MapFilterSheet(
        selectedCategories: _selectedCategories,
        selectedStatuses: _selectedStatuses,
        onFiltersChanged: _onFiltersChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildMap(),
          _buildSearchBar(),
          _buildLayerControls(),
          _buildCurrentLocationButton(),
          if (_selectedIssue != null) _buildIssuePreviewCard(),
          _buildBottomSheet(),
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
        if (_currentPosition != null) {
          controller.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
            ),
          );
        }
      },
      initialCameraPosition: CameraPosition(
        target: _currentPosition != null
            ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
            : const LatLng(37.7749, -122.4194),
        zoom: 14.0,
      ),
      markers: _markers,
      onTap: _onMapTapped,
      onLongPress: _onMapLongPressed,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
    );
  }

  Widget _buildSearchBar() {
    return SafeArea(
      child: MapSearchBar(
        onSearch: _onSearch,
        onFilterTap: _showFilterSheet,
      ),
    );
  }

  Widget _buildLayerControls() {
    return MapLayerControls(
      isHeatmapEnabled: _isHeatmapEnabled,
      isClusteringEnabled: _isClusteringEnabled,
      onHeatmapToggle: () {
        setState(() {
          _isHeatmapEnabled = !_isHeatmapEnabled;
        });
      },
      onClusteringToggle: () {
        setState(() {
          _isClusteringEnabled = !_isClusteringEnabled;
        });
      },
    );
  }

  Widget _buildCurrentLocationButton() {
    return CurrentLocationButton(
      onPressed: _getCurrentLocation,
      isLoading: _isLocationLoading,
    );
  }

  Widget _buildIssuePreviewCard() {
    return Positioned(
      bottom: 35.h,
      left: 0,
      right: 0,
      child: IssuePreviewCard(
        issue: _selectedIssue!,
        onViewDetails: () {
          Navigator.pushNamed(context, '/issue-dashboard');
        },
        onClose: () {
          setState(() {
            _selectedIssue = null;
          });
        },
      ),
    );
  }

  Widget _buildBottomSheet() {
    return MapBottomSheet(
      issues: _filteredIssues,
      onIssueSelected: (issue) {
        setState(() {
          _selectedIssue = issue;
        });
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(issue['latitude'], issue['longitude']),
            ),
          );
        }
      },
      onFilterTap: _showFilterSheet,
    );
  }

  Widget _buildBottomNavigation() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: 2, // Map tab is active
            elevation: 0,
            backgroundColor: Colors.transparent,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
            items: [
              BottomNavigationBarItem(
                icon: CustomIconWidget(
                  iconName: 'dashboard',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                activeIcon: CustomIconWidget(
                  iconName: 'dashboard',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: CustomIconWidget(
                  iconName: 'add_circle_outline',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                activeIcon: CustomIconWidget(
                  iconName: 'add_circle',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                label: 'Report',
              ),
              BottomNavigationBarItem(
                icon: CustomIconWidget(
                  iconName: 'map',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                activeIcon: CustomIconWidget(
                  iconName: 'map',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: CustomIconWidget(
                  iconName: 'person_outline',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                activeIcon: CustomIconWidget(
                  iconName: 'person',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                label: 'Profile',
              ),
            ],
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushNamed(context, '/issue-dashboard');
                  break;
                case 1:
                  Navigator.pushNamed(context, '/report-issue');
                  break;
                case 2:
                  // Already on map screen
                  break;
                case 3:
                  Navigator.pushNamed(context, '/user-profile');
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}
