import '../models/favorite_item.dart';
import 'api_client.dart';

/// Server-synced favourites (per authenticated user).
class FavoritesApi {
  FavoritesApi(this._client);
  final ApiClient _client;

  Future<List<FavoriteItem>> list() async {
    final json = await _client.get('/favorites');
    final list = (json['data'] as List?) ?? [];
    return list.map((e) => FavoriteItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> add(FavoriteItem item) async {
    await _client.post('/favorites', data: item.toJson());
  }

  Future<void> remove(String id) async {
    await _client.delete('/favorites/${Uri.encodeComponent(id)}');
  }
}
