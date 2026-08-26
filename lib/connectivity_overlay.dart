import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityOverlay extends StatefulWidget {
  final Widget child;

  const ConnectivityOverlay({super.key, required this.child});

  @override
  State<ConnectivityOverlay> createState() => _ConnectivityOverlayState();
}

class _ConnectivityOverlayState extends State<ConnectivityOverlay> {
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOffline = false;
  bool _isRestoring = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnectivity();
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    _updateConnectionStatus(result);
  }

  void _updateConnectionStatus(List<ConnectivityResult> result) {
    bool hasConnection = result.any((r) => 
      r == ConnectivityResult.wifi || 
      r == ConnectivityResult.mobile || 
      r == ConnectivityResult.ethernet || 
      r == ConnectivityResult.vpn
    );

    if (hasConnection) {
      if (_isOffline) {
        // Transitioning from offline to online
        setState(() {
          _isRestoring = true;
        });

        // Show green spinner for 600ms, then fade out overlay
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted) {
            setState(() {
              _isRestoring = false;
              _isOffline = false;
            });
          }
        });
      }
    } else {
      // Transitioning to offline
      if (!_isOffline) {
        setState(() {
          _isOffline = true;
          _isRestoring = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool showOverlay = _isOffline || _isRestoring;

    return Stack(
      children: [
        widget.child,
        
        Positioned.fill(
          child: IgnorePointer(
            ignoring: !showOverlay, // Let touches pass through when not showing overlay
            child: AnimatedOpacity(
              opacity: showOverlay ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black.withOpacity(0.8),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedScale(
                        scale: showOverlay ? 1.0 : 0.8,
                        duration: const Duration(milliseconds: 300),
                        child: SizedBox(
                          width: 110,
                          height: 110,
                          child: CircularProgressIndicator(
                            strokeWidth: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _isRestoring ? const Color(0xFF4CAF50) : Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const Text(
                        'No Internet',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
