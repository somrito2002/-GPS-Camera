import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';

import '../models/template_config.dart';

enum GeotagTemplate {
  classic,
  reporting,
  navigationCompass,
  advance,
  dateTime,
  scanLocation,
}

class GeotagOverlayBuilder {
  static Widget buildOverlay({
    required BuildContext context,
    required GeotagTemplate template,
    required String addressLine1,
    required String addressLine2,
    required String latLong,
    required String currentTime,
    required LatLng? currentLatLng,
    double? heading,
    double? accuracy,
    TemplateConfig? config,
  }) {
    final effectiveConfig = config ?? const TemplateConfig();
    
    switch (template) {
      case GeotagTemplate.classic:
        return _buildClassicTemplate(
          context: context,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          latLong: latLong,
          currentTime: currentTime,
          currentLatLng: currentLatLng,
          config: effectiveConfig,
        );
      case GeotagTemplate.reporting:
        return _buildReportingTemplate(
          context: context,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          latLong: latLong,
          currentTime: currentTime,
          currentLatLng: currentLatLng,
          config: effectiveConfig,
        );
      case GeotagTemplate.navigationCompass:
        return _buildNavigationCompassTemplate(
          context: context,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          latLong: latLong,
          currentTime: currentTime,
          currentLatLng: currentLatLng,
          heading: heading,
          accuracy: accuracy,
          config: effectiveConfig,
        );
      case GeotagTemplate.advance:
        return _buildAdvanceTemplate(
          context: context,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          latLong: latLong,
          currentTime: currentTime,
          currentLatLng: currentLatLng,
          config: effectiveConfig,
        );
      case GeotagTemplate.dateTime:
        return _buildDateTimeTemplate(
          context: context,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          latLong: latLong,
          config: effectiveConfig,
        );
      case GeotagTemplate.scanLocation:
        return _buildScanLocationTemplate(
          context: context,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          latLong: latLong,
          currentTime: currentTime,
          currentLatLng: currentLatLng,
          config: effectiveConfig,
        );
    }
  }

  static String _getMapUrl(MapType type) {
    switch (type) {
      case MapType.satellite:
        return 'https://mt0.google.com/vt/lyrs=s&hl=en&x={x}&y={y}&z={z}';
      case MapType.terrain:
        return 'https://mt0.google.com/vt/lyrs=p&hl=en&x={x}&y={y}&z={z}';
      case MapType.hybrid:
        return 'https://mt0.google.com/vt/lyrs=y&hl=en&x={x}&y={y}&z={z}';
      case MapType.normal:
      default:
        return 'https://mt0.google.com/vt/lyrs=m&hl=en&x={x}&y={y}&z={z}';
    }
  }

  static Widget _buildMap(LatLng? latLng, TemplateConfig config, {double size = 80, double borderRadius = 8, bool isInteractive = false}) {
    final effectiveSize = size * config.mapScale;
    
    return Container(
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: latLng != null
            ? FlutterMap(
                key: ValueKey(latLng),
                options: MapOptions(
                  initialCenter: latLng,
                  initialZoom: 15.0,
                  interactionOptions: InteractionOptions(
                    flags: isInteractive ? InteractiveFlag.all : InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: _getMapUrl(MapType.satellite), // Strictly satellite as requested
                    userAgentPackageName: 'com.example.geotag',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: latLng,
                        child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                      ),
                    ],
                  ),
                ],
              )
            : const Center(
                child: Text('Google', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
              ),
      ),
    );
  }

  static Widget _buildAddressText({
    required String addressLine1,
    required String addressLine2,
    required String latLong,
    required TemplateConfig config,
    String? currentTime,
    Color titleColor = Colors.white,
    Color subtitleColor = Colors.grey,
  }) {
    String formattedTime = currentTime ?? "";
    if (formattedTime.isNotEmpty && config.dateTimeFormat.isNotEmpty) {
      try {
        formattedTime = DateFormat(config.dateTimeFormat).format(DateTime.now());
      } catch (e) {
        // Fallback if format is invalid
      }
    }

    final effectiveColor = config.stampColor;
    final scale = config.stampSize;
    final fontFam = config.stampFont;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                addressLine1,
                style: TextStyle(
                  color: effectiveColor, 
                  fontSize: 14 * scale, 
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFam,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Text('🇮🇳', style: TextStyle(fontSize: 14)), // Indian Flag placeholder
          ],
        ),
        const SizedBox(height: 4),
        if (!config.shortAddress)
          Text(
            addressLine2,
            style: TextStyle(color: effectiveColor.withValues(alpha: 0.8), fontSize: 11 * scale, fontFamily: fontFam),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        Text(
          latLong,
          style: TextStyle(color: effectiveColor.withValues(alpha: 0.8), fontSize: 11 * scale, fontFamily: fontFam),
        ),
        if (formattedTime.isNotEmpty)
          Text(
            formattedTime,
            style: TextStyle(color: effectiveColor.withValues(alpha: 0.8), fontSize: 11 * scale, fontFamily: fontFam),
          ),
        if (config.notes.isNotEmpty)
          Text(
            'Note: ${config.notes}',
            style: TextStyle(color: effectiveColor.withValues(alpha: 0.9), fontSize: 11 * scale, fontStyle: FontStyle.italic, fontFamily: fontFam),
          ),
        if (config.hashtags.isNotEmpty)
          Text(
            config.hashtags,
            style: TextStyle(color: Colors.blueAccent, fontSize: 11 * scale, fontWeight: FontWeight.w600, fontFamily: fontFam),
          ),
      ],
    );
  }

  static Widget _buildClassicTemplate({
    required BuildContext context,
    required String addressLine1,
    required String addressLine2,
    required String latLong,
    required String currentTime,
    required LatLng? currentLatLng,
    required TemplateConfig config,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, size: 8, color: Colors.black),
              ),
              const SizedBox(width: 4),
              const Text('Meco GPS Camera', style: TextStyle(color: Colors.white, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMap(currentLatLng, config),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAddressText(
                  addressLine1: addressLine1,
                  addressLine2: addressLine2,
                  latLong: latLong,
                  currentTime: currentTime,
                  subtitleColor: Colors.grey[400]!,
                  config: config,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildReportingTemplate({
    required BuildContext context,
    required String addressLine1,
    required String addressLine2,
    required String latLong,
    required String currentTime,
    required LatLng? currentLatLng,
    required TemplateConfig config,
  }) {
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('Check In', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 4),
                  _buildMap(currentLatLng, config),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: _buildAddressText(
                    addressLine1: addressLine1,
                    addressLine2: addressLine2,
                    latLong: latLong,
                    currentTime: currentTime,
                    subtitleColor: Colors.grey[400]!,
                    config: config,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Widget _buildNavigationCompassTemplate({
    required BuildContext context,
    required String addressLine1,
    required String addressLine2,
    required String latLong,
    required String currentTime,
    required LatLng? currentLatLng,
    double? heading,
    double? accuracy,
    required TemplateConfig config,
  }) {
    String headingText = "N/A";
    if (heading != null) {
      if (heading >= 315 || heading < 45) {
        headingText = "Facing North";
      } else if (heading >= 45 && heading < 135) {
        headingText = "Facing East";
      } else if (heading >= 135 && heading < 225) {
        headingText = "Facing South";
      } else {
        headingText = "Facing West";
      }
    }

    return Container(
      width: MediaQuery.of(context).size.width - 32,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compass UI
          Container(
            width: 90,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Column(
              children: [
                SizedBox(
                  height: 60,
                  width: 60,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: (heading ?? 0) * (3.14159 / 180) * -1,
                        child: const Icon(Icons.explore, color: Colors.white, size: 50),
                      ),
                      Text(
                        "${heading?.toStringAsFixed(0) ?? '0'}°",
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(headingText, style: const TextStyle(color: Colors.white, fontSize: 8)),
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Address Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddressText(
                  addressLine1: addressLine1,
                  addressLine2: addressLine2,
                  latLong: latLong,
                  currentTime: currentTime,
                  titleColor: Colors.white,
                  subtitleColor: Colors.grey[400]!,
                  config: config,
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Azimuth/Bearing: ${heading?.toStringAsFixed(2) ?? 'N/A'}°', style: const TextStyle(color: Colors.white, fontSize: 8)),
                  ],
                ),
                Row(
                  children: [
                    const Icon(Icons.landscape, color: Colors.orange, size: 12),
                    const SizedBox(width: 2),
                    Text('${accuracy?.toStringAsFixed(0) ?? '2'} m', style: const TextStyle(color: Colors.white, fontSize: 10)),
                    const SizedBox(width: 16),
                    const Icon(Icons.radar, color: Colors.blue, size: 12),
                    const SizedBox(width: 2),
                    const Text('13.95 µT', style: TextStyle(color: Colors.white, fontSize: 10)),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Map
          _buildMap(currentLatLng, config, size: 60),
        ],
      ),
    );
  }

  static Widget _buildAdvanceTemplate({
    required BuildContext context,
    required String addressLine1,
    required String addressLine2,
    required String latLong,
    required String currentTime,
    required LatLng? currentLatLng,
    required TemplateConfig config,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: MediaQuery.of(context).size.width - 32,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(8),
            border: const Border(left: BorderSide(color: Colors.orange, width: 4)),
          ),
          padding: const EdgeInsets.all(8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _buildMap(currentLatLng, config, size: 80, borderRadius: 8),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAddressText(
                  addressLine1: addressLine1,
                  addressLine2: addressLine2,
                  latLong: latLong,
                  currentTime: currentTime,
                  subtitleColor: Colors.grey[400]!,
                  config: config,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildDateTimeTemplate({
    required BuildContext context,
    required String addressLine1,
    required String addressLine2,
    required String latLong,
    required TemplateConfig config,
  }) {
    final now = DateTime.now();
    final timeStr = DateFormat('hh:mm a').format(now);
    final dateStr = DateFormat('dd MMM yyyy\nEEEE').format(now);

    return Container(
      width: MediaQuery.of(context).size.width - 32,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                timeStr,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                height: 30,
                width: 2,
                color: Colors.amber,
              ),
              const SizedBox(width: 8),
              Text(
                dateStr,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildAddressText(
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            latLong: latLong,
            subtitleColor: Colors.grey[400]!,
            config: config,
          ),
        ],
      ),
    );
  }

  static Widget _buildScanLocationTemplate({
    required BuildContext context,
    required String addressLine1,
    required String addressLine2,
    required String latLong,
    required String currentTime,
    required LatLng? currentLatLng,
    required TemplateConfig config,
  }) {
    String qrData = currentLatLng != null 
        ? "https://maps.google.com/?q=${currentLatLng.latitude},${currentLatLng.longitude}" 
        : "No Location";

    return Container(
      width: MediaQuery.of(context).size.width - 32,
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('Scan Location Template', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('New', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildMap(currentLatLng, config, size: 70),
              const SizedBox(width: 8),
              Expanded(
                child: _buildAddressText(
                  addressLine1: addressLine1,
                  addressLine2: addressLine2,
                  latLong: latLong,
                  currentTime: currentTime,
                  subtitleColor: Colors.grey[400]!,
                  config: config,
                ),
              ),
              const SizedBox(width: 8),
              if (config.showQrCode)
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(4),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 60.0 * config.stampSize,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
