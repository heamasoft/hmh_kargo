import 'package:flutter/material.dart';

import 'product.dart';

/// A saved (hearted) product. Works for both catalog products and items
/// captured from a store WebView, so it carries its own data.
class FavoriteItem {
  final String id;
  final String name;
  final String store;
  final int? storeId;
  final String? sourceUrl;
  final int priceIqd;
  final String imageUrl;

  const FavoriteItem({
    required this.id,
    required this.name,
    required this.store,
    this.storeId,
    this.sourceUrl,
    this.priceIqd = 0,
    this.imageUrl = '',
  });

  factory FavoriteItem.fromProduct(Product p) => FavoriteItem(
        id: p.id,
        name: p.name,
        store: p.store,
        storeId: p.storeId,
        sourceUrl: p.sourceUrl,
        priceIqd: p.priceIqd,
        imageUrl: p.imageUrl,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'store': store,
        'store_id': storeId,
        'source_url': sourceUrl,
        'iqd_price': priceIqd,
        'image_url': imageUrl,
      };

  factory FavoriteItem.fromJson(Map<String, dynamic> json) => FavoriteItem(
        id: (json['id'] ?? '') as String,
        name: (json['name'] ?? '') as String,
        store: (json['store'] ?? '') as String,
        storeId: json['store_id'] as int?,
        sourceUrl: json['source_url'] as String?,
        priceIqd: (json['iqd_price'] ?? 0) as int,
        imageUrl: (json['image_url'] ?? '') as String,
      );

  /// A [Product] view for the shared product card.
  Product toProduct() => Product(
        id: id,
        name: name,
        store: store,
        storeId: storeId,
        sourceUrl: sourceUrl,
        priceIqd: priceIqd,
        usd: '',
        oldUsd: '',
        imageUrl: imageUrl,
        gradient: const [Color(0xFFC9B6E8), Color(0xFFE9C7D6)],
      );
}
