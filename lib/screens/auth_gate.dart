import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/heama_splash.dart';
import 'auth/welcome_screen.dart';
import 'shell/main_shell.dart';

/// Decides the first screen based on the saved session:
///  - still checking → splash
///  - signed in      → the app (Home)
///  - signed out     → Welcome
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.restoring) return const HeamaSplash();
    return auth.isAuthenticated ? const MainShell() : const WelcomeScreen();
  }
}
