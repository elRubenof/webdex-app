import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:webdex_app/widgets/custom_search_bar.dart';
import 'package:webdex_app/widgets/details_card.dart';

ValueNotifier responseBody = ValueNotifier(null);

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

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero)
        .then((e) => (_key as ScaffoldState).openDrawer());
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _key,
      drawerEnableOpenDragGesture: false,
      drawerScrimColor: Colors.transparent,
      onEndDrawerChanged: (isOpened) {
        if (!isOpened) responseBody.value = null;
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
              initialCenter: LatLng(widget.lat, widget.lon),
              initialZoom: widget.search ? 9 : 5,
              onMapReady: () {
                if (widget.search) {
                  loadLocationDetails(widget.lat, widget.lon);
                  openDetails();
                }
              },
              onPositionChanged: (camera, hasGesture) {
                if (_controller.camera.zoom < 4.5) Navigator.pop(context);
              },
              onTap: (tapPosition, point) {
                travelTo(point.latitude, point.longitude);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: height * 0.05),
            alignment: Alignment.bottomCenter,
            child: CustomSearchBar(
              onSubmitted: (p0) => travelTo(p0.latitude, p0.longitude),
            ),
          ),
          if (Platform.isIOS)
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
    loadLocationDetails(lat, lon);

    openDetails();
    _controller.move(LatLng(lat, lon), 9);
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

  void loadLocationDetails(double lat, double lon) {
    http
        .get(Uri.parse("https://webdex-api.vercel.app/path/?lat=$lat&lon=$lon"))
        .then((value) async {
      Map response = json.decode(value.body);

      try {
        final geoRes = await http.get(Uri.parse(
            "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&zoom=10&addressdetails=1"));

        response['location'] = json.decode(geoRes.body)['address']['state'];
      } catch (e) {}

      responseBody.value = response;
    });
  }
}
