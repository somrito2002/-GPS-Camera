import 'package:flutter/material.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:gal/gal.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'video_preview_screen.dart';
import 'locations_screen.dart';
import 'main.dart'; // Access 'cameras' global

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  double _brightnessValue = 0.5;
  bool _showBrightnessSlider = false;
  Timer? _sliderTimer;
  Timer? _timeTimer;

  CameraController? _cameraController;
  
  String _addressLine1 = "Fetching address...";
  String _addressLine2 = "";
  String _latLong = "Lat -- Long --";
  String _currentTime = "";
  LatLng? _currentLatLng;
  XFile? _lastCapturedFile;
  int _selectedCameraIndex = 0;
  bool _isVideoMode = false;
  bool _isRecording = false;
  double _currentZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _initLocation();
    _currentTime = DateFormat("EEEE, dd/MM/yyyy hh:mm a 'GMT' Z").format(DateTime.now());
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateFormat("EEEE, dd/MM/yyyy hh:mm a 'GMT' Z").format(DateTime.now());
        });
      }
    });
  }

  Future<void> _initCamera() async {
    if (cameras.isEmpty) return;
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
    _cameraController = CameraController(
      cameras[_selectedCameraIndex], 
      ResolutionPreset.high,
      enableAudio: true,
    );
    try {
      await _cameraController!.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  void _switchCamera() {
    if (cameras.isEmpty) return;
    setState(() {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras.length;
    });
    _initCamera();
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() { _addressLine1 = "Location services disabled"; });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() { _addressLine1 = "Location permissions denied"; });
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      if (mounted) setState(() { _addressLine1 = "Location denied forever"; });
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      if (mounted) {
        setState(() {
          _latLong = "Lat ${position.latitude.toStringAsFixed(6)}° Long ${position.longitude.toStringAsFixed(6)}°";
          _currentLatLng = LatLng(position.latitude, position.longitude);
        });
      }

      List<Placemark> placemarks = await Geocoding().placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        if (mounted) {
          setState(() {
            _addressLine1 = "${place.subLocality ?? place.locality ?? ''}, ${place.administrativeArea ?? ''}, ${place.country ?? ''}".trim().replaceAll(RegExp(r'^,|,$'), '');
            _addressLine2 = "${place.street ?? ''} ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.administrativeArea ?? ''} ${place.postalCode ?? ''}, ${place.country ?? ''}".replaceAll(RegExp(r'\s+'), ' ').trim();
          });
        }
      }
    } catch (e) {
      debugPrint("Location Error: $e");
    }
  }

  Future<void> _setZoom(double zoom) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      await _cameraController!.setZoomLevel(zoom);
      setState(() {
        _currentZoom = zoom;
      });
    } catch (e) {
      debugPrint("Zoom Error: $e");
    }
  }

  Future<void> _handleShutter() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    
    if (_isVideoMode) {
      if (_isRecording) {
        try {
          XFile file = await _cameraController!.stopVideoRecording();
          if (mounted) {
            setState(() { 
              _isRecording = false;
              _lastCapturedFile = file; 
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Video captured!'), backgroundColor: Colors.green),
            );
          }
        } catch (e) {
          debugPrint("Stop video error: $e");
        }
      } else {
        try {
          await _cameraController!.startVideoRecording();
          if (mounted) {
            setState(() { _isRecording = true; });
          }
        } catch (e) {
          debugPrint("Start video error: $e");
        }
      }
    } else {
      if (_cameraController!.value.isTakingPicture) return;
      try {
        Uint8List? imageBytes = await _screenshotController.capture(delay: const Duration(milliseconds: 10));
        
        if (imageBytes != null) {
          final directory = await getTemporaryDirectory();
          final imagePath = await File('${directory.path}/image_${DateTime.now().millisecondsSinceEpoch}.png').create();
          await imagePath.writeAsBytes(imageBytes);

          if (mounted) {
            setState(() {
              _lastCapturedFile = XFile(imagePath.path);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Photo captured!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
            );
          }
        }
      } catch (e) {
        debugPrint("Take picture error: $e");
      }
    }
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _timeTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.camera, color: Colors.white, size: 28),
                  const Icon(Icons.flash_off, color: Colors.white, size: 28),
                  const Icon(Icons.note_add_outlined, color: Colors.white, size: 28),
                  const Icon(Icons.location_on_outlined, color: Colors.white, size: 28),
                  GestureDetector(
                    onTap: _switchCamera,
                    child: const Icon(Icons.flip_camera_ios_outlined, color: Colors.white, size: 28),
                  ),
                  const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
                ],
              ),
            ),

            // Camera Preview Area (Expanded)
            Expanded(
              child: Screenshot(
                controller: _screenshotController,
                child: GestureDetector(
                onVerticalDragUpdate: (details) {
                  setState(() {
                    _showBrightnessSlider = true;
                    // decrease because dragging up is negative delta, which should increase brightness
                    _brightnessValue -= details.delta.dy / 300;
                    _brightnessValue = _brightnessValue.clamp(0.0, 1.0);
                    // Update camera exposure if supported
                    if (_cameraController != null && _cameraController!.value.isInitialized) {
                       // map 0.0-1.0 to min-max exposure
                       _cameraController!.getMinExposureOffset().then((min) {
                         _cameraController!.getMaxExposureOffset().then((max) {
                           double target = min + (max - min) * _brightnessValue;
                           _cameraController!.setExposureOffset(target);
                         });
                       });
                    }
                  });
                  
                  _sliderTimer?.cancel();
                  _sliderTimer = Timer(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() => _showBrightnessSlider = false);
                    }
                  });
                },
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Camera Preview
                    if (_cameraController != null && _cameraController!.value.isInitialized)
                      ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: SizedBox(
                              width: _cameraController!.value.previewSize?.height ?? 1,
                              height: _cameraController!.value.previewSize?.width ?? 1,
                              child: CameraPreview(_cameraController!),
                            ),
                          ),
                        ),
                      )
                    else
                      const Center(child: CircularProgressIndicator(color: Colors.white)),


                    // Right side slider
                    Positioned(
                      right: 16,
                      top: 100,
                      bottom: 100,
                      child: AnimatedOpacity(
                        opacity: _showBrightnessSlider ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: RotatedBox(
                                quarterTurns: 3,
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 2,
                                    activeTrackColor: Colors.amber,
                                    inactiveTrackColor: Colors.white,
                                    thumbColor: Colors.transparent,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0),
                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 0),
                                  ),
                                  child: Slider(
                                    value: _brightnessValue,
                                    onChanged: (val) {
                                      // slider UI can just read the value, drag controls it
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Icon(Icons.wb_sunny_outlined, color: Colors.white, size: 20),
                            const SizedBox(height: 8),
                            Text(
                              (_brightnessValue * 100).toInt().toString(), 
                              style: const TextStyle(color: Colors.white, fontSize: 16)
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Map Info Overlay
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 40,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
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
                                // Map Image Placeholder
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: _currentLatLng != null ? FlutterMap(
                                      options: MapOptions(
                                        initialCenter: _currentLatLng!,
                                        initialZoom: 15.0,
                                        interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
                                      ),
                                      children: [
                                        TileLayer(
                                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                          userAgentPackageName: 'com.example.geotag',
                                        ),
                                        MarkerLayer(
                                          markers: [
                                            Marker(
                                              point: _currentLatLng!,
                                              child: const Icon(Icons.location_on, color: Colors.red, size: 30),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ) : const Center(
                                      child: Text('Google', style: TextStyle(color: Colors.white54, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Address Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _addressLine1,
                                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _addressLine2,
                                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        _latLong,
                                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                      ),
                                      Text(
                                        _currentTime,
                                        style: TextStyle(color: Colors.grey[400], fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              ),
            ),

            // Tab Bar Area
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_lastCapturedFile != null) {
                        Share.shareXFiles([_lastCapturedFile!]);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please take a photo first!'), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text('SHARE PHOTO', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!_isRecording) setState(() => _isVideoMode = false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: !_isVideoMode ? Colors.amber : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('PHOTO', style: TextStyle(color: !_isVideoMode ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!_isRecording) setState(() => _isVideoMode = true);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _isVideoMode ? Colors.amber : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text('VIDEO', style: TextStyle(color: _isVideoMode ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Text('REPORTS', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            // Bottom Controls Area
            Container(
              color: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Preview
                  GestureDetector(
                    onTap: () {
                      if (_lastCapturedFile != null) {
                        if (_lastCapturedFile!.path.endsWith('.mp4')) {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => VideoPreviewScreen(videoPath: _lastCapturedFile!.path)));
                          return;
                        }
                        Navigator.push(context, MaterialPageRoute(builder: (_) => Scaffold(
                          backgroundColor: Colors.black,
                          appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
                          body: Center(child: Image.file(File(_lastCapturedFile!.path))),
                        )));
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                            color: Colors.grey[800],
                            image: (_lastCapturedFile != null && !_lastCapturedFile!.path.endsWith('.mp4'))
                              ? DecorationImage(
                                  image: FileImage(File(_lastCapturedFile!.path)),
                                  fit: BoxFit.cover,
                                ) 
                              : null,
                          ),
                          child: (_lastCapturedFile != null && _lastCapturedFile!.path.endsWith('.mp4'))
                            ? const Center(child: Icon(Icons.play_arrow, color: Colors.white, size: 20))
                            : null,
                        ),
                        const SizedBox(height: 4),
                        const Text('Preview', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  // Locations
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => LocationsScreen(
                          addressLine1: _addressLine1,
                          addressLine2: _addressLine2,
                          latLong: _latLong,
                          currentLatLng: _currentLatLng,
                        )
                      ));
                    },
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on_outlined, color: Colors.white, size: 32),
                        SizedBox(height: 4),
                        Text('Locations', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                  // Shutter Button
                  GestureDetector(
                    onTap: _handleShutter,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: (_isVideoMode && _isRecording) ? Colors.red : Colors.white, width: 4),
                      ),
                      child: Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: (_isVideoMode && _isRecording) ? 28 : 54,
                          height: (_isVideoMode && _isRecording) ? 28 : 54,
                          decoration: BoxDecoration(
                            shape: (_isVideoMode && _isRecording) ? BoxShape.rectangle : BoxShape.circle,
                            borderRadius: (_isVideoMode && _isRecording) ? BorderRadius.circular(6) : null,
                            color: (_isVideoMode && _isRecording) ? Colors.red : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Storage
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder_outlined, color: Colors.white, size: 32),
                      SizedBox(height: 4),
                      Text('Storage', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                  // Template
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          const Icon(Icons.grid_view, color: Colors.white, size: 32),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 14,
                                minHeight: 14,
                              ),
                              child: const Text(
                                '1',
                                style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Template', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
