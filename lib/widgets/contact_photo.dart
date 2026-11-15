import 'dart:typed_data';

import 'package:material_ui/material_ui.dart';

import '../app_theme.dart';

class ContactPhoto extends StatelessWidget {
  const ContactPhoto({super.key, this.bytes});

  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    if (bytes == null) return _placeholder();
    return Image.memory(
      bytes!,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, error, stackTrace) => _placeholder(),
    );
  }

  Widget _placeholder() => const ColoredBox(
    color: Color(0xFF3C4E67),
    child: Center(
      child: Icon(Icons.person_rounded, size: 76, color: AppTheme.cream),
    ),
  );
}
