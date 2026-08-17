import '../models/api_user.dart';
import 'api_client.dart';

/// Result of a successful OTP verification.
class AuthResult {
  final String token;
  final ApiUser user;
  const AuthResult({required this.token, required this.user});
}

/// Auth endpoints on the Heama API.
class AuthApi {
  AuthApi(this._client);
  final ApiClient _client;

  /// Sends an OTP to [identifier] over [channel] ('whatsapp' | 'email').
  Future<void> requestOtp({
    required String identifier,
    required String channel,
    String purpose = 'login',
  }) async {
    await _client.post('/auth/otp/request', data: {
      'identifier': identifier,
      'channel': channel,
      'purpose': purpose,
    });
  }

  /// Verifies [code]; creates/logs in the user and returns a token.
  Future<AuthResult> verifyOtp({
    required String identifier,
    required String channel,
    required String code,
    String? name,
    String? city,
  }) async {
    final body = <String, dynamic>{
      'identifier': identifier,
      'channel': channel,
      'code': code,
    };
    if (name != null && name.isNotEmpty) body['name'] = name;
    if (city != null && city.isNotEmpty) body['city'] = city;

    final json = await _client.post('/auth/otp/verify', data: body);
    return AuthResult(
      token: json['token'] as String,
      user: ApiUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Optional password login (backup to OTP).
  Future<AuthResult> login({
    required String phone,
    required String password,
  }) async {
    final json = await _client.post('/auth/login', data: {
      'phone': phone,
      'password': password,
    });
    return AuthResult(
      token: json['token'] as String,
      user: ApiUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Sets/updates the current user's password (requires auth).
  Future<void> setPassword(String password) async {
    await _client.post('/auth/password', data: {'password': password});
  }

  /// Updates the current user's profile (name / city / email). Returns the
  /// refreshed user.
  Future<ApiUser> updateProfile({String? name, String? city, String? email}) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (city != null) body['city'] = city;
    if (email != null) body['email'] = email;
    final json = await _client.patch('/auth/profile', data: body);
    return ApiUser.fromJson(json['user'] as Map<String, dynamic>);
  }

  Future<ApiUser> me() async {
    final json = await _client.get('/auth/me');
    return ApiUser.fromJson(json['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    await _client.post('/auth/logout');
  }
}
