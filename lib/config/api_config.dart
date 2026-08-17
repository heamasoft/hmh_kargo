/// Backend endpoints. Swap [baseUrl] to a local server during development.
class ApiConfig {
  ApiConfig._();

  /// Live Heama API on Hostinger.
  static const String baseUrl = 'https://shipping.heama-soft.com/api/v1';

  // For local testing against `php artisan serve`, use e.g.:
  // static const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator
}
