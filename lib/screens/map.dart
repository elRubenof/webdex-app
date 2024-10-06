import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:webdex_app/widgets/custom_search_bar.dart';
import 'package:webdex_app/widgets/details_card.dart';

Map responseBody = {};
Function? update;

class MapScreen extends StatefulWidget {
  final double lat, lon;
  final bool search;

  const MapScreen({
    super.key,
    required this.lat,
    required this.lon,
    this.search = false,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final _controller = MapController();
  final GlobalKey _key = GlobalKey();

  List<Polygon<Object>> polygons = [];

  void updateApp() {
    if (update != null) {
      update!();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _key,
      drawerEnableOpenDragGesture: false,
      drawerScrimColor: Colors.transparent,
      onEndDrawerChanged: (isOpened) {
        if (!isOpened) responseBody = {};
      },
      drawer: kIsWeb
          ? const Drawer(
              shape: BeveledRectangleBorder(),
              child: DetailsCard(),
            )
          : null,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _controller,
            options: MapOptions(
              minZoom: 4.5,
              initialCenter: LatLng(widget.lat, widget.lon),
              initialZoom: widget.search ? 9 : 5,
              onMapReady: () {
                if (widget.search) {
                  loadLocationDetails(widget.lat, widget.lon);
                  openDetails();
                }
              },
              onPositionChanged: (camera, hasGesture) {
                if (kIsWeb && _controller.camera.zoom <= 4.5) {
                  Navigator.pop(context);
                }
              },
              onTap: (tapPosition, point) {
                travelTo(point.latitude, point.longitude);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.webdex.landsat',
              ),
              PolygonLayer(polygons: polygons),
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: height * 0.05),
            alignment: Alignment.bottomCenter,
            child: CustomSearchBar(
              onSubmitted: (p0) => travelTo(p0.latitude, p0.longitude),
            ),
          ),
          if (!kIsWeb)
            SafeArea(
              child: Container(
                margin: EdgeInsets.only(bottom: height * 0.05),
                alignment: Alignment.topLeft,
                child: CupertinoButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void travelTo(double lat, double lon) {
    setState(() => polygons.clear());
    loadLocationDetails(lat, lon);

    openDetails();
    _controller.move(LatLng(lat, lon), 8);
  }

  void openDetails() {
    if (kIsWeb) {
      (_key.currentState as ScaffoldState).openDrawer();
      return;
    }

    showModalBottomSheet<dynamic>(
      context: context,
      builder: (context) {
        final height = MediaQuery.of(context).size.height;
        return Wrap(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: height * 0.03),
              child: const DetailsCard(),
            ),
          ],
        );
      },
    );
  }

  void loadLocationDetails(double lat, double lon) async {
    final x1 = await http.get(
      Uri.parse("https://webdex-api.vercel.app/path/?lat=$lat&lon=$lon"),
    );
    Map response = json.decode(x1.body);

    int index = 0;
    for (var chunk in response['chunks']) {
      final x2 = await http.get(
        Uri.parse(
            "https://webdex-api.vercel.app/search/?path=${chunk['path']}&row=${chunk['row']}"),
      );

      final e = json.decode(x2.body);
      response['chunks'][index]['items'] = [];

      int count = 0;
      for (var item in e['data']['results']) {
        response['chunks'][index]['items'].add({
          "entityId": item['entityId'],
          "displayId": item['displayId'],
          "browseName": item['browse'][0]['browseName'],
          "browsePath": item['browse'][0]['browsePath'],
          "thumbnailPath": item['browse'][0]['thumbnailPath'],
        });

        if (count++ >= 3) break;
      }

      index++;
    }

    try {
      final geoRes = await http.get(Uri.parse(
          "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1"));

      response['location'] = json.decode(geoRes.body)['address']['state'];
    } catch (e) {}

    responseBody = response;

    for (var chunk in response["chunks"]) {
      polygons.add(
        Polygon(
          label: "Path: ${chunk["path"]} Row: ${chunk["row"]}",
          borderColor: Colors.red,
          borderStrokeWidth: 3,
          points: [
            LatLng(
              chunk["ul_lat"],
              chunk["ul_lon"],
            ),
            LatLng(
              chunk["ll_lat"],
              chunk["ll_lon"],
            ),
            LatLng(
              chunk["lr_lat"],
              chunk["lr_lon"],
            ),
            LatLng(
              chunk["ur_lat"],
              chunk["ur_lon"],
            ),
          ],
        ),
      );
    }

    updateApp();
  }
}
