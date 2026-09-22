import 'package:dio/dio.dart';

import 'api_client.dart';

/// A home-page ad: an image, optionally opening [linkUrl] when tapped.
class Ad {
  const Ad({required this.id, required this.imageUrl, this.linkUrl, this.isActive = true});

  final int id;
  final String imageUrl;
  final String? linkUrl;
  final bool isActive; // admin view

  factory Ad.fromJson(Map<String, dynamic> j) => Ad(
        id: (j['id'] ?? 0) as int,
        imageUrl: (j['image_url'] ?? '') as String,
        linkUrl: (j['link_url'] as String?)?.trim().isEmpty ?? true ? null : j['link_url'] as String,
        isActive: (j['is_active'] ?? true) as bool,
      );
}

class AdsApi {
  AdsApi(this._client);
  final ApiClient _client;

  static List<Ad> _parse(Map<String, dynamic> json) => ((json['data'] as List?) ?? const [])
      .map((e) => Ad.fromJson(e as Map<String, dynamic>))
      .toList();

  /// The active ads for the home page (kept on the phone for the next launch).
  Future<List<Ad>> list() async => _parse(await _client.getAndCache('/ads'));

  /// The ads as last loaded, or null the first time.
  Future<List<Ad>?> cached() async {
    final json = await _client.cached('/ads');
    return json == null ? null : _parse(json);
  }

  // ---- Admin ----

  Future<List<Ad>> adminList() async => _parse(await _client.get('/admin/ads'));

  /// Uploads the image at [path] as a new ad.
  Future<Ad> upload(String path, {String? linkUrl}) async {
    final form = FormData.fromMap({
      'image': await MultipartFile.fromFile(path),
      if (linkUrl != null && linkUrl.trim().isNotEmpty) 'link_url': linkUrl.trim(),
    });
    final json = await _client.post('/admin/ads', data: form);
    return Ad.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<Ad> setActive(int id, bool active) async {
    final json = await _client.patch('/admin/ads/$id', data: {'is_active': active});
    return Ad.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _client.delete('/admin/ads/$id');
  }
}
