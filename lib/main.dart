import 'package:sizer/sizer.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ui/screens/report_issue_screen.dart'; // update path if you name differently
import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import './services/supabase_service.dart';

Future<Map<String, dynamic>> loadEnv() async {
  final jsonStr = await rootBundle.loadString('env.json');
  return json.decode(jsonStr) as Map<String, dynamic>;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final env = await loadEnv();

  // Initialize Supabase
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
  }
  
  await Supabase.initialize(
    url: "https://nwraxhyomamwyxsscdup.supabase.co",
    anon_Key: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53cmF4aHlvbWFtd3l4c3NjZHVwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc1ODIyNjAsImV4cCI6MjA3MzE1ODI2MH0.0c9AOJn-aWO6LFIbsh4WRnbMLL2kY9cTX3XXk-oz-Ho"
  );
  
  bool _hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!_hasShownError) {
      _hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        _hasShownError = false;
      });

      return CustomErrorWidget(
        errorDetails: details,
      );
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'civiclink',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const ReportIssueScreen(), // quick test screen
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.initial,
      );
    });
  }
}
