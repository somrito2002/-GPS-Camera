import 'package:flutter/material.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationsScreen extends StatelessWidget {
  final String addressLine1;
  final String addressLine2;
  final String latLong;
  final LatLng? currentLatLng;

  const LocationsScreen({
    super.key,
    required this.addressLine1,
    required this.addressLine2,
    required this.latLong,
    this.currentLatLng,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final textSubColor = isDark ? Colors.white70 : Colors.black87;
    final dividerColor = isDark ? Colors.grey[900] : const Color(0xFFEEEEEE);
    final cardColor = isDark ? Colors.grey[900] : Colors.grey[200];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Locations', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          const Icon(Icons.play_circle_filled, color: Colors.red, size: 24),
          const SizedBox(width: 8),
          Center(child: Text('Help', style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 14))),
          const SizedBox(width: 16),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Map placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: currentLatLng != null ? FlutterMap(
                      options: MapOptions(
                        initialCenter: currentLatLng!,
                        initialZoom: 15.0,
                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://mt0.google.com/vt/lyrs=y&hl=en&x={x}&y={y}&z={z}',
                          userAgentPackageName: 'com.example.geotag',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: currentLatLng!,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                            ),
                          ],
                        ),
                      ],
                    ) : const Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(child: Text('Google', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 11))),
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.0),
                          child: Icon(Icons.location_on, color: Colors.red, size: 24),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Current Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textSubColor)),
                      const SizedBox(height: 4),
                      Text(
                        '$addressLine1\n$addressLine2',
                        style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        latLong,
                        style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Icon(Icons.check_circle, color: Colors.amber, size: 20),
                ),
              ],
            ),
          ),
          Divider(thickness: 1, color: dividerColor),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            child: Text('Manual Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textSubColor)),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  "You can edit location's address by\nadding manual location.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.white38 : Colors.black38, fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 24.0, right: 8.0),
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.amber,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
