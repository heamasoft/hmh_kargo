import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../router.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/heama_toast.dart';
import '../../widgets/labeled_field.dart';

/// Step 3 of the password reset: set a new password (the user is signed in from
/// the verified code), then sign out and return to login to sign in fresh.
class ForgotNewPasswordScreen extends StatefulWidget {
  final String phone;
  const ForgotNewPasswordScreen({super.key, required this.phone});

  @override
  State<ForgotNewPasswordScreen> createState() => _ForgotNewPasswordScreenState();
}

class _ForgotNewPasswordScreenState extends State<ForgotNewPasswordScreen> {
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _pw.dispose();
    _pw2.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_loading) return;
    final l = AppLocalizations.of(context);
    if (_pw.text.length < 6 || _pw.text != _pw2.text) {
      setState(() => _error = l.errPw);
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final auth = context.read<AuthProvider>();
      // Signed in from the verified code — update the password, then sign out so
      // the user logs in fresh with their new password.
      await auth.setPassword(_pw.text);
      await auth.logout();
      if (!mounted) return;
      showHeamaToast(context, l.passwordUpdated);
      Navigator.pushNamedAndRemoveUntil(context, Routes.login, (r) => false);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _eye(bool obscured, VoidCallback toggle) => IconButton(
        icon: Icon(
          obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: AppColors.muted,
          size: 20,
        ),
        onPressed: toggle,
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AuthScaffold(
      totalSteps: 3,
      currentStep: 3,
      title: l.newPwTitle,
      subtitle: l.newPwSub,
      buttonLabel: _loading ? '${l.savePassword}…' : l.savePassword,
      onButton: _save,
      children: [
        LabeledField(
          label: l.password,
          child: TextField(
            controller: _pw,
            obscureText: _obscure1,
            decoration: InputDecoration(
              hintText: l.passwordHint,
              suffixIcon: _eye(_obscure1, () => setState(() => _obscure1 = !_obscure1)),
            ),
          ),
        ),
        LabeledField(
          label: l.confirmPassword,
          error: _error,
          child: TextField(
            controller: _pw2,
            obscureText: _obscure2,
            decoration: InputDecoration(
              hintText: l.confirmPasswordHint,
              suffixIcon: _eye(_obscure2, () => setState(() => _obscure2 = !_obscure2)),
            ),
            onSubmitted: (_) => _save(),
          ),
        ),
      ],
    );
  }
}
