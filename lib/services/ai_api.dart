import 'api_client.dart';

/// AI-refined variant extraction (selected colour + size).
class AiVariants {
  final bool available;
  final String size;
  final String color;
  final List<String> sizeOptions;
  final List<String> colorOptions;

  const AiVariants({
    this.available = false,
    this.size = '',
    this.color = '',
    this.sizeOptions = const [],
    this.colorOptions = const [],
  });

  factory AiVariants.fromJson(Map<String, dynamic> json) {
    List<String> list(dynamic v) => v is List
        ? v.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
        : const [];
    return AiVariants(
      available: (json['available'] ?? false) as bool,
      size: (json['size'] ?? '') as String? ?? '',
      color: (json['color'] ?? '') as String? ?? '',
      sizeOptions: list(json['size_options']),
      colorOptions: list(json['color_options']),
    );
  }
}

class AiApi {
  AiApi(this._client);
  final ApiClient _client;

  Future<AiVariants> variants({
    required String store,
    required String url,
    required String context,
  }) async {
    final json = await _client.post('/ai/variants', data: {
      'store': store,
      'url': url,
      'context': context,
    });
    return AiVariants.fromJson(json);
  }
}
