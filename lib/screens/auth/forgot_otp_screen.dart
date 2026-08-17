import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../router.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/heama_toast.dart';

/// Step 2 of the password reset: verify the code sent to [phone]. Verifying
/// signs the (existing) user in transiently so the new password can be set.
class ForgotOtpScreen extends StatefulWidget {
  final String phone;
  const ForgotOtpScreen({super.key, required this.phone});

  @override
  State<ForgotOtpScreen> createState() => _ForgotOtpScreenState();
}

class _ForgotOtpScreenState extends State<ForgotOtpScreen> {
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

  void _onChanged(int i, String v) {
    if (v.isNotEmpty && i < 3) _nodes[i + 1].requestFocus();
    if (v.isEmpty && i > 0) _nodes[i - 1].requestFocus();
  }

  Future<void> _verify() async {
    if (_loading) return;
    final l = AppLocalizations.of(context);
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 4) {
      setState(() => _error = l.errOtp);
      return;
    }
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      await context.read<AuthProvider>().verifyOtp(
            identifier: widget.phone,
            channel: 'whatsapp',
            code: code,
          );
      if (!mounted) return;
      // Code accepted — now let them choose a new password.
      Navigator.pushNamed(context, Routes.forgotNewPassword, arguments: widget.phone);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    final l = AppLocalizations.of(context);
    try {
      await context.read<AuthProvider>().requestOtp(
            identifier: widget.phone,
            channel: 'whatsapp',
            purpose: 'reset',
          );
      if (mounted) showHeamaToast(context, l.codeResent);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AuthScaffold(
      totalSteps: 3,
      currentStep: 2,
      title: l.resetTitle,
      subtitle: l.regOtpStep('+964 ${widget.phone}'),
      buttonLabel: _loading ? '${l.verify}…' : l.verify,
      onButton: _verify,
      children: [
        const SizedBox(height: 22),
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i == 3 ? 0 : 11),
                child: TextField(
                  controller: _controllers[i],
                  focusNode: _nodes[i],
                  maxLength: 1,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppFonts.display(fontSize: 22),
                  decoration: const InputDecoration(
                    counterText: '',
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (v) => _onChanged(i, v),
                ),
              ),
            );
          }),
        ),
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
