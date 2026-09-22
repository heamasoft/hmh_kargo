import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../services/api_client.dart';
import '../../services/coupon_api.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/heama_toast.dart';

/// Admin only (reached from Me): the discount codes — create one with a name,
/// a percentage and an expiry date, see how often each was used, switch one
/// off. Each customer may use each code once; the server enforces it.
class CouponsScreen extends StatefulWidget {
  const CouponsScreen({super.key});

  @override
  State<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  late final CouponApi _api = CouponApi(context.read<ApiClient>());
  List<Coupon>? _coupons;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _api.list();
      if (mounted) setState(() => (_coupons = list, _error = null));
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    }
  }

  Future<void> _toggle(Coupon c) async {
    try {
      final updated = await _api.setActive(c.id, !c.isActive);
      if (!mounted) return;
      setState(() => _coupons = [for (final x in _coupons!) x.id == c.id ? updated : x]);
    } on ApiException catch (e) {
      if (mounted) showHeamaToast(context, e.message);
    }
  }

  Future<void> _create() async {
    final created = await showModalBottomSheet<Coupon>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _NewCouponSheet(api: _api),
    );
    if (created != null && mounted) {
      setState(() => _coupons = [created, ...?_coupons]);
      showHeamaToast(context, AppLocalizations.of(context).couponCreated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final coupons = _coupons;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        title: Text(l.coupons, style: AppFonts.display(fontSize: 18)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _create,
        backgroundColor: AppColors.pomegranate,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 90),
          children: [
            Text(l.couponOnePerCustomer,
                style: AppFonts.body(fontSize: 12.5, color: AppColors.muted)),
            const SizedBox(height: 14),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Text(_error!,
                    textAlign: TextAlign.center,
                    style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
              )
            else if (coupons == null)
              const Padding(
                padding: EdgeInsets.only(top: 60),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              )
            else if (coupons.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Text(l.couponsEmpty,
                    textAlign: TextAlign.center,
                    style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
              )
            else
              ...coupons.map((c) => _row(l, c)),
          ],
        ),
      ),
    );
  }

  Widget _row(AppLocalizations l, Coupon c) {
    final live = c.isActive && !c.expired;
    final (label, bg, fg) = c.expired
        ? (l.couponExpired, AppColors.cloud, AppColors.muted)
        : c.isActive
            ? (l.couponActive, AppColors.greenTint, AppColors.green)
            : (l.couponOff, AppColors.cloud, AppColors.muted);
    final d = c.expiresAt?.toLocal();
    final expiry = d == null
        ? l.couponNoExpiry
        : '${l.couponExpires} ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: live ? AppColors.line : AppColors.cloud),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: live ? AppColors.pomTintBg : AppColors.cloud,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(c.percentLabel,
                style: AppFonts.display(
                    fontSize: 14, color: live ? AppColors.pomegranate : AppColors.muted)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(c.code,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.body(
                              fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
                      child: Text(label,
                          style: AppFonts.body(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text('$expiry · ${l.couponUsedTimes(c.timesUsed)}',
                    style: AppFonts.body(fontSize: 11.5, color: AppColors.muted)),
              ],
            ),
          ),
          // Switch a code off (or back on) without deleting its history.
          if (!c.expired)
            Switch(
              value: c.isActive,
              activeThumbColor: AppColors.green,
              onChanged: (_) => _toggle(c),
            ),
        ],
      ),
    );
  }
}

class _NewCouponSheet extends StatefulWidget {
  const _NewCouponSheet({required this.api});
  final CouponApi api;

  @override
  State<_NewCouponSheet> createState() => _NewCouponSheetState();
}

class _NewCouponSheetState extends State<_NewCouponSheet> {
  final _code = TextEditingController();
  final _percent = TextEditingController();
  DateTime? _expires;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _percent.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _expires ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (d != null) setState(() => _expires = d);
  }

  Future<void> _save() async {
    final code = _code.text.trim();
    final pct = double.tryParse(_percent.text.trim().replaceAll(',', '.')) ?? 0;
    if (code.isEmpty || pct <= 0 || pct > 100) {
      setState(() => _error = code.isEmpty ? '${AppLocalizations.of(context).couponHint}?' : '1–100 %');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final c = await widget.api.create(code: code, percent: pct, expiresAt: _expires);
      if (mounted) Navigator.pop(context, c);
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = _expires;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration:
                      BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Text(l.couponNew, style: AppFonts.display(fontSize: 19)),
              const SizedBox(height: 16),
              Text(l.couponHint, style: _label()),
              const SizedBox(height: 5),
              TextField(
                controller: _code,
                autofocus: true,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')),
                  LengthLimitingTextInputFormatter(40),
                ],
                style: AppFonts.body(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                decoration: const InputDecoration(isDense: true, hintText: 'SUMMER10'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.couponPercent, style: _label()),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _percent,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                          style: AppFonts.body(fontSize: 15, fontWeight: FontWeight.w700),
                          decoration: const InputDecoration(isDense: true, hintText: '10', suffixText: '%'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.couponExpires, style: _label()),
                        const SizedBox(height: 5),
                        GestureDetector(
                          onTap: _pickDate,
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              isDense: true,
                              suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                            ),
                            child: Text(
                              d == null
                                  ? l.couponNoExpiry
                                  : '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}',
                              style: AppFonts.body(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 10),
                Text(_error!,
                    style: AppFonts.body(
                        fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.pomegranate)),
              ],
              const SizedBox(height: 18),
              GestureDetector(
                onTap: _saving ? null : _save,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.pomegranate,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(l.couponCreate,
                          style: AppFonts.body(
                              fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _label() => AppFonts.body(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.muted);
}
