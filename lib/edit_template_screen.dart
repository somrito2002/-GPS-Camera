import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/template_config.dart';
import 'widgets/geotag_overlays.dart';

const Color _mecoGreen = Color(0xFF4CAF50);

class EditTemplateScreen extends StatefulWidget {
  final GeotagTemplate template;
  final String templateName;
  final TemplateConfig initialConfig;

  final String addressLine1;
  final String addressLine2;
  final String latLong;
  final String currentTime;
  final LatLng? currentLatLng;
  final double? currentHeading;
  final double? currentAccuracy;

  const EditTemplateScreen({
    super.key,
    required this.template,
    required this.templateName,
    required this.initialConfig,
    required this.addressLine1,
    required this.addressLine2,
    required this.latLong,
    required this.currentTime,
    required this.currentLatLng,
    this.currentHeading,
    this.currentAccuracy,
  });

  @override
  State<EditTemplateScreen> createState() => _EditTemplateScreenState();
}

class _EditTemplateScreenState extends State<EditTemplateScreen> {
  late TemplateConfig _config;
  
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _hashtagsController = TextEditingController();
  final TextEditingController _customDateController = TextEditingController();

  final List<String> _dateFormats = [
    'dd MMM yyyy, hh:mm a',
    'dd/MM/yyyy HH:mm',
    'MM/dd/yyyy hh:mm a',
    'yyyy-MM-dd HH:mm:ss',
    'Custom'
  ];

  late String _selectedDateFormat;

  @override
  void initState() {
    super.initState();
    _config = widget.initialConfig;
    _notesController.text = _config.notes;
    _hashtagsController.text = _config.hashtags;
    
    if (_dateFormats.contains(_config.dateTimeFormat)) {
      _selectedDateFormat = _config.dateTimeFormat;
    } else {
      _selectedDateFormat = 'Custom';
      _customDateController.text = _config.dateTimeFormat;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _hashtagsController.dispose();
    _customDateController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('template_config_${widget.template.index}', _config.toJson());
    // Also set as active template
    await prefs.setInt('selected_template_index', widget.template.index);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  void _updateConfig(TemplateConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: _mecoGreen,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final appBarBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close, color: titleColor),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: Text(
          widget.templateName,
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: _saveConfig,
            child: const Text('Save', style: TextStyle(color: _mecoGreen, fontWeight: FontWeight.bold)),
          )
        ],
        backgroundColor: appBarBg,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Live Preview Header
          Container(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
            padding: const EdgeInsets.all(16),
            child: AbsorbPointer(
              child: GeotagOverlayBuilder.buildOverlay(
                context: context,
                template: widget.template,
                addressLine1: widget.addressLine1,
                addressLine2: widget.addressLine2,
                latLong: widget.latLong,
                currentTime: widget.currentTime,
                currentLatLng: widget.currentLatLng,
                heading: widget.currentHeading,
                accuracy: widget.currentAccuracy,
                config: _config,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 1),
          // Settings List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('MAP SETTINGS'),
                DropdownButton<MapType>(
                  value: _config.mapType,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: MapType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _updateConfig(_config.copyWith(mapType: val));
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Short Address'),
                  subtitle: const Text('Hide secondary address line'),
                  activeTrackColor: _mecoGreen.withValues(alpha: 0.5),
                  activeThumbColor: _mecoGreen,
                  value: _config.shortAddress,
                  onChanged: (val) => _updateConfig(_config.copyWith(shortAddress: val)),
                  contentPadding: EdgeInsets.zero,
                ),

                _buildSectionHeader('DATE & TIME'),
                DropdownButton<String>(
                  value: _selectedDateFormat,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _dateFormats.map((format) {
                    return DropdownMenuItem(
                      value: format,
                      child: Text(format),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedDateFormat = val;
                        if (val != 'Custom') {
                          _updateConfig(_config.copyWith(dateTimeFormat: val));
                        }
                      });
                    }
                  },
                ),
                if (_selectedDateFormat == 'Custom') ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: _customDateController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Format (e.g. dd/MM/yyyy)',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => _updateConfig(_config.copyWith(dateTimeFormat: val)),
                  ),
                ],

                _buildSectionHeader('EXTRA INFO'),
                TextField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  onChanged: (val) => _updateConfig(_config.copyWith(notes: val)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _hashtagsController,
                  decoration: const InputDecoration(
                    labelText: 'Hashtags',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                  ),
                  onChanged: (val) => _updateConfig(_config.copyWith(hashtags: val)),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Show QR Code'),
                  activeTrackColor: _mecoGreen.withValues(alpha: 0.5),
                  activeThumbColor: _mecoGreen,
                  value: _config.showQrCode,
                  onChanged: (val) => _updateConfig(_config.copyWith(showQrCode: val)),
                  contentPadding: EdgeInsets.zero,
                ),

                _buildSectionHeader('STAMP SETTINGS'),
                // Stamp Font
                DropdownButton<String>(
                  value: _config.stampFont,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ['Roboto', 'Courier', 'Serif', 'Sans-serif'].map((font) {
                    return DropdownMenuItem(
                      value: font,
                      child: Text(font, style: TextStyle(fontFamily: font)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) _updateConfig(_config.copyWith(stampFont: val));
                  },
                ),
                const SizedBox(height: 16),
                
                // Color Picker
                const Text('Stamp Color', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Colors.white,
                      Colors.black,
                      _mecoGreen,
                      Colors.red,
                      Colors.blue,
                      Colors.orange,
                      Colors.purple,
                      Colors.amber,
                    ].map((color) {
                      return GestureDetector(
                        onTap: () => _updateConfig(_config.copyWith(stampColor: color)),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _config.stampColor.toARGB32() == color.toARGB32() ? _mecoGreen : Colors.grey,
                              width: _config.stampColor.toARGB32() == color.toARGB32() ? 3 : 1,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Size Slider
                const Text('Stamp Size', style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: _config.stampSize,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  activeColor: _mecoGreen,
                  label: _config.stampSize.toStringAsFixed(1),
                  onChanged: (val) => _updateConfig(_config.copyWith(stampSize: val)),
                ),

                // Map Scale Slider
                const Text('Map Scale', style: TextStyle(fontWeight: FontWeight.bold)),
                Slider(
                  value: _config.mapScale,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  activeColor: _mecoGreen,
                  label: _config.mapScale.toStringAsFixed(1),
                  onChanged: (val) => _updateConfig(_config.copyWith(mapScale: val)),
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
