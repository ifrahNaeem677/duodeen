import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_screens.dart';
import 'screens/main_shell.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

// ===================== YOUR SUPABASE DETAILS =====================
// Supabase → Project Settings → API (or "API Keys").
// Use the PUBLISHABLE key only. NEVER put the secret key here.
const String supabaseUrl = 'https://jdkbegdebhfasrzmlpbh.supabase.co';
const String supabasePublishableKey = 'sb_publishable_vSWka3ukLZoFcnHjmpD5iQ_qHF2R10J';
// =================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String? startupError;
  try {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabasePublishableKey);
  } catch (e) {
    startupError = e.toString();
  }
  await NotificationService.init();
  runApp(DuoDeenApp(startupError: startupError));
}

class DuoDeenApp extends StatelessWidget {
  final String? startupError;
  const DuoDeenApp({super.key, this.startupError});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DuoDeen',
      theme: buildAppTheme(),
      home: startupError != null ? _StartupError(startupError!) : const AuthGate(),
    );
  }
}

/// Logged in → Home. Not logged in → Welcome / Login.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;
    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = auth.currentSession;
        if (session == null) return const WelcomeScreen();
        return const MainShell();
      },
    );
  }
}

class _StartupError extends StatelessWidget {
  final String message;
  const _StartupError(this.message);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('Could not connect to Supabase',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text('Check the URL and publishable key in lib/main.dart.\n\n$message',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
