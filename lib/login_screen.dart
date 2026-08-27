import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'splash_screen.dart'; // for AppLogo and potentially map background

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ValueNotifier<bool> _obscurePasswordNotifier = ValueNotifier<bool>(true);
  final ValueNotifier<String?> _selectedLocationNotifier = ValueNotifier<String?>(null);

  bool _isLoginEnabled = false;

  static const Color _mecoGreen = Color(0xFF4CAF50);
  static const Color _backgroundColor = Color(0xFF091410);
  static const Color _surfaceColor = Color(0xFF132018);
  static const Color _borderColor = Color(0xFF223629);
  static const Color _textSecondary = Color(0xFFA1ACA6);

  final List<String> _locations = [
    'Location A',
    'Location B',
    'Location C',
  ];

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updateLoginState);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscurePasswordNotifier.dispose();
    _selectedLocationNotifier.dispose();
    super.dispose();
  }

  void _updateLoginState() {
    setState(() {
      _isLoginEnabled = _passwordController.text.isNotEmpty;
    });
  }

  Future<void> _handleLogin() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    
    bool isOffline = false;
    if (connectivityResult.contains(ConnectivityResult.none) && connectivityResult.length == 1) {
      isOffline = true;
    } else if (connectivityResult.isEmpty) {
      isOffline = true;
    }

    if (!mounted) return;

    if (isOffline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Check your internet connection. You are offline')),
      );
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email == 'siteeng@meco.com' && password == 'nopass') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('login_time', DateTime.now().millisecondsSinceEpoch);
      
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('LogIn credentials Mismatched')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: Stack(
        children: [
          // Subtle Map Background (reusing the splash screen painter)
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(
                painter: MapBackgroundPainter(),
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- Logo ---
                      const AppLogo(),
                      const SizedBox(height: 16),
                      const Text(
                        'MECO',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Text(
                        'Geo Camera',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: _mecoGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Capture • Tag • Track',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- Login Card ---
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: _borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome Back',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Login to continue',
                              style: TextStyle(
                                fontSize: 15,
                                color: _textSecondary,
                              ),
                            ),
                            const SizedBox(height: 28),

                            // --- Email Field ---
                            const Text(
                              'Email',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _InputField(
                              controller: _emailController,
                              hint: 'Enter email',
                              icon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 20),

                            // --- Password Field ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Password',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {},
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: _mecoGreen,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder<bool>(
                              valueListenable: _obscurePasswordNotifier,
                              builder: (context, obscurePassword, _) {
                                return _InputField(
                                  controller: _passwordController,
                                  hint: 'Enter password',
                                  icon: Icons.lock_outline,
                                  obscureText: obscurePassword,
                                  trailing: IconButton(
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: _textSecondary,
                                      size: 22,
                                    ),
                                    onPressed: () {
                                      _obscurePasswordNotifier.value = !obscurePassword;
                                    },
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),

                            // --- Location Dropdown ---
                            const Text(
                              'Location',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              height: 52,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, color: _mecoGreen),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ValueListenableBuilder<String?>(
                                      valueListenable: _selectedLocationNotifier,
                                      builder: (context, selectedValue, _) {
                                        return DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: selectedValue,
                                            dropdownColor: _surfaceColor,
                                            hint: Text(
                                              'Select your location',
                                              style: TextStyle(
                                                color: Colors.white.withOpacity(0.4),
                                                fontSize: 15,
                                              ),
                                            ),
                                            icon: Icon(
                                              Icons.keyboard_arrow_down,
                                              color: Colors.white.withOpacity(0.6),
                                            ),
                                            style: const TextStyle(color: Colors.white, fontSize: 15),
                                            isExpanded: true,
                                            items: _locations.map((String location) {
                                              return DropdownMenuItem<String>(
                                                value: location,
                                                child: Text(location),
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              _selectedLocationNotifier.value = newValue;
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            // --- Login Button ---
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoginEnabled ? _handleLogin : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _mecoGreen,
                                  disabledBackgroundColor: _mecoGreen.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _isLoginEnabled ? Colors.white : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // --- Divider ---
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Or continue with',
                                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.white.withOpacity(0.1))),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // --- Google Button ---
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 32),
                                label: const Text(
                                  'Google',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // --- Footer ---
                            Center(
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  const Text(
                                    "Don't have an account? ",
                                    style: TextStyle(color: _textSecondary, fontSize: 13),
                                  ),
                                  GestureDetector(
                                    onTap: () {},
                                    child: const Text(
                                      'Sign Up',
                                      style: TextStyle(
                                        color: _mecoGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable outlined text field matching the design (icon + hint + optional trailing).
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscureText;
  final Widget? trailing;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscureText = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Icon(icon, color: const Color(0xFF4CAF50)),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 56,
            minHeight: 24,
          ),
          suffixIcon: trailing,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
          filled: true,
          fillColor: Colors.transparent,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF4CAF50)),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }
}
