import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/globe_coordinates.dart';
import 'package:http/http.dart' as http;

class CustomSearchBar extends StatefulWidget {
  final bool darkMode;
  final Function(GlobeCoordinates)? onSubmitted;
  const CustomSearchBar({super.key, this.darkMode = false, this.onSubmitted});

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final backgroundColor =
        widget.darkMode ? const Color(0xFF151515) : const Color(0xFF303234);
    final borderColor =
        widget.darkMode ? Colors.grey.shade600 : Colors.grey.shade500;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: borderColor, width: 0.5),
        borderRadius: BorderRadius.circular(21),
        boxShadow: [
          if (!widget.darkMode)
            BoxShadow(
              color: Colors.grey.shade600,
              spreadRadius: 5,
              blurRadius: 15,
            )
        ],
      ),
      width: width * 0.28,
      child: TextField(
        maxLines: 1,
        cursorColor: Colors.white,
        cursorWidth: 0.5,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10),
          hintText: "Search...",
          hintStyle: TextStyle(color: borderColor, fontSize: 15),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        ),
        controller: _controller,
        onSubmitted: (value) async {
          if (value.isEmpty) return;

          final response = await http.get(Uri.parse(
              "https://nominatim.openstreetmap.org/search.php?q=$value&format=jsonv2"));
          final x = json.decode(response.body);

          if (x is List && x.isNotEmpty && widget.onSubmitted != null) {
            widget.onSubmitted!(
              GlobeCoordinates(
                double.parse(x[0]['lat']),
                double.parse(x[0]['lon']),
              ),
            );
          }
        },
      ),
    );
  }
}
