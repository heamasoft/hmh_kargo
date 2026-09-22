import 'package:flutter/material.dart';

import '../theme/app_typography.dart';
import '../utils/digits.dart';

/// The row of one-digit boxes for a verification code.
///
/// Always laid out left-to-right: a code is read 1-2-3-4 in every language,
/// and under Arabic/Kurdish the row used to flip, so typing filled the boxes
/// from the right. Digits typed on an Arabic or Kurdish keyboard become 0–9,
/// and pasting (or autofilling) the whole code spreads it across the boxes.
class OtpBoxes extends StatelessWidget {
  const OtpBoxes({super.key, required this.controllers, required this.nodes, this.onCompleted});

  final List<TextEditingController> controllers;
  final List<FocusNode> nodes;

  /// Called once every box holds a digit.
  final VoidCallback? onCompleted;

  void _onChanged(int i, String v) {
    final n = controllers.length;
    if (v.length > 1) {
      // A pasted / autofilled code: spread it from this box onwards.
      var k = i;
      for (final ch in v.split('')) {
        if (k >= n) break;
        controllers[k].text = ch;
        k++;
      }
      nodes[(k < n ? k : n - 1)].requestFocus();
    } else if (v.isNotEmpty && i < n - 1) {
      nodes[i + 1].requestFocus();
    } else if (v.isEmpty && i > 0) {
      nodes[i - 1].requestFocus();
    }
    if (controllers.every((c) => c.text.length == 1)) onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final n = controllers.length;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: List.generate(n, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == n - 1 ? 0 : 11),
              child: TextField(
                controller: controllers[i],
                focusNode: nodes[i],
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                keyboardType: TextInputType.number,
                autofillHints: i == 0 ? const [AutofillHints.oneTimeCode] : null,
                // Up to the whole code, so a paste isn't cut to one digit.
                inputFormatters: [AsciiDigitsFormatter(maxLength: n)],
                style: AppFonts.display(fontSize: 22),
                decoration: const InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
                onChanged: (v) => _onChanged(i, v),
              ),
            ),
          );
        }),
      ),
    );
  }
}
