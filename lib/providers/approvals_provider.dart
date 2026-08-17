import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/approval.dart';
import '../services/api_client.dart';
import '../services/approval_api.dart';

/// Pending shipping-fee approvals for the logged-in customer. While the shell
/// is on screen it POLLS the server (no push infrastructure needed), so the
/// badge and amber highlights appear without a manual refresh.
class ApprovalsProvider extends ChangeNotifier {
  ApprovalsProvider(ApiClient client) : _api = ApprovalApi(client);
  final ApprovalApi _api;

  List<ShippingApproval> pending = [];
  bool loading = false;
  String? error;

  Timer? _poll;

  int get count => pending.length;
  bool get hasPending => pending.isNotEmpty;

  /// Order codes that have at least one pending approval — used to highlight
  /// those orders in the list until the customer answers.
  Set<String> get pendingOrderCodes => pending.map((a) => a.orderCode).toSet();

  /// Starts the background check (default every 45 s) and runs one right away.
  /// Safe to call repeatedly — the previous timer is replaced.
  void startPolling({Duration every = const Duration(seconds: 45)}) {
    _poll?.cancel();
    _poll = Timer.periodic(every, (_) => refreshSilently());
    refreshSilently();
  }

  void stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  /// Background refresh: no spinner, keeps the old list on network failure and
  /// only notifies when something actually changed.
  Future<void> refreshSilently() async {
    try {
      final fresh = await _api.list(status: 'pending');
      final changed = fresh.length != pending.length ||
          !fresh.every((f) => pending.any((p) => p.id == f.id));
      pending = fresh;
      error = null;
      if (changed) notifyListeners();
    } on ApiException {
      // Silent — the next tick will retry.
    }
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      pending = await _api.list(status: 'pending');
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  /// Answers a request. Returns true on success; the row is removed locally and
  /// the list refreshed. One-shot: an already-answered row returns an error.
  Future<bool> respond(int id, {required bool accept}) async {
    try {
      if (accept) {
        await _api.accept(id);
      } else {
        await _api.reject(id);
      }
      pending.removeWhere((a) => a.id == id);
      error = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      error = e.message;
      notifyListeners();
      return false;
    }
  }
}
