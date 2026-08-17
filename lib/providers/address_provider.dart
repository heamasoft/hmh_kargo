import 'package:flutter/foundation.dart';

import '../models/address.dart';
import '../services/address_api.dart';
import '../services/api_client.dart';

/// Server-backed list of the user's delivery addresses.
class AddressProvider extends ChangeNotifier {
  AddressProvider(ApiClient client) : _api = AddressApi(client);
  final AddressApi _api;

  List<Address> addresses = [];
  bool loading = false;
  bool busy = false;
  String? error;

  Address? get defaultAddress {
    for (final a in addresses) {
      if (a.isDefault) return a;
    }
    return addresses.isNotEmpty ? addresses.first : null;
  }

  Future<void> load() async {
    loading = true;
    notifyListeners();
    try {
      addresses = await _api.list();
      error = null;
    } on ApiException catch (e) {
      error = e.message;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<bool> add(Map<String, dynamic> body) async {
    return _mutate(() async {
      await _api.create(body);
      addresses = await _api.list();
    });
  }

  Future<bool> edit(int id, Map<String, dynamic> body) async {
    return _mutate(() async {
      await _api.update(id, body);
      addresses = await _api.list();
    });
  }

  Future<bool> remove(int id) async {
    return _mutate(() async {
      addresses = await _api.remove(id);
    });
  }

  Future<bool> _mutate(Future<void> Function() action) async {
    busy = true;
    notifyListeners();
    try {
      await action();
      error = null;
      return true;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}
