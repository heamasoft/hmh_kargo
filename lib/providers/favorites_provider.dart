import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/favorite_item.dart';
import '../services/api_client.dart';
import '../services/favorites_api.dart';

/// Saved (hearted) products — catalog items and captured store items alike.
/// Cached to disk (works offline / for guests) and synced to the server per
/// authenticated user so favourites follow the account across devices.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider(ApiClient client) : _api = FavoritesApi(client);
  final FavoritesApi _api;

  static const _key = 'heama_favorites_v1';
  final Map<String, FavoriteItem> _items = {};

  List<FavoriteItem> get items => _items.values.toList().reversed.toList();
  bool isFavorite(String id) => _items.containsKey(id);
  int get count => _items.length;

  /// Loads the local cache (call once at startup).
  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return;
      final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      _items.clear();
      for (final j in list) {
        final item = FavoriteItem.fromJson(j);
        if (item.id.isNotEmpty) _items[item.id] = item;
      }
      notifyListeners();
    } catch (_) {
      // ignore corrupt data
    }
  }

  /// Merges the server's favourites with the local cache. Any local-only items
  /// are pushed up; the union is kept. No-op (silently) for guests / offline.
  Future<void> syncFromServer() async {
    try {
      final server = await _api.list();
      final serverIds = server.map((e) => e.id).toSet();
      // Push local-only favourites to the server.
      for (final local in _items.values.toList()) {
        if (!serverIds.contains(local.id)) {
          try {
            await _api.add(local);
          } catch (_) {}
        }
      }
      // Adopt server items into the local cache.
      for (final s in server) {
        _items[s.id] = s;
      }
      await _persist();
      notifyListeners();
    } on ApiException {
      // not authenticated / offline — keep local only
    }
  }

  /// Adds or removes a favourite. Returns true if it's now saved.
  bool toggle(FavoriteItem item) {
    final saved = !_items.containsKey(item.id);
    if (saved) {
      _items[item.id] = item;
      _api.add(item).catchError((_) {});
    } else {
      _items.remove(item.id);
      _api.remove(item.id).catchError((_) {});
    }
    _persist();
    notifyListeners();
    return saved;
  }

  void removeById(String id) {
    if (_items.remove(id) != null) {
      _api.remove(id).catchError((_) {});
      _persist();
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _key, jsonEncode(_items.values.map((e) => e.toJson()).toList()));
    } catch (_) {
      // ignore write errors
    }
  }
}
