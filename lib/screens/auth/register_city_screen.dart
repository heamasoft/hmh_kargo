import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/iraq_locations.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/registration_provider.dart';
import '../../router.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';
import '../../widgets/auth_scaffold.dart';
import '../../widgets/labeled_field.dart';

const _otherCity = '__other__';

class RegisterCityScreen extends StatefulWidget {
  const RegisterCityScreen({super.key});

  @override
  State<RegisterCityScreen> createState() => _RegisterCityScreenState();
}

class _RegisterCityScreenState extends State<RegisterCityScreen> {
  final _phone = TextEditingController();
  final _customCity = TextEditingController();
  String? _governorate; // canonical Arabic governorate name
  String? _city; // canonical Arabic city name, or _otherCity
  String? _govError;
  String? _cityError;
  String? _phoneError;
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    _customCity.dispose();
    super.dispose();
  }

  String get _cityValue =>
      _city == _otherCity ? _customCity.text.trim() : (_city ?? '');

  Future<void> _next() async {
    if (_loading) return;
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final phone = _phone.text.trim();
    final digits = _phone.text.replaceAll(RegExp(r'\D'), '');
    setState(() {
      _govError = _governorate == null ? l.selectGovernorate : null;
      _cityError = _cityValue.isEmpty ? l.errCity : null;
      _phoneError = digits.length < 7 ? l.errPhone : null;
    });
    if (_governorate == null || _cityValue.isEmpty || digits.length < 7) return;

    // Store the readable "City, Governorate" for the account (byKey passes it
    // through unchanged since it isn't a fixed key).
    final cityName = _city == _otherCity
        ? _customCity.text.trim()
        : IraqLocations.cityDisplay(_governorate!, _city!, lang);
    final govName = IraqLocations.govDisplay(_governorate!, lang);

    context.read<RegistrationProvider>()
      ..setCity('$cityName, $govName')
      ..setLocation(_governorate!, _cityValue)
      ..setPhone(phone);

    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().requestOtp(
            identifier: phone,
            channel: 'whatsapp',
            purpose: 'register',
          );
      if (!mounted) return;
      Navigator.pushNamed(context, Routes.registerOtp);
    } on ApiException catch (e) {
      if (mounted) setState(() => _phoneError = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final cities =
        _governorate == null ? <String>[] : IraqLocations.citiesOf(_governorate!);

    return AuthScaffold(
      totalSteps: 4,
      currentStep: 2,
      title: l.regCityTitle,
      subtitle: l.regCityStep,
      buttonLabel: _loading ? '${l.sendCode}…' : l.sendCode,
      onButton: _next,
      children: [
        LabeledField(
          label: l.governorate,
          error: _govError,
          child: _dropdown(
            hint: l.selectGovernorate,
            value: _governorate,
            items: IraqLocations.governorateNames,
            display: (v) => IraqLocations.govDisplay(v, lang),
            onChanged: (v) => setState(() {
              _governorate = v;
              _city = null;
              _customCity.clear();
              _govError = null;
            }),
          ),
        ),
        LabeledField(
          label: l.city,
          error: _cityError,
          child: _dropdown(
            hint: l.selectCity,
            value: _city,
            items: cities,
            display: (v) => IraqLocations.cityDisplay(_governorate ?? '', v, lang),
            extra: (_otherCity, l.otherCity),
            enabled: _governorate != null,
            onChanged: (v) => setState(() {
              _city = v;
              _cityError = null;
            }),
          ),
        ),
        if (_city == _otherCity)
          LabeledField(
            label: l.city,
            child: TextField(
              controller: _customCity,
              decoration: InputDecoration(hintText: l.otherCity),
              onChanged: (_) => setState(() {}),
            ),
          ),
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
                child: Text(
                  '🇮🇶 +964',
                  style: AppFonts.body(fontSize: 14.5, fontWeight: FontWeight.w700),
                ),
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
      ],
    );
  }

  Widget _dropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String)? display,
    (String, String)? extra,
    bool enabled = true,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      hint: Text(hint, style: AppFonts.body(fontSize: 14.5, color: AppColors.hintText)),
      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.muted),
      decoration: const InputDecoration(isDense: true),
      style: AppFonts.body(fontSize: 14.5, fontWeight: FontWeight.w500, color: AppColors.ink),
      items: [
        ...items.map((o) => DropdownMenuItem(
              value: o,
              child: Text(display != null ? display(o) : o,
                  overflow: TextOverflow.ellipsis),
            )),
        if (extra != null)
          DropdownMenuItem(
            value: extra.$1,
            child: Text(extra.$2,
                style: AppFonts.body(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.pomegranate)),
          ),
      ],
      onChanged: enabled ? onChanged : null,
    );
  }
}
