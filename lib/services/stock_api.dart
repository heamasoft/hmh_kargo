import '../models/stock_item.dart';
import 'api_client.dart';

/// Reads the in-stock storefront and adds a stock item to the cart.
class StockApi {
  StockApi(this._client);
  final ApiClient _client;

  /// GET /stock?lang=xx → {shein:[...], other:[...]}. [lang] localizes the
  /// scraped titles/colours into the app's language (en/ar/ku).
  Future<({List<StockItem> shein, List<StockItem> other})> list({String lang = 'en'}) async =>
      _parse(await _client.getAndCache('/stock?lang=$lang'));

  /// The stock list as last loaded in [lang], kept on the phone — or null.
  Future<({List<StockItem> shein, List<StockItem> other})?> cachedList({String lang = 'en'}) async {
    final res = await _client.cached('/stock?lang=$lang');
    return res == null ? null : _parse(res);
  }

  static ({List<StockItem> shein, List<StockItem> other}) _parse(Map<String, dynamic> res) {
    List<StockItem> parse(String key) => ((res[key] as List?) ?? [])
        .map((e) => StockItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return (shein: parse('shein'), other: parse('other'));
  }

  /// POST /stock/{itemId}/add — add this stock unit to the cart.
  Future<void> addToCart(int itemId) async {
    await _client.post('/stock/$itemId/add');
  }
}
