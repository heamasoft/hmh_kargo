import 'package:flutter/material.dart';

/// Carries the values entered across the multi-step sign-up flow.
class RegistrationProvider extends ChangeNotifier {
  String name = '';
  String cityKey = '';
  String phone = '';

  // Canonical (Arabic) governorate + city chosen at registration, so the first
  // delivery address can be pre-selected from them.
  String governorate = '';
  String city = '';

  String get firstName => name.trim().isEmpty ? '' : name.trim().split(' ').first;

  void setName(String value) {
    name = value;
    notifyListeners();
  }

  void setCity(String value) {
    cityKey = value;
    notifyListeners();
  }

  /// Remembers the canonical governorate + city picked during sign-up.
  void setLocation(String governorate, String city) {
    this.governorate = governorate;
    this.city = city;
    notifyListeners();
  }

  void setPhone(String value) {
    phone = value;
    notifyListeners();
  }
}
