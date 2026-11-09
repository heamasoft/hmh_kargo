import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/catalog_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/order_anywhere_card.dart';

/// The Shop tab: order from any website.
///
/// It used to be a grid of named shops. App Review read that as the app
/// presenting other companies' brands (guideline 4.1(b)), so it lists none:
/// the shopper types the site they want or pastes a link, and the service —
/// buying it and shipping it — is what this screen explains.
class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});

  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  @override
  void initState() {
    super.initState();
    // Not shown: only used to tell which site a typed address belongs to.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CatalogProvider>().loadStores();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
            children: [
              Text(l.shopTitle, style: AppFonts.display(fontSize: 21)),
              const SizedBox(height: 4),
              Text(l.shopSub,
                  style: AppFonts.body(fontSize: 12.5, color: AppColors.muted, height: 1.4)),
              const SizedBox(height: 16),
              const OrderAnywhereCard(),
              const SizedBox(height: 24),
              const HowItWorks(),
              const SizedBox(height: 10),
              Text(
                l.brandDisclaimer,
                style: AppFonts.body(fontSize: 11.5, color: AppColors.muted, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
