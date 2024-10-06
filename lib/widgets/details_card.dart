import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:panara_dialogs/panara_dialogs.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webdex_app/screens/map.dart';

class DetailsCard extends StatefulWidget {
  const DetailsCard({super.key});

  @override
  State<DetailsCard> createState() => _DetailsCardState();
}

class _DetailsCardState extends State<DetailsCard> {
  @override
  void dispose() {
    update = null;
    responseBody = {};

    super.dispose();
  }

  @override
  void initState() {
    update = () => setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final value = responseBody;

    if (value.isEmpty) {
      if (kIsWeb) {
        return const Center(
          child: Text("Loading..."),
        );
      }

      return SizedBox(
        width: width,
        child: Column(
          children: [
            const SizedBox(height: 20),
            shimmer(width * 0.4, 35),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      shimmer(width * 0.22, 35),
                      const SizedBox(height: 10),
                      shimmer(width * 0.15, 18),
                    ],
                  ),
                  Column(
                    children: [
                      shimmer(width * 0.22, 35),
                      const SizedBox(height: 10),
                      shimmer(width * 0.15, 18),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                children: [
                  shimmer(width * 0.2, width * 0.2),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: width * 0.19,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        shimmer(width * 0.55, width * 0.05),
                        shimmer(width * 0.15, width * 0.05),
                        shimmer(width * 0.13, width * 0.05),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                children: [
                  shimmer(width * 0.2, width * 0.2),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: width * 0.19,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        shimmer(width * 0.55, width * 0.05),
                        shimmer(width * 0.15, width * 0.05),
                        shimmer(width * 0.13, width * 0.05),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
            value['location'] ?? "Location",
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
          chunks(),
          if (!kIsWeb) SizedBox(height: height * 0.05),
          if (kIsWeb) const Expanded(child: SizedBox()),
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
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.all(5),
                          child: Text(
                            e,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: height * 0.022,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                TableRow(
                  children: List.generate(
                    dates.values.length,
                    (index) => tableDateRow(
                      "Next pass",
                      nextDates.values.elementAt(index).first,
                      iconData: Icons.notifications,
                      onTap: () => showNotificationDialog(),
                    ),
                  ),
                ),
                TableRow(
                  children: List.generate(
                    dates.values.length,
                    (index) => tableDateRow(
                      "Last pass",
                      pastDates.values.elementAt(index).last,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget shimmer(double width, double height) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade700.withOpacity(0.2),
      highlightColor: Colors.grey.shade400.withOpacity(0.2),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(3),
          color: Colors.grey.shade900,
        ),
      ),
    );
  }

  Widget chunks() {
    List<Widget> cards = [];
    for (var item in responseBody['chunks']) {
      if (item['items'] == null || item['items'].isEmpty) continue;

      cards.add(
        Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: chunkCard(item),
        ),
      );
    }

    return Column(children: cards);
  }

  Widget chunkCard(Map chunk) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final data = chunk['items'][0];

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) {
                return SizedBox(
                  height: height,
                  width: height,
                  child: Stack(
                    children: [
                      Center(child: Image.network(data['browsePath'])),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: CupertinoButton(
                          child: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Image.network(data['thumbnailPath']),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: width * (kIsWeb ? 0.14 : 0.7),
              child: Text(
                "ID: ${data['displayId']}",
                style: const TextStyle(
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Text("Path: ${chunk['path']}"),
            Text("Row: ${chunk['row']}"),
          ],
        )
      ],
    );
  }

  Widget coordText(double? value, String label) {
    final height = MediaQuery.of(context).size.height;
    if (value == null) return Container();

    return Column(
      children: [
        Text(
          value.toStringAsPrecision(3),
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

  Widget tableDateRow(String label, String date,
      {IconData? iconData, Function? onTap}) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                date,
                style: TextStyle(
                  fontSize: height * 0.021,
                ),
              ),
              if (iconData != null)
                MouseRegion(
                  cursor: onTap != null
                      ? SystemMouseCursors.click
                      : MouseCursor.defer,
                  child: GestureDetector(
                    onTap: () {
                      if (onTap != null) onTap();
                    },
                    child: Container(
                      margin: const EdgeInsets.only(left: 2),
                      child: Icon(iconData),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void showNotificationDialog() {
    PanaraConfirmDialog.show(
      context,
      noImage: true,
      message: "Do you want to recieve a notification the following day?",
      confirmButtonText: "Yes",
      cancelButtonText: "No",
      onTapConfirm: () => Navigator.pop(context),
      onTapCancel: () => Navigator.pop(context),
      panaraDialogType: PanaraDialogType.custom,
      color: Colors.black,
    );
  }
}
