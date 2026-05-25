import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? 'https://placeholder.supabase.co',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder_anon_key',
    );
  } catch (_) {
    // Demo mode — Supabase not configured, app runs with local seed data
  }

  final appState = AppState();
  await appState.initialize();

  runApp(
    ChangeNotifierProvider.value(value: appState, child: const GrowWiseApp()),
  );
}

class GrowWiseApp extends StatelessWidget {
  const GrowWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return MaterialApp(
      title: 'GrowWise',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.rootTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.of(context).textScaler.clamp(
            minScaleFactor: 1.0,
            maxScaleFactor: 1.15,
          ),
        ),
        child: child!,
      ),
      home: const SplashScreen(),
    );
  }
}
