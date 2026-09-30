import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../router.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'primary_button.dart';

/// What a signed-out shopper sees on the parts of the app that are their own —
/// their cart, their orders, their account.
///
/// Browsing needs no account: the stores, the products and the prices are open
/// to anyone who opens the app. Only what belongs to a person sits behind a
/// login, and this is where they are offered one rather than being stopped at
/// the door.
class SignInRequired extends StatelessWidget {
  const SignInRequired({super.key, required this.title, this.icon = Icons.lock_outline_rounded});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: const BoxDecoration(color: AppColors.cloud, shape: BoxShape.circle),
                child: Icon(icon, size: 32, color: AppColors.midnight),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppFonts.display(fontSize: 19),
              ),
              const SizedBox(height: 8),
              Text(
                l.guestSub,
                textAlign: TextAlign.center,
                style: AppFonts.body(fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 22),
              PrimaryButton(
                label: l.login,
                onPressed: () => Navigator.pushNamed(context, Routes.login),
              ),
              const SizedBox(height: 10),
              PrimaryButton(
                label: l.createAccount,
                style: HeamaButtonStyle.cloud,
                onPressed: () => Navigator.pushNamed(context, Routes.registerName),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
