import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

import '../app_theme.dart';
import '../models/contact.dart';
import 'contact_photo.dart';

class ContactForm extends StatefulWidget {
  const ContactForm({super.key, required this.onSave});

  final Future<void> Function(Contact contact) onSave;

  @override
  State<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  Uint8List? _photo;
  bool _saving = false;
  bool _choosingPhoto = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _choosePhoto() async {
    setState(() {
      _choosingPhoto = true;
      _error = null;
    });
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        requestFullMetadata: false,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (bytes.length > 2 * 1024 * 1024) {
        if (mounted) {
          setState(() => _error = 'Choose a photo smaller than 2 MB.');
        }
        return;
      }
      final decoded = await decodeImageFromList(bytes);
      decoded.dispose();
      if (mounted) setState(() => _photo = bytes);
    } catch (error, stackTrace) {
      debugPrint('Contact photo could not be opened: $error\n$stackTrace');
      if (mounted) {
        setState(() => _error = 'Could not open that photo. Choose another.');
      }
    } finally {
      if (mounted) setState(() => _choosingPhoto = false);
    }
  }

  Future<void> _submit() async {
    if (_saving || _choosingPhoto || !_formKey.currentState!.validate()) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _saving = true;
      _error = null;
    });
    final contact = Contact(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      photo: _photo,
    );
    try {
      await widget.onSave(contact);
      if (mounted) Navigator.of(context).pop();
    } catch (error, stackTrace) {
      debugPrint('Contact could not be saved: $error\n$stackTrace');
      if (mounted) {
        setState(
          () => _error = 'Could not save your contact. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving && !_choosingPhoto,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _header(),
                const SizedBox(height: 16),
                _preview(),
                const SizedBox(height: 24),
                ..._fields(),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppTheme.red),
                    ),
                  ),
                FilledButton(
                  onPressed: _saving || _choosingPhoto ? null : _submit,
                  child: _saving
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save contact'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Widget _header() => Row(
    children: [
      const Expanded(
        child: Text(
          'New contact',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      IconButton(
        tooltip: 'Close',
        onPressed: _saving || _choosingPhoto
            ? null
            : () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close_rounded),
      ),
    ],
  );

  Widget _preview() => Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Semantics(
        button: true,
        label: 'Choose contact photo',
        child: InkWell(
          onTap: _saving || _choosingPhoto ? null : _choosePhoto,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 116,
            height: 132,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.cream),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _photo != null
                ? ContactPhoto(bytes: _photo)
                : Lottie.asset(
                    'assets/animations/image_picker.json',
                    controller: MediaQuery.disableAnimationsOf(context)
                        ? const AlwaysStoppedAnimation(0.5)
                        : null,
                    fit: BoxFit.contain,
                  ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _previewLine(_name, 'Name'),
            const Divider(color: AppTheme.cream, height: 22),
            _previewLine(_email, 'Email'),
            const Divider(color: AppTheme.cream, height: 22),
            _previewLine(_phone, 'Phone'),
          ],
        ),
      ),
    ],
  );

  Widget _previewLine(TextEditingController controller, String placeholder) =>
      ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, child) => Text(
          value.text.trim().isEmpty ? placeholder : value.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      );

  List<Widget> _fields() => [
    TextFormField(
      controller: _name,
      enabled: !_saving,
      decoration: const InputDecoration(labelText: 'Name'),
      keyboardType: TextInputType.name,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.name],
      validator: ContactValidation.name,
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _email,
      enabled: !_saving,
      decoration: const InputDecoration(labelText: 'Email'),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      validator: ContactValidation.email,
    ),
    const SizedBox(height: 14),
    TextFormField(
      controller: _phone,
      enabled: !_saving,
      decoration: const InputDecoration(labelText: 'Phone'),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      autofillHints: const [AutofillHints.telephoneNumber],
      validator: ContactValidation.phone,
      onFieldSubmitted: (_) => _submit(),
    ),
    const SizedBox(height: 22),
  ];
}
