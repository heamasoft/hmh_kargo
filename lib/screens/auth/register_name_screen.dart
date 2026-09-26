import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/registration_provider.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/labeled_field.dart';

/// Step 1: the customer's name, asked as the three parts an Iraqi name is made
/// of. All three are required. They are joined with single spaces into the one
/// name the account is saved under, so the rest of the app — deliveries, the
/// admin console — keeps seeing a single full name.
class RegisterNameScreen extends StatefulWidget {
  const RegisterNameScreen({super.key});

  @override
  State<RegisterNameScreen> createState() => _RegisterNameScreenState();
}

class _RegisterNameScreenState extends State<RegisterNameScreen> {
  final _first = TextEditingController();
  final _middle = TextEditingController();
  final _last = TextEditingController();

  final _middleFocus = FocusNode();
  final _lastFocus = FocusNode();

  String? _firstError;
  String? _middleError;
  String? _lastError;

  @override
  void dispose() {
    _first.dispose();
    _middle.dispose();
    _last.dispose();
    _middleFocus.dispose();
    _lastFocus.dispose();
    super.dispose();
  }

  void _next() {
    final l = AppLocalizations.of(context);
    // Collapse any run of spaces the customer typed inside a part, so joining
    // the three cannot produce a double space.
    String clean(TextEditingController c) => c.text.trim().replaceAll(RegExp(r'\s+'), ' ');

    final first = clean(_first);
    final middle = clean(_middle);
    final last = clean(_last);

    setState(() {
      _firstError = first.length < 2 ? l.errFirstName : null;
      _middleError = middle.length < 2 ? l.errMiddleName : null;
      _lastError = last.length < 2 ? l.errLastName : null;
    });
    if (_firstError != null || _middleError != null || _lastError != null) return;

    context.read<RegistrationProvider>().setName('$first $middle $last');
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
        _namePart(
          label: l.firstName,
          hint: l.firstNameHint,
          controller: _first,
          error: _firstError,
          onSubmitted: () => _middleFocus.requestFocus(),
        ),
        _namePart(
          label: l.middleName,
          hint: l.middleNameHint,
          controller: _middle,
          error: _middleError,
          focusNode: _middleFocus,
          onSubmitted: () => _lastFocus.requestFocus(),
        ),
        _namePart(
          label: l.lastName,
          hint: l.lastNameHint,
          controller: _last,
          error: _lastError,
          focusNode: _lastFocus,
          action: TextInputAction.done,
          onSubmitted: _next,
        ),
      ],
    );
  }

  Widget _namePart({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? error,
    required VoidCallback onSubmitted,
    FocusNode? focusNode,
    TextInputAction action = TextInputAction.next,
  }) {
    return LabeledField(
      label: label,
      error: error,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: action,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(hintText: hint),
        onSubmitted: (_) => onSubmitted(),
      ),
    );
  }
}
