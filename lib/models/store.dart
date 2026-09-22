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

  /// A logo set for this store in the dashboard (stores.logo_url), if any.
  final String? logoUrl;

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
    this.logoUrl,
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
      logoUrl: (json['logo_url'] as String?)?.trim().isEmpty ?? true ? null : json['logo_url'] as String,
    );
  }
}

extension StoreLogo on Store {
  /// The picture for this store's tile: the dashboard logo if set, else the
  /// store website's own icon (fetched by Google's icon service at up to
  /// 256 px, from the main www. domain — m./shop. hosts give smaller icons).
  /// Null when the store has no usable web address.
  String? get iconUrl {
    if (logoUrl != null) return logoUrl;
    final host = (Uri.tryParse(url)?.host ?? '').toLowerCase();
    if (host.isEmpty) return null;
    final parts = host.split('.');
    // "m.shein.com" / "shop.mango.com" → "shein.com" / "mango.com";
    // "zara.com.tr"-style keeps three labels.
    final keep = parts.length >= 3 && const ['com', 'co', 'org', 'net'].contains(parts[parts.length - 2])
        ? 3
        : 2;
    final domain = parts.length <= keep ? host : parts.sublist(parts.length - keep).join('.');
    return 'https://t3.gstatic.com/faviconV2?client=SOCIAL&type=FAVICON'
        '&fallback_opts=TYPE,SIZE,URL&url=https://www.$domain&size=256';
  }
}
