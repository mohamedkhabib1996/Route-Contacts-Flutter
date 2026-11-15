import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/contact.dart';

abstract interface class ContactStore {
  Future<List<Contact>> load();
  Future<void> save(List<Contact> contacts);
}

class PreferencesContactStore implements ContactStore {
  static const storageKey = 'route_contacts_v1';

  @override
  Future<List<Contact>> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(storageKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      throw const FormatException('Invalid contact list.');
    }
    return decoded.map((entry) {
      if (entry is! Map<String, dynamic>) {
        throw const FormatException('Invalid contact entry.');
      }
      return Contact.fromJson(entry);
    }).toList();
  }

  @override
  Future<void> save(List<Contact> contacts) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(
      storageKey,
      jsonEncode(contacts.map((contact) => contact.toJson()).toList()),
    );
    if (!saved) throw StateError('The device could not save contacts.');
  }
}
