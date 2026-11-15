import 'dart:convert';
import 'dart:typed_data';

class Contact {
  const Contact({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photo,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final Uint8List? photo;

  factory Contact.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    final email = json['email'];
    final phone = json['phone'];
    final photo = json['photo'];
    if (id is! String ||
        id.isEmpty ||
        name is! String ||
        email is! String ||
        phone is! String ||
        (photo != null && photo is! String)) {
      throw const FormatException('Invalid saved contact.');
    }
    return Contact(
      id: id,
      name: name,
      email: email,
      phone: phone,
      photo: photo == null ? null : base64Decode(photo as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    if (photo != null) 'photo': base64Encode(photo!),
  };
}

abstract final class ContactValidation {
  static String? name(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Enter a name.';
    if (input.length > 60) return 'Use 60 characters or fewer.';
    return null;
  }

  static String? email(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Enter an email address.';
    if (input.length > 254 ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(input)) {
      return 'Enter a valid email address.';
    }
    return null;
  }

  static String? phone(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return 'Enter a phone number.';
    final digits = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (!RegExp(r'^\+?[0-9 ()-]+$').hasMatch(input) ||
        digits.length < 7 ||
        digits.length > 15) {
      return 'Use 7–15 digits, with an optional country code.';
    }
    return null;
  }
}
