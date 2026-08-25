import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF15193B);
    final bgColor = isDark ? Colors.black : const Color(0xFFF0F5F2);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Simulated Map Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.3,
              child: CustomPaint(
                painter: MapBackgroundPainter(),
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 120),
                  
                  // Logo and Title Row
                  Row(
                    children: [
                      // Logo
                      const AppLogo(),
                      const SizedBox(width: 16),
                      // Title
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MECO GPS CAMERA',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: textColor,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Captures proof, not just photos',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Main Heading
                  Text(
                    'Trusted.\nAccurate.\nAuthentic.',
                    style: TextStyle(
                      fontSize: 34,
                      height: 1.2,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -0.5,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Bottom Section
                  Center(
                    child: Column(
                      children: [
                        // Yellow Badge
                        CustomPaint(
                          size: const Size(40, 40),
                          painter: BadgePainter(),
                        ),
                        const SizedBox(height: 24),
                        // Version
                        Text(
                          '1.0.0',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: textColor.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF5DA7F8), // Light Blue
            Color(0xFF72D0A4), // Greenish
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Stack(
        children: [
          // White Corners
          Positioned(top: 8, left: 8, child: _buildCorner(0)),
          Positioned(top: 8, right: 8, child: _buildCorner(math.pi / 2)),
          Positioned(bottom: 8, right: 8, child: _buildCorner(math.pi)),
          Positioned(bottom: 8, left: 8, child: _buildCorner(math.pi * 1.5)),
          
          // Camera Lens
          Center(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF2C324A),
                border: Border.all(color: const Color(0xFFFFC107), width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                  )
                ],
              ),
              child: Center(
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF15193B),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          // Bottom Tag
          Positioned(
            bottom: 4,
            left: 8,
            right: 8,
            child: Container(
              height: 16,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFC107),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.0),
                      child: Text(
                        'LOCATION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner(double angle) {
    return Transform.rotate(
      angle: angle,
      child: CustomPaint(
        size: const Size(12, 12),
        painter: CornerPainter(),
      ),
    );
  }
}

class CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);
      
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BadgePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFFFC107);
    final path = Path();
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final points = 12; // Number of points in the badge
    
    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : radius * 0.8;
      final angle = (i * math.pi) / points;
      
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD4E6DF)
      ..style = PaintingStyle.fill;
      
    // Draw some random map-like blocks
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.1, size.height * 0.2, 100, 150),
        const Radius.circular(8),
      ),
      paint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.6, size.height * 0.1, 120, 80),
        const Radius.circular(8),
      ),
      paint,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.3, size.height * 0.5, 180, 200),
        const Radius.circular(16),
      ),
      Paint()..color = const Color(0xFFE8F1D4),
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.2, size.height * 0.8, 150, 60),
        const Radius.circular(30),
      ),
      Paint()..color = const Color(0xFFD6EAF8),
    );
    
    // Draw some "roads"
    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final roadPath = Path()
      ..moveTo(size.width * 0.8, size.height)
      ..quadraticBezierTo(
          size.width * 0.9, size.height * 0.7, size.width, size.height * 0.6);
          
    canvas.drawPath(roadPath, roadPaint);
    
    // Add location pins
    _drawPin(canvas, Offset(size.width * 0.7, size.height * 0.6), const Color(0xFFE57373));
    _drawPin(canvas, Offset(size.width * 0.1, size.height * 0.65), const Color(0xFF81C784));
    _drawPin(canvas, Offset(size.width * 0.28, size.height * 0.74), const Color(0xFFFFB74D));
    _drawPin(canvas, Offset(size.width * 0.9, size.height * 0.15), const Color(0xFFBA68C8));
  }
  
  void _drawPin(Canvas canvas, Offset position, Color color) {
    final paint = Paint()..color = color.withOpacity(0.5);
    canvas.drawCircle(position, 12, paint);
    
    paint.color = Colors.white;
    canvas.drawCircle(position, 4, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
