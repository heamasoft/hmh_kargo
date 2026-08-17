import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'back_chip.dart';
import 'primary_button.dart';

/// Shared layout for the sign-up / login screens: a top bar with a back chip
/// and progress dots, a scrollable body, and a pinned bottom action button.
class AuthScaffold extends StatelessWidget {
  final int totalSteps;
  final int currentStep; // 1-based; used to light the progress dots
  final String title;
  final String subtitle;
  final List<Widget> children;
  final String buttonLabel;
  final VoidCallback onButton;
  final Widget? footer;
  final VoidCallback? onBack;

  const AuthScaffold({
    super.key,
    required this.totalSteps,
    required this.currentStep,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.buttonLabel,
    required this.onButton,
    this.footer,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  BackChip(onTap: onBack ?? () => Navigator.of(context).maybePop()),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Row(
                      children: List.generate(totalSteps, (i) {
                        final on = i < currentStep;
                        return Expanded(
                          child: Container(
                            height: 5,
                            margin: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 6),
                            decoration: BoxDecoration(
                              color: on ? AppColors.pomegranate : AppColors.line,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppFonts.display(fontSize: 24, height: 1.15),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: AppFonts.body(
                          fontSize: 13.5,
                          color: AppColors.muted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...children,
                    ],
                  ),
                ),
              ),
              PrimaryButton(label: buttonLabel, onPressed: onButton),
              if (footer != null) ...[const SizedBox(height: 16), footer!],
            ],
          ),
        ),
      ),
    );
  }
}
