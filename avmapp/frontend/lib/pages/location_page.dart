import 'package:flutter/material.dart';
import 'package:frontend/services/api/mall_api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/animated_bottom_navbar.dart';
import '../services/location_service.dart';
import '../models/mall.dart';
import 'dart:async';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  GoogleMapController? _mapController;
  Position? _userPosition;
  List<Mall> _malls = [];
  List<Mall> _filteredMalls = [];
  final TextEditingController _searchController = TextEditingController();

  Set<Marker> get _mallMarkers {
    return _filteredMalls
        .where((mall) => mall.latitude != null && mall.longitude != null)
        .map((mall) {
          return Marker(
            markerId: MarkerId(mall.id.toString()),
            position: LatLng(mall.latitude!, mall.longitude!),
            infoWindow: InfoWindow(title: mall.name),
          );
        })
        .toSet();
  }

  Future<void> _loadData() async {
    final position = await LocationService.getCurrentLocation();
    if (position == null) return;

    final malls = await MallApi.fetchMalls();
    setState(() {
      _userPosition = position;
      _malls = malls;
      _filteredMalls =
          malls
              .where((m) => m.latitude != null && m.longitude != null)
              .toList();
    });
  }

  void _onSearchChanged(String query) {
    final filtered =
        _malls
            .where(
              (mall) =>
                  mall.name.toLowerCase().contains(query.toLowerCase()) &&
                  mall.latitude != null &&
                  mall.longitude != null,
            )
            .toList();

    setState(() {
      _filteredMalls = filtered;
    });

    if (filtered.isNotEmpty && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(filtered.first.latitude!, filtered.first.longitude!),
          14,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yakınımda'),
        automaticallyImplyLeading: false,
      ),
      bottomNavigationBar: const AnimatedBottomNavBar(currentIndex: 2),
      body:
          _userPosition == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: LatLng(
                        _userPosition!.latitude,
                        _userPosition!.longitude,
                      ),
                      zoom: 13,
                    ),
                    onMapCreated: (controller) => _mapController = controller,
                    myLocationEnabled: true,
                    markers: _mallMarkers,
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: const InputDecoration(
                          hintText: 'AVM ara...',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
