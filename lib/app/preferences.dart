import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  final _storage = SharedPreferencesAsync();
  String name = '', phone = '', neighborhood = '';
  bool reduceMotion = false;

  Future<void> load() async {
    try {
      name = await _storage.getString('name') ?? '';
      phone = await _storage.getString('phone') ?? '';
      neighborhood = await _storage.getString('neighborhood') ?? '';
      reduceMotion = await _storage.getBool('reduceMotion') ?? false;
    } catch (error) {
      debugPrint('Unable to load preferences: $error');
    }
  }

  Future<void> saveProfile(String name, String phone) async {
    await _storage.setString('name', name);
    await _storage.setString('phone', phone);
    this.name = name;
    this.phone = phone;
    notifyListeners();
  }

  Future<void> saveNeighborhood(String value) async {
    await _storage.setString('neighborhood', value);
    neighborhood = value;
    notifyListeners();
  }

  Future<void> saveMotion(bool value) async {
    await _storage.setBool('reduceMotion', value);
    reduceMotion = value;
    notifyListeners();
  }
}
