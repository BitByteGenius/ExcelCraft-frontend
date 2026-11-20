import 'package:flutter/foundation.dart';
import 'dart:io' as io;
import 'api_service.dart';

class BackendProcessService {
  static io.Process? _backendProcess;

  static Future<void> ensureBackendRunning() async {
    if (kIsWeb) return;

    final isOnline = await ApiService.checkBackendHealth();
    if (isOnline) {
      debugPrint('✅ Node.js Backend is already running on port 5050.');
      return;
    }

    debugPrint('⏳ Node.js Backend is offline. Attempting to start background service...');
    try {
      String backendDir = 'backend';
      if (!io.Directory(backendDir).existsSync()) {
        final parentBackend = '..\\backend';
        if (io.Directory(parentBackend).existsSync()) {
          backendDir = parentBackend;
        }
      }

      if (io.Directory(backendDir).existsSync()) {
        _backendProcess = await io.Process.start(
          'node',
          ['src/server.js'],
          workingDirectory: backendDir,
          mode: io.ProcessStartMode.detached,
        );
        debugPrint('🚀 Started Node.js backend with PID: ${_backendProcess?.pid}');
      }
    } catch (e) {
      debugPrint('⚠️ Could not automatically launch backend process: $e');
    }
  }

  static void dispose() {
    if (!kIsWeb) {
      _backendProcess?.kill();
    }
  }
}
