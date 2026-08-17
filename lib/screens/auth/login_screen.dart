import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../router.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/labeled_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _pw = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _phoneError;
  String? _pwError;

  @override
  void dispose() {
    _phone.dispose();
    _pw.dispose();
    super.dispose();
  }

  bool _validPhone() {
    final ok = _phone.text.replaceAll(RegExp(r'\D'), '').length >= 7;
    setState(() => _phoneError = ok ? null : AppLocalizations.of(context).errPhone);
    return ok;
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_validPhone()) return;
    final phone = _phone.text.trim();
    setState(() {
      _pwError = null;
      _loading = true;
    });
    try {
      await context.read<AuthProvider>().login(phone: phone, password: _pw.text);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, Routes.home, (r) => false);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _pwError = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final label = l.login;
    return AuthScaffold(
      totalSteps: 1,
      currentStep: 1,
      title: l.welcomeBack,
      subtitle: l.loginSub,
      buttonLabel: _loading ? '$label…' : label,
      onButton: _submit,
      footer: Center(
        child: GestureDetector(
          onTap: () => Navigator.pushReplacementNamed(context, Routes.registerName),
          child: Text.rich(
            TextSpan(
              text: '${l.newToHeama} ',
              style: AppFonts.body(fontSize: 13, color: AppColors.muted),
              children: [
                TextSpan(
                  text: l.createAccount,
                  style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pomegranate,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      children: [
        LabeledField(
          label: l.phoneNumber,
          error: _phoneError,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 15),
                decoration: BoxDecoration(
                  color: AppColors.cloud,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  border: Border.all(color: AppColors.line, width: 1.5),
                ),
                child: Text('🇮🇶 +964',
                    style: AppFonts.body(fontSize: 14.5, fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: TextField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(hintText: l.phoneHint),
                ),
              ),
            ],
          ),
        ),
        LabeledField(
          label: l.password,
          error: _pwError,
          child: TextField(
            controller: _pw,
            obscureText: _obscure,
            decoration: InputDecoration(
              hintText: l.yourPassword,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.muted,
                  size: 20,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
            onSubmitted: (_) => _submit(),
          ),
        ),
        // Forgot password → phone → code → new password flow.
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, Routes.forgotPassword),
              child: Text(
                l.forgotPassword,
                style: AppFonts.body(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pomegranate,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
