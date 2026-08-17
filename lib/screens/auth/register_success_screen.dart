import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/registration_provider.dart';
import '../../router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../widgets/primary_button.dart';

class RegisterSuccessScreen extends StatelessWidget {
  const RegisterSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final first = context.read<RegistrationProvider>().firstName;
    final title = first.isEmpty ? l.regDoneTitle : l.regDoneTitleNamed(first);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: AppColors.greenTint,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, size: 44, color: AppColors.green),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppFonts.display(fontSize: 24, height: 1.15),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        l.regDoneSub,
                        textAlign: TextAlign.center,
                        style: AppFonts.body(fontSize: 13.5, color: AppColors.muted, height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              PrimaryButton(
                label: l.enterHeama,
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.home,
                  (r) => false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
