import 'package:material_ui/material_ui.dart';

import 'app_theme.dart';
import 'data/contact_store.dart';
import 'screens/contacts_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ContactsApp(store: PreferencesContactStore()));
}

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key, required this.store});

  final ContactStore store;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Contacts',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    home: ContactsScreen(store: store),
  );
}
