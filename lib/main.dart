import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kologsoft/models/itemregmodel.dart';
import 'package:kologsoft/providers/Datafeed.dart';
import 'package:kologsoft/providers/routes.dart';
import 'package:kologsoft/providers/survey_controller.dart';
import 'package:kologsoft/screens/home_dashboard.dart';
import 'package:kologsoft/services/storage_service.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
 // Hive.registerAdapter(ItemModelAdapter());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Enable Firestore offline persistence
  await _enableFirestoreOffline();

  // Initialize storage service

  runApp(MyApp());
}

Future<void> _enableFirestoreOffline() async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Enable offline persistence for mobile and desktop platforms
    if (!kIsWeb) {
      await firestore.enableNetwork();

      // Configure persistence settings
      firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );

      debugPrint('✅ Firestore offline persistence enabled');
    } else {
      // For web, enable persistence differently
      try {
        firestore.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        debugPrint('✅ Firestore web persistence enabled');
      } catch (e) {
        debugPrint('⚠️ Web persistence may already be enabled: $e');
      }
    }
  } catch (e) {
    debugPrint('⚠️ Firestore persistence error: $e');
    // Persistence can fail if already enabled, which is fine
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Datafeed()),
        ChangeNotifierProvider(create: (_) => Survey()),
      ],
      child: MaterialApp(
        initialRoute: Routes.login,
        routes: pages,
        title: 'KologSoft POS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF0D1A26), // blue-black
            onPrimary: Colors.white,
            secondary: Color(0xFF1976D2), // blue
            onSecondary: Colors.white,
            background: Colors.white,
            onBackground: Color(0xFF0D1A26),
            surface: Colors.white,
            onSurface: Color(0xFF0D1A26),
            error: Colors.red,
            onError: Colors.white,
          ),
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.white,
          dialogBackgroundColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
            fillColor: const Color(0xFFF4F6F8),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0D1A26),
            foregroundColor: Colors.white,
            elevation: 2,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.light,
        home: const HomeDashboard(),
      ),
    );
  }
}
