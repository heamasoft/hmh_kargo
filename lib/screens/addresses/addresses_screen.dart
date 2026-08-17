import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/iraq_locations.dart';
import '../../l10n/app_localizations.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/back_chip.dart';
import 'address_form_sheet.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<AddressProvider>().load());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final provider = context.watch<AddressProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
              child: Row(
                children: [
                  BackChip(onTap: () => Navigator.pop(context), size: 34),
                  const SizedBox(width: 10),
                  Text(l.addresses, style: AppFonts.display(fontSize: 20)),
                  const Spacer(),
                  _AddButton(onTap: () => showAddressForm(context)),
                ],
              ),
            ),
            Expanded(
              child: provider.loading && provider.addresses.isEmpty
                  ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : provider.addresses.isEmpty
                      ? _empty(l)
                      : RefreshIndicator(
                          onRefresh: provider.load,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                            itemCount: provider.addresses.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, i) =>
                                _AddressCard(address: provider.addresses[i]),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(AppLocalizations l) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                  color: AppColors.cloud, borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.location_on_outlined,
                  size: 30, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            Text(l.noAddressesTitle,
                style: AppFonts.display(fontSize: 17), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(l.noAddressesSub,
                style: AppFonts.body(fontSize: 13, color: AppColors.muted, height: 1.4),
                textAlign: TextAlign.center),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: () => showAddressForm(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                    color: AppColors.pomegranate,
                    borderRadius: BorderRadius.circular(14)),
                child: Text(l.addAddress,
                    style: AppFonts.body(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: AppColors.pomegranate, borderRadius: BorderRadius.circular(13)),
        child: const Icon(Icons.add, color: Colors.white, size: 22),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Address address;
  const _AddressCard({required this.address});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final gov = IraqLocations.govDisplay(address.governorate, lang);
    final city = IraqLocations.cityDisplay(address.governorate, address.city, lang);
    final line = [city, gov].where((s) => s.isNotEmpty).join(' · ');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
            color: address.isDefault ? AppColors.pomegranate : AppColors.line,
            width: address.isDefault ? 1.4 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(address.recipientName,
                    style: AppFonts.body(fontSize: 14.5, fontWeight: FontWeight.w700)),
              ),
              if (address.isDefault)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppColors.pomegranate.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(l.defaultLabel,
                      style: AppFonts.body(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pomegranate)),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(line,
              style: AppFonts.body(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
          const SizedBox(height: 2),
          Text(address.street,
              style: AppFonts.body(fontSize: 12.5, color: AppColors.muted, height: 1.35)),
          const SizedBox(height: 2),
          Text(address.phone,
              style: AppFonts.body(fontSize: 12, color: AppColors.muted)),
          const SizedBox(height: 12),
          Row(
            children: [
              _action(Icons.edit_outlined, l.editAddress,
                  () => showAddressForm(context, existing: address)),
              const SizedBox(width: 18),
              _action(Icons.delete_outline, l.deleteLabel,
                  () => _confirmDelete(context, l), color: AppColors.pomegranate),
            ],
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, String label, VoidCallback onTap,
      {Color color = AppColors.ink}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: AppFonts.body(
                  fontSize: 12.5, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l.deleteLabel, style: AppFonts.display(fontSize: 17)),
        content: Text(address.shortLine,
            style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel,
                style: AppFonts.body(fontSize: 13, color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AddressProvider>().remove(address.id);
            },
            child: Text(l.deleteLabel,
                style: AppFonts.body(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pomegranate)),
          ),
        ],
      ),
    );
  }
}
