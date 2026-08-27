import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _handleLogout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('login_time');

    if (!context.mounted) return;
    
    // Clear all routes and push login screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
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
          icon: Icon(Icons.arrow_back_ios, color: titleColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: appBarBg,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Log out',
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Log out'),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          _handleLogout(context); // Perform logout
                        },
                        child: const Text(
                          'Log out',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
