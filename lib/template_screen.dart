import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'widgets/geotag_overlays.dart';

class TemplateScreen extends StatefulWidget {
  final String addressLine1;
  final String addressLine2;
  final String latLong;
  final String currentTime;
  final LatLng? currentLatLng;
  final double? currentHeading;
  final double? currentAccuracy;
  
  const TemplateScreen({
    super.key,
    required this.addressLine1,
    required this.addressLine2,
    required this.latLong,
    required this.currentTime,
    required this.currentLatLng,
    this.currentHeading,
    this.currentAccuracy,
  });

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  GeotagTemplate _selectedTemplate = GeotagTemplate.classic;
  final List<GeotagTemplate> _templates = GeotagTemplate.values;

  @override
  void initState() {
    super.initState();
    _loadSelectedTemplate();
  }

  Future<void> _loadSelectedTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('selected_template_index') ?? 0;
    if (index >= 0 && index < GeotagTemplate.values.length) {
      setState(() {
        _selectedTemplate = GeotagTemplate.values[index];
      });
    }
  }

  Future<void> _selectTemplate(GeotagTemplate template) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('selected_template_index', template.index);
    setState(() {
      _selectedTemplate = template;
    });
    if (mounted) {
      Navigator.pop(context, template);
    }
  }

  String _getTemplateName(GeotagTemplate template) {
    switch (template) {
      case GeotagTemplate.classic: return "Classic Template";
      case GeotagTemplate.reporting: return "Reporting Template";
      case GeotagTemplate.navigationCompass: return "Navigation Compass Template";
      case GeotagTemplate.advance: return "Advance Template";
      case GeotagTemplate.dateTime: return "DateTime Template";
      case GeotagTemplate.scanLocation: return "Scan Location Template";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Template', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _templates.length,
        separatorBuilder: (context, index) => const Divider(height: 32, thickness: 8, color: Color(0xFFF0F0F0)),
        itemBuilder: (context, index) {
          final template = _templates[index];
          final isSelected = _selectedTemplate == template;
          
          return GestureDetector(
            onTap: () => _selectTemplate(template),
            child: Container(
              color: isSelected ? Colors.grey[200] : Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      _getTemplateName(template),
                      style: TextStyle(
                        fontSize: 16, 
                        fontWeight: FontWeight.bold,
                        color: template == GeotagTemplate.advance ? Colors.orange : Colors.grey[800]
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AbsorbPointer(
                      child: GeotagOverlayBuilder.buildOverlay(
                        context: context,
                        template: template,
                        addressLine1: widget.addressLine1,
                        addressLine2: widget.addressLine2,
                        latLong: widget.latLong,
                        currentTime: widget.currentTime,
                        currentLatLng: widget.currentLatLng,
                        heading: widget.currentHeading,
                        accuracy: widget.currentAccuracy,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
