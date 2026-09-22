import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../l10n/l10n_keys.dart';
import '../../providers/auth_provider.dart';
import '../../providers/registration_provider.dart';
import '../../router.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/heama_toast.dart';
import '../../widgets/otp_boxes.dart';

class RegisterOtpScreen extends StatefulWidget {
  const RegisterOtpScreen({super.key});

  @override
  State<RegisterOtpScreen> createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _nodes = List.generate(4, (_) => FocusNode());
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final n in _nodes) {
      n.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    if (_loading) return;
    final l = AppLocalizations.of(context);
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 4) {
      setState(() => _error = l.errOtp);
      return;
    }

    final reg = context.read<RegistrationProvider>();
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await context.read<AuthProvider>().verifyOtp(
        identifier: reg.phone,
        channel: 'whatsapp',
        code: code,
        name: reg.name,
        city: reg.cityKey.isEmpty ? null : l.byKey(reg.cityKey),
      );
      if (!mounted) return;
      // Signed in via OTP. Continue to set an optional backup password.
      Navigator.pushNamed(context, Routes.registerPassword);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    final l = AppLocalizations.of(context);
    final reg = context.read<RegistrationProvider>();
    try {
      await context.read<AuthProvider>().requestOtp(
        identifier: reg.phone,
        channel: 'whatsapp',
        purpose: 'register',
      );
      if (mounted) showHeamaToast(context, l.codeResent);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final phone = context.watch<RegistrationProvider>().phone;
    return AuthScaffold(
      totalSteps: 4,
      currentStep: 3,
      title: l.regOtpTitle,
      subtitle: l.regOtpStep('+964 $phone'),
      buttonLabel: _loading ? '${l.verify}…' : l.verify,
      onButton: _verify,
      children: [
        const SizedBox(height: 22),
        OtpBoxes(controllers: _controllers, nodes: _nodes),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: AppFonts.body(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.pomegranate),
          ),
        ],
        const SizedBox(height: 16),
        Center(
          child: GestureDetector(
            onTap: _resend,
            child: Text.rich(
              TextSpan(
                text: '${l.didntGetIt} ',
                style: AppFonts.body(fontSize: 12.5, color: AppColors.muted),
                children: [
                  TextSpan(
                    text: l.resendCode,
                    style: AppFonts.body(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pomegranate,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
