/// A saved delivery address (governorate → city → home address).
class Address {
  final int id;
  final String recipientName;
  final String governorate;
  final String city;
  final String street; // home address / عنوان
  final String phone;
  final String? note;
  final bool isDefault;

  const Address({
    required this.id,
    required this.recipientName,
    required this.governorate,
    required this.city,
    required this.street,
    required this.phone,
    this.note,
    this.isDefault = false,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as int,
        recipientName: (json['recipient_name'] ?? '') as String,
        governorate: (json['governorate'] ?? '') as String? ?? '',
        city: (json['city'] ?? '') as String,
        street: (json['street'] ?? '') as String,
        phone: (json['phone'] ?? '') as String,
        note: json['note'] as String?,
        isDefault: (json['is_default'] ?? false) as bool,
      );

  /// One-line summary for lists (city, governorate).
  String get shortLine => [city, governorate].where((s) => s.isNotEmpty).join(' · ');
}
