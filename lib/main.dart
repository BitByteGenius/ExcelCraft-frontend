import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/themes/app_theme.dart';
import 'core/services/navigation_provider.dart';
import 'core/services/backend_process_service.dart';
import 'shared/widgets/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Attempt to start Node.js backend only on native Windows desktop (never on Web)
  if (!kIsWeb && io.Platform.isWindows) {
    await BackendProcessService.ensureBackendRunning();
  }

  runApp(const ExcelCraftApp());
}

class ExcelCraftApp extends StatelessWidget {
  const ExcelCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainLayout(),
      ),
    );
  }
}
