import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:latlong2/latlong.dart';
import 'widgets/geotag_overlays.dart';
import 'models/template_config.dart';
import 'edit_template_screen.dart';

/// Meco brand green — matches the logo gradient and location-pin green.
const Color _mecoGreen = Color(0xFF4CAF50);

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

class _TemplateScreenState extends State<TemplateScreen>
    with SingleTickerProviderStateMixin {
  /// The template currently persisted / active on the camera screen.
  GeotagTemplate _activeTemplate = GeotagTemplate.classic;

  /// The template the user has highlighted in this screen session.
  /// Starts equal to _activeTemplate; may differ before the user confirms via pencil.
  GeotagTemplate _selectedTemplate = GeotagTemplate.classic;

  final List<GeotagTemplate> _templates = GeotagTemplate.values;
  
  Map<GeotagTemplate, TemplateConfig> _configs = {};

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _scaleAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _loadSelectedTemplateAndConfigs();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadSelectedTemplateAndConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load configs for all templates
    Map<GeotagTemplate, TemplateConfig> loadedConfigs = {};
    for (var template in _templates) {
      final configJson = prefs.getString('template_config_${template.index}');
      if (configJson != null) {
        try {
          loadedConfigs[template] = TemplateConfig.fromJson(configJson);
        } catch (_) {
          loadedConfigs[template] = const TemplateConfig();
        }
      } else {
        loadedConfigs[template] = const TemplateConfig();
      }
    }

    final index = prefs.getInt('selected_template_index') ?? 0;
    if (mounted) {
      setState(() {
        _configs = loadedConfigs;
        if (index >= 0 && index < GeotagTemplate.values.length) {
          _activeTemplate = GeotagTemplate.values[index];
          _selectedTemplate = GeotagTemplate.values[index];
        }
      });
      _animController.value = 1.0; // show pencil immediately for active
    }
  }

  /// Highlights a card in-screen — does NOT persist or close yet.
  void _onCardTapped(GeotagTemplate template) {
    if (_selectedTemplate == template) return;
    setState(() => _selectedTemplate = template);
    _animController.forward(from: 0.0);
  }

  /// Navigates to the edit screen
  Future<void> _onPencilTapped(GeotagTemplate template) async {
    final bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTemplateScreen(
          template: template,
          templateName: _getTemplateName(template),
          initialConfig: _configs[template] ?? const TemplateConfig(),
          addressLine1: widget.addressLine1,
          addressLine2: widget.addressLine2,
          latLong: widget.latLong,
          currentTime: widget.currentTime,
          currentLatLng: widget.currentLatLng,
          currentHeading: widget.currentHeading,
          currentAccuracy: widget.currentAccuracy,
        ),
      ),
    );

    if (result == true) {
      // Refresh configs if saved
      _loadSelectedTemplateAndConfigs();
    }
  }

  String _getTemplateName(GeotagTemplate template) {
    switch (template) {
      case GeotagTemplate.classic:
        return 'Classic Template';
      case GeotagTemplate.reporting:
        return 'Reporting Template';
      case GeotagTemplate.navigationCompass:
        return 'Navigation Compass Template';
      case GeotagTemplate.advance:
        return 'Advance Template';
      case GeotagTemplate.dateTime:
        return 'DateTime Template';
      case GeotagTemplate.scanLocation:
        return 'Scan Location Template';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : Colors.white;
    final appBarBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : Colors.black;
    final dividerColor =
        isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: titleColor),
          onPressed: () => Navigator.pop(context, _activeTemplate),
        ),
        title: Text(
          'Template',
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBarBg,
        elevation: 1,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: _templates.length,
        separatorBuilder: (context, index) =>
            Divider(height: 32, thickness: 8, color: dividerColor),
        itemBuilder: (context, index) {
          final template = _templates[index];
          return _TemplateCard(
            template: template,
            isSelected: _selectedTemplate == template,
            isActive: _activeTemplate == template,
            templateName: _getTemplateName(template),
            fadeAnim: _fadeAnim,
            scaleAnim: _scaleAnim,
            onCardTap: () => _onCardTapped(template),
            onPencilTap: () => _onPencilTapped(template),
            config: _configs[template] ?? const TemplateConfig(),
            addressLine1: widget.addressLine1,
            addressLine2: widget.addressLine2,
            latLong: widget.latLong,
            currentTime: widget.currentTime,
            currentLatLng: widget.currentLatLng,
            currentHeading: widget.currentHeading,
            currentAccuracy: widget.currentAccuracy,
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// _TemplateCard — isolated widget for a single template entry in the list.
// ---------------------------------------------------------------------------

class _TemplateCard extends StatelessWidget {
  final GeotagTemplate template;
  final bool isSelected;
  final bool isActive;
  final String templateName;
  final Animation<double> fadeAnim;
  final Animation<double> scaleAnim;
  final VoidCallback onCardTap;
  final VoidCallback onPencilTap;
  final TemplateConfig config;

  final String addressLine1;
  final String addressLine2;
  final String latLong;
  final String currentTime;
  final LatLng? currentLatLng;
  final double? currentHeading;
  final double? currentAccuracy;

  const _TemplateCard({
    required this.template,
    required this.isSelected,
    required this.isActive,
    required this.templateName,
    required this.fadeAnim,
    required this.scaleAnim,
    required this.onCardTap,
    required this.onPencilTap,
    required this.config,
    required this.addressLine1,
    required this.addressLine2,
    required this.latLong,
    required this.currentTime,
    required this.currentLatLng,
    required this.currentHeading,
    required this.currentAccuracy,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark
        ? _mecoGreen.withValues(alpha: 0.08)
        : _mecoGreen.withValues(alpha: 0.05);
    final nameColor = template == GeotagTemplate.advance
        ? Colors.orange
        : (isDark ? Colors.white : Colors.grey[800]);

    return GestureDetector(
      onTap: onCardTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? selectedBg : Colors.transparent,
          border: isSelected
              ? const Border(left: BorderSide(color: _mecoGreen, width: 4))
              : const Border(),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // ── Card body ─────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row — leave right space for pencil button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 64, 4),
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          templateName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: nameColor,
                          ),
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _mecoGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Template overlay preview
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: AbsorbPointer(
                    child: GeotagOverlayBuilder.buildOverlay(
                      context: context,
                      template: template,
                      addressLine1: addressLine1,
                      addressLine2: addressLine2,
                      latLong: latLong,
                      currentTime: currentTime,
                      currentLatLng: currentLatLng,
                      heading: currentHeading,
                      accuracy: currentAccuracy,
                      config: config,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),

            // ── Green pencil button (only for the selected template) ───────
            if (isSelected)
              Positioned(
                top: 6,
                right: 12,
                child: FadeTransition(
                  opacity: fadeAnim,
                  child: ScaleTransition(
                    scale: scaleAnim,
                    child: GestureDetector(
                      onTap: onPencilTap,
                      // Prevent the tap from propagating to the card tap
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _mecoGreen,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _mecoGreen.withValues(alpha: 0.45),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


