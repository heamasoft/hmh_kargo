import 'package:flutter/material.dart';

import '../utils/hex_color.dart';

/// A storefront returned by the Heama API `/stores` endpoint.
class Store {
  final String id; // the store "key"
  final int storeId;
  final String name;
  final String glyph;
  final Color glyphColor;
  final String categoryKey;
  final String url;
  final String region; // international | turkiye
  final String currency;

  const Store({
    required this.id,
    required this.storeId,
    required this.name,
    required this.glyph,
    required this.glyphColor,
    required this.categoryKey,
    required this.url,
    required this.region,
    required this.currency,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['key'] as String,
      storeId: json['id'] as int,
      name: (json['name'] ?? '') as String,
      glyph: (json['glyph'] ?? '') as String? ?? '',
      glyphColor: hexToColor((json['glyph_color'] ?? '#211B3E') as String? ?? '#211B3E'),
      categoryKey: (json['category_key'] ?? 'catFashion') as String? ?? 'catFashion',
      url: (json['base_url'] ?? '') as String,
      region: (json['region'] ?? 'international') as String,
      currency: (json['currency'] ?? 'USD') as String,
    );
  }
}
