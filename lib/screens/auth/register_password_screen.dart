import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../router.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/labeled_field.dart';

class RegisterPasswordScreen extends StatefulWidget {
  const RegisterPasswordScreen({super.key});

  @override
  State<RegisterPasswordScreen> createState() => _RegisterPasswordScreenState();
}

class _RegisterPasswordScreenState extends State<RegisterPasswordScreen> {
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
      // The user is already signed in from the OTP step.
      await context.read<AuthProvider>().setPassword(_pw.text);
      if (mounted) Navigator.pushNamed(context, Routes.registerSuccess);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _skip() => Navigator.pushNamed(context, Routes.registerSuccess);

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
      totalSteps: 4,
      currentStep: 4,
      title: l.regPwTitle,
      subtitle: l.regPwOptionalSub,
      buttonLabel: _loading ? '${l.createAccount}…' : l.createAccount,
      onButton: _save,
      footer: Center(
        child: GestureDetector(
          onTap: _skip,
          child: Text(
            l.skipForNow,
            style: AppFonts.body(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ),
      ),
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
