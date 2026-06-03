import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  runZonedGuarded(_bootstrap, (error, stack) {
    // Catch unhandled async exceptions (e.g. expired refresh token from Supabase)
    if (error is AuthApiException) {
      debugPrint('[Auth] Session error caught: ${error.message}');
      try {
        Supabase.instance.client.auth.signOut();
      } catch (_) {}
    } else {
      debugPrint('[Error] Unhandled: $error');
    }
  });
}

Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? 'https://placeholder.supabase.co',
      anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'placeholder_anon_key',
      // detectSessionInUri: false → tắt tự xử lý URL trong initialize().
      // Mình tự gọi getSessionFromUrl() SAU KHI đăng ký listener,
      // đảm bảo bắt được event passwordRecovery đúng thứ tự.
      authOptions: const FlutterAuthClientOptions(detectSessionInUri: false),
    );
  } catch (_) {
    // Demo mode — Supabase not configured, app runs with local seed data
  }

  final appState = AppState();

  // 1. Đăng ký listener TRƯỚC khi xử lý URL
  Supabase.instance.client.auth.onAuthStateChange.listen(
    (data) {
      if (data.event == AuthChangeEvent.passwordRecovery) {
        appState.onPasswordRecovery();
      }
    },
    onError: (error) {
      // Auth stream errors (e.g. refresh token invalid) — sign out gracefully
      debugPrint('[Auth] Stream error: $error');
      Supabase.instance.client.auth.signOut().ignore();
    },
    cancelOnError: false,
  );

  // 2. Bây giờ mới xử lý URL — event sẽ được listener bắt đúng thứ tự
  if (kIsWeb) {
    final uri = Uri.base;
    final hasCode = uri.queryParameters.containsKey('code');
    final hasFragment = uri.fragment.contains('access_token');
    if (hasCode || hasFragment) {
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      } catch (_) {}
    }
  }

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
          textScaler: MediaQuery.of(
            context,
          ).textScaler.clamp(minScaleFactor: 1.0, maxScaleFactor: 1.15),
        ),
        child: child!,
      ),
      home: const SplashScreen(),
    );
  }
}
