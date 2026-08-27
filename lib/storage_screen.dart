import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({Key? key}) : super(key: key);

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen> {
  bool _isPhoneStorageEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPhoneStorageEnabled = prefs.getBool('save_to_gallery') ?? false;
    });
  }

  Future<void> _togglePhoneStorage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isPhoneStorageEnabled = value;
    });
    await prefs.setBool('save_to_gallery', value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Files',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Auto-save photos to',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            
            // Phone Storage Card (frozen / coming soon)
            IgnorePointer(
              child: Opacity(
                opacity: 0.5,
                child: _buildStorageOptionCard(
                  icon: Icons.folder,
                  iconColor: Colors.amber,
                  title: 'Phone Storage',
                  subtitle: 'Device Storage -> DCIM -> ...',
                  isEnabled: _isPhoneStorageEnabled,
                  onChanged: null,
                  isFrozen: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageOptionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isEnabled,
    required Function(bool)? onChanged,
    bool isFrozen = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isFrozen) ...
                    [
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Coming Soon',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (!isFrozen)
            const Icon(Icons.chevron_right, color: Colors.grey),
          if (isFrozen)
            const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
          const SizedBox(width: 8),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            activeColor: Colors.amber.shade200,
            activeTrackColor: Colors.amber,
          ),
        ],
      ),
    );
  }
}
