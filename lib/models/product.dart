import 'package:flutter/material.dart';

import '../utils/hex_color.dart';

/// A selectable colour option on a product.
class ProductColor {
  final String name;
  final Color color;
  const ProductColor({required this.name, required this.color});
}

/// A shoppable product, as returned by the Heama API `/products` endpoint.
class Product {
  final String id; // the product "key"
  final String name;
  final String store;
  final int? storeId;
  final String? category;
  final String? sourceUrl;
  final int priceIqd; // all-in IQD price
  final String usd;
  final String oldUsd;
  final String imageUrl;
  final List<Color> gradient;
  final double rating;
  final String reviews;
  final List<ProductColor> colors;
  final List<String> sizes;

  const Product({
    required this.id,
    required this.name,
    required this.store,
    this.storeId,
    this.category,
    this.sourceUrl,
    required this.priceIqd,
    required this.usd,
    required this.oldUsd,
    required this.imageUrl,
    required this.gradient,
    this.rating = 4.6,
    this.reviews = '',
    this.colors = const [],
    this.sizes = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final colorList = (json['colors'] as List?)
            ?.map((c) => ProductColor(
                  name: (c['name'] ?? '') as String,
                  color: hexToColor((c['hex'] ?? '#C9B6E8') as String),
                ))
            .toList() ??
        const <ProductColor>[];

    return Product(
      id: json['key'] as String,
      name: (json['name'] ?? '') as String,
      store: (json['store'] ?? 'Shein') as String,
      storeId: json['store_id'] as int?,
      category: json['category'] as String?,
      sourceUrl: json['source_url'] as String?,
      priceIqd: (json['iqd_price'] ?? 0) as int,
      usd: (json['usd'] ?? '') as String,
      oldUsd: (json['old_usd'] ?? '') as String? ?? '',
      imageUrl: (json['image_url'] ?? '') as String,
      gradient: gradientFromHex(json['gradient'] as List?),
      rating: ((json['rating'] ?? 4.6) as num).toDouble(),
      reviews: (json['reviews'] ?? '') as String? ?? '',
      colors: colorList,
      sizes: ((json['sizes'] as List?)?.map((s) => s.toString()).toList()) ?? const [],
    );
  }
}
