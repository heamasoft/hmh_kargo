import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/iraq_locations.dart';
import '../../l10n/app_localizations.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/registration_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/heama_toast.dart';

/// Bottom sheet to add or edit a delivery address
/// (governorate → city → home address).
Future<void> showAddressForm(BuildContext context, {Address? existing}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AddressForm(existing: existing),
  );
}

const _otherCity = '__other__';

class _AddressForm extends StatefulWidget {
  final Address? existing;
  const _AddressForm({this.existing});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _name = TextEditingController();
  final _street = TextEditingController();
  final _phone = TextEditingController();
  final _customCity = TextEditingController();
  String? _governorate;
  String? _city; // a listed city, or _otherCity
  bool _isDefault = false;
  bool _saving = false;
  bool _showErrors = false;

  @override
  void initState() {
    super.initState();
    // Recipient name + phone are always the logged-in user's and can't be changed.
    final user = context.read<AuthProvider>().user;
    _name.text = user?.name ?? '';
    _phone.text = user?.phone ?? '';

    final a = widget.existing;
    if (a != null) {
      _street.text = a.street;
      _isDefault = a.isDefault;
      if (IraqLocations.governorateNames.contains(a.governorate)) {
        _governorate = a.governorate;
        if (IraqLocations.citiesOf(a.governorate).contains(a.city)) {
          _city = a.city;
        } else if (a.city.isNotEmpty) {
          _city = _otherCity;
          _customCity.text = a.city;
        }
      } else if (a.governorate.isNotEmpty) {
        // Not in our list — keep it via the "other city" text.
        _governorate = IraqLocations.governorateNames.first;
        _city = _otherCity;
        _customCity.text = a.city;
      }
    } else {
      // New address: pre-select the governorate + city the user already chose,
      // from this session's registration or, failing that, their saved account
      // city (so it works across app restarts and for logged-in users).
      _prefillDefaultLocation();
    }
  }

  /// Applies canonical governorate + city if they exist in our list.
  void _applyLocation(String governorate, String city, {String rawCity = ''}) {
    if (!IraqLocations.governorateNames.contains(governorate)) return;
    _governorate = governorate;
    if (city.isNotEmpty && IraqLocations.citiesOf(governorate).contains(city)) {
      _city = city;
    } else if (rawCity.isNotEmpty) {
      _city = _otherCity;
      _customCity.text = rawCity;
    }
  }

  void _prefillDefaultLocation() {
    // 1) Exact selection from this session's sign-up (canonical values).
    final reg = context.read<RegistrationProvider>();
    if (reg.governorate.isNotEmpty) {
      _applyLocation(reg.governorate, reg.city, rawCity: reg.city);
      if (_governorate != null) return;
    }
    // 2) Parse the city saved on the account (durable across sessions).
    final stored = context.read<AuthProvider>().user?.city ?? '';
    if (stored.isEmpty) return;
    final p = IraqLocations.parseLabel(stored);
    _applyLocation(p.governorate, p.city, rawCity: p.rawCity);
  }

  @override
  void dispose() {
    for (final c in [_name, _street, _phone, _customCity]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _cityValue =>
      _city == _otherCity ? _customCity.text.trim() : (_city ?? '');

  Future<void> _save() async {
    if (_saving) return;
    final ok = _name.text.trim().isNotEmpty &&
        _governorate != null &&
        _cityValue.isNotEmpty &&
        _street.text.trim().isNotEmpty &&
        _phone.text.trim().isNotEmpty;
    if (!ok) {
      setState(() => _showErrors = true);
      return;
    }

    setState(() => _saving = true);
    final provider = context.read<AddressProvider>();
    final body = <String, dynamic>{
      'recipient_name': _name.text.trim(),
      'governorate': _governorate,
      'city': _cityValue,
      'street': _street.text.trim(),
      'phone': _phone.text.trim(),
      'is_default': _isDefault,
    };
    final success = widget.existing == null
        ? await provider.add(body)
        : await provider.edit(widget.existing!.id, body);
    if (!mounted) return;
    setState(() => _saving = false);
    if (!success) {
      showHeamaToast(context, provider.error ?? 'Could not save.');
      return;
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final cities = _governorate == null
        ? <String>[]
        : IraqLocations.citiesOf(_governorate!);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.line, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 14),
            Text(widget.existing == null ? l.addAddress : l.editAddress,
                style: AppFonts.display(fontSize: 18)),
            const SizedBox(height: 14),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _textField(l.fullName, _name, readOnly: true),
                    const SizedBox(height: 12),
                    _dropdown(
                      label: l.governorate,
                      hint: l.selectGovernorate,
                      value: _governorate,
                      items: IraqLocations.governorateNames,
                      display: (v) => IraqLocations.govDisplay(v, lang),
                      onChanged: (v) => setState(() {
                        _governorate = v;
                        _city = null;
                        _customCity.clear();
                      }),
                    ),
                    const SizedBox(height: 12),
                    _dropdown(
                      label: l.city,
                      hint: l.selectCity,
                      value: _city,
                      items: cities,
                      display: (v) =>
                          IraqLocations.cityDisplay(_governorate ?? '', v, lang),
                      extra: (_otherCity, l.otherCity),
                      enabled: _governorate != null,
                      onChanged: (v) => setState(() => _city = v),
                    ),
                    if (_city == _otherCity) ...[
                      const SizedBox(height: 10),
                      _textField(l.city, _customCity, hint: l.otherCity),
                    ],
                    const SizedBox(height: 12),
                    _textField(l.homeAddress, _street,
                        hint: l.homeAddressHint, maxLines: 2),
                    const SizedBox(height: 12),
                    _textField(l.phoneNumber, _phone,
                        keyboard: TextInputType.phone, readOnly: true),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => setState(() => _isDefault = !_isDefault),
                      behavior: HitTestBehavior.opaque,
                      child: Row(
                        children: [
                          Icon(
                            _isDefault
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: _isDefault ? AppColors.pomegranate : AppColors.muted,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Text(l.setDefault,
                              style: AppFonts.body(
                                  fontSize: 13.5, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 4),
              child: GestureDetector(
                onTap: _save,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                      color: AppColors.pomegranate,
                      borderRadius: BorderRadius.circular(15)),
                  alignment: Alignment.center,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(l.saveLabel,
                          style: AppFonts.body(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController c,
      {String? hint, int maxLines = 1, TextInputType? keyboard, bool readOnly = false}) {
    final err = !readOnly && _showErrors && c.text.trim().isEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: AppFonts.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: err ? AppColors.pomegranate : AppColors.muted)),
            if (readOnly) ...[
              const SizedBox(width: 5),
              const Icon(Icons.lock_outline, size: 11, color: AppColors.muted),
            ],
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          controller: c,
          maxLines: maxLines,
          minLines: 1,
          keyboardType: keyboard,
          readOnly: readOnly,
          onChanged: readOnly ? null : (_) => setState(() {}),
          style: AppFonts.body(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: readOnly ? AppColors.muted : AppColors.ink),
          decoration: InputDecoration(
            isDense: true,
            filled: readOnly,
            fillColor: readOnly ? AppColors.cloud : null,
            hintText: hint,
            hintStyle: AppFonts.body(fontSize: 12.5, color: AppColors.hintText),
            errorText: err ? '' : null,
            errorStyle: const TextStyle(height: 0, fontSize: 0),
          ),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String)? display,
    (String, String)? extra,
    bool enabled = true,
  }) {
    final err = _showErrors && (value == null || value.isEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppFonts.body(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: err ? AppColors.pomegranate : AppColors.muted)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          hint: Text(hint,
              style: AppFonts.body(fontSize: 14, color: AppColors.hintText)),
          icon: const Icon(Icons.expand_more, size: 20, color: AppColors.muted),
          decoration: const InputDecoration(isDense: true),
          style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
          items: [
            ...items.map((o) => DropdownMenuItem(
                value: o,
                child: Text(display != null ? display(o) : o,
                    overflow: TextOverflow.ellipsis))),
            if (extra != null)
              DropdownMenuItem(
                value: extra.$1,
                child: Text(extra.$2,
                    style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pomegranate)),
              ),
          ],
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
