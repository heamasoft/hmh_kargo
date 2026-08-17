import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/registration_provider.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/labeled_field.dart';

class RegisterNameScreen extends StatefulWidget {
  const RegisterNameScreen({super.key});

  @override
  State<RegisterNameScreen> createState() => _RegisterNameScreenState();
}

class _RegisterNameScreenState extends State<RegisterNameScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    final l = AppLocalizations.of(context);
    final value = _controller.text.trim();
    if (value.length < 2) {
      setState(() => _error = l.errName);
      return;
    }
    context.read<RegistrationProvider>().setName(value);
    Navigator.pushNamed(context, Routes.registerCity);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return AuthScaffold(
      totalSteps: 4,
      currentStep: 1,
      title: l.regNameTitle,
      subtitle: l.regNameStep,
      buttonLabel: l.continueLabel,
      onButton: _next,
      footer: Center(
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(context, Routes.login),
          child: Text.rich(
            TextSpan(
              text: '${l.alreadyHaveAccount} ',
              style: AppFonts.body(fontSize: 13, color: AppColors.muted),
              children: [
                TextSpan(
                  text: l.login,
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
          label: l.fullName,
          error: _error,
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(hintText: l.fullNameHint),
            onSubmitted: (_) => _next(),
          ),
        ),
      ],
    );
  }
}
