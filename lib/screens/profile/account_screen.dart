import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../router.dart';
import '../../services/api_client.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/heama_toast.dart';

/// Account settings: update name, change password, manage addresses.
/// The phone number is shown but locked (can't be changed).
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pw = TextEditingController();
  final _pw2 = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _savingProfile = false;
  bool _savingPw = false;
  String? _nameError;
  String? _pwError;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _name.text = user?.name ?? '';
    _phone.text = user?.phone ?? '';
  }

  @override
  void dispose() {
    for (final c in [_name, _phone, _pw, _pw2]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_savingProfile) return;
    final l = AppLocalizations.of(context);
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = l.errName);
      return;
    }
    setState(() {
      _nameError = null;
      _savingProfile = true;
    });
    final auth = context.read<AuthProvider>();
    try {
      await auth.updateProfile(name: name);
      if (mounted) showHeamaToast(context, l.profileUpdated);
    } on ApiException catch (e) {
      if (mounted) setState(() => _nameError = e.message);
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  Future<void> _savePassword() async {
    if (_savingPw) return;
    final l = AppLocalizations.of(context);
    if (_pw.text.length < 6 || _pw.text != _pw2.text) {
      setState(() => _pwError = l.errPw);
      return;
    }
    setState(() {
      _pwError = null;
      _savingPw = true;
    });
    try {
      await context.read<AuthProvider>().setPassword(_pw.text);
      if (!mounted) return;
      _pw.clear();
      _pw2.clear();
      showHeamaToast(context, l.passwordUpdated);
    } on ApiException catch (e) {
      if (mounted) setState(() => _pwError = e.message);
    } finally {
      if (mounted) setState(() => _savingPw = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        title: Text(l.accountTitle, style: AppFonts.display(fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 28),
        children: [
          Text(l.accountSubtitle,
              style: AppFonts.body(fontSize: 12.5, color: AppColors.muted)),
          const SizedBox(height: 18),

          // ---- Profile ----
          _sectionTitle(l.profileSection),
          _field(l.fullName, _name, error: _nameError),
          const SizedBox(height: 12),
          _field(l.phoneNumber, _phone, readOnly: true, prefix: '🇮🇶 +964 '),
          const SizedBox(height: 6),
          Text(l.phoneLocked,
              style: AppFonts.body(fontSize: 11.5, color: AppColors.hintText)),
          const SizedBox(height: 14),
          _primaryButton(
            label: l.saveChanges,
            loading: _savingProfile,
            onTap: _saveProfile,
          ),

          const SizedBox(height: 26),

          // ---- Change password ----
          _sectionTitle(l.changePassword),
          _field(l.password, _pw,
              obscure: _obscure1,
              hint: l.passwordHint,
              onToggle: () => setState(() => _obscure1 = !_obscure1)),
          const SizedBox(height: 12),
          _field(l.confirmPassword, _pw2,
              obscure: _obscure2,
              hint: l.confirmPasswordHint,
              error: _pwError,
              onToggle: () => setState(() => _obscure2 = !_obscure2)),
          const SizedBox(height: 14),
          _primaryButton(
            label: l.savePassword,
            loading: _savingPw,
            onTap: _savePassword,
          ),

          const SizedBox(height: 26),

          // ---- Addresses ----
          _sectionTitle(l.addresses),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, Routes.addresses),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.cloud,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 20, color: AppColors.ink),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(l.addresses,
                        style: AppFonts.body(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  ),
                  const Icon(Icons.chevron_right, size: 20, color: AppColors.muted),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text.toUpperCase(),
            style: AppFonts.body(
                fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.4)),
      );

  Widget _field(
    String label,
    TextEditingController c, {
    bool readOnly = false,
    bool obscure = false,
    String? hint,
    String? prefix,
    String? error,
    VoidCallback? onToggle,
  }) {
    final showToggle = onToggle != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: AppFonts.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: error != null ? AppColors.pomegranate : AppColors.muted)),
            if (readOnly) ...[
              const SizedBox(width: 5),
              const Icon(Icons.lock_outline, size: 11, color: AppColors.muted),
            ],
          ],
        ),
        const SizedBox(height: 5),
        TextField(
          controller: c,
          readOnly: readOnly,
          obscureText: obscure,
          style: AppFonts.body(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: readOnly ? AppColors.muted : AppColors.ink),
          decoration: InputDecoration(
            isDense: true,
            filled: readOnly,
            fillColor: readOnly ? AppColors.cloud : null,
            prefixText: prefix,
            prefixStyle: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w700),
            hintText: hint,
            hintStyle: AppFonts.body(fontSize: 12.5, color: AppColors.hintText),
            suffixIcon: showToggle
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.muted,
                      size: 20,
                    ),
                    onPressed: onToggle,
                  )
                : null,
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 5),
          Text(error, style: AppFonts.body(fontSize: 11.5, color: AppColors.pomegranate)),
        ],
      ],
    );
  }

  Widget _primaryButton({
    required String label,
    required bool loading,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: AppColors.pomegranate,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: AppFonts.body(
                    fontSize: 14.5, fontWeight: FontWeight.w700, color: Colors.white)),
      ),
    );
  }
}
