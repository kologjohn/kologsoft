import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:kologsoft/providers/Datafeed.dart';
import 'package:kologsoft/providers/routes.dart';
import 'package:kologsoft/providers/survey_controller.dart';
import 'package:kologsoft/screens/home_dashboard.dart';
import 'package:kologsoft/services/storage_service.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize storage service

  runApp(MyApp());
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
        initialRoute: Routes.home,
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
