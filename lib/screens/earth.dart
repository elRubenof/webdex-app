import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:flutter_earth_globe/point.dart';
import 'package:flutter_earth_globe/point_connection.dart';
import 'package:webdex_app/screens/map.dart';
import 'package:webdex_app/utils/custom_page_transition.dart';
import 'package:webdex_app/widgets/custom_search_bar.dart';

class EarthScreen extends StatefulWidget {
  const EarthScreen({super.key});

  @override
  State<EarthScreen> createState() => _EarthScreenState();
}

class _EarthScreenState extends State<EarthScreen> {
  late FlutterEarthGlobeController _controller;
  GlobeCoordinates? focusCoords;

  List<PointConnection> connections = [];
  List<Point> points = [];

  @override
  void initState() {
    _controller = FlutterEarthGlobeController(
      zoom: 0.7,
      maxZoom: 1.55,
      isBackgroundFollowingSphereRotation: true,
      background: const AssetImage('assets/2k_stars.jpg'),
      surface: const AssetImage('assets/2k_earth.jpg'),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          FlutterEarthGlobe(
            controller: _controller,
            radius: 120,
            onZoomChanged: (zoom) {
              if (zoom >= 1.55) _travel2D();
            },
            onTap: (coordinates) => _travel2D(coords: coordinates),
            onHover: (coordinates) => focusCoords = coordinates,
          ),
          Container(
            margin: EdgeInsets.only(bottom: height * 0.05),
            alignment: Alignment.bottomCenter,
            child: CustomSearchBar(
              darkMode: true,
              onSubmitted: (coords) => _travel2D(coords: coords, search: true),
            ),
          ),
        ],
      ),
    );
  }

  void _travel2D({GlobeCoordinates? coords, search = false}) {
    coords ??= focusCoords!;

    Navigator.of(context).push(
      CustomPageRoute(
        MapScreen(
          lat: coords.latitude,
          lon: coords.longitude,
          search: search,
        ),
      ),
    );
  }

  Widget connectionLabelBuilder(BuildContext context,
      PointConnection connection, bool isHovering, bool visible) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Text(
        connection.label ?? '',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            ),
      ),
    );
  }
}
