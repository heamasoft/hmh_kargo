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

/// Step 1 of the password reset: enter the phone number and send a code.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phone = TextEditingController();
  bool _loading = false;
  String? _phoneError;
  bool _notRegistered = false; // number has no account → offer to register

  @override
  void dispose() {
    _phone.dispose();
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
      _notRegistered = false;
      _loading = true;
    });
    try {
      await context.read<AuthProvider>().requestOtp(
            identifier: phone,
            channel: 'whatsapp',
            purpose: 'reset',
          );
      if (mounted) Navigator.pushNamed(context, Routes.forgotOtp, arguments: phone);
    } on ApiException catch (e) {
      if (!mounted) return;
      // 404 → the number has no account. Don't advance; prompt to register.
      if (e.statusCode == 404) {
        setState(() => _notRegistered = true);
      } else {
        setState(() => _phoneError = e.message);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AuthScaffold(
      totalSteps: 3,
      currentStep: 1,
      title: l.resetTitle,
      subtitle: l.resetSub,
      buttonLabel: _loading ? '${l.sendCode}…' : l.sendCode,
      onButton: _submit,
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
                  onChanged: (_) {
                    if (_notRegistered) setState(() => _notRegistered = false);
                  },
                  onSubmitted: (_) => _submit(),
                ),
              ),
            ],
          ),
        ),
        if (_notRegistered) ...[
          const SizedBox(height: 18),
          _registerPrompt(l),
        ],
      ],
    );
  }

  /// Shown when the entered number has no account: explains it and offers to
  /// open the registration form.
  Widget _registerPrompt(AppLocalizations l) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.pomegranate.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.pomegranate.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 17, color: AppColors.pomegranate),
              const SizedBox(width: 8),
              Expanded(
                child: Text(l.notRegistered,
                    style: AppFonts.body(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pomegranate,
                        height: 1.4)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pushReplacementNamed(context, Routes.registerName),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.pomegranate,
                borderRadius: BorderRadius.circular(13),
              ),
              alignment: Alignment.center,
              child: Text(l.createAccount,
                  style: AppFonts.body(
                      fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
