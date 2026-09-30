import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hmh_kargo/l10n/app_localizations.dart';
import 'package:hmh_kargo/widgets/sign_in_required.dart';

/// Browsing the shop needs no account; the parts that belong to a person do.
/// What matters on those parts is that a shopper is *offered a way in* rather
/// than stopped, which is what App Review asks for under guideline 5.1.1(v).
void main() {
  testWidgets('an account-only tab offers a guest both ways in', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: SignInRequired(title: 'Log in to use your cart')),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Log in to use your cart'), findsOneWidget);
    // Both routes in are present: an existing account, and a new one.
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Create an account'), findsOneWidget);
    // And it says why the login is being asked for at all.
    expect(
      find.text('Browsing is open to everyone — an account is only needed to order.'),
      findsOneWidget,
    );
  });
}
