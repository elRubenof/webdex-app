import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:intl/intl.dart';
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
      drawer: const Drawer(
        shape: BeveledRectangleBorder(),
        child: TestS(),
      ),
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
                        "https://webdex-api.vercel.app/path/?lat=${point.latitude}&lon=${point.longitude}"))
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

        final pastDates = {};
        final nextDates = {};

        final Map? dates = value["dates"];
        final dateFormat = DateFormat('M/d/y');
        if (dates != null) {
          dates.keys.map((e) => Container()).toList();

          for (var value in dates.values) {
            pastDates[value] = [];
            nextDates[value] = [];

            for (var item in value) {
              final date = dateFormat.parse(item);

              if (date.isBefore(DateTime.now())) {
                pastDates[value].add(item);
                continue;
              }

              nextDates[value].add(item);
              break;
            }
          }
        }

        const tableBorder = BorderSide(
          color: Colors.black,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
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
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: height * 0.02,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    coordText(value['latitude'], "Latitude"),
                    coordText(value['longitude'], "Longitude"),
                  ],
                ),
              ),
              const Expanded(child: SizedBox()),
              if (dates != null)
                Table(
                  border: const TableBorder(
                    top: tableBorder,
                    bottom: tableBorder,
                    left: tableBorder,
                    right: tableBorder,
                    horizontalInside: tableBorder,
                  ),
                  children: [
                    TableRow(
                      children: dates.keys
                          .map((e) => Padding(
                              padding: const EdgeInsets.all(5),
                              child: Text(e,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: height * 0.022,
                                    fontWeight: FontWeight.w700,
                                  ))))
                          .toList(),
                    ),
                    TableRow(
                      children: List.generate(
                        dates.values.length,
                        (index) => tableDateRow(
                          "Next pass",
                          nextDates.values.elementAt(index).first,
                        ),
                      ),
                    ),
                    TableRow(
                      children: List.generate(
                        dates.values.length,
                        (index) => tableDateRow(
                          "Last passes",
                          pastDates.values.elementAt(index).last,
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget tableDateRow(String label, String date) {
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.all(5),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: height * 0.017,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: height * 0.021,
            ),
          ),
        ],
      ),
    );
  }
}
