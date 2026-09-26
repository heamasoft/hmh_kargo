import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:hmh_kargo/models/approval.dart';
import 'package:hmh_kargo/providers/approvals_provider.dart';
import 'package:hmh_kargo/services/api_client.dart';
import 'package:hmh_kargo/widgets/notification_bell.dart';

ShippingApproval _approval(int id) => ShippingApproval(
      id: id,
      itemId: id,
      orderCode: 'HM-2$id',
      title: 'A dress',
      imageUrl: '',
      itemPrice: 7.5,
      newShipping: 3,
      newTotal: 10.5,
    );

Widget _bellWith(List<ShippingApproval> pending) {
  final approvals = ApprovalsProvider(ApiClient())..pending = pending;

  return ChangeNotifierProvider<ApprovalsProvider>.value(
    value: approvals,
    child: const MaterialApp(
      home: Scaffold(body: NotificationBell()),
    ),
  );
}

void main() {
  group('the Home bell', () {
    testWidgets('carries no badge when nothing is waiting', (tester) async {
      await tester.pumpWidget(_bellWith([]));

      expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
      expect(find.text('1'), findsNothing);
    });

    testWidgets('shows how many answers the admin is waiting for', (tester) async {
      await tester.pumpWidget(_bellWith([_approval(1), _approval(2)]));

      expect(find.byIcon(Icons.notifications_active_rounded), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('caps the badge so a long number cannot stretch it', (tester) async {
      await tester.pumpWidget(_bellWith([for (var i = 1; i <= 12; i++) _approval(i)]));

      expect(find.text('9+'), findsOneWidget);
    });
  });
}
