import 'package:contact_app/data/contact_store.dart';
import 'package:contact_app/main.dart';
import 'package:contact_app/models/contact.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

class MemoryContactStore implements ContactStore {
  List<Contact> contacts = [];
  bool failSave = false;
  bool failLoad = false;

  @override
  Future<List<Contact>> load() async {
    if (failLoad) throw StateError('Read failed');
    return [...contacts];
  }

  @override
  Future<void> save(List<Contact> next) async {
    if (failSave) throw StateError('Write failed');
    contacts = [...next];
  }
}

Future<void> mountApp(WidgetTester tester, MemoryContactStore store) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await tester.pumpWidget(ContactsApp(store: store));
  await tester.pumpAndSettle();
}

Future<void> enterContact(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Add contact'));
  await tester.pumpAndSettle();
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'Mohamed Khaled');
  await tester.enterText(fields.at(1), 'mohamed@example.com');
  await tester.enterText(fields.at(2), '+201001234567');
  await tester.ensureVisible(find.text('Save contact'));
}

void main() {
  testWidgets('add, delete, and undo update both screen and saved list', (
    tester,
  ) async {
    final store = MemoryContactStore();
    await mountApp(tester, store);
    expect(find.text('No contacts yet'), findsOneWidget);
    await enterContact(tester);
    await tester.tap(find.text('Save contact'));
    await tester.pumpAndSettle();
    expect(store.contacts.single.name, 'Mohamed Khaled');
    expect(find.text('Mohamed Khaled'), findsOneWidget);
    expect(find.text('New contact'), findsNothing);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(store.contacts, isEmpty);
    expect(find.text('No contacts yet'), findsOneWidget);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(store.contacts.single.name, 'Mohamed Khaled');
    expect(find.text('Mohamed Khaled'), findsOneWidget);
  });

  testWidgets('an empty form cannot create a contact', (tester) async {
    final store = MemoryContactStore();
    await mountApp(tester, store);
    await tester.tap(find.byTooltip('Add contact'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save contact'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a name.'), findsOneWidget);
    expect(find.text('Enter an email address.'), findsOneWidget);
    expect(
      find.text('Use 7–15 digits, with an optional country code.'),
      findsNothing,
    );
    expect(store.contacts, isEmpty);
  });

  testWidgets('failed save keeps entered data and allows retry', (
    tester,
  ) async {
    final store = MemoryContactStore()..failSave = true;
    await mountApp(tester, store);
    await enterContact(tester);
    await tester.tap(find.text('Save contact'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not save your contact. Please try again.'),
      findsOneWidget,
    );
    expect(store.contacts, isEmpty);
    expect(
      find.widgetWithText(TextFormField, 'Mohamed Khaled'),
      findsOneWidget,
    );
    store.failSave = false;
    await tester.ensureVisible(find.text('Save contact'));
    await tester.tap(find.text('Save contact'));
    await tester.pumpAndSettle();
    expect(store.contacts.single.name, 'Mohamed Khaled');
  });

  testWidgets('failed load does not permit replacing unread contacts', (
    tester,
  ) async {
    final store = MemoryContactStore()..failLoad = true;
    await mountApp(tester, store);
    expect(find.text('Could not load your contacts.'), findsOneWidget);
    expect(find.byTooltip('Add contact'), findsNothing);
    store.failLoad = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('No contacts yet'), findsOneWidget);
  });
}
