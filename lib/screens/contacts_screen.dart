import 'package:material_ui/material_ui.dart';
import 'package:lottie/lottie.dart';

import '../app_theme.dart';
import '../data/contact_store.dart';
import '../models/contact.dart';
import '../widgets/contact_card.dart';
import '../widgets/contact_form.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key, required this.store});

  final ContactStore store;

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  List<Contact> _contacts = [];
  bool _loading = true;
  bool _saving = false;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadFailed = false;
    });
    try {
      final contacts = await widget.store.load();
      if (mounted) setState(() => _contacts = contacts);
    } catch (error, stackTrace) {
      debugPrint('Saved contacts could not be loaded: $error\n$stackTrace');
      if (mounted) setState(() => _loadFailed = true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save(List<Contact> contacts) async {
    if (_saving) throw StateError('A save is already in progress.');
    setState(() => _saving = true);
    try {
      await widget.store.save(contacts);
      if (mounted) setState(() => _contacts = contacts);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _addContact() => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: AppTheme.navy,
    constraints: const BoxConstraints(maxWidth: 560),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      side: BorderSide(color: Color(0xFF526078)),
    ),
    builder: (context) =>
        ContactForm(onSave: (contact) => _save([..._contacts, contact])),
  );

  Future<void> _deleteContact(Contact contact) async {
    final previousIndex = _contacts.indexWhere((item) => item.id == contact.id);
    try {
      await _save(_contacts.where((item) => item.id != contact.id).toList());
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('${contact.name} deleted'),
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () => _restoreContact(contact, previousIndex),
            ),
          ),
        );
    } catch (error, stackTrace) {
      debugPrint('Contact could not be deleted: $error\n$stackTrace');
      if (mounted) _showError('Could not delete this contact. Try again.');
    }
  }

  Future<void> _restoreContact(Contact contact, int index) async {
    if (_contacts.any((item) => item.id == contact.id)) return;
    final next = [..._contacts];
    next.insert(index.clamp(0, next.length), contact);
    try {
      await _save(next);
    } catch (error, stackTrace) {
      debugPrint('Contact could not be restored: $error\n$stackTrace');
      if (mounted) _showError('Could not restore this contact. Try again.');
    }
  }

  void _showError(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Contacts')),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1040),
          child: _body(),
        ),
      ),
    ),
    floatingActionButton: _loading || _loadFailed
        ? null
        : FloatingActionButton(
            onPressed: _saving ? null : _addContact,
            tooltip: 'Add contact',
            child: const Icon(Icons.add_rounded, size: 30),
          ),
  );

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_loadFailed) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 16),
              const Text(
                'Could not load your contacts.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton(onPressed: _load, child: const Text('Try again')),
            ],
          ),
        ),
      );
    }
    if (_contacts.isEmpty) return _emptyState();
    return LayoutBuilder(
      builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(16) > 22;
        final minWidth = largeText ? 290.0 : 160.0;
        final columns = ((constraints.maxWidth - 24) / minWidth).floor().clamp(
          1,
          4,
        );
        final cardWidth =
            (constraints.maxWidth - 40 - (columns - 1) * 14) / columns;
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 16,
            mainAxisExtent: cardWidth * 0.95 + (largeText ? 160 : 130),
          ),
          itemCount: _contacts.length,
          itemBuilder: (context, index) => ContactCard(
            key: ValueKey(_contacts[index].id),
            contact: _contacts[index],
            onDelete: _saving ? null : () => _deleteContact(_contacts[index]),
          ),
        );
      },
    );
  }

  Widget _emptyState() => LayoutBuilder(
    builder: (context, constraints) {
      return SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 96),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/animations/empty_list.json',
                  width: 270,
                  height: 240,
                  controller: MediaQuery.disableAnimationsOf(context)
                      ? const AlwaysStoppedAnimation(0.5)
                      : null,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 18),
                const Text(
                  'No contacts yet',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
