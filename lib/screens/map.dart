import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

ValueNotifier responseBody = ValueNotifier(null);

class MapScreen extends StatefulWidget {
  final double lat, lon;

  const MapScreen({super.key, required this.lat, required this.lon});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _controller = MapController();
  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawerEnableOpenDragGesture: false,
      drawerScrimColor: Colors.transparent,
      onEndDrawerChanged: (isOpened) {
        if (!isOpened) responseBody.value = null;
      },
      drawer: const Drawer(child: TestS()),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              initialCenter: LatLng(widget.lat, widget.lon),
              initialZoom: 5,
              onPositionChanged: (camera, hasGesture) {
                if (_controller.camera.zoom < 4.5) Navigator.pop(context);
              },
              onTap: (tapPosition, point) {
                http
                    .get(Uri.parse(
                        "http://localhost:8000/path/?lat=${point.latitude}&lon=${point.longitude}"))
                    .then((value) {
                  responseBody.value = json.decode(value.body);
                });

                (_key.currentState as ScaffoldState).openDrawer();
                _controller.move(LatLng(point.latitude, point.longitude), 9);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TestS extends StatefulWidget {
  const TestS({super.key});

  @override
  State<TestS> createState() => _TestSState();
}

class _TestSState extends State<TestS> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return ValueListenableBuilder(
      valueListenable: responseBody,
      builder: (context, value, child) {
        if (value == null) return const Text("LOADING...");

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            children: [
              Text(
                value['state'] ?? "Location",
                style: TextStyle(
                  fontSize: height * 0.033,
                  fontWeight: FontWeight.bold,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: height * 0.02),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    coordText(value['latitude'], "Latitude"),
                    coordText(value['longitude'], "Longitude"),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget coordText(double? value, String label) {
    final height = MediaQuery.of(context).size.height;
    if (value == null) return Container();

    return Column(
      children: [
        Text(
          "43.172",
          style: TextStyle(fontSize: height * 0.03),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey,
            fontSize: height * 0.015,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
