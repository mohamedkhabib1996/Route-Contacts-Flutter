import 'dart:typed_data';

import 'package:contact_app/data/contact_store.dart';
import 'package:contact_app/models/contact.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'validation accepts international phones and rejects malformed input',
    () {
      expect(ContactValidation.name(' محمد خالد '), isNull);
      expect(ContactValidation.name('  '), isNotNull);
      expect(ContactValidation.email('mohamed@example.com'), isNull);
      expect(ContactValidation.email('mohamed@'), isNotNull);
      expect(ContactValidation.phone('+20 (100) 123-4567'), isNull);
      expect(ContactValidation.phone('123'), isNotNull);
      expect(ContactValidation.phone('010abc1234567'), isNotNull);
      expect(ContactValidation.phone('++201001234567'), isNotNull);
      expect(ContactValidation.phone('1234567890123456'), isNotNull);
    },
  );

  test(
    'contacts and photo bytes survive storage and deletion persists',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = PreferencesContactStore();
      final photo = Uint8List.fromList([1, 2, 3, 4]);
      await store.save([
        Contact(
          id: 'one',
          name: 'محمد خالد',
          email: 'mohamed@example.com',
          phone: '+201001234567',
          photo: photo,
        ),
      ]);
      final restored = await PreferencesContactStore().load();
      expect(restored.single.name, 'محمد خالد');
      expect(restored.single.phone, '+201001234567');
      expect(restored.single.photo, orderedEquals(photo));
      await store.save([]);
      expect(await PreferencesContactStore().load(), isEmpty);
    },
  );

  test(
    'malformed saved data is reported rather than silently overwritten',
    () async {
      const brokenData = '{not-json';
      SharedPreferences.setMockInitialValues({
        PreferencesContactStore.storageKey: brokenData,
      });
      await expectLater(
        PreferencesContactStore().load(),
        throwsFormatException,
      );
      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString(PreferencesContactStore.storageKey),
        brokenData,
      );
    },
  );
}
